<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import GUI from "lil-gui";
  import { base } from "$app/paths";
  import shaderVertex from '$lib/shaders/coffee/vertex.glsl';
  import shaderFragment from '$lib/shaders/coffee/fragment.glsl';

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    const parameters = {
      color: new THREE.Color(0x994c33),
      speed: 0.03,
      wireframe: false,
      windStrength: 3.0,
      windSpeed: 0.01,
    }

    const textureLoader = new THREE.TextureLoader();
    const gltfLoader = new GLTFLoader();
    gui = new GUI();

    // Scene
    const scene = new THREE.Scene();

    // Model
    gltfLoader.load(base + "/coffee/bakedModel.glb", (gltf) => {
      (
        (gltf.scene.getObjectByName("baked") as THREE.Mesh)
          .material as THREE.MeshStandardMaterial
      ).map!.anisotropy = 8;
      scene.add(gltf.scene);
    });

    // Smoke
    // Geometry
    const smokeGeometry = new THREE.PlaneGeometry(1, 1, 16, 64);
    smokeGeometry.translate(0, 0.5, 0) // Move the geometry up
    smokeGeometry.scale(1.5, 6, 1.5)
    // Texture
    const perlinTexture = textureLoader.load(base + "/coffee/perlin.png");
    perlinTexture.wrapS = THREE.RepeatWrapping;
    perlinTexture.wrapT = THREE.RepeatWrapping;
    const smokeTexture = new THREE.ShaderMaterial({
      wireframe: parameters.wireframe,
      vertexShader: shaderVertex,
      fragmentShader: shaderFragment,
      side: THREE.DoubleSide,
      transparent: true,
      depthWrite: false, // the smoke occludes itself otherwise
      uniforms: {
        // uPerlin: { value: perlinTexture },
        uPerlin: new THREE.Uniform(perlinTexture),
        uTime: new THREE.Uniform(0),
        uColor: new THREE.Uniform(parameters.color),
        uSpeed: new THREE.Uniform(parameters.speed),
        uWindStrength: new THREE.Uniform(parameters.windStrength),
        uWindSpeed: new THREE.Uniform(parameters.windSpeed),
      }
    });
    const smoke = new THREE.Mesh(smokeGeometry, smokeTexture);
    smoke.position.y = 1.83;
    scene.add(smoke);

    // Debug
    const guiSmoke = gui.addFolder("Smoke");
    guiSmoke.addColor(parameters, "color").onChange(() => {
      smokeTexture.uniforms.uColor.value = parameters.color;
    });
    guiSmoke.add(parameters, "speed", 0, 1).step(.01).onChange(() => {
      smokeTexture.uniforms.uSpeed.value = parameters.speed;
    });
    guiSmoke.add(parameters, "wireframe").onChange(() => {
      smokeTexture.wireframe = parameters.wireframe;
    });
    const guiWind = gui.addFolder("Wind");
    guiWind.add(parameters, "windStrength", 0, 10).step(.01).name("strength").onChange(() => {
      smokeTexture.uniforms.uWindStrength.value = parameters.windStrength;
    });
    guiWind.add(parameters, "windSpeed", 0, 1.0).step(.001).name("speed").onChange(() => {
      smokeTexture.uniforms.uWindSpeed.value = parameters.windSpeed;
    });


    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);

    camera.position.set(3, 4, 6);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.target.y = 2;
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      smokeTexture.uniforms.uTime.value = elapsedTime;
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
      }
    }
  });
</script>

<!-- ================================================= CONTENT -->
<canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
