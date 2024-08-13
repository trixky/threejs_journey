<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { RGBELoader } from "three/addons/loaders/RGBELoader.js";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/addons/loaders/DRACOLoader.js";
  import CustomShaderMaterial from "three-custom-shader-material/vanilla";
  import GUI from "lil-gui";
  import { base } from "$app/paths";
  import wobbleVertexShader from "$lib/shaders/wobbly/wobble/vertex.glsl";
  import wobbleFragmentShader from "$lib/shaders/wobbly/wobble/fragment.glsl";
  import { mergeVertices } from "three/examples/jsm/utils/BufferGeometryUtils.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);
    // Scene
    const scene = new THREE.Scene();

    // Debug
    gui = new GUI({ width: 325 });

    // Loaders
    const rgbeLoader = new RGBELoader();
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath(base + "/draco/");
    const gltfLoader = new GLTFLoader();
    gltfLoader.setDRACOLoader(dracoLoader);

    /**
     * Environment map
     */
    rgbeLoader.load(
      base + "/wobbly/urban_alley_01_1k.hdr",
      (environmentMap) => {
        environmentMap.mapping = THREE.EquirectangularReflectionMapping;

        scene.background = environmentMap;
        scene.environment = environmentMap;
      }
    );

    /**
     * Wobble
     */
    // Uniforms
    const colors = {
      a: "#0000ff",
      b: "#57e389",
    };
    const uniforms = {
      uTime: new THREE.Uniform(0),
      // Material
      uMetalness: new THREE.Uniform(1.0),
      uRoughness: new THREE.Uniform(1.0),
      // Basic
      uPositionFrequency: new THREE.Uniform(0.5),
      uTimeFrequency: new THREE.Uniform(0.4),
      uStrength: new THREE.Uniform(0.3),
      // Warp
      uWarpPositionFrequency: new THREE.Uniform(0.38),
      uWarpTimeFrequency: new THREE.Uniform(0.12),
      uWarpStrength: new THREE.Uniform(1.7),
      // Colors
      uColorA: new THREE.Uniform(new THREE.Color(colors.a)),
      uColorB: new THREE.Uniform(new THREE.Color(colors.b)),
    };

    // Material
    const material = new CustomShaderMaterial({
      // CSM
      baseMaterial: THREE.MeshPhysicalMaterial,
      vertexShader: wobbleVertexShader,
      fragmentShader: wobbleFragmentShader,
      uniforms,
      silent: true, // remove console logs warnings
      // MeshPhysicalMaterial
      color: "#ffffff",
      transmission: 0,
      ior: 1.5,
      thickness: 1.5,
      transparent: true,
      wireframe: false,
    });

    // Fix the shadow (on self and other objects)
    const depthMaterial = new CustomShaderMaterial({
      // CSM
      baseMaterial: THREE.MeshDepthMaterial,
      vertexShader: wobbleVertexShader,
      // fragmentShader: wobbleFragmentShader, // no need for fragment shader (no color)
      uniforms,
      silent: true, // remove console logs warnings
      // MeshDepthMaterial
      depthPacking: THREE.RGBADepthPacking, // NEW increase the quality of the shadow using the alpha channel
    });

    // Tweaks
    // ------------ Material
    const guiMaterial = gui.addFolder("Material");
    guiMaterial.add(uniforms.uMetalness, "value", 0, 1, 0.001).name("Metalness");
    guiMaterial.add(uniforms.uRoughness, "value", 0, 1, 0.001).name("Roughness");
    guiMaterial.add(material, "transmission", 0, 1, 0.001).name("Transmission");
    guiMaterial.add(material, "ior", 0, 10, 0.001).name("IOR");
    guiMaterial.add(material, "thickness", 0, 10, 0.001).name("Thickness");
    guiMaterial.addColor(colors, "a").name("Color A").onChange((value: any) => {
      uniforms.uColorA.value.set(value);
    });
    guiMaterial.addColor(colors, "b").name("Color B").onChange((value: any) => {
      uniforms.uColorB.value.set(value);
    });
    // ------------ Wobble
    const guiWobble = gui.addFolder("Wobble");
    guiWobble
      .add(uniforms.uPositionFrequency, "value", 0, 2, 0.001)
      .name("Position Frequency");
    guiWobble
      .add(uniforms.uTimeFrequency, "value", 0, 2, 0.001)
      .name("Time Frequency");
    guiWobble.add(uniforms.uStrength, "value", 0, 2, 0.001).name("Strength");
    // ------------ Warper
    const guiWarper = gui.addFolder("Warper");
    guiWarper
      .add(uniforms.uWarpPositionFrequency, "value", 0, 2, 0.001)
      .name("Position Frequency");
    guiWarper
      .add(uniforms.uWarpTimeFrequency, "value", 0, 2, 0.001)
      .name("Time Frequency");
    guiWarper
      .add(uniforms.uWarpStrength, "value", 0, 2, 0.001)
      .name("Strength");

    // ------------------------------------- Sphere
    // Geometry
    const geometry = mergeVertices(new THREE.IcosahedronGeometry(2.5, 100));
    // NEW mergeVertices is a helper function to merge vertices indices
    // performance are exponential to the number of vertices but it's useful
    // because this computation is done only once at the beginning
    // IOS can reload the page if it's too long to compute and finally never load the page
    // vertices can be already merged in Blender or other 3D software (ex: smooth in blender)
    geometry.computeTangents();

    // Mesh
    const wobble = new THREE.Mesh(geometry, material);
    wobble.customDepthMaterial = depthMaterial;
    wobble.receiveShadow = true;
    wobble.castShadow = true;
    wobble.position.x = -5;
    scene.add(wobble);

    // ------------------------------------- Suzanne
    gltfLoader.load(base + "/wobbly/suzanne.glb", (gltf) => {
      const suzanne = gltf.scene.children[0] as THREE.Mesh;
      suzanne.receiveShadow = true;
      suzanne.castShadow = true;
      suzanne.material = material;
      suzanne.customDepthMaterial = depthMaterial;
      suzanne.position.x = 5;
      suzanne.rotation.y = Math.PI / 2;
      scene.add(suzanne);
    });

    /**
     * Plane
     */
    const plane = new THREE.Mesh(
      new THREE.PlaneGeometry(20, 20, 20),
      new THREE.MeshStandardMaterial()
    );
    plane.receiveShadow = true;
    plane.rotation.y = Math.PI;
    plane.position.y = -5;
    plane.position.z = 5;
    scene.add(plane);

    /**
     * Lights
     */
    const directionalLight = new THREE.DirectionalLight("#ffffff", 3);
    directionalLight.castShadow = true;
    directionalLight.shadow.mapSize.set(1024, 1024);
    directionalLight.shadow.camera.far = 15;
    directionalLight.shadow.normalBias = 0.05;
    // increase the width and height of the shadow box
    directionalLight.shadow.camera.top = 10;
    directionalLight.shadow.camera.right = 10;
    directionalLight.shadow.camera.bottom = -10;
    directionalLight.shadow.camera.left = -10;
    directionalLight.position.set(0.25, 2, -2.25);
    scene.add(directionalLight);

    // Camera
    const camera = new THREE.PerspectiveCamera(35, RATIO, 0.1, 100);
    camera.position.set(0, 0, -20);
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
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setPixelRatio(pixelRatio);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      uniforms.uTime.value = elapsedTime;
      controls.update(); // NEW
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
