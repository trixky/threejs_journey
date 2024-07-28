<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { base } from "$app/paths";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader.js";
  import { GroundedSkybox } from "three/addons/objects/GroundedSkybox.js";
  import GUI from "lil-gui";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Map
    // LDR cube texture
    // const cubeTextureLoader = new THREE.CubeTextureLoader();
    // const environmentMap = cubeTextureLoader.load([
    //   base + "/environmentMaps/0/px.png",
    //   base + "/environmentMaps/0/nx.png",
    //   base + "/environmentMaps/0/py.png",
    //   base + "/environmentMaps/0/ny.png",
    //   base + "/environmentMaps/0/pz.png",
    //   base + "/environmentMaps/0/nz.png",
    // ]);
    // HDR cube texture (rgbe (e for exponent (brightness)))
    // much better for the brightness
    // usually much heavier than ldr to load and render

    // const rgbLoader = new RGBELoader();
    // const environmentMap = rgbLoader.load(
    //   base + "/environmentMaps/2/2k.hdr",
    //   (texture) => {
    //     const skyBox = new GroundedSkybox(texture, 15, 70, 32);
    //     skyBox.position.y = 15;
    //     scene.add(skyBox);

    //     texture.mapping = THREE.EquirectangularReflectionMapping;
    //   }
    // );

    // const rgbLoader = new RGBELoader();
    // const environmentMap = rgbLoader.load(base + "/environmentMaps/1/2k.hdr", (texture) => {
    //     texture.mapping = THREE.EquirectangularReflectionMapping;
    //     scene.environment = texture;
    //   }
    // );

    const textureLoader = new THREE.TextureLoader();
    const environmentMap = textureLoader.load(
      base +
        "/environmentMaps/blockadesLabsSkybox/interior_views_cozy_wood_cabin_with_cauldron_and_p.jpg",
      (texture) => {
        texture.mapping = THREE.EquirectangularReflectionMapping;
        // scene.environment = texture;
      }
    );

    scene.background = environmentMap;
    // scene.backgroundBlurriness = 0;
    scene.backgroundIntensity = 1;
    // scene.environment = environmentMap;
    // scene.environmentIntensity = 5;

    // Object
    const geometry = new THREE.TorusKnotGeometry(1, 0.4, 100, 16);
    const material = new THREE.MeshStandardMaterial({
      roughness: 0,
      metalness: 1,
      color: 0xaaaaaa,
    });
    const mech = new THREE.Mesh(geometry, material);
    mech.position.y = 4;
    mech.position.x = -4;
    scene.add(mech);

    // Holy donut
    const donutGeometry = new THREE.TorusGeometry(8, 0.5);
    const donutMaterial = new THREE.MeshBasicMaterial({
      color: new THREE.Color(10, 10, 10),
    });
    const donut = new THREE.Mesh(donutGeometry, donutMaterial);
    donut.rotation.x = Math.PI / 2;
    donut.position.y = 3.5;
    donut.layers.enable(1); // only the donut will be rendered in the cubeCamera (and not the torus)
    scene.add(donut);

    // Models import
    const gltfLoader = new GLTFLoader();
    const model = gltfLoader.load(
      base + "/models/FlightHelmet/glTF/FlightHelmet.gltf",
      (gltf) => {
        const root = gltf.scene;
        root.scale.set(10, 10, 10);
        scene.add(root);
      }
    );

    // Cube render target
    const cubeRenderTarget = new THREE.WebGLCubeRenderTarget(
      256, // try to reduce the size for better performance (256 x 6 = 1536)
       {
      type: THREE.HalfFloatType, // Improved performance without losing quality
    });
    scene.environment = cubeRenderTarget.texture;
    // cubeCamera
    const cubeCamera = new THREE.CubeCamera(0.1, 100, cubeRenderTarget);
    cubeCamera.layers.set(1);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 10;
    camera.position.y = 8;
    scene.add(camera);
    camera.lookAt(mech.position);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Debug
    const gui = new GUI();
    gui
      .add(scene, "environmentIntensity")
      .min(0)
      .max(10)
      .step(0.1)
      .name("environmentIntensity");
    gui
      .add(scene, "backgroundIntensity")
      .min(0)
      .max(10)
      .step(0.1)
      .name("backgroundIntensity");
    gui
      .add(scene, "backgroundBlurriness")
      .min(0)
      .max(1)
      .step(0.01)
      .name("backgroundBlurriness");
    gui
      .add(scene.backgroundRotation, "y")
      .min(0)
      .max(Math.PI * 2)
      .step(0.1)
      .name("rotation");

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      donut.rotation.x = elapsedTime;
      cubeCamera.update(renderer, scene);
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
