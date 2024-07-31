<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import generatePatterns from "./patterns";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  interface XY {
    x: number;
    y: number;
  }

  const ORDER_WIDTH = 9;
  const ORDER_WIDTH_START = -ORDER_WIDTH / 2 + 0.5;
  const ORDER_HEIGHT = 6;
  const ORDER_HEIGHT_START = ORDER_HEIGHT / 2 - 0.5;
  function getXYfromOrder(order: number): XY {
    const x = ORDER_WIDTH_START + order % ORDER_WIDTH;
    const y = ORDER_HEIGHT_START - Math.floor(order / ORDER_WIDTH);
    return { x, y };
  }

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Objects
    const patterns = generatePatterns();

    for (const [index, pattern] of patterns.entries()) {
      const { x, y } = getXYfromOrder(index);
      pattern.position.x = x;
      pattern.position.y = y;
    }
    scene.add(...patterns);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 4.7;
    scene.add(camera);
    camera.lookAt(new THREE.Vector3(0, 0, 0));

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
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
