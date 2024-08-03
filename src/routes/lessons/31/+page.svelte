<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/examples/jsm/loaders/DRACOLoader.js";
  import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader.js";
  import GUI from "lil-gui";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  const customUniforms = {
    uTime: { value: 0 },
  };

  function start() {
    // Scene
    const scene = new THREE.Scene();

    const plane = new THREE.Mesh(
      new THREE.PlaneGeometry(20, 20),
      new THREE.MeshStandardMaterial({
        color: new THREE.Color("red"),
      })
    );
    plane.rotation.x = -Math.PI * 0.5;
    plane.position.y = 0;
    plane.receiveShadow = true;
    scene.add(plane);

    /**
     * Environment map
     */
    // Intensity
    const gui = new GUI();
    scene.environmentIntensity = 1;
    gui.add(scene, "environmentIntensity").min(0).max(10).step(0.001);

    const cubeTextureLoader = new THREE.CubeTextureLoader();
    const environmentMap = cubeTextureLoader.load([
      base + "/textures/modified_material/px.jpg",
      base + "/textures/modified_material/nx.jpg",
      base + "/textures/modified_material/py.jpg",
      base + "/textures/modified_material/ny.jpg",
      base + "/textures/modified_material/pz.jpg",
      base + "/textures/modified_material/nz.jpg",
    ]);

    scene.background = environmentMap;
    scene.environment = environmentMap;

    /**
     * Models
     */
    const gltfLoader = new GLTFLoader();
    // Textures
    const textureLoader = new THREE.TextureLoader();
    const mapTexture = textureLoader.load(
      base + "/models/LeePerrySmith/color.jpg"
    );
    mapTexture.colorSpace = THREE.SRGBColorSpace;
    const normalTexture = textureLoader.load(
      base + "/models/LeePerrySmith/normal.jpg"
    );

    // Material
    const material = new THREE.MeshStandardMaterial({
      map: mapTexture,
      normalMap: normalTexture,
    });

    const depthMaterial = new THREE.MeshDepthMaterial({
      depthPacking: THREE.RGBADepthPacking, // NEW tips to have a better depth qualities
    });

    const rotationStrength = 0.3;
    material.onBeforeCompile = (shader) => {
      console.log("ouiiii");
      shader.uniforms.uTime = customUniforms.uTime;
      shader.vertexShader = shader.vertexShader.replace(
        "#include <common>",
        `
          #include <common>
          uniform float uTime;

          mat2 get2dRotateMatrix(float _angle)
          {
              return mat2(cos(_angle), - sin(_angle), sin(_angle), cos(_angle));
          }
        `
      );
      shader.vertexShader = shader.vertexShader.replace(
        "#include <beginnormal_vertex>",
        `
          #include <beginnormal_vertex>

                    float angle = sin(position.y + uTime) * ${rotationStrength};

          mat2 rotateMatrix = get2dRotateMatrix(angle);

          objectNormal.xz = rotateMatrix * objectNormal.xz;
        `
      );
      shader.vertexShader = shader.vertexShader.replace(
        "#include <begin_vertex>",
        `
          #include <begin_vertex>
          // float angle = sin(position.y + uTime) * ${rotationStrength};

          // mat2 rotateMatrix = get2dRotateMatrix(angle);

          transformed.xz = rotateMatrix * transformed.xz;
        `
      );
    };

    depthMaterial.onBeforeCompile = (shader) => {
      console.log("ouiiii");
      shader.uniforms.uTime = customUniforms.uTime;
      shader.vertexShader = shader.vertexShader.replace(
        "#include <common>",
        `
          #include <common>
          uniform float uTime;

          mat2 get2dRotateMatrix(float _angle)
          {
              return mat2(cos(_angle), - sin(_angle), sin(_angle), cos(_angle));
          }
        `
      );
      shader.vertexShader = shader.vertexShader.replace(
        "#include <begin_vertex>",
        `
          #include <begin_vertex>
          float angle = sin(position.y + uTime) * ${rotationStrength};

          mat2 rotateMatrix = get2dRotateMatrix(angle);

          transformed.xz = rotateMatrix * transformed.xz;
        `
      );
    };

    /**
     * Update all materials
     */
    const updateAllMaterials = () => {
      scene.traverse((child) => {
        if (
          child instanceof THREE.Mesh &&
          child.material instanceof THREE.MeshStandardMaterial
        ) {
          child.material.envMapIntensity = 1;
          child.material.needsUpdate = true;
          child.castShadow = true;
          child.receiveShadow = true;
        }
      });
    };

    /**
     * Models
     */
    gltfLoader.load(
      base + "/models/LeePerrySmith/LeePerrySmith.glb",
      (gltf) => {
        // Model
        const mesh = gltf.scene.children[0];
        mesh.rotation.y = Math.PI * 0.5;
        (mesh as THREE.Mesh).material = material;
        (mesh as THREE.Mesh).customDepthMaterial = depthMaterial;
        mesh.position.y = 3;
        scene.add(mesh);

        // Update materials
        updateAllMaterials();
      }
    );

    // NEW gltfLoader already contains the texture format (linear or sRGB)
    // so it's not necessary to change it

    /**
     * Camera
     */
    // Base camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(7, 5, -2);
    scene.add(camera);

    // Controls
    const controls = new OrbitControls(camera, canvas);
    controls.target.y = 3.5;
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true, // default is false // NEW
      // anti-aliasing is ok in terms of performance, is like mipmapping but only for the edges
    });
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);
    // ---------- mip mapping
    // renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    // ---------- pixel ratio
    // super sampling (SSAA) or fullscreen sampling (FSAA)

    // Light
    const directionalLight = new THREE.DirectionalLight(0xffffff, 4);
    directionalLight.position.set(3, 7, 6);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    gui
      .add(directionalLight, "intensity")
      .min(0)
      .max(10)
      .step(0.001)
      .name("lightIntensity");
    gui.add(directionalLight, "castShadow").name("castShadow");
    gui
      .add(directionalLight.position, "x")
      .min(-10)
      .max(10)
      .step(0.001)
      .name("lightX");
    gui
      .add(directionalLight.position, "y")
      .min(-10)
      .max(10)
      .step(0.001)
      .name("lightY");
    gui
      .add(directionalLight.position, "z")
      .min(-10)
      .max(10)
      .step(0.001)
      .name("lightZ");
    // Light Bias // NEW
    gui // NEW
      // normalBias for rounded surfaces // shadow acne
      .add(directionalLight.shadow, "normalBias")
      .min(-0.05)
      .max(0.05)
      .step(0.001)
      .name("normalBias");
    gui // NEW
      // bias for flat surfaces // shadow acne
      .add(directionalLight.shadow, "bias")
      .min(-0.05)
      .max(0.05)
      .step(0.001)
      .name("bias");
    directionalLight.target.position.set(0, 4, 0);
    // directionalLight is in the scene but not the target
    // scene.add(directionalLight.target); // NEW solition 1
    directionalLight.target.updateMatrixWorld(); // NEW solition 2
    directionalLight.shadow.camera.far = 30;
    directionalLight.shadow.mapSize.set(256, 256); // Blur
    // directionalLight.shadow.mapSize.set(1024, 1024);
    // directionalLight.shadow.mapSize.set(4096, 4096);

    const directionalLightHelper = new THREE.CameraHelper(
      directionalLight.shadow.camera
    );
    directionalLightHelper.visible = true;
    scene.add(directionalLightHelper);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      customUniforms.uTime.value = elapsedTime;
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
