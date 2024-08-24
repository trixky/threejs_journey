<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { RGBELoader } from "three/addons/loaders/RGBELoader.js";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/addons/loaders/DRACOLoader.js";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { base } from "$app/paths";
  import CustomShaderMaterial from "three-custom-shader-material/vanilla";
  import GUI from "lil-gui";
  import slicedVertexShader from "$lib/shaders/sliced/vertex.glsl";
  import slicedFragmentShader from "$lib/shaders/sliced/fragment.glsl";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    const pixelRatio = Math.min(2, window.devicePixelRatio);
    // Loaders
    const rgbeLoader = new RGBELoader();
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath(base + "/draco/");
    const gltfLoader = new GLTFLoader();
    gltfLoader.setDRACOLoader(dracoLoader);

    // Debug
    gui = new GUI();

    // Scene
    const scene = new THREE.Scene();

    /**
     * Environment map
     */
    rgbeLoader.load(
      base + "/slice/aerodynamics_workshop.hdr",
      (environmentMap) => {
        environmentMap.mapping = THREE.EquirectangularReflectionMapping;

        scene.background = environmentMap;
        scene.backgroundBlurriness = 0.5;
        scene.environment = environmentMap;
      }
    );

    /**
     * Sliced model
     */

    const uniforms = {
      uSliceStart: new THREE.Uniform(1.75),
      uSliceArc: new THREE.Uniform(1.25),
    };

    gui
      .add(uniforms.uSliceStart, "value", -Math.PI, Math.PI, 0.01)
      .name("Slice Start");
    gui
      .add(uniforms.uSliceArc, "value", 0, Math.PI * 2, 0.01)
      .name("Slice Arc");

    const patchMap = {
      csm_Slice: {
        // float csm_Slice; > in the fragment.glsl for activate it
        "#include <colorspace_fragment>": `
            #include <colorspace_fragment>

            if(!gl_FrontFacing)
                gl_FragColor = vec4(0.75, 0.15, 0.3, 1.0);
        `,
      },
    };

    // Material
    const material = new THREE.MeshStandardMaterial({
      metalness: 0.5,
      roughness: 0.25,
      envMapIntensity: 0.5,
      color: "#858080",
    });
    const slicedMaterial = new CustomShaderMaterial({
      // CSM
      baseMaterial: THREE.MeshStandardMaterial,
      fragmentShader: slicedFragmentShader,
      vertexShader: slicedVertexShader,
      silent: true,
      patchMap,
      // MeshStandardMaterial
      uniforms,
      side: THREE.DoubleSide,
      metalness: 0.5,
      roughness: 0.25,
      envMapIntensity: 0.5,
      color: "#858080",
    });
    const slicedDepthMaterial = new CustomShaderMaterial({
      // CSM
      baseMaterial: THREE.MeshDepthMaterial,
      fragmentShader: slicedFragmentShader,
      vertexShader: slicedVertexShader,
      silent: true,
      patchMap,
      // MeshStandardMaterial
      uniforms,
      depthPacking: THREE.RGBADepthPacking,
    });

    // CustomShaderMaterial

    // Models
    let model: THREE.Group<THREE.Object3DEventMap> | null = null;
    gltfLoader.load(base + "/slice/gears.glb", (gltf) => {
      model = gltf.scene;

      model.traverse((child) => {
        // console.log(child.name);

        // if (child.isMesh) {
        if (child instanceof THREE.Mesh) {
          if (child.name === "outerHull") {
            child.material = slicedMaterial;
            child.customDepthMaterial = slicedDepthMaterial;
          } else child.material = material;

          child.castShadow = true;
          child.receiveShadow = true;
        }
      });

      scene.add(model);
    });

    /**
     * Plane
     */
    const plane = new THREE.Mesh(
      new THREE.PlaneGeometry(10, 10, 10),
      new THREE.MeshStandardMaterial({ color: "#aaaaaa" })
    );
    plane.receiveShadow = true;
    plane.position.x = -4;
    plane.position.y = -3;
    plane.position.z = -4;
    plane.lookAt(new THREE.Vector3(0, 0, 0));
    scene.add(plane);

    /**
     * Lights
     */
    const directionalLight = new THREE.DirectionalLight("#ffffff", 4);
    directionalLight.position.set(6.25, 3, 4);
    directionalLight.castShadow = true;
    directionalLight.shadow.mapSize.set(1024, 1024);
    directionalLight.shadow.camera.near = 0.1;
    directionalLight.shadow.camera.far = 30;
    directionalLight.shadow.normalBias = 0.05;
    directionalLight.shadow.camera.top = 8;
    directionalLight.shadow.camera.right = 8;
    directionalLight.shadow.camera.bottom = -8;
    directionalLight.shadow.camera.left = -8;
    scene.add(directionalLight);

    /**
     * Camera
     */
    // Base camera
    const camera = new THREE.PerspectiveCamera(35, RATIO, 0.1, 100);
    camera.position.set(-5, 5, 12);
    scene.add(camera);

    // Controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    /**
     * Renderer
     */
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

      if (model !== null) model.rotation.y = elapsedTime * 0.1;

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
