<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import vertexShader from "$lib/shaders/raging_sea_shading/vertex.glsl";
  import fragmentShader from "$lib/shaders/raging_sea_shading/fragment.glsl";
  import GUI from "lil-gui";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Plan
    const colors = {
      deepth: "#ff4000",
      surface: "#151c37",
    };
    const uniforms = {
      // ------------------------------- time
      uTime: { value: 0 },
      uSpeed: { value: 1.0 },
      // ------------------------------- waves
      uElevation: { value: 0.2 },
      uFrequencies: { value: new THREE.Vector2(4, 1.5) },
      // ------------------------------- chaos
      uChaosElevation: { value: 0.15 },
      uChaosFrequency: { value: 3 },
      uChaosSpeed: { value: 0.2 },
      uChaosIterations: { value: 4 },
      // ------------------------------- colors
      uColorDeepth: { value: new THREE.Color(colors.deepth) },
      uColorSurface: { value: new THREE.Color(colors.surface) },
      uColorOffset: { value: 0.925 },
      uColorMultiplier: { value: 1.0 },
    };
    const planGeometry = new THREE.PlaneGeometry(2, 2, 1024, 1024);
    planGeometry.deleteAttribute("normal"); // improve performance (gpu memory)
    planGeometry.deleteAttribute("uv"); // improve performance (gpu memory)
    const planeMaterial = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: {
        ...uniforms,
      },
    });
    const plane = new THREE.Mesh(planGeometry, planeMaterial);
    plane.rotation.x = -Math.PI * 0.5;
    scene.add(plane);

    // Debug
    const gui = new GUI();
    const waveGroup = gui.addFolder("Waves");
    const chaosGroup = gui.addFolder("Chaos");
    const colorGroup = gui.addFolder("Colors");
    waveGroup
      .add(uniforms.uElevation, "value")
      .min(0)
      .max(1)
      .step(0.01)
      .name("Elevation");
    waveGroup
      .add(uniforms.uSpeed, "value")
      .min(0)
      .max(10)
      .step(0.01)
      .name("Speed");
    waveGroup
      .add(uniforms.uFrequencies.value, "x")
      .min(0)
      .max(10)
      .step(0.01)
      .name("Frequency X");
    waveGroup
      .add(uniforms.uFrequencies.value, "y")
      .min(0)
      .max(10)
      .step(0.01)
      .name("Frequency Y");

    chaosGroup
      .add(uniforms.uChaosElevation, "value")
      .min(0)
      .max(1)
      .step(0.01)
      .name("Elevation");
    chaosGroup
      .add(uniforms.uChaosFrequency, "value")
      .min(0)
      .max(10)
      .step(0.01)
      .name("Frequency");
    chaosGroup
      .add(uniforms.uChaosSpeed, "value")
      .min(0)
      .max(1)
      .step(0.01)
      .name("Speed");
    chaosGroup
      .add(uniforms.uChaosIterations, "value")
      .min(0)
      .max(10)
      .step(1)
      .name("Iterations");
    colorGroup
      .addColor(colors, "surface")
      .name("Color Surface")
      .onChange(() => {
        uniforms.uColorSurface.value.set(colors.surface);
      });
    colorGroup
      .addColor(colors, "deepth")
      .name("Color Deepth")
      .onChange(() => {
        uniforms.uColorDeepth.value.set(colors.deepth);
      });
    colorGroup
      .add(uniforms.uColorOffset, "value")
      .min(0)
      .max(1)
      .step(0.01)
      .name("Offset");
    colorGroup
      .add(uniforms.uColorMultiplier, "value")
      .min(0)
      .max(10)
      .step(0.01)
      .name("Multiplier");

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(1, 1, 1);
    scene.add(camera);
    camera.lookAt(plane.position);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      uniforms.uTime.value = elapsedTime;
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
