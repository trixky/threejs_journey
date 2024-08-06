<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import shadingVertexShader from "$lib/shaders/light/vertex.glsl";
  import shadingFragmentShader from "$lib/shaders/light/fragment.glsl";
  import GUI from "lil-gui";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    gui = new GUI();
    const gltfLoader = new GLTFLoader();

    // Scene
    const scene = new THREE.Scene();

    // Material
    const materialParameters = {
      color: "#ffffff",
    };

    const material = new THREE.ShaderMaterial({
      vertexShader: shadingVertexShader,
      fragmentShader: shadingFragmentShader,
      uniforms: {
        uColor: new THREE.Uniform(new THREE.Color(materialParameters.color)),
      },
    });

    // Objects
    // Torus knot
    const torusKnot = new THREE.Mesh(
      new THREE.TorusKnotGeometry(0.6, 0.25, 128, 32),
      material
    );
    torusKnot.position.x = 3;
    scene.add(torusKnot);

    // Sphere
    const sphere = new THREE.Mesh(new THREE.SphereGeometry(), material);
    sphere.position.x = -3;
    scene.add(sphere);

    // Suzanne
    let suzanne: any = null;
    gltfLoader.load(base + "/hologram/suzanne.glb", (gltf) => {
      suzanne = gltf.scene;
      suzanne.traverse((child: THREE.Mesh) => {
        if (child.isMesh) child.material = material;
      });
      scene.add(suzanne);
    });

    gui.addColor(materialParameters, "color").onChange(() => {
      material.uniforms.uColor.value.set(materialParameters.color);
    });

    // Camera
    const camera = new THREE.PerspectiveCamera(25, RATIO, 0.1, 100);
    camera.position.x = 7;
    camera.position.y = 7;
    camera.position.z = 7;
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Light Helpers
    // ------------------ directional light
    const directionalLightHelper = new THREE.Mesh(
      new THREE.PlaneGeometry(),
      new THREE.MeshBasicMaterial()
    );
    directionalLightHelper.material.color.setRGB(0.1, 0.1, 1);
    directionalLightHelper.material.side = THREE.DoubleSide;
    directionalLightHelper.position.set(0, 0, 3);
    scene.add(directionalLightHelper);
    // ------------------ point light 1
    const pointLightHelper1 = new THREE.Mesh(
      new THREE.IcosahedronGeometry(0.1, 2),
      new THREE.MeshBasicMaterial()
    );
    pointLightHelper1.material.color.setRGB(1, 0.1, 0.1);
    pointLightHelper1.position.set(0, 2.5, 0);
    scene.add(pointLightHelper1);
    // ------------------ point light 1
    const pointLightHelper2 = new THREE.Mesh(
      new THREE.IcosahedronGeometry(0.1, 2),
      new THREE.MeshBasicMaterial()
    );
    pointLightHelper2.material.color.setRGB(0.1, 1, 0.5);
    pointLightHelper2.position.set(2, 2, 2);
    scene.add(pointLightHelper2);

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      // Rotate objects
      if (suzanne !== null) {
        suzanne.rotation.x = -elapsedTime * 0.1;
        suzanne.rotation.y = elapsedTime * 0.2;
      }

      sphere.rotation.x = -elapsedTime * 0.1;
      sphere.rotation.y = elapsedTime * 0.2;

      torusKnot.rotation.x = -elapsedTime * 0.1;
      torusKnot.rotation.y = elapsedTime * 0.2;

      controls.update();
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
