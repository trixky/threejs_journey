<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import {base} from '$app/paths';

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();
    
    // Textures
    const textureLoader = new THREE.TextureLoader();
    const starTexture = textureLoader.load(base + "/textures/particles/2.png");

    // Particles // NEW
    // ***** classic cube
    const cube = new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1),
      new THREE.MeshBasicMaterial({
        color: "orange",
      })
    );
    scene.add(cube);

    // ***** sphere
    const sphereParticlesGeometry = new THREE.SphereGeometry(1, 32, 32);
    const sphereParticlesMaterial = new THREE.PointsMaterial({
      color: "blue",
      size: 0.02, // NEW
      sizeAttenuation: true, // NEW (makes particles smaller when far away) // better performances
    });
    const sphereParticles = new THREE.Points(sphereParticlesGeometry, sphereParticlesMaterial);
    scene.add(sphereParticles); // NEW
    // ***** random
    const particlesCount = 10000;
    const randomGeometry = new THREE.BufferGeometry();
    const randomPositions = new Float32Array(particlesCount * 3);
    const randomColors = new Float32Array(particlesCount * 3);
    for (let i = 0; i < particlesCount * 3; i++) {
      randomPositions[i] = (Math.random() - 0.5) * 15; // Don't forget to activate vertexColors
      randomColors[i] = Math.random(); // Don't forget to activate vertexColors
    }
    randomGeometry.setAttribute(
      "position",
      new THREE.BufferAttribute(randomPositions, 3)
    );
    randomGeometry.setAttribute(
      "color", // Don't forget to activate vertexColors
      new THREE.BufferAttribute(randomColors, 3)
    );
    const randomParticlesMaterial = new THREE.PointsMaterial({
      // color: "white", // color is mixed with the vertexColors
      size: 0.1, // NEW
      transparent: true, // NEW
      // map: starTexture, // NEW // transparent doesn't work with map, use alphaMap instead
      alphaMap: starTexture, // NEW
      // alphaTest: 0.001, // NEW // to remove the black border (no render them) (not perfect)
      // depthTest: false, // NEW // generate bugs, not depthTest
      depthWrite: false, // NEW // better performances
      blending: THREE.AdditiveBlending, // NEW // impact perfs / add blending, more brightness on overlapping
      sizeAttenuation: true, // NEW (makes particles smaller when far away) // better performances
      vertexColors: true, // NEW // color is mixed with the vertexColors // needed for color attribute
    });
    const randomParticles = new THREE.Points(randomGeometry, randomParticlesMaterial);
    scene.add(randomParticles);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 3;
    scene.add(camera);
    camera.position.z = 3;

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
    const rotationMultiplier = 0.1;
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      controls.update();
      const rotation = elapsedTime * rotationMultiplier;

      for (let i = 0; i < particlesCount; i++) { // NEW
        const i3 = i * 3; // NEW
        const x = randomGeometry.attributes.position.array[i3]; // NEW
        const z = randomGeometry.attributes.position.array[i3 + 2]; // NEW
        randomGeometry.attributes.position.array[i3 + 1] = (Math.sin(elapsedTime + x) + Math.cos(elapsedTime + z)) / 3 - 1; // NEW
      }
      randomGeometry.attributes.position.needsUpdate = true; // NEW Don't forget to update the geometry

      sphereParticles.rotation.y = rotation;
      cube.rotation.x = rotation;
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
