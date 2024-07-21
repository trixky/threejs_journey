<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";

  let canvas: any = null;

  let WIDTH = 800;
  let HEIGHT = 600;
  let RATIO = WIDTH / HEIGHT;

  const cursor = { x: 0, y: 0 };

  let handleResize: ((width: number, height: number) => void) | null = null;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Object
    const geometry = new THREE.BoxGeometry(1, 1, 1);
    const material = new THREE.MeshBasicMaterial({ color: 0xff0000 });
    const mech = new THREE.Mesh(geometry, material);
    scene.add(mech);

    // Axes Helper
    const axesHelper = new THREE.AxesHelper(2);
    scene.add(axesHelper);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);

    camera.position.z = 3;
    scene.add(camera);
    camera.position.z = 3;
    camera.lookAt(mech.position);

    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    // renderer.setPixelRatio(Math.min(0.2)); // NEW
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)); // NEW

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      mech.rotation.x = (elapsedTime * Math.PI) / 2;
      controls.update();
      renderer.render(scene, camera);
      window.requestAnimationFrame(tick);
    };

    // Resize // NEW
    // window.addEventListener("resize", () => {  // NEW
    //   camera.aspect = WIDTH / HEIGHT; // NEW
    //   camera.updateProjectionMatrix(); // NEW
    //   renderer.setSize(WIDTH, HEIGHT); // NEW
    // }); // NEW

    handleResize = (width: number, height: number) => {
      WIDTH = width; // NEW
      HEIGHT = height; // NEW
      RATIO = WIDTH / HEIGHT; // NEW
      camera.aspect = RATIO; // NEW
      camera.updateProjectionMatrix(); // NEW
      renderer.setSize(width, height); // NEW
    };

    tick();
  }

  onMount(() => {
    if (browser) {
      start();
    }

    // Full Screen // NEW
    window.addEventListener("dblclick", () => {
      console.log("dblclick");

      // Because some browsers don't support the fullscreen API like Safari, use webkit prefix
      const screenElement =
        document.fullscreenElement || (document as any).webkitFullscreenElement; // NEW

      if (!screenElement) {
        if (canvas.requestFullscreen) canvas.requestFullscreen(); // NEW
        else if ((canvas as any).webkitRequestFullscreen) (canvas as any).webkitRequestFullscreen(); // NEW // for unsupported browsers
      } else {
        if (document.exitFullscreen) document.exitFullscreen(); // NEW
        else if ((document as any).webkitExitFullscreen) (document as any).webkitExitFullscreen(); // NEW // for unsupported browsers
      }
    });
  });
</script>

<!-- ================================================= CONTENT -->
<div class="flex flex-col items-center justify-center">
  <canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>
  <div class="flex justify-center items-center gap-5 p-5">
    <button
      on:click={() => {
        if (handleResize !== null) handleResize(800, 600);
      }}>800 x 600</button
    >
    <button
      on:click={() => {
        if (handleResize !== null) handleResize(600, 400);
      }}>600 x 400</button
    >
    <button
      on:click={() => {
        if (handleResize !== null) handleResize(200, 100);
      }}>200 x 100</button
    >
    <button
      on:click={() => {
        if (handleResize !== null) handleResize(200, 100);
      }}>full screen</button
    >
  </div>
  <p>You can double click on the canvas to enter/leave the full screen mode</p>
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
