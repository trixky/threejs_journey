<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import particlesVertexShader from "$lib/shaders/cpa/vertex.glsl";
  import particlesFragmentShader from "$lib/shaders/cpa/fragment.glsl";
  import { base } from "$app/paths";

  const MAP_WIDTH = 200;
  const MAP_HEIGHT = MAP_WIDTH;

  const WIDTH = 800;
  const HEIGHT = WIDTH;
  const RATIO = WIDTH / HEIGHT;

  let map: any = null;
  let canvas: any = null;

  function start() {
    // Texture
    let textureFromMapCanvas = new THREE.CanvasTexture(map);

    // Map
    const mapCtx = map.getContext("2d");
    mapCtx.fillStyle = "black";
    mapCtx.fillRect(0, 0, MAP_WIDTH, MAP_HEIGHT);
    mapCtx.glowImage = new Image();
    mapCtx.glowImage.src = base + "/cpa/glow.png";

    // Scene
    const pixelRatio = Math.min(window.devicePixelRatio, 2);
    const scene = new THREE.Scene();

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(0, 0, 8);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Particles
    const particlesGeometry = new THREE.PlaneGeometry(10, 10, 128, 128);
    particlesGeometry.setIndex(null); // Don't forget to remove index only one particle by vertex, not 3
    particlesGeometry.deleteAttribute("normal"); // Optimization
    const intensityArray = new Float32Array(particlesGeometry.attributes.position.count);
    const angleArray = new Float32Array(particlesGeometry.attributes.position.count);
    for (let i = 0; i < intensityArray.length; i++) {
      intensityArray[i] = Math.random();
      angleArray[i] = Math.random() * Math.PI * 2;
    }
    particlesGeometry.setAttribute(
      "aIntensity",
      new THREE.BufferAttribute(intensityArray, 1)
    );
    particlesGeometry.setAttribute(
      "aAngle",
      new THREE.BufferAttribute(angleArray, 1)
    );

    const particlesMaterial = new THREE.ShaderMaterial({
      vertexShader: particlesVertexShader,
      fragmentShader: particlesFragmentShader,
      uniforms: {
        uResolution: new THREE.Uniform(
          new THREE.Vector2(WIDTH * pixelRatio, HEIGHT * pixelRatio)
        ),
        uPictureTexture: {
          value: new THREE.TextureLoader().load(base + "/cpa/picture-3.png"),
        },
        uDisplacementTexture: {
          value: textureFromMapCanvas,
        },
      },
    });
    const particles = new THREE.Points(particlesGeometry, particlesMaterial);
    scene.add(particles);

    // Interactive Plane
    const interactiveGeometry = new THREE.PlaneGeometry(10, 10, 1, 1);
    const interactiveMaterial = new THREE.MeshBasicMaterial({
      side: THREE.DoubleSide, // enable raycaster to detect both sides
      transparent: true,
      opacity: 0,
    });
    const interactivePlane = new THREE.Mesh(
      interactiveGeometry,
      interactiveMaterial
    );
    scene.add(interactivePlane);

    // Raycaster
    const raycaster = new THREE.Raycaster();
    const screenCursor = new THREE.Vector2(999, 999);
    const canvasCursor = new THREE.Vector2(999, 999);
    const canvasCursorPrevious = new THREE.Vector2(999, 999);

    window.addEventListener("pointermove", (event) => {
      const canvaShifter = canvas.getBoundingClientRect();
      screenCursor.x = ((event.clientX - canvaShifter.left) / WIDTH) * 2 - 1;
      screenCursor.y = -((event.clientY - canvaShifter.top) / HEIGHT) * 2 + 1;
      // console.log(screenCursor);
    });

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setPixelRatio(pixelRatio);
    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      controls.update(); // NEW

      // Raycaster
      raycaster.setFromCamera(screenCursor, camera);
      const intersections = raycaster.intersectObject(interactivePlane);
      if (intersections.length > 0) {
        const intersectionUV = intersections[0].uv as THREE.Vector2;
        canvasCursor.x = intersectionUV.x * MAP_WIDTH;
        canvasCursor.y = (1 - intersectionUV.y) * MAP_HEIGHT;
      }

      // Displacement
      mapCtx.globalCompositeOperation = "source-over";
      mapCtx.globalAlpha = 0.02;
      mapCtx.fillRect(0, 0, MAP_WIDTH, MAP_HEIGHT);

      const canvasCursorDelta = canvasCursor.distanceTo(canvasCursorPrevious);
      canvasCursorPrevious.copy(canvasCursor);
      const alpha = Math.min(1, canvasCursorDelta * 0.1);

      const glowSize = MAP_WIDTH / 4;
      const glowHalfSize = glowSize / 2;
      mapCtx.globalCompositeOperation = "lighten";
      mapCtx.globalAlpha = alpha;
      mapCtx.drawImage(
        mapCtx.glowImage,
        canvasCursor.x - glowHalfSize,
        canvasCursor.y - glowHalfSize,
        glowSize,
        glowSize
      );
      textureFromMapCanvas.needsUpdate = true;

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
  <div class="border border-cyan-400 border-solid absolute top-0 left-0 z-10">
    <canvas bind:this={map} width={MAP_WIDTH} height={MAP_HEIGHT}></canvas>
  </div>
  <canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
  p {
    @apply bg-blue-300;
  }
</style>
