<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import GUI from "lil-gui";
  import gsap from "gsap";

  let canvas: any = null;
  let gui: GUI | null = null; // NEW

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    gui = new GUI({
      // NEW
      width: 300,
      title: "Debug title example",
    });
    // gui.close(); // NEW
    // gui.hide(); // NEW
    // gui.show(); // NEW

    window.addEventListener("keydown", (e) => {
      if (e.key === "h") {
        gui?.show(gui?._hidden); // NEW
      }
    });

    // Scene
    const scene = new THREE.Scene();

    const defaultSubdivision = 3;
    const debugObject = {
      color: 0xff0000,
      spin: () => {},
      subDivision: defaultSubdivision,
    }; // NEW

    // Object
    const geometry = new THREE.BoxGeometry(
      1,
      1,
      1,
      defaultSubdivision,
      defaultSubdivision,
      defaultSubdivision
    );
    const material = new THREE.MeshBasicMaterial({
      color: 0xff0000,
      wireframe: true,
    });
    const mech = new THREE.Mesh(geometry, material);
    scene.add(mech);

    // Axes Helper
    const axesHelper = new THREE.AxesHelper(2);
    scene.add(axesHelper);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);

    camera.position.z = 3;
    scene.add(camera);
    camera.position.z = 3;
    camera.lookAt(mech.position);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    debugObject.spin = () => {
      // NEW
      gsap.to(mech.rotation, { duration: 1, y: mech.rotation.y + Math.PI * 2 });
    };

    // Debug // NEW

    const categ_1 = gui.addFolder("Folder 1"); // NEW
    const categ_2 = gui.addFolder("Folder 2"); // NEW

    // gui.add(mech.position, 'x', -3, 3, 0.01); // NEW
    categ_1.add(mech.position, "y").min(-3).max(3).step(0.01).name("elevation"); // NEW

    categ_1.add(mech, "visible").name("visible"); // NEW
    categ_1.add(material, "wireframe"); // NEW
    categ_1.addColor(debugObject, "color").onChange(() => {
      material.color.set(debugObject.color);
    }); // NEW
    categ_2.add(debugObject, "spin"); // NEW
    categ_2
      .add(debugObject, "subDivision")
      .min(1)
      .max(20)
      .step(1)
      .onFinishChange(() => {
        const newGeometry = new THREE.BoxGeometry(
          1,
          1,
          1,
          debugObject.subDivision,
          debugObject.subDivision,
          debugObject.subDivision
        );
        mech.geometry.dispose(); // NEW dont forget to dispose the old geometry
        mech.geometry = newGeometry;
      }); // NEW

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

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
