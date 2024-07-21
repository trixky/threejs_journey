<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  const cursor = { x: 0, y: 0 };

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Object
    // const geometry = new THREE.BoxGeometry(1, 1, 1, 4, 4, 4); // NEW (add 4)
    const geometry = new THREE.SphereGeometry(1); // NEW (add 4)

    const material = new THREE.MeshBasicMaterial({
      color: 0xff0000,
      wireframe: true, // NEW
    });
    const mech = new THREE.Mesh(geometry, material);
    scene.add(mech);

    // Geometry: // NEW
    // - Vertices: Points (coordinates) in 3D space (singular: vertex)
    // - Edges: Line segments connecting vertices
    // - Faces: Polygons connecting edges

    // can be used to create a mesh or particle system (each vertex is a particle) // NEW
    // BufferGeometry is the parent class of all geometries

    // Children of BufferGeometry: // NEW
    // - BoxGeometry
    // - PlaneGeometry
    // - CircleGeometry
    // - ConeGeometry
    // - CylinderGeometry
    // - RingGeometry
    // - TorusGeometry
    // - TorusKnotGeometry
    // - DodecahedronGeometry
    // - OctahedronGeometry
    // - TetrahedronGeometry (can control the number of segments)
    // - IcosahedronGeometry
    // - SphereGeometry (can control the number of segments)
    // - ShapeGeometry (heart)
    // - TubeGeometry (can control the number of segments)
    // - ExtrudeGeometry
    // - LatheGeometry
    // - TextGeometry

    const positions = new Float32Array([
      // NEW
      0,
      0,
      0, // NEW
      0,
      1,
      0, // NEW
      1,
      0,
      0, // NEW
    ]);

    const positionAttribute = new THREE.BufferAttribute(positions, 3); // NEW
    // 3 Because each vertex has 3 values (x, y, z)
    // For 2D, use 2 (exemple: uv coordinates)
    // For 1D, use 1 (exemple: time or particle size)

    const manualGeometry = new THREE.BufferGeometry(); // NEW
    manualGeometry.setAttribute("position", positionAttribute); // Position is the shader attribute // NEW

    const manualMaterial = new THREE.MeshBasicMaterial({
      color: 0x00ff00,
      wireframe: true,
    }); // NEW
    const manualMesh = new THREE.Mesh(manualGeometry, manualMaterial); // NEW
    manualMesh.position.x = 1; // NEW
    manualMesh.position.y = 1; // NEW
    scene.add(manualMesh); // NEW

    // Random Geometry // NEW
    const randomGeometry = new THREE.BufferGeometry(); // NEW
    const randomVertices = new Float32Array(300 * 3 * 3).map(() =>
      Math.random()
    ); // NEW
    randomGeometry.setAttribute(
      "position",
      new THREE.BufferAttribute(randomVertices, 3)
    ); // NEW
    const randomMaterial = new THREE.MeshBasicMaterial({
      color: 0x0000ff,
      wireframe: true,
    }); // NEW
    const randomMesh = new THREE.Mesh(randomGeometry, randomMaterial); // NEW
    randomMesh.position.x = -2; // NEW
    randomMesh.position.y = 1; // NEW
    scene.add(randomMesh); // NEW

    // Axes Helper
    const axesHelper = new THREE.AxesHelper(2);
    scene.add(axesHelper);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 3;
    scene.add(camera);
    camera.position.z = 3;
    camera.lookAt(mech.position);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      mech.rotation.y = (elapsedTime * Math.PI) / 8;
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
<div class="relative">
  <div class="border border-solid border-black">
    <canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>
  </div>
  <p class="absolute bottom-0 right-0 py-3 px-5">transparent background</p>
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
