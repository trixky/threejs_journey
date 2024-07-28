<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/examples/jsm/loaders/DRACOLoader.js";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  // Blender shortcuts
  // t: open the tools panel
  // f9: open the properties panel of the active object
  // x: delete
  // shift + a: add
  // shift + click: select multiple objects
  // shift + click on selected object: deselect
  // shift + h: hide
  // g/r/s: move/rotate/scale (selected)
  // g/r/s + x/y/z: move/rotate/scale on the x/y/z axis
  // ctrl + tab: change the mode (object, edit, vertex, edge, face)
  // tab: change the selection mode (vertex, edge, face)
  // z: change the material view (solid, wireframe, material, rendered)
  // *** solid: default (good perfs)
  // *** wireframe: see the wireframe of the object
  // *** material: see the material of the object
  // *** rendered: see the object with the texture
  // Renderer: EEVEE (good perfs), like threejs (reality limitation: light bounce, reflection etc..)

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Models import
    const modelDracoLoader = new DRACOLoader();
    modelDracoLoader.setDecoderPath(`${base}/draco/`);
    // loaded only if a draco model is used
    const modelLoader = new GLTFLoader();
    modelLoader.setDRACOLoader(modelDracoLoader);
    // ************* Duck
    modelLoader.load(`${base}/models/Burger/burger.glb`, (gltf) => {
      console.log("sucess");
      const childs = gltf.scene
      childs.castShadow = true;
      childs.scale.set(0.2, 0.2, 0.2);
      scene.add(childs);
    });

    // ------------------- plan
    const planMaterial = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      metalness: 0.5,
      roughness: 0.5,
    });
    const plan = new THREE.Mesh(
      new THREE.PlaneGeometry(20, 20, 20, 20),
      planMaterial
    );
    plan.receiveShadow = true;
    plan.rotation.x = -Math.PI / 2;
    scene.add(plan);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);

    camera.position.z = 7;
    camera.position.y = 4;
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.shadowMap.enabled = true;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Lights
    const ambientLight = new THREE.AmbientLight(0x00ffff, 0.5);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 8);
    directionalLight.position.set(10, 5, 5);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    // Animation
    const tick = () => {
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
