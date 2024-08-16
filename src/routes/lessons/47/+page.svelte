<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { base } from "$app/paths";
  import gsap from "gsap";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let progressPercent = 0;
  let progressItem = "";
  let progressFinished = false;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);

    /**
     * Loaders
     */
    const loadingManager = new THREE.LoadingManager(
      () => {
        setTimeout(() => {
          console.log("loaded");
          progressFinished = true;
          gsap.to(overlayMaterial.uniforms.uAlpha, { value: 0, duration: 3 });
        }, 500);
      },
      (itemUrl: string, itemLoaded: number, itemTotal: number) => {
        progressPercent = Math.ceil((itemLoaded / itemTotal) * 100) / 100;
        progressItem = itemUrl.split("/").pop() || "";
        console.log(progressItem, progressPercent);
      },
      () => {
        console.log("error");
      }
    );
    const gltfLoader = new GLTFLoader(loadingManager);
    const cubeTextureLoader = new THREE.CubeTextureLoader(loadingManager);

    // Debug
    const debugObject = {
      envMapIntensity: 2.5,
    };

    // Scene
    const scene = new THREE.Scene();

    /**
     * Overlay
     */
    const overlayGeometry = new THREE.PlaneGeometry(2, 2, 1, 1);
    const overlayMaterial = new THREE.ShaderMaterial({
      // wireframe: true,
      transparent: true,
      uniforms: {
        uAlpha: { value: 1 },
      },
      vertexShader: `
        void main() {
          // gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
          gl_Position = vec4(position, 1.0);
        }
      `,
      fragmentShader: `
        uniform float uAlpha;

        void main() {
          gl_FragColor = vec4(0.0, 0.0, 0.0, uAlpha);
        }
      `,
    });
    const overlay = new THREE.Mesh(overlayGeometry, overlayMaterial);
    scene.add(overlay);

    /**
     * Update all materials
     */
    const updateAllMaterials = () => {
      scene.traverse((child) => {
        if (
          child instanceof THREE.Mesh &&
          child.material instanceof THREE.MeshStandardMaterial
        ) {
          // child.material.envMap = environmentMap
          child.material.envMapIntensity = debugObject.envMapIntensity;
          child.material.needsUpdate = true;
          child.castShadow = true;
          child.receiveShadow = true;
        }
      });
    };

    /**
     * Environment map
     */
    const environmentMap = cubeTextureLoader.load([
      base + "/loading/textures/environmentMaps/0/px.jpg",
      base + "/loading/textures/environmentMaps/0/nx.jpg",
      base + "/loading/textures/environmentMaps/0/py.jpg",
      base + "/loading/textures/environmentMaps/0/ny.jpg",
      base + "/loading/textures/environmentMaps/0/pz.jpg",
      base + "/loading/textures/environmentMaps/0/nz.jpg",
    ]);

    environmentMap.colorSpace = THREE.SRGBColorSpace;

    scene.background = environmentMap;
    scene.environment = environmentMap;

    debugObject.envMapIntensity = 2.5;

    /**
     * Models
     */
    gltfLoader.load(
      base + "/loading/models/FlightHelmet/glTF/FlightHelmet.gltf",
      (gltf) => {
        gltf.scene.scale.set(10, 10, 10);
        gltf.scene.position.set(0, -4, 0);
        gltf.scene.rotation.y = Math.PI * 0.5;
        scene.add(gltf.scene);

        updateAllMaterials();
      }
    );

    /**
     * Lights
     */
    const directionalLight = new THREE.DirectionalLight("#ffffff", 3);
    directionalLight.castShadow = true;
    directionalLight.shadow.camera.far = 15;
    directionalLight.shadow.mapSize.set(1024, 1024);
    directionalLight.shadow.normalBias = 0.05;
    directionalLight.position.set(0.25, 3, -2.25);
    scene.add(directionalLight);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(4, 1, -4);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    renderer.toneMapping = THREE.ReinhardToneMapping;
    renderer.toneMappingExposure = 3;
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setPixelRatio(pixelRatio);
    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      controls.update();
      renderer.render(scene, camera);
      window.requestAnimationFrame(tick);
    };

    tick();
  }

  onMount(() => {
    if (browser) {
      start();
    }
  });
</script>

<!-- ================================================= CONTENT -->
<div class="relative w-fit h-fit overflow-hidden">
  <div
    class:ended={progressFinished}
    class="progress-bar h-[1px] w-full absolute top-1/2 left-0 z-10 bg-white origin-left"
    style={`transform: scaleX(${progressPercent});`}
  ></div>
  <canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
  .progress-bar {
    @apply transition-all duration-500;
  }

  .progress-bar.ended {
    @apply transition-all duration-1000;
    transform: translateX(100%) !important;
  }
</style>
