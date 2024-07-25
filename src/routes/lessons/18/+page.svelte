<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import GUI from "lil-gui";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  const parameters = {
    count: 60000,
    size: 0.02,
    radius: 5,
    branches: 3,
    spin: 1,
    randomness: 1,
    randomnessPower: 5,
    insideColor: "#ff6030",
    outsideColor: "#1b3984",
  };

  let scene: THREE.Scene | null = null;

  let galaxyMaterial: THREE.PointsMaterial | null = null;
  let galaxyGeometry: THREE.BufferGeometry | null = null;
  let galaxyPoints: THREE.Points | null = null;

  function generateGalaxy() {
    if (
      galaxyPoints !== null &&
      (galaxyMaterial !== null || galaxyGeometry !== null)
    )
      scene?.remove(galaxyPoints);
    if (galaxyMaterial !== null) galaxyMaterial.dispose();
    if (galaxyGeometry !== null) galaxyGeometry.dispose();

    // ****** Material
    galaxyMaterial = new THREE.PointsMaterial({
      size: parameters.size,
      sizeAttenuation: true,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
      vertexColors: true, // Don't forget to set this to true to enable colors
    });

    // ****** Geometry
    galaxyGeometry = new THREE.BufferGeometry();
    const positions = new Float32Array(parameters.count * 3);
    const colors = new Float32Array(parameters.count * 3);

    const colorInside = new THREE.Color(parameters.insideColor);
    const colorOutside = new THREE.Color(parameters.outsideColor);

    for (let i = 0; i < parameters.count; i++) {
      // Position
      const i3 = i * 3;
      const randomRadius = Math.random() * parameters.radius;
      const spinAngle = randomRadius * parameters.spin;
      const branchAngle =
        ((i % parameters.branches) / parameters.branches) * Math.PI * 2;
      const angle = spinAngle + branchAngle;

      const randomX =
        Math.pow(
          Math.random() * parameters.randomness,
          parameters.randomnessPower
        ) * (Math.random() < 0.5 ? -1 : 1);
      const randomY =
        Math.pow(
          Math.random() * parameters.randomness,
          parameters.randomnessPower
        ) * (Math.random() < 0.5 ? -1 : 1);
      const randomZ =
        Math.pow(
          Math.random() * parameters.randomness,
          parameters.randomnessPower
        ) * (Math.random() < 0.5 ? -1 : 1);

      positions[i3 + 0] = Math.cos(angle) * randomRadius + randomX;
      positions[i3 + 1] = 0 + randomY;
      positions[i3 + 2] = Math.sin(angle) * randomRadius + randomZ;

      // Color
      const mixedColor = colorInside.clone();
      mixedColor.lerp(colorOutside, randomRadius / parameters.radius);

      colors[i3 + 0] = mixedColor.r;
      colors[i3 + 1] = mixedColor.g;
      colors[i3 + 2] = mixedColor.b;
    }

    // ****** Points
    galaxyPoints = new THREE.Points(galaxyGeometry, galaxyMaterial);
    galaxyGeometry.setAttribute(
      "position",
      new THREE.BufferAttribute(positions, 3)
    );
    galaxyGeometry.setAttribute("color", new THREE.BufferAttribute(colors, 3));

    scene?.add(galaxyPoints);
  }

  let gui: GUI | null = null;

  function start() {
    // Scene
    scene = new THREE.Scene();

    // ***************************** Galaxy
    generateGalaxy();

    // Debug
    gui = new GUI();
    gui
      .add(parameters, "count")
      .min(100)
      .max(100000)
      .step(100)
      .name("count")
      .onFinishChange(generateGalaxy);
    gui
      .add(parameters, "size")
      .min(0.001)
      .max(0.1)
      .step(0.001)
      .name("size")
      .onFinishChange(generateGalaxy);
    gui
      .add(parameters, "radius")
      .min(0.3)
      .max(20)
      .step(0.1)
      .name("radius")
      .onFinishChange(generateGalaxy);
    gui
      .add(parameters, "branches")
      .min(2)
      .max(20)
      .step(1)
      .name("branches")
      .onFinishChange(generateGalaxy);
    gui
      .add(parameters, "spin")
      .min(-5)
      .max(5)
      .step(0.1)
      .name("spin")
      .onFinishChange(generateGalaxy);
    gui
      .add(parameters, "randomness")
      .min(0)
      .max(2)
      .step(0.1)
      .name("randomness")
      .onFinishChange(generateGalaxy);
    gui
      .add(parameters, "randomnessPower")
      .min(1)
      .max(10)
      .step(0.1)
      .name("randomnessPower")
      .onFinishChange(generateGalaxy);
    gui
      .addColor(parameters, "insideColor")
      .name("insideColor")
      .onFinishChange(generateGalaxy);
    gui
      .addColor(parameters, "outsideColor")
      .name("outsideColor")
      .onFinishChange(generateGalaxy);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 6;
    camera.position.y = 5;
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      galaxyPoints!.rotation.y = elapsedTime * 0.1;
      controls.update();
      renderer.render(scene!, camera);
      window.requestAnimationFrame(tick);
    };

    tick();
  }

  onMount(() => {
    if (browser) {
      start();
    }
    return () => {
      gui?.destroy(); // NEW
    };
  });
</script>

<!-- ================================================= CONTENT -->
<canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
