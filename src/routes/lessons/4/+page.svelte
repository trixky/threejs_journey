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

    // Group
    const group = new THREE.Group();
    scene.add(group);
    group.position.y = 1; // NEW
    group.scale.y = 1.3 // NEW
    group.rotation.x = - Math.PI / 8; // NEW

    // Group Objects
    const cube1 = new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1),
      new THREE.MeshBasicMaterial({ color: 0x00ff00 })
    );
    group.add(cube1); // NEW

    const cube2 = new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1),
      new THREE.MeshBasicMaterial({ color: 0xffff00 })
    );
    cube2.position.x = -2;
    group.add(cube2); // NEW

    const cube3 = new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1),
      new THREE.MeshBasicMaterial({ color: 0x00ffff })
    );
    cube3.position.x = 2;
    group.add(cube3); // NEW

    // Object
    const geometry = new THREE.BoxGeometry(1, 1, 1);
    const material = new THREE.MeshBasicMaterial({ color: 0xff0000 });
    const mech = new THREE.Mesh(geometry, material);

    mech.position.x = 1; // NEW
    mech.position.y = 1; // NEW
    mech.position.z = 1; // NEW Position is a 3d vector
    mech.position.set(-1, 0, 3); // Position is a 3d vector
    scene.add(mech);
    console.log(mech.position.length()); // NEW Distance from origin
    mech.position.normalize(); // NEW Normalize the vector (length = 1)
    console.log(mech.position.length()); // NEW Distance from origin

    // Scale
    mech.scale.x = 2; // NEW
    mech.scale.y = 0.5; // NEW
    mech.scale.z = 0.5; // NEW
    mech.scale.set(2, 0.5, 0.5); // NEW Scale is a 3d vector

    // Rotation
    mech.rotation.reorder("YXZ"); // NEW
    mech.rotation.y = Math.PI / 4; // NEW

    // Axes Helper
    const axesHelper = new THREE.AxesHelper(2); // NEW
    scene.add(axesHelper); // NEW

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO);
    camera.position.z = 3;
    scene.add(camera);
    camera.lookAt(mech.position); // NEW Look at the object
    // NEW Work with all objects

    console.log(mech.position.distanceTo(camera.position)); // Distance from origin
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
