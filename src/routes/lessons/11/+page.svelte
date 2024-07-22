<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { base } from "$app/paths";
  import GUI from "lil-gui";
  import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Debug
    const gui = new GUI();

    // Scene
    const scene = new THREE.Scene();

    // Textures
    const textureLoader = new THREE.TextureLoader();

    const doorColorTexture = textureLoader.load(
      `${base}/textures/door/color.jpg`
    );
    const doorAlphaTexture = textureLoader.load(
      `${base}/textures/door/alpha.jpg`
    );
    const doorAmbientOcclusionTexture = textureLoader.load(
      `${base}/textures/door/ambientOcclusion.jpg`
    );
    const doorHeightTexture = textureLoader.load(
      `${base}/textures/door/height.jpg`
    );
    const doorNormalTexture = textureLoader.load(
      `${base}/textures/door/normal.jpg`
    );
    const doorMetalnessTexture = textureLoader.load(
      `${base}/textures/door/metalness.jpg`
    );
    const doorRoughnessTexture = textureLoader.load(
      `${base}/textures/door/roughness.jpg`
    );
    const matcapTextures = [
      textureLoader.load(`${base}/textures/matcaps/1.png`),
      textureLoader.load(`${base}/textures/matcaps/2.png`),
      textureLoader.load(`${base}/textures/matcaps/3.png`),
      textureLoader.load(`${base}/textures/matcaps/4.png`),
      textureLoader.load(`${base}/textures/matcaps/5.png`),
      textureLoader.load(`${base}/textures/matcaps/6.png`),
      textureLoader.load(`${base}/textures/matcaps/7.png`),
      textureLoader.load(`${base}/textures/matcaps/8.png`),
    ];

    const gradientTexture = textureLoader.load(
      `${base}/textures/gradients/3.jpg`
    );

    // map and matcap supposed to be sRGB
    doorColorTexture.colorSpace = THREE.SRGBColorSpace;
    for (const matcapTexture of matcapTextures)
      matcapTexture.colorSpace = THREE.SRGBColorSpace;

    // Objects
    // const material = new THREE.MeshBasicMaterial({ map: doorColorTexture });
    const basicMaterial = new THREE.MeshBasicMaterial();
    basicMaterial.map = doorColorTexture; // NEW
    basicMaterial.color = new THREE.Color(0xff0000); // NEW can't put directly a string
    // basicMaterial.wireframe = true;
    basicMaterial.transparent = true; // NEW
    basicMaterial.opacity = 0.5; // NEW
    basicMaterial.alphaMap = doorAlphaTexture; // NEW
    basicMaterial.side = THREE.DoubleSide; // NEW

    const plane = new THREE.Mesh(new THREE.PlaneGeometry(1, 1), basicMaterial);

    const normalMaterial = new THREE.MeshNormalMaterial(); // NEW
    normalMaterial.flatShading = true; // NEW

    const sphere = new THREE.Mesh(
      new THREE.SphereGeometry(0.5, 16, 16),
      normalMaterial
    );
    sphere.position.x = 2;

    const taurus = new THREE.Mesh(
      new THREE.TorusGeometry(0.3, 0.2, 16, 32),
      basicMaterial
    );
    taurus.position.x = -2;

    const meshMatcap = new THREE.MeshMatcapMaterial();
    meshMatcap.matcap = matcapTextures[0]; // NEW
    // light effect without light, need spherical texture

    const sphere2 = new THREE.Mesh(
      new THREE.SphereGeometry(0.5, 16, 16),
      meshMatcap
    );
    sphere2.position.y = 1.3;

    const materialLambert = new THREE.MeshLambertMaterial(); // NEW
    // Lambert is less performant than Basic but it has more properties
    // but still less than Phong or Standard or Physical
    const taurus2 = new THREE.Mesh(
      new THREE.TorusGeometry(0.3, 0.2, 16, 32),
      materialLambert
    );
    taurus2.position.x = 2;
    taurus2.position.y = 1.3;

    const materialPhong = new THREE.MeshPhongMaterial(); // NEW
    // MeshPhongMaterial is less performant than MeshLambertMaterial
    // but it has more properties and more realistic
    materialPhong.shininess = 100; // NEW
    materialPhong.specular = new THREE.Color(0x1188ff); // NEW
    const taurus3 = new THREE.Mesh(
      new THREE.TorusGeometry(0.3, 0.2, 16, 32),
      materialPhong
    );
    taurus3.position.x = 2;
    taurus3.position.y = 2.3;

    const materialToon = new THREE.MeshToonMaterial(); // NEW
    gradientTexture.minFilter = THREE.NearestFilter;
    gradientTexture.magFilter = THREE.NearestFilter;
    gradientTexture.generateMipmaps = false;
    materialToon.gradientMap = gradientTexture; // NEW

    const taurus4 = new THREE.Mesh(
      new THREE.TorusGeometry(0.3, 0.2, 16, 32),
      materialToon
    );
    taurus4.position.x = -2;
    taurus4.position.y = 1.3;

    const materialStandard = new THREE.MeshStandardMaterial(); // NEW
    // Standard use PBR (Physically Based Rendering)
    materialStandard.metalness = 0.9;
    materialStandard.roughness = 0.1; // NEW
    const sphere3 = new THREE.Mesh(
      new THREE.SphereGeometry(0.5, 16, 16),
      materialStandard
    );
    sphere3.position.y = -1.3;
    sphere3.position.x = -2;
    sphere3.position.y = -1.3;

    const materialStandard2 = new THREE.MeshStandardMaterial(); // NEW
    // Standard use PBR (Physically Based Rendering)
    materialStandard2.metalness = 1;
    materialStandard2.roughness = 1; // NEW
    materialStandard2.map = doorColorTexture; // NEW
    materialStandard2.aoMap = doorAmbientOcclusionTexture; // NEW
    materialStandard2.displacementMap = doorHeightTexture; // NEW
    // ^ need to increase vertices of the geometry
    materialStandard2.displacementScale = 0.15; // NEW
    materialStandard2.metalnessMap = doorMetalnessTexture; // NEW
    materialStandard2.roughnessMap = doorRoughnessTexture; // NEW
    materialStandard2.normalMap = doorNormalTexture; // NEW
    // ^ add realistic effect without increasing geometry
    materialStandard2.normalScale.set(0.5, 0.5); // NEW
    materialStandard2.transparent = true; // NEW
    materialStandard2.alphaMap = doorAlphaTexture; // NEW

    const cube = new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1, 100, 100, 100),
      materialStandard2
    );
    cube.position.y = -1.3;

    const materialPhysic = new THREE.MeshPhysicalMaterial(); // NEW
    // Standard use PBR (Physically Based Rendering)
    materialPhysic.metalness = 1;
    materialPhysic.roughness = 1; // NEW
    materialPhysic.map = doorColorTexture; // NEW
    materialPhysic.aoMap = doorAmbientOcclusionTexture; // NEW
    materialPhysic.displacementMap = doorHeightTexture; // NEW
    // ^ need to increase vertices of the geometry
    materialPhysic.displacementScale = 0.15; // NEW
    materialPhysic.metalnessMap = doorMetalnessTexture; // NEW
    materialPhysic.roughnessMap = doorRoughnessTexture; // NEW
    materialPhysic.normalMap = doorNormalTexture; // NEW
    // ^ add realistic effect without increasing geometry
    materialPhysic.normalScale.set(0.5, 0.5); // NEW
    materialPhysic.transparent = true; // NEW
    materialPhysic.alphaMap = doorAlphaTexture; // NEW
    // ------ Physic extra properties
    // clearcoat
    materialPhysic.clearcoat = 1; // NEW
    materialPhysic.clearcoatRoughness = 0.1; // NEW
    // sheen
    materialPhysic.sheen = 1; // NEW
    materialPhysic.sheenRoughness = 0.25; // NEW
    materialPhysic.sheenColor.set(1, 1, 1);
    // iridescence
    // fuel puddle / soap bubble / laser disc effect
    materialPhysic.iridescence = 1; // NEW
    materialPhysic.iridescenceIOR = 1.6; // NEW
    materialPhysic.iridescenceThicknessRange = [100, 800]; // NEW

    const cube2 = new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1, 100, 100, 100),
      materialPhysic
    );
    cube2.position.y = -1.3;
    cube2.position.x = 2;

    //---------------------------------------
    const materialPhysic2 = new THREE.MeshPhysicalMaterial(); // NEW
    // transmission
    materialPhysic2.metalness = 0;
    materialPhysic2.roughness = 0;
    materialPhysic2.transmission = 1; // NEW
    materialPhysic2.ior = 1.6; //
    materialPhysic2.thickness = 0.5; // NEW

    const sphere4 = new THREE.Mesh(
      new THREE.SphereGeometry(0.5, 16, 16),
      materialPhysic2
    );
    sphere4.position.z = 1.5;

    gui
      .add(materialStandard, "metalness")
      .min(0)
      .max(1)
      .step(0.01)
      .name("metalness");
    gui
      .add(materialStandard, "roughness")
      .min(0)
      .max(1)
      .step(0.01)
      .name("roughness");

    // Lights
    const ambiantLight = new THREE.AmbientLight(0xffffff, 1); // NEW
    const pointLight = new THREE.PointLight(0xffffff, 30); // NEW
    pointLight.position.set(2, 3, 4); // NEW
    scene.add(ambiantLight, pointLight); // NEW

    // Environment
    const rgbdLoader = new RGBELoader();
    rgbdLoader.load(
      `${base}/textures/environmentMap/2k.hdr`,
      (environmentMap) => {
        console.log(environmentMap);
        environmentMap.mapping = THREE.EquirectangularReflectionMapping;
        scene.background = environmentMap;
        scene.environment = environmentMap;
      }
    );

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 3;
    scene.add(camera);
    camera.position.z = 3;

    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    scene.add(
      plane,
      sphere,
      taurus,
      sphere2,
      taurus2,
      taurus3,
      taurus4,
      sphere3,
      cube,
      cube2,
      sphere4
    ); // NEW can add multiple objects at once

    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    const MAX_MESH_TEXTURE_NUMBER = 8;
    let lastMeshTextureNumber = 0;

    // Animation
    function tick() {
      const elapsedTime = clock.getElapsedTime();
      const meshTextureNumber =
        Math.floor(elapsedTime) % MAX_MESH_TEXTURE_NUMBER;
      if (meshTextureNumber !== lastMeshTextureNumber) {
        meshMatcap.matcap = matcapTextures[meshTextureNumber];
        lastMeshTextureNumber = meshTextureNumber;
      }
      sphere.rotation.y = elapsedTime;
      taurus.rotation.y = elapsedTime;
      plane.rotation.y = elapsedTime;
      controls.update();
      renderer.render(scene, camera);
      window.requestAnimationFrame(tick);
    }

    window;

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
