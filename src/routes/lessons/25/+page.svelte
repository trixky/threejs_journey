<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/examples/jsm/loaders/DRACOLoader.js";
  import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader.js";
  import GUI from "lil-gui";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    /**
     * Environment map
     */
    // Intensity
    const gui = new GUI();
    scene.environmentIntensity = 1;
    gui.add(scene, "environmentIntensity").min(0).max(10).step(0.001);

    // HDR (RGBE) equirectangular
    const rgbeLoader = new RGBELoader();
    rgbeLoader.load(base + "/environmentMaps/0/2k.hdr", (environmentMap) => {
      environmentMap.mapping = THREE.EquirectangularReflectionMapping;

      scene.background = environmentMap;
      scene.environment = environmentMap;
    });

    /**
     * Models
     */
    const gltfLoader = new GLTFLoader();
    const modelDracoLoader = new DRACOLoader();
    modelDracoLoader.setDecoderPath(`${base}/draco/`);
    gltfLoader.setDRACOLoader(modelDracoLoader);

    // Burger
    gltfLoader.load(base + "/models/Burger/burger.glb", (gltf) => {
      gltf.scene.position.set(0, 3, 3);
      gltf.scene.scale.set(0.2, 0.2, 0.2);

      gltf.scene.rotation.y = Math.PI;
      gltf.scene.traverse((child) => {
        child.castShadow = true;
        child.receiveShadow = true;
      });
      scene.add(gltf.scene);
    });

    // Helmet
    gltfLoader.load(
      base + "/models/FlightHelmet/glTF/FlightHelmet.gltf",
      (gltf) => {
        gltf.scene.scale.set(10, 10, 10);
        gltf.scene.traverse((child) => {
          child.castShadow = true;
          child.receiveShadow = true;
        });
        scene.add(gltf.scene);
      }
    );
    // NEW gltfLoader already contains the texture format (linear or sRGB)
    // so it's not necessary to change it

    /**
     * Camera
     */
    // Base camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(4, 5, 4);
    scene.add(camera);

    // Controls
    const controls = new OrbitControls(camera, canvas);
    controls.target.y = 3.5;
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true, // default is false // NEW
      // anti-aliasing is ok in terms of performance, is like mipmapping but only for the edges
    });
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);
    // ---------- mip mapping
    // renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    // ---------- pixel ratio
    // super sampling (SSAA) or fullscreen sampling (FSAA)

    // ---------- tonemapping // NEW
    renderer.toneMapping = THREE.ReinhardToneMapping;
    renderer.toneMappingExposure = 3;
    gui.add(renderer, "toneMappingExposure", {
      no: THREE.NoToneMapping,
      linear: THREE.LinearToneMapping,
      "reinhard (default)": THREE.ReinhardToneMapping,
      cineon: THREE.CineonToneMapping,
      "ACES Filmic": THREE.ACESFilmicToneMapping,
    });
    gui.add(renderer, "toneMappingExposure").min(0).max(10).step(0.01);

    // Textures
    const textureLoader = new THREE.TextureLoader();
    // --- floor
    const floorMaterialColor = textureLoader.load(
      base +
        "/textures/wood_cabinet_worn_long/wood_cabinet_worn_long_diff_1k.jpg"
    );
    const floorMaterialARM = textureLoader.load(
      base +
        "/textures/wood_cabinet_worn_long/wood_cabinet_worn_long_arm_1k.jpg"
    );
    const floorMaterialNRM = textureLoader.load(
      base +
        "/textures/wood_cabinet_worn_long/wood_cabinet_worn_long_nor_gl_1k.png"
    );
    // --- wall
    const wallMaterialColor = textureLoader.load(
      base +
        "/textures/castle_brick_broken_06/castle_brick_broken_06_diff_1k.jpg"
    );
    const wallMaterialARM = textureLoader.load(
      base +
        "/textures/castle_brick_broken_06/castle_brick_broken_06_arm_1k.jpg"
    );
    const wallMaterialNRM = textureLoader.load(
      base +
        "/textures/castle_brick_broken_06/castle_brick_broken_06_nor_gl_1k.png"
    );

    // By default, threejs uses linear filtering for textures
    // But for color textures (for humans), we need to change it to sRGB
    floorMaterialColor.colorSpace = THREE.SRGBColorSpace;
    wallMaterialColor.colorSpace = THREE.SRGBColorSpace;

    // Panels
    const panel1 = new THREE.Mesh(
      new THREE.PlaneGeometry(10, 10),
      new THREE.MeshStandardMaterial({
        map: wallMaterialColor,
        aoMap: wallMaterialARM,
        normalMap: wallMaterialNRM,
        roughnessMap: wallMaterialNRM,
        metalnessMap: wallMaterialNRM,
      })
    );
    panel1.position.set(0, 3, -5);
    scene.add(panel1);

    const panel2 = new THREE.Mesh(
      new THREE.PlaneGeometry(10, 10),
      new THREE.MeshStandardMaterial({
        map: floorMaterialColor,
        aoMap: floorMaterialARM,
        normalMap: floorMaterialNRM,
        roughnessMap: floorMaterialNRM,
        metalnessMap: floorMaterialNRM,
      })
    );
    panel2.position.set(0, -2, 0);
    panel2.rotation.x = -Math.PI / 2;
    scene.add(panel2);

    // Light
    const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(3, 7, 6);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    gui
      .add(directionalLight, "intensity")
      .min(0)
      .max(10)
      .step(0.001)
      .name("lightIntensity");
    gui.add(directionalLight, "castShadow").name("castShadow");
    gui
      .add(directionalLight.position, "x")
      .min(-10)
      .max(10)
      .step(0.001)
      .name("lightX");
    gui
      .add(directionalLight.position, "y")
      .min(-10)
      .max(10)
      .step(0.001)
      .name("lightY");
    gui
      .add(directionalLight.position, "z")
      .min(-10)
      .max(10)
      .step(0.001)
      .name("lightZ");
    // Light Bias // NEW
    gui // NEW
      // normalBias for rounded surfaces // shadow acne
      .add(directionalLight.shadow, "normalBias")
      .min(-0.05)
      .max(0.05)
      .step(0.001)
      .name("normalBias");
    gui // NEW
      // bias for flat surfaces // shadow acne
      .add(directionalLight.shadow, "bias")
      .min(-0.05)
      .max(0.05)
      .step(0.001)
      .name("bias");
    directionalLight.target.position.set(0, 4, 0);
    // directionalLight is in the scene but not the target
    // scene.add(directionalLight.target); // NEW solition 1
    directionalLight.target.updateMatrixWorld(); // NEW solition 2
    directionalLight.shadow.camera.far = 15;
    directionalLight.shadow.mapSize.set(256, 256); // Blur
    // directionalLight.shadow.mapSize.set(1024, 1024);
    // directionalLight.shadow.mapSize.set(4096, 4096);

    const directionalLightHelper = new THREE.CameraHelper(
      directionalLight.shadow.camera
    );
    scene.add(directionalLightHelper);

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
<canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
