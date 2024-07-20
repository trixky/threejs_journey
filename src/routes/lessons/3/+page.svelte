<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";

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

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO);
    camera.position.z = 3;
    scene.add(camera);

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);
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
