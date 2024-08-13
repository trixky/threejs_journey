<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/addons/loaders/DRACOLoader.js";
  import GUI from "lil-gui";
  import particlesVertexShader from "$lib/shaders/gpgpu/vertex.glsl";
  import particlesFragmentShader from "$lib/shaders/gpgpu/fragment.glsl";
  import gpgpuParticlesShader from "$lib/shaders/gpgpu/computation/particles.glsl";
  import { base } from "$app/paths";
  import {
    GPUComputationRenderer,
    type Variable,
  } from "three/addons/misc/GPUComputationRenderer.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  const debugObject = {
    clearColor: "#1d3352",
  };

  let gui: GUI | null = null;

  async function start() {
    gui = new GUI();
    const pixelRatio = Math.min(window.devicePixelRatio, 2);

    // Loaders
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath(base + "/draco/");
    const gltfLoader = new GLTFLoader();
    gltfLoader.setDRACOLoader(dracoLoader);

    // Scene
    const scene = new THREE.Scene();

    // Camera
    const camera = new THREE.PerspectiveCamera(35, RATIO, 0.1, 100);
    camera.position.set(6, 3, 12);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    renderer.setPixelRatio(pixelRatio);
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setClearColor(debugObject.clearColor);
    renderer.render(scene, camera);

    /**
     * Load model
     */
    const gltf = await gltfLoader.loadAsync(base + "/gpgpu/model.glb");

    /**
     * Base geometry
     */
    const model = gltf.scene.children[0] as THREE.InstancedMesh;
    const baseGeometry = {
      instance: model.geometry,
      count: 0,
    };
    baseGeometry.count = baseGeometry.instance.attributes.position.count;

    /**
     * GPU Compute
     */
    // Setup
    const gpgpu = {
      size: Math.ceil(Math.sqrt(baseGeometry.count)),
      computation: null as GPUComputationRenderer | null,
      variable: null as Variable | null,
    };
    gpgpu.computation = new GPUComputationRenderer(
      gpgpu.size,
      gpgpu.size,
      renderer
    );
    // Base particles
    const baseParticlesTexture = gpgpu.computation.createTexture();
    for (let i = 0; i < baseGeometry.count; i++) {
      const i3 = i * 3;
      const i4 = i * 4;
      for (let i = 0; i < 3; i++)
        baseParticlesTexture.image.data[i4 + i] =
          baseGeometry.instance.attributes.position.array[i3 + i];
      baseParticlesTexture.image.data[i4 + 3] = Math.random();
    }
    console.log(baseParticlesTexture.image.data);

    gpgpu.variable = gpgpu.computation.addVariable(
      "uParticles",
      gpgpuParticlesShader,
      baseParticlesTexture
    );
    gpgpu.variable.material.uniforms.uTimes = new THREE.Uniform(0);
    gpgpu.variable.material.uniforms.uDeltaTime = new THREE.Uniform(0);
    gpgpu.variable.material.uniforms.uBase = new THREE.Uniform(
      baseParticlesTexture
    );
    gpgpu.variable.material.uniforms.uFlowFieldInfluence = new THREE.Uniform(
      0.5
    );
    gpgpu.variable.material.uniforms.uFlowFieldStrength = new THREE.Uniform(2);
    gpgpu.variable.material.uniforms.uFlowFieldFrequency = new THREE.Uniform(0.5);

    // Create the ping-pong loop
    gpgpu.computation.setVariableDependencies(gpgpu.variable as Variable, [
      gpgpu.variable as Variable,
    ]);
    // Init
    gpgpu.computation.init();
    // Debug
    const debug = new THREE.Mesh(
      new THREE.PlaneGeometry(84, 84),
      new THREE.MeshBasicMaterial({
        visible: true,
        map: gpgpu.computation.getCurrentRenderTarget(
          gpgpu.variable as Variable
        ).texture,
      })
    );
    debug.rotation.x = -Math.PI * 0.5;
    debug.position.set(0, -21, 0);
    scene.add(debug);
    gui.add(debug.material, "visible").name("Debug");

    /**
     * Particles
     */
    const particles = {
      geometry: null as THREE.BufferGeometry | null,
      material: null as THREE.ShaderMaterial | null,
      points: null as THREE.Points | null,
      positions: [] as Array<THREE.BufferAttribute>,
    };
    // Geometry
    const particlesUvArray = new Float32Array(baseGeometry.count * 2);
    const sizesArray = new Float32Array(baseGeometry.count);
    for (let y = 0; y < gpgpu.size; y++) {
      for (let x = 0; x < gpgpu.size; x++) {
        const i = y * gpgpu.size + x;
        const i2 = i * 2;

        const uvX = (x + 0.5) / gpgpu.size;
        const uvY = (y + 0.5) / gpgpu.size;

        particlesUvArray[i2] = uvX;
        particlesUvArray[i2 + 1] = uvY;

        sizesArray[i] = Math.random();
      }
    }

    particles.geometry = new THREE.BufferGeometry();
    particles.geometry.setDrawRange(0, baseGeometry.count);
    particles.geometry.setAttribute(
      "aParticlesUv",
      new THREE.BufferAttribute(particlesUvArray, 2)
    );
    particles.geometry.setAttribute("aColor", model.geometry.attributes.color);
    particles.geometry.setAttribute(
      "aSize",
      new THREE.BufferAttribute(sizesArray, 1)
    );

    // Material
    particles.material = new THREE.ShaderMaterial({
      vertexShader: particlesVertexShader,
      fragmentShader: particlesFragmentShader,
      uniforms: {
        uSize: new THREE.Uniform(0.07),
        uResolution: new THREE.Uniform(
          new THREE.Vector2(WIDTH * pixelRatio, HEIGHT * pixelRatio)
        ),
        uParticlesTexture: new THREE.Uniform(
          gpgpu.computation.getCurrentRenderTarget(
            gpgpu.variable as Variable
          ).texture
        ),
      },
    });

    // Points
    particles.points = new THREE.Points(
      // baseGeometry.instance,
      particles.geometry,
      particles.material
    );
    scene.add(particles.points);

    /**
     * Tweaks
     */
    gui.addColor(debugObject, "clearColor").onChange(() => {
      renderer.setClearColor(debugObject.clearColor);
    });
    gui
      .add(particles.material.uniforms.uSize, "value")
      .min(0)
      .max(1)
      .step(0.001)
      .name("Particle Size");
    const flowfieldGuiGroup = gui.addFolder("Flow Field");
    flowfieldGuiGroup
      .add(gpgpu.variable.material.uniforms.uFlowFieldInfluence, "value")
      .min(0)
      .max(1)
      .step(0.01)
      .name("Influence");
    flowfieldGuiGroup
      .add(gpgpu.variable.material.uniforms.uFlowFieldStrength, "value")
      .min(0)
      .max(10)
      .step(0.1)
      .name("Strength");
    flowfieldGuiGroup
      .add(gpgpu.variable.material.uniforms.uFlowFieldFrequency, "value")
      .min(0)
      .max(1)
      .step(0.01)
      .name("Frequency");

    // Clock
    const clock = new THREE.Clock();
    let previousTime = 0;

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      const deltaTime = elapsedTime - previousTime;
      previousTime = elapsedTime;

      controls.update();

      // GGPGU Update
      if (gpgpu.computation !== null && gpgpu.variable !== null) {
        gpgpu.variable.material.uniforms.uDeltaTime.value = deltaTime;
        gpgpu.variable.material.uniforms.uTimes.value = elapsedTime;
        gpgpu.computation.compute();
        particles.material!.uniforms.uParticlesTexture.value =
          gpgpu.computation.getCurrentRenderTarget(
            gpgpu.variable as Variable
          ).texture; // After the compute
      }

      renderer.render(scene, camera);
      window.requestAnimationFrame(tick);
    };

    tick();
  }

  onMount(() => {
    if (browser) {
      start();

      return () => {
        gui?.destroy();
      };
    }
  });
</script>

<!-- ================================================= CONTENT -->
<canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
