<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import GUI from "lil-gui";
  import Stats from "stats.js";
  import { base } from "$app/paths";
  import { BufferGeometryUtils } from "three/examples/jsm/Addons.js";
  import vertexShader from "$lib/shaders/optimization/vertex.glsl";
  import fragmentShader from "$lib/shaders/optimization/fragment.glsl";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let stats: Stats | null = null;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);

    // fps stats
    stats = new Stats();
    stats.showPanel(0); // 0: fps, 1: ms, 2: mb, 3+: custom
    document.body.appendChild(stats.dom);

    /**
     * Textures
     */
    const textureLoader = new THREE.TextureLoader();
    const displacementTexture = textureLoader.load(
      base + "/optimization/displacementMap.png"
    );

    // Scene
    const scene = new THREE.Scene();

    /**
     * Test meshes
     */
    const cube = new THREE.Mesh(
      new THREE.BoxGeometry(2, 2, 2),
      new THREE.MeshStandardMaterial()
    );
    cube.castShadow = true;
    cube.receiveShadow = false;
    cube.position.set(-5, 0, 0);
    scene.add(cube);

    const torusKnot = new THREE.Mesh(
      new THREE.TorusKnotGeometry(1, 0.4, 128, 32),
      new THREE.MeshStandardMaterial()
    );
    torusKnot.castShadow = true;
    torusKnot.receiveShadow = false;
    scene.add(torusKnot);

    const sphere = new THREE.Mesh(
      new THREE.SphereGeometry(1, 32, 32),
      new THREE.MeshStandardMaterial()
    );
    sphere.position.set(5, 0, 0);
    sphere.castShadow = true;
    sphere.receiveShadow = false;
    scene.add(sphere);

    const floor = new THREE.Mesh(
      new THREE.BoxGeometry(10, 10, 2, 20, 20),
      new THREE.MeshPhysicalMaterial({
        color: "#aaaaaa",
        roughness: 0.1,
        metalness: 0.8,
      })
    );
    floor.position.set(0, -3, 0);
    floor.rotation.x = -Math.PI * 0.5;
    floor.castShadow = true;
    floor.receiveShadow = true;
    scene.add(floor);

    // --------------------------------- multi boxes 1
    const multiBoxesCount = 100000;
    const boxes: THREE.BoxGeometry[] = [];
    const area = 200;
    for (let i = 0; i < multiBoxesCount; i++) {
      const boxesGeometry = new THREE.BoxGeometry(0.5, 0.5, 0.5);

      boxesGeometry.translate(
        (Math.random() - 0.5) * area,
        Math.random() * area - 3,
        (Math.random() - 0.5) * area
      );
      // boxesGeometry.rotateY((Math.random() - 0.5) * Math.PI * 2);
      // boxesGeometry.rotateZ((Math.random() - 0.5) * Math.PI * 2);

      boxes.push(boxesGeometry);
    }

    const mergedBoxesGeometry = BufferGeometryUtils.mergeGeometries(boxes);
    const boxesMaterial = new THREE.MeshNormalMaterial();

    const mergedBoxes = new THREE.Mesh(mergedBoxesGeometry, boxesMaterial);

    scene.add(mergedBoxes);
    // --------------------------------- multi boxes 2
    const multiBoxesCount2 = 100000;
    const area2 = area;

    const boxesGeometry2 = new THREE.BoxGeometry(0.5, 0.5, 0.5);
    const boxesMaterial2 = new THREE.MeshLambertMaterial({
      color: "#ffff00",
    });
    const instancedBoxes = new THREE.InstancedMesh(
      boxesGeometry2,
      boxesMaterial2,
      multiBoxesCount2
    );

    for (let i = 0; i < multiBoxesCount2; i++) {
      const matrix = new THREE.Matrix4();

      const quaternion = new THREE.Quaternion();
      quaternion.setFromEuler(
        new THREE.Euler(
          (Math.random() - 0.5) * Math.PI * 2,
          (Math.random() - 0.5) * Math.PI * 2,
          0
        )
      );
      matrix.makeRotationFromQuaternion(quaternion);

      matrix.setPosition(
        (Math.random() - 0.5) * area2,
        Math.random() * area2 - 3,
        (Math.random() - 0.5) * area2
      );

      instancedBoxes.setMatrixAt(i, matrix);
    }
    scene.add(instancedBoxes);
    // --------------------------------- Shader
    const shaderGeometry = new THREE.PlaneGeometry(30, 30, 256, 256);

    const shaderMaterial = new THREE.ShaderMaterial({
      precision: "lowp",
      defines: {
        uDisplacementStrength: 1.5, // Dont change, because it recomplie shader
      },
      uniforms: {
        uDisplacementTexture: { value: displacementTexture },
        uDisplacementStrength: { value: 1.5 },
        uTime: { value: 0 },
      },
      vertexShader,
      fragmentShader,
    });

    const shaderMesh = new THREE.Mesh(shaderGeometry, shaderMaterial);
    shaderMesh.rotation.x = -Math.PI * 0.5;
    shaderMesh.position.y = -4;
    shaderMesh.receiveShadow = true;
    scene.add(shaderMesh);

    /**
     * Lights
     */
    const directionalLight = new THREE.DirectionalLight("#ffffff", 3);
    directionalLight.castShadow = true;
    directionalLight.shadow.mapSize.set(1024, 1024);
    directionalLight.shadow.camera.far = 15;
    directionalLight.shadow.normalBias = 0.05;
    // increase light shadow square dimension
    const shadowSize = 6;
    directionalLight.shadow.camera.top = shadowSize;
    directionalLight.shadow.camera.right = shadowSize;
    directionalLight.shadow.camera.left = -shadowSize;
    directionalLight.shadow.camera.bottom = -shadowSize;
    directionalLight.position.set(0.25, 3, 2.25);
    scene.add(directionalLight);

    // Base camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(2, 2, 6);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    const renderer = new THREE.WebGLRenderer({
      canvas: canvas,
      powerPreference: "high-performance",
      antialias: true,
    });
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setPixelRatio(pixelRatio);
    renderer.render(scene, camera); // NEW
    renderer.shadowMap.autoUpdate = false; // NEW
    console.log(renderer.info); // NEW

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      stats!.begin();
      const elapsedTime = clock.getElapsedTime();

      torusKnot.rotation.y = elapsedTime * 0.1;
      torusKnot.position.y = Math.cos(elapsedTime) * 0.1 + 0.3;
      sphere.rotation.y = elapsedTime * 0.1;
      sphere.position.y = Math.sin(elapsedTime) * 0.1 + 0.3;

      shaderMaterial.uniforms.uTime.value = elapsedTime;

      controls.update();
      renderer.render(scene, camera);

      stats!.end();

      window.requestAnimationFrame(tick);
    };

    tick();
  }

  onMount(() => {
    if (browser) {
      start();

      return () => {
        stats?.dom.remove();
      };
    }
  });
</script>

<!-- ================================================= CONTENT -->
<canvas bind:this={canvas} width={WIDTH} height={HEIGHT}></canvas>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
