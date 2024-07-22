<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  // import typeFaceFont from "three/examples/fonts/helvetiker_regular.typeface.json";
  import { FontLoader } from "three/examples/jsm/Addons.js";
  import { TextGeometry } from "three/examples/jsm/geometries/TextGeometry.js";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);

    camera.position.z = 3;
    scene.add(camera);
    camera.position.z = 3;

    // Font // NEW
    const fontLoader = new FontLoader(); // NEW
    fontLoader.load(
      // NEW
      base + "/fonts/helvetiker_regular.typeface.json",
      (font) => {
        console.log(font);
        const textGeometry = new TextGeometry("Hello Three.js", {
          font,
          size: 0.5,
          depth: 0.2,
          curveSegments: 6, // play with that to improve perf
          bevelEnabled: true,
          bevelThickness: 0.03,
          bevelSize: 0.02,
          bevelOffset: 0,
          bevelSegments: 4, // play with that to improve perf
        });

        const textureLoader = new THREE.TextureLoader();
        const textTexture = textureLoader.load(
          base + "/textures/matcaps/2.png"
        );
        textTexture.colorSpace = THREE.SRGBColorSpace; // NEW don't forget that

        const textMaterial = new THREE.MeshMatcapMaterial({
          matcap: textTexture,
        });

        // textGeometry.computeBoundingBox(); // NEW
        // console.log(textGeometry.boundingBox);
        // textGeometry.translate( // NEW
        //   (-textGeometry.boundingBox!.max.x - 0.02) * 0.5,
        //   (-textGeometry.boundingBox!.max.y - 0.02) * 0.5,
        //   (-textGeometry.boundingBox!.max.z - 0.03) * 0.5
        // );
        textGeometry.center(); // NEW

        const text = new THREE.Mesh(textGeometry, textMaterial);

        scene.add(text);
        camera.lookAt(text.position);
      }
    );

    console.time("donuts");

    // Random Donuts
    const geometry = new THREE.TorusGeometry(0.3, 0.2, 16, 100);
    const material = new THREE.MeshMatcapMaterial({
      matcap: new THREE.TextureLoader().load(base + "/textures/matcaps/8.png"),
    });
    const donuts: Array<THREE.Mesh> = [];
    for (let i = 0; i < 100; i++) {
      // const geometry = new THREE.TorusGeometry(0.3, 0.2, 16, 100);
      // const material = new THREE.MeshMatcapMaterial({
      //   matcap: new THREE.TextureLoader().load(
      //     base + "/textures/matcaps/8.png"
      //   ),
      // });
      const donut = new THREE.Mesh(geometry, material);

      donut.position.x = (Math.random() - 0.5) * 10;
      donut.position.y = (Math.random() - 0.5) * 10;
      donut.position.z = (Math.random() - 0.5) * 10;

      donut.rotation.x = Math.random() * Math.PI;
      donut.rotation.y = Math.random() * Math.PI;

      donut.scale.setScalar(Math.random() * 1 + 0.3);

      donuts.push(donut);
      scene.add(donut);
    }

    console.timeEnd("donuts");

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
      controls.update();
      renderer.render(scene, camera);
      const timeElapsed = clock.getElapsedTime();
      for (const donut of donuts) {
        donut.rotation.x = timeElapsed * donut.position.x;
        donut.rotation.y = timeElapsed * donut.position.y;
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
<div class="border border-solid border-black">
  <canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
