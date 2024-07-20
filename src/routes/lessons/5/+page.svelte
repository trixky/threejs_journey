<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import gsap from "gsap";

  let canvas: any;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

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
    const camera = new THREE.PerspectiveCamera(75, RATIO);
    camera.position.z = 3;
    scene.add(camera);

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock(); // NEW

    // Animation

    gsap.to(mech.position, { y: 1, duration: 1, delay: 1, yoyo: true, repeat: -1 });

    // let time = Date.now(); // NEW
    const tick = () => { // NEW
      // const currentTime = Date.now(); // NEW
      // const deltaTime = currentTime - time; // NEW
      // time = currentTime; // NEW
      // mech.rotation.y += 0.001 * deltaTime; // NEW
      const elapsedTime = clock.getElapsedTime(); // NEW don't use getDelta()
      mech.rotation.y = elapsedTime * Math.PI / 2; // NEW
      mech.position.x = Math.sin(elapsedTime); // NEW
      camera.lookAt(mech.position); // NEW
      // mech.rotation.y += 0.01; // NEW
      renderer.render(scene, camera); // NEW
      window.requestAnimationFrame(tick); // NEW
    }; // NEW

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
