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

  function start() {
    // Scene
    const scene = new THREE.Scene();

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

    // Models import
    const modelDracoLoader = new DRACOLoader();
    modelDracoLoader.setDecoderPath(`${base}/draco/`);
    // loaded only if a draco model is used
    const modelLoader = new GLTFLoader();
    modelLoader.setDRACOLoader(modelDracoLoader);
    // ************* Duck
    modelLoader.load(`${base}/models/Duck/glTF-Draco/Duck.gltf`, (gltf) => {
      console.log("sucess");
      const child = gltf.scene.children[0];
      child.castShadow = true;
      child.position.set(-2, 0, 0);
      scene.add(child);
    });

    // ************* DucFlightHelmetk
    modelLoader.load(
      `${base}/models/FlightHelmet/glTF/FlightHelmet.gltf`,
      // `${base}/models/Duck/glTF/Duck.gltf`,
      (gltf) => {
        console.log("sucess");
        // for (const child of gltf.scene.children) { // Doestn't work well
        //   child.castShadow = true; // Doestn't work well
        //   scene.add(child); // Doesn't work well
        // } // Doesn't work well

        while (gltf.scene.children.length) {
          const child = gltf.scene.children[0];
          child.castShadow = true;
          scene.add(child);
        }
      },
      (progress) => {
        console.log("progress");
        console.error(progress);
      },
      (error) => {
        console.log("error");
        console.error(error);
      }
    );

    let mixer: THREE.AnimationMixer | null = null;
    // ************* Fox
    modelLoader.load(`${base}/models/Fox/glTF/Fox.gltf`, (gltf) => {
      mixer = new THREE.AnimationMixer(gltf.scene);
      const action = mixer.clipAction(gltf.animations[0]);
      action.play();

      console.log("sucess");
      const child = gltf.scene.children[0];
      child.castShadow = true;
      child.position.set(2, 0, 0);
      child.scale.set(0.03, 0.03, 0.03);
      scene.add(child);
    });

    // Clock
    const clock = new THREE.Clock();
    let previousTime = 0;

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      const deltaTime = elapsedTime - previousTime;
      previousTime = elapsedTime;
      controls.update();
      renderer.render(scene, camera);
      if (mixer !== null) {
        mixer.update(deltaTime);
      }
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
