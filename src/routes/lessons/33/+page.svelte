<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { base } from "$app/paths";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import vertexShader from "$lib/shaders/hologram/holographic/vertex.glsl";
  import fragmentShader from "$lib/shaders/hologram/holographic/fragment.glsl";
  import GUI from 'lil-gui';

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  const parameters = {
    uTime: { value: 0 },
    uColor: { value: new THREE.Color(0x0076e3) },
    uSharpness: { value: 2.0 },
    uStripeNumber: { value: 20 },
    uStripeSpeed: { value: 0.02 },
    uGlitchStrength: { value: 0.25 },
    uGlitchSpeed: { value: 1.0 },
    uGlitchSharpness: { value: 0.3 },
  };

  let gui: GUI | null = null;

  function start() {
    gui = new GUI();

    gui.addColor(parameters.uColor, "value").name("Color");
    gui.add(parameters.uSharpness, "value", 0, 10).step(0.25).name("Sharpness");

    const guiStripes = gui.addFolder("Stripes");
    guiStripes.add(parameters.uStripeNumber, "value", 1, 50).step(1).name("Number");
    guiStripes.add(parameters.uStripeSpeed, "value", 0, 0.1).step(0.01).name("Speed");

    const guiGlich = gui.addFolder("Glitch");
    guiGlich.add(parameters.uGlitchStrength, "value", 0, 1).step(0.1).name("Strength");
    guiGlich.add(parameters.uGlitchSpeed, "value", 0, 10).step(0.1).name("Speed");
    guiGlich.add(parameters.uGlitchSharpness, "value", 0, 1).step(0.1).name("Sharpness");

    // Scene
    const scene = new THREE.Scene();

    const gltfLoader = new GLTFLoader();

    /**
     * Objects
     */
    const material = new THREE.ShaderMaterial({
      side: THREE.DoubleSide,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
      vertexShader,
      fragmentShader,
      uniforms: {
        ...parameters
      },
      transparent: true,
    });

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
      suzanne.traverse((child: any) => {
        if ((child as THREE.Mesh).isMesh)
          (child as THREE.Mesh).material = material;
      });
      scene.add(suzanne);
    });

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(0, 0, 5);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);
    renderer.pixelRatio = Math.min(window.devicePixelRatio, 2);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      parameters.uTime.value = elapsedTime;

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
