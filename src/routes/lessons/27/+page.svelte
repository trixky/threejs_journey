<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import test1ShaderVertex from "$lib/shaders/test/1/vertex.glsl";
  import test1ShaderFragment from "$lib/shaders/test/1/fragment.glsl";
  import test2ShaderVertex from "$lib/shaders/test/2/vertex.glsl";
  import test2ShaderFragment from "$lib/shaders/test/2/fragment.glsl";
  import test3ShaderVertex from "$lib/shaders/test/3/vertex.glsl";
  import test3ShaderFragment from "$lib/shaders/test/3/fragment.glsl";
  import GUI from 'lil-gui';
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();
    
    // GUI
    const gui = new GUI();

    // Shaders
    // - Vertex shader: position
    // - Fragment shader: color
    // - attributes: different for every vertex
    // - uniforms: same for every vertex (only for fragment shader)
    // - varyings: interpolated between vertices (from vertex to fragment shader)

    // ShaderMateriala: have some code
    // RawShaderMaterial: have nothing
    // ^^ need to write everything: vertex and fragment shader

    const textureLoader = new THREE.TextureLoader();
    const frenchFlagTexture = textureLoader.load(base + "/textures/flags/flag-french.jpg");
    // ********************************************************* 1
    // frenchFlagTexture is 1024x1024 for mipmapping
    const uFrequency = { value: new THREE.Vector2(10, 5) };
    const uTime = { value: 0 };
    const shaderMaterial1 = new THREE.RawShaderMaterial({
      // NEW
      vertexShader: test1ShaderVertex,
      fragmentShader: test1ShaderFragment,
      // transparent: true,
      uniforms: {
        uFrequency,
        uTime,
        uColor: { value: new THREE.Color("orange") },
        uTexture: { value: frenchFlagTexture },
      }
      // wireframe: true,
      // side: THREE.DoubleSide,
    });
    gui.add(uFrequency.value, 'x').min(0).max(20).step(0.01).name('uFrequencyX');
    gui.add(uFrequency.value, 'y').min(0).max(20).step(0.01).name('uFrequencyY');

    // Object
    const geometry1 = new THREE.PlaneGeometry(1, 1, 32, 32);
    const count1 = geometry1.attributes.position.count;
    const randoms1 = new Float32Array(count1).fill(0).map(() => Math.random());
    console.log(randoms1);
    geometry1.setAttribute("aRandom", new THREE.BufferAttribute(randoms1, 1));

    const plan1 = new THREE.Mesh(geometry1, shaderMaterial1);
    plan1.position.set(-1, 0, 0);
    plan1.scale.y = 2 / 3;
    scene.add(plan1);
    // ********************************************************* 2
    const shaderMaterial2 = new THREE.RawShaderMaterial({
      // NEW
      vertexShader: test2ShaderVertex,
      fragmentShader: test2ShaderFragment,
      transparent: true,
      // wireframe: true,
      // side: THREE.DoubleSide,
    });

    // Object
    const geometry2 = new THREE.PlaneGeometry(1, 1, 32, 32);
    const count2 = geometry2.attributes.position.count;
    const randoms2 = new Float32Array(count2).fill(0).map(() => Math.random());
    console.log(randoms2);
    geometry2.setAttribute("aRandom", new THREE.BufferAttribute(randoms2, 1));

    const plan2 = new THREE.Mesh(geometry2, shaderMaterial2);
    scene.add(plan2);
// ********************************************************* 1
    const shaderMaterial3 = new THREE.ShaderMaterial({
      vertexShader: test3ShaderVertex,
      fragmentShader: test3ShaderFragment,
      uniforms: {
        uFrequency,
        uTime,
        uColor: { value: new THREE.Color("orange") },
        uTexture: { value: frenchFlagTexture },
      }
    });

    // Object
    const geometry3 = new THREE.PlaneGeometry(1, 1, 32, 32);
    const plan3 = new THREE.Mesh(geometry3, shaderMaterial3);
    plan3.position.set(1, 0, 0);
    plan3.scale.y = 2 / 3;
    scene.add(plan3);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(0, 0.5,1.5);
    scene.add(camera);
    camera.lookAt(new THREE.Vector3(0, 0, 0));

    // Camera controls
    const controls = new OrbitControls(camera, canvas);

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const speed = { value: 3 };
    gui.add(speed, 'value').min(0).max(30).step(0.01).name('speed');
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      uTime.value = elapsedTime * speed.value;
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
<canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
