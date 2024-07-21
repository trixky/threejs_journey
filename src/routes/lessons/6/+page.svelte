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
    //  Cursor // NEW
    // window.addEventListener("mousemove", (event) => {
    //   if (canvas !== null) {
    //     const canvasShiftX = canvas.getBoundingClientRect().left;
    //     const canvasShiftY = canvas.getBoundingClientRect().top;

    //     cursor.x = (event.clientX - canvasShiftX) / WIDTH - 0.5;
    //     cursor.y = -((event.clientY - canvasShiftY) / HEIGHT) + 0.5;

    //     console.log(cursor.y);
    //   }
    // });

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
    // The Camera class is an abstract class, dont use it directly
    // The ArrayCamera, CubeCamera, OrthographicCamera, and PerspectiveCamera are derived from Camera
    // - The ArrayCamera is used to render a scene from multiple cameras
    // - The StereoCamera is used to render a scene in stereo 3D for VR
    // - The CubeCamera is used to render a scene from six directions, don't use it directly, it's used by Three.js internally
    // - The OrthographicCamera is used to render a scene in parallel projection like old video games like age of empires
    // - The PerspectiveCamera is used to render a scene in perspective projection like modern video games

    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    // NEW 75 is the field of view in degrees
    // NEW RATIO is the aspect ratio
    // NEW 1 is the near clipping plane
    // NEW 1000 is the far clipping plane
    // const camera = new THREE.OrthographicCamera(-1 * RATIO, 1 * RATIO, 1, -1, 1, 10);

    camera.position.z = 3;
    scene.add(camera);
    // camera.position.set(2, 2, 2);
    camera.position.z = 3;
    camera.lookAt(mech.position);

    // Camera controls // NEW
    // - DeviceOrientation Controls (not available in Three.js yet because IOS removed the deviceorientation event)
    // - Fly Controls
    // - First Person Controls: like Fly Controls but can't rotate on x-axis
    // - Pointer Lock Controls: like First Person Controls but can't rotate on x-axis, and the mouse is locked to the canvas and is invisible
    // - Orbit Controls
    // - Trackball Controls: like Orbit Controls but the camera can exceed axis limits
    // - Transform Controls: for moving, rotating, and scaling objects
    // - Drag Controls: for dragging objects

    const controls = new OrbitControls(camera, canvas); // NEW
    controls.enableDamping = true; // NEW need to call controls.update() in the animation loop
    // controls.target.y = 2; // NEW
    // controls.update(); // NEW

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      // camera.position.x = cursor.x * 10;
      // camera.position.y = cursor.y * 10;
      // camera.position.x = Math.sin(cursor.x * Math.PI * 2) * 3; // NEW
      // camera.position.z = Math.cos(cursor.x * Math.PI * 2) * 3; // NEW

      // camera.lookAt(new THREE.Vector3()); // NEW
      mech.rotation.x = (elapsedTime * Math.PI) / 2;
    controls.update(); // NEW
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
