<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { RGBELoader } from "three/addons/loaders/RGBELoader.js";
  import GUI from "lil-gui";
  import { base } from "$app/paths";
  import { Brush, Evaluator, SUBTRACTION } from "three-bvh-csg";
  import CustomShaderMaterial from "three-custom-shader-material/vanilla";
  // import terrainVertexShader from "$lib/shaders/procedural/vertex.glsl";
  // import terrainFragmentShader from "$lib/shaders/procedural/fragment.glsl";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);
    // Debug
    gui = new GUI();

    // Loaders
    const rgbeLoader = new RGBELoader();

    // Scene
    const scene = new THREE.Scene();

    /**
     * Environment map
     */
    rgbeLoader.load(
      base + "/procedural/spruit_sunrise.hdr",
      (environmentMap) => {
        environmentMap.mapping = THREE.EquirectangularReflectionMapping;

        scene.background = environmentMap;
        scene.backgroundBlurriness = 0.5;
        scene.environment = environmentMap;
      }
    );

    /**
     * Board
     */
    // Brushes
    const boardFill = new Brush(new THREE.BoxGeometry(11, 2, 11));
    const boardHole = new Brush(new THREE.BoxGeometry(10, 2.1, 10));
    // boardHole.position.set(0, 0.2, 0);
    // boardHole.updateMatrixWorld(); // Update matrix world to get the correct position

    // (boardFill.material as THREE.MeshPhysicalMaterial).color.set("blue");
    // boardHole.material = new THREE.MeshNormalMaterial();
    // We can use 2 colors because it is a group of meshes

    // Evaluator
    const evaluator = new Evaluator();
    const board = evaluator.evaluate(boardFill, boardHole, SUBTRACTION);
    console.log(board.geometry.groups);
    board.geometry.clearGroups(); // Clear groups to avoid issues with the renderer
    board.material = new THREE.MeshStandardMaterial({
      color: "white",
      metalness: 0.1,
      roughness: 0.3,
    });
    board.receiveShadow = true;
    board.castShadow = true;
    scene.add(board);

    /**
     * Terrain
     */
    // Geometry
    const geometry = new THREE.PlaneGeometry(10, 10, 500, 500);
    geometry.rotateX(-Math.PI / 2);
    // Material
    const material = new CustomShaderMaterial({
      // CSM
      baseMaterial: THREE.MeshStandardMaterial,
      // vertexShader: terrainVertexShader,
      // fragmentShader: terrainFragmentShader,
      silent: true,
      // MeshStandardMaterial
      metalness: 0,
      roughness: 0.5,
      color: "#85d534",
    })
    // Mesh
    const terrain = new THREE.Mesh(geometry, material);
    terrain.receiveShadow = true;
    terrain.castShadow = true;
    scene.add(terrain);


    /**
     * Lights
     */
    const directionalLight = new THREE.DirectionalLight("#ffffff", 2);
    directionalLight.position.set(6.25, 3, 4);
    directionalLight.castShadow = true;
    directionalLight.shadow.mapSize.set(1024, 1024);
    directionalLight.shadow.camera.near = 0.1;
    directionalLight.shadow.camera.far = 30;
    directionalLight.shadow.camera.top = 8;
    directionalLight.shadow.camera.right = 8;
    directionalLight.shadow.camera.bottom = -8;
    directionalLight.shadow.camera.left = -8;
    scene.add(directionalLight);

    // Camera
    const camera = new THREE.PerspectiveCamera(35, RATIO, 0.1, 100);
    camera.position.set(-10, 6, -2);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({
      canvas: canvas,
      antialias: true,
    });
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1;
    renderer.setSize(WIDTH * pixelRatio, HEIGHT * pixelRatio);
    renderer.setPixelRatio(pixelRatio);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      controls.update(); // NEW
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
