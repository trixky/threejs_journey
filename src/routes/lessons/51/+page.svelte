<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/examples/jsm/loaders/DRACOLoader.js";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  const cursor = { x: 0, y: 0 };

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);

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
    const portalLightMaterial = new THREE.MeshBasicMaterial({ color: 0xffef5e, side: THREE.DoubleSide });

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

      scene.add(gltf.scene);
    });

    // Camera
    const camera = new THREE.PerspectiveCamera(45, RATIO, 0.1, 100);
    camera.position.x = 4;
    camera.position.y = 2;
    camera.position.z = 4;
    scene.add(camera);

    camera.position.z = 3;
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
