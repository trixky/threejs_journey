<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";

  const CANVAS_WIDTH = 300;
  const CANVAS_HEIGHT = 200;
  const CANVAS_RATIO = CANVAS_WIDTH / CANVAS_HEIGHT;

  let canvas: any;

  function start() {
    let renderer: any;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(
      75,
      CANVAS_RATIO,
      0.1,
      1000
    );
    const geometry = new THREE.BoxGeometry();
    const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
    const cube = new THREE.Mesh(geometry, material);

    scene.add(cube);
    camera.position.z = 5;

    const animate = () => {
      requestAnimationFrame(animate);
      cube.rotation.x += 0.01;
      cube.rotation.y += 0.01;
      renderer.render(scene, camera);
    };

    const resize = () => {
      renderer.setSize(CANVAS_WIDTH, CANVAS_HEIGHT);
      camera.aspect = CANVAS_RATIO;
      camera.updateProjectionMatrix();
    };

    const createScene = (el: any) => {
      renderer = new THREE.WebGLRenderer({ antialias: true, canvas: el });
      resize();
      animate();
    };

    createScene(canvas);
    window.addEventListener("resize", resize);
  }

  onMount(() => {
    if (browser) {
      start();
    }
  });
</script>

<!-- ================================================= CONTENT -->
<canvas bind:this={canvas} width={CANVAS_WIDTH} height={CANVAS_HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
