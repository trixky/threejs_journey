<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import shadingVertexShader from "$lib/shaders/halftone/vertex.glsl";
  import shadingFragmentShader from "$lib/shaders/halftone/fragment.glsl";
  import GUI from "lil-gui";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    gui = new GUI();
    const pixelRatio = Math.min(2, window.devicePixelRatio);
    const gltfLoader = new GLTFLoader();

    // Scene
    const scene = new THREE.Scene();

    // Material
    const rendererParameters = {
      clearColor: "#26132f",
    };

    gui.addColor(rendererParameters, "clearColor").onChange(() => {
      renderer.setClearColor(rendererParameters.clearColor);
    });

    const parameters = {
      color: "#ff794d",
      shadowRepetition: 100,
      shadowColor: "#8e19b8",
      lightRepetition: 100,
      lightColor: "#e5ffe00",
    };

    const material = new THREE.ShaderMaterial({
      vertexShader: shadingVertexShader,
      fragmentShader: shadingFragmentShader,
      uniforms: {
        uResolution: new THREE.Uniform(
          new THREE.Vector2(WIDTH * pixelRatio, HEIGHT * pixelRatio)
        ),
        uColor: new THREE.Uniform(new THREE.Color(parameters.color)),
        uShadowRepetition: new THREE.Uniform(parameters.shadowRepetition),
        uShadowColor: new THREE.Uniform(
          new THREE.Color(parameters.shadowColor)
        ),
        uLightRepetition: new THREE.Uniform(parameters.lightRepetition),
        uLightColor: new THREE.Uniform(new THREE.Color(parameters.lightColor)),
      },
    });

    gui.addColor(parameters, "color").onChange(() => {
      material.uniforms.uColor.value.set(parameters.color);
    });
    gui
      .add(parameters, "shadowRepetition")
      .min(10)
      .max(1000)
      .step(1)
      .onChange(() => {
        material.uniforms.uShadowRepetition.value = parameters.shadowRepetition;
      });
    gui.addColor(parameters, "shadowColor").onChange(() => {
      material.uniforms.uShadowColor.value.set(parameters.shadowColor);
    });
    gui
      .add(parameters, "lightRepetition")
      .min(10)
      .max(1000)
      .step(1)
      .onChange(() => {
        material.uniforms.uLightRepetition.value = parameters.lightRepetition;
      });
    gui.addColor(parameters, "lightColor").onChange(() => {
      material.uniforms.uLightColor.value.set(parameters.lightColor);
    });

    // Objects
    // Torus knot
    const torusKnot = new THREE.Mesh(
      new THREE.TorusKnotGeometry(0.6, 0.25, 128, 32),
      material
    );
    torusKnot.position.x = 3;
    scene.add(torusKnot);

    // Sphere
    const sphere = new THREE.Mesh(new THREE.SphereGeometry(), material);
    sphere.position.x = -3;
    scene.add(sphere);

    // Suzanne
    let suzanne: any = null;
    gltfLoader.load(base + "/hologram/suzanne.glb", (gltf) => {
      suzanne = gltf.scene;
      suzanne.traverse((child: THREE.Mesh) => {
        if (child.isMesh) child.material = material;
      });
      scene.add(suzanne);
    });

    // gui.addColor(parameters, "color").onChange(() => {
    //   material.uniforms.uColor.value.set(parameters.color);
    // });

    // Base camera
    const camera = new THREE.PerspectiveCamera(25, RATIO, 0.1, 100);
    camera.position.x = 7;
    camera.position.y = 7;
    camera.position.z = 7;
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setClearColor(rendererParameters.clearColor);
    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      // Rotate objects
      if (suzanne !== null) {
        suzanne.rotation.x = -elapsedTime * 0.1;
        suzanne.rotation.y = elapsedTime * 0.2;
      }

      sphere.rotation.x = -elapsedTime * 0.1;
      sphere.rotation.y = elapsedTime * 0.2;

      torusKnot.rotation.x = -elapsedTime * 0.1;
      torusKnot.rotation.y = elapsedTime * 0.2;

      controls.update();
      renderer.setPixelRatio(pixelRatio);
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
