<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/examples/jsm/loaders/DRACOLoader.js";
  import { base } from "$app/paths";
  import firefliesVertexShader from "$lib/shaders/portal/fireflies/vertex.glsl";
  import firefliesFragmentShader from "$lib/shaders/portal/fireflies/fragment.glsl";
  import portalVertexShader from "$lib/shaders/portal/portal/vertex.glsl";
  import portalFragmentShader from "$lib/shaders/portal/portal/fragment.glsl";
  import GUI from "lil-gui";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);

    // Debug
    gui = new GUI();

    const debugObject = {
      clearColor: "#232232",
      internalColor: "#f66151",
      externalColor: "#f9f06b",
      uSize: 100,
    };

    // Scene
    const scene = new THREE.Scene();

    /**
     * Loaders
     */
    // Texture loader
    const textureLoader = new THREE.TextureLoader();

    // Draco loader
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath(base + "/draco/");

    // GLTF loader
    const gltfLoader = new GLTFLoader();
    gltfLoader.setDRACOLoader(dracoLoader);

    /**
     * Textures
     */
    const bakedTexture = textureLoader.load(
      base + "/blender/49/baked_result_2.jpg"
    );
    bakedTexture.flipY = false;
    bakedTexture.colorSpace = THREE.SRGBColorSpace;

    /**
     * Material
     */
    const bakedMaterial = new THREE.MeshBasicMaterial({ map: bakedTexture });

    // Pole light material
    const poleLightMaterial = new THREE.MeshBasicMaterial({ color: 0x7ad3ff });
    // Portal light material
    const portalLightMaterial = new THREE.ShaderMaterial({
      vertexShader: portalVertexShader,
      fragmentShader: portalFragmentShader,
      uniforms: {
        uTime: new THREE.Uniform(0),
        uInternalColor: { value: new THREE.Color(debugObject.internalColor) },
        uExternalColor: { value: new THREE.Color(debugObject.externalColor) },
      },
      side: THREE.DoubleSide,
    });

    /**
     * Model
     */
    gltfLoader.load(base + "/blender/49/portal_2.glb", (gltf) => {
      gltf.scene.traverse((child) => {
        if (child instanceof THREE.Mesh) {
          if (child.name.startsWith("poleLign"))
            child.material = poleLightMaterial;
          else if (child.name.startsWith("portal"))
            child.material = portalLightMaterial;
          else child.material = bakedMaterial;
        }
      });

      gltf.scene.rotateY(Math.PI / 2);

      scene.add(gltf.scene);
    });

    /**
     * Fireflies
     */
    const firefliesGeometry = new THREE.BufferGeometry();
    const firefliesCount = 30;
    const positionArray = new Float32Array(firefliesCount * 3);
    const scaleArray = new Float32Array(firefliesCount);

    for (let i = 0; i < firefliesCount * 3; i++) {
      const i3 = i * 3;
      scaleArray[i] = Math.random() + 0.5;
      positionArray[i3] = (Math.random() - 0.5) * 4;
      positionArray[i3 + 1] = Math.random() * 2;
      positionArray[i3 + 2] = (Math.random() - 0.5) * 4;
    }

    firefliesGeometry.setAttribute(
      "position", // native attribute name
      new THREE.BufferAttribute(positionArray, 3)
    );

    firefliesGeometry.setAttribute(
      "aScale", // native attribute name
      new THREE.BufferAttribute(scaleArray, 1)
    );

    // const firefliesMaterial = new THREE.PointsMaterial({
    const firefliesMaterial = new THREE.ShaderMaterial({
      vertexShader: firefliesVertexShader,
      fragmentShader: firefliesFragmentShader,
      uniforms: {
        uTime: new THREE.Uniform(0),
        uPixelRatio: new THREE.Uniform(pixelRatio), // update me in the resize too
        uSize: new THREE.Uniform(debugObject.uSize),
      },
      transparent: true,
      depthWrite: false,
    });

    const fireflies = new THREE.Points(firefliesGeometry, firefliesMaterial);
    scene.add(fireflies);

    // Camera
    const camera = new THREE.PerspectiveCamera(45, RATIO, 0.1, 100);
    camera.position.x = 3;
    camera.position.y = 2.5;
    camera.position.z = 4;
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true,
    });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setPixelRatio(pixelRatio);
    renderer.render(scene, camera);

    // Debug
    gui.addColor(debugObject, "clearColor").name("Background color").onChange(() => {
      renderer.setClearColor(debugObject.clearColor);
    });
    gui.addColor(debugObject, "internalColor").name("Portal internal color").onChange(() => {
      portalLightMaterial.uniforms.uInternalColor.value.set(debugObject.internalColor);
    });
    gui.addColor(debugObject, "externalColor").name("Portal external color").onChange(() => {
      portalLightMaterial.uniforms.uExternalColor.value.set(debugObject.externalColor);
    });
    gui.add(debugObject, "uSize").name("Fireflies size").min(1).max(200).step(1).onChange(() => {
      firefliesMaterial.uniforms.uSize.value = debugObject.uSize;
    });

    renderer.setClearColor(debugObject.clearColor);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      firefliesMaterial.uniforms.uTime.value = elapsedTime;
      portalLightMaterial.uniforms.uTime.value = elapsedTime;

      controls.update();
      renderer.render(scene, camera);
      window.requestAnimationFrame(tick);
    };

    tick();
  }

  onMount(() => {
    if (browser) {
      start();

      return () => {
        gui?.destroy();
      };
    }
  });
</script>

<!-- ================================================= CONTENT -->
<canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
