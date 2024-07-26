<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import GUI from "lil-gui";
  import { base } from "$app/paths";
  import gsap from "gsap";

  let canvas: any;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let sectionContainer: any = null;

  const parameters = {
    materialColor: "#8ff0a4",
  };

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Objects
    const objectDistance = 4;

    const textureLoader = new THREE.TextureLoader();
    const toonTexture = textureLoader.load(base + "/textures/gradients/3.jpg");
    toonTexture.magFilter = THREE.NearestFilter; // Don't forget to set the magFilter to NearestFilter

    const meshMaterial = new THREE.MeshToonMaterial({
      color: parameters.materialColor,
      gradientMap: toonTexture,
    });
    // ------------- mesh1
    const mesh1 = new THREE.Mesh(
      new THREE.TorusGeometry(1, 0.4, 16, 60),
      meshMaterial
    );
    // ------------- mesh2
    const mesh2 = new THREE.Mesh(
      new THREE.ConeGeometry(1, 2, 32),
      meshMaterial
    );
    // ------------- mesh3
    const mesh3 = new THREE.Mesh(
      new THREE.TorusKnotGeometry(0.8, 0.35, 100, 16),
      meshMaterial
    );

    mesh1.position.y = -objectDistance * 0;
    mesh1.position.x = 2;
    mesh2.position.y = -objectDistance * 1;
    mesh2.position.x = -2;
    mesh3.position.y = -objectDistance * 2;
    mesh3.position.x = 2;

    const sectionMeshes = [mesh1, mesh2, mesh3];
    scene.add(...sectionMeshes);

    // Particles
    const particleCount = 300;
    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 30;
      positions[i * 3 + 1] = objectDistance * 2 - Math.random() * 30;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 30;
    }
    const particlesGeometry = new THREE.BufferGeometry();
    particlesGeometry.setAttribute(
      "position",
      new THREE.BufferAttribute(positions, 3)
    );
    const particlesMaterial = new THREE.PointsMaterial({
      size: 0.05,
      sizeAttenuation: true,
      color: parameters.materialColor,
    });
    const particles = new THREE.Points(particlesGeometry, particlesMaterial);
    scene.add(particles);

    // Lights
    const directionalLight = new THREE.DirectionalLight(0xffffff, 3);
    directionalLight.position.set(1, 1, 0);
    scene.add(directionalLight);

    // Camera
    const cameraGroup = new THREE.Group();
    scene.add(cameraGroup);
    const camera = new THREE.PerspectiveCamera(75, RATIO);
    camera.position.z = 4;
    cameraGroup.add(camera);

    // Debug
    const gui = new GUI({ width: 300 });

    gui.addColor(parameters, "materialColor").onChange(() => {
      meshMaterial.color.set(parameters.materialColor);
      particlesMaterial.color.set(parameters.materialColor);
    });

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock(); // NEW

    // Cursor
    const cursor = {
      x: 0,
      y: 0,
    };

    window.addEventListener("mousemove", (event) => {
      cursor.x = event.clientX / window.innerWidth - 0.5;
      cursor.y = -(event.clientY / window.innerHeight - 0.5);
    });

    let currentSection = 0;

    // Animation
    const parallaxSmoothness = 2;
    let previousTime = 0;
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      const parallaxX = cursor.x;
      const parallaxY = cursor.y;

      const deltaTime = elapsedTime - previousTime;
      previousTime = elapsedTime;

      cameraGroup.position.x +=
        (parallaxX - cameraGroup.position.x) * parallaxSmoothness * deltaTime;
      cameraGroup.position.y +=
        (parallaxY - cameraGroup.position.y) * parallaxSmoothness * deltaTime;

      // camera.position.x = parallaxX;
      camera.position.y =
        (sectionContainer.scrollTop / HEIGHT) * -objectDistance; // - parallaxY;

      const newSection = Math.round(-camera.position.y / objectDistance);
      if (newSection !== currentSection) {
        currentSection = newSection;
        console.log("ouiiiii")
        gsap.to(sectionMeshes[newSection].rotation, {
          y: '+=6',
          x: '+=3',
          duration: 1,
          ease: "power2.inOut",
        });
      }

      for (const sectionMesh of sectionMeshes) {
        sectionMesh.rotation.y += deltaTime / 6;
        sectionMesh.rotation.x += deltaTime / 5;
      }

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
<div
  class="relative border border-solid border-black bg-neutral-800"
  style="width: {WIDTH}px; height: {HEIGHT}px;"
>
  <canvas class=" z-10" bind:this={canvas} width={WIDTH} height={HEIGHT}
  ></canvas>
  <!-- ---------------- sections -->
  <div
    bind:this={sectionContainer}
    class="h-full w-full overflow-y-scroll absolute top-0 left-0"
  >
    <section>
      <h2>Section 1</h2>
    </section>
    <section class="right">
      <h2>Section 2</h2>
    </section>
    <section>
      <h2>Section 3</h2>
    </section>
  </div>
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
  section {
    @apply relative h-full w-full flex items-center justify-start z-30;
  }

  section.right {
    @apply justify-end;
  }

  section > h2 {
    @apply text-white font-bold mx-16;
    font-size: 60px;
  }
</style>
