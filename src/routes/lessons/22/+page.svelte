<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { base } from "$app/paths";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Object
    const geometry = new THREE.SphereGeometry(1, 32, 32);

    const distance = 3;
    const mesh1 = new THREE.Mesh(
      geometry,
      new THREE.MeshBasicMaterial({ color: 0xff0000 })
    );
    mesh1.position.x = -distance;
    const mesh2 = new THREE.Mesh(
      geometry,
      new THREE.MeshBasicMaterial({ color: 0xff0000 })
    );
    const mesh3 = new THREE.Mesh(
      geometry,
      new THREE.MeshBasicMaterial({ color: 0xff0000 })
    );
    mesh3.position.x = distance;
    mesh1.updateMatrixWorld(); // do this before raycasting
    mesh2.updateMatrixWorld(); // do this before raycasting
    mesh3.updateMatrixWorld(); // do this before raycasting
    scene.add(mesh1, mesh2, mesh3);

    // Raycaster // NEW
    // on model/group, raycaster test all mesh in the group
    // it is possible to deactivate this with the recursive option
    const raycaster = new THREE.Raycaster(); // NEW
    const mouseRaycaster = new THREE.Raycaster(); // NEW

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 6;
    camera.position.y = 2;
    scene.add(camera);
    camera.lookAt(new THREE.Vector3(0, 0, 0));

    // Mouse
    const mouse = new THREE.Vector2(); // NEW
    window.addEventListener("mousemove", (event) => {
      // NEW
      // get the x of canvas
      const rect = canvas.getBoundingClientRect(); // NEW
      const rectX = event.clientX - rect.left; // NEW
      const rectY = event.clientY - rect.top; // NEW
      mouse.x = (rectX / WIDTH) * 2 - 1; // NEW
      mouse.y = (-rectY / HEIGHT) * 2 + 1; // NEW

      // it's possible to have more mouse event than the tick event
      // so we need to update the raycaster in the tick event
    }); // NEW

    // Camera controls // NEW
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Model
    let model: THREE.Object3D | null = null;
    const modelLoader = new GLTFLoader();
    modelLoader.load(
      base + "/models/Duck/glTF-Binary/Duck.glb",
      (gltf) => {
        model = gltf.scene;
        model.position.z = 2;
        model.position.x = 1;
        scene.add(model);
      },
      undefined,
      (error) => {
        console.error(error);
      }
    );

    // Light
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);
    const light = new THREE.DirectionalLight(0xffffff, 2);
    light.position.set(0, 0, 5);
    scene.add(light);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      const multiplier = 2;
      mesh1.position.y = Math.sin(elapsedTime * 0.6) * multiplier;
      mesh2.position.y = Math.sin(elapsedTime + 2 * 0.9) * multiplier;
      mesh3.position.y = Math.sin(elapsedTime + 4 * 1.3) * multiplier;

      // ------------------- raycasting -------------------
      for (const mesh of [mesh1, mesh2, mesh3]) {
        (mesh.material as THREE.MeshBasicMaterial).color.set(0xff0000);
      }
      // ---------- fixed line
      const rayOrigin = new THREE.Vector3(distance * -2, 0, 0); // NEW
      const rayDirection = new THREE.Vector3(10, 0, 0);
      // console.log(rayDirection.length());
      rayDirection.normalize(); // IMPORTANT for direction vectors: normalize them first before using them
      // console.log(rayDirection.length()); // Check the logs

      raycaster.set(rayOrigin, rayDirection); // NEW

      scene.add(
        new THREE.ArrowHelper(
          raycaster.ray.direction,
          raycaster.ray.origin,
          20,
          0x00ff00
        )
      );

      //   const intersect = raycaster.intersectObject(mesh1); // NEW
      // console.log(intersect); // NEW

      const intersects = raycaster.intersectObjects([mesh1, mesh2, mesh3]); // NEW

      for (const intersect of intersects) {
        (
          (intersect.object as THREE.Mesh).material as THREE.MeshBasicMaterial
        ).color.set(0x00ff00);
      }
      // ---------- mouse
      mouseRaycaster.setFromCamera(mouse, camera); // NEW
      const intersectsMouse = mouseRaycaster.intersectObjects([
        mesh1,
        mesh2,
        mesh3,
      ]); // NEW
      for (const intersect of intersectsMouse) {
        (
          (intersect.object as THREE.Mesh).material as THREE.MeshBasicMaterial
        ).color.set(0x0000ff);
      }
      // ----------- mouse duck
      if (model) {
        model.rotation.y = elapsedTime * 0.1;

        // duckRaycasterHelper.setDirection(new THREE.Vector3(1,2,3)); // NEW
        // duckRaycasterHelper.updateMatrixWorld(); // NEW
        // duckRaycasterHelper.setRotationFromEuler(model.rotation); // NEW
        // raycast helper

        model.scale.set(1, 1, 1);
        const intersectsModel = mouseRaycaster.intersectObject(model, true);
        if (intersectsModel.length) model.scale.set(1.1, 1.1, 1.1);
      }

      controls.update(); // NEW
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
