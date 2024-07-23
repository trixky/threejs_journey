<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import GUI from "lil-gui";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Bake shadow map
    const textureLoader = new THREE.TextureLoader(); // NEW
    const bakedShadowMap = textureLoader.load(
      // NEW
      base + "/textures/shadows/bakedShadow.jpg" // NEW
    );
    bakedShadowMap.colorSpace = THREE.SRGBColorSpace; // doesn't forget to set the color space
    const backedShadowMaterial = new THREE.MeshBasicMaterial({
      map: bakedShadowMap,
    });
    const bakedShadowMapAlternative = textureLoader.load(
      // NEW
      base + "/textures/shadows/simpleShadow.jpg" // NEW
    );
    bakedShadowMapAlternative.colorSpace = THREE.SRGBColorSpace; // doesn't forget to set the color space
    const backedShadowMaterialAlternative = new THREE.MeshBasicMaterial({
      color: 0x000000,
      transparent: true,
      alphaMap: bakedShadowMapAlternative,
    });

    // Objects
    const material = new THREE.MeshStandardMaterial();
    material.roughness = 0.5;
    // -------------- sphere
    const sphereGeometry = new THREE.SphereGeometry(0.5, 32, 32);
    const sphere = new THREE.Mesh(sphereGeometry, material);
    sphere.castShadow = true; // NEW
    sphere.position.y = 0.5;
    scene.add(sphere);
    // -------------- plan
    const planeGeometry = new THREE.PlaneGeometry(5, 5);
    const plane = new THREE.Mesh(planeGeometry, material);
    plane.receiveShadow = true; // NEW
    plane.rotation.x = -Math.PI / 2;
    scene.add(plane);
    // -------------- sphere 2 (baked shadow)
    const sphere2Material = new THREE.MeshBasicMaterial({
      color: "black",
    });
    const sphere2 = new THREE.Mesh(sphereGeometry, sphere2Material);
    sphere2.position.x = -5;
    sphere2.position.y = 0.5;
    scene.add(sphere2);
    // -------------- plan 2 (baked shadow)
    const plane2 = new THREE.Mesh(planeGeometry, backedShadowMaterial);
    plane2.rotation.x = -Math.PI / 2;
    plane2.position.x = -5;
    scene.add(plane2);
    // -------------- sphere 3 (baked shadow alternative)
    const sphere3Material = new THREE.MeshBasicMaterial({
      color: "yellow",
    });
    const sphere3 = new THREE.Mesh(sphereGeometry, sphere3Material);
    sphere3.position.x = 5;
    sphere3.position.y = 0.5;
    scene.add(sphere3);
    // -------------- sphere 3 simple shadow (baked shadow alternative)
    const sphere3SimpleShadowGeometry = new THREE.PlaneGeometry(1, 1);
    const sphere3SimpleShadow = new THREE.Mesh(
      sphere3SimpleShadowGeometry,
      backedShadowMaterialAlternative
    );
    sphere3SimpleShadow.rotation.x = -Math.PI / 2;
    sphere3SimpleShadow.position.x = 5;
    sphere3SimpleShadow.position.y = 0.01;
    sphere3SimpleShadow.scale.set(2, 2, 2);

    scene.add(sphere3SimpleShadow);

    // -------------- plan 3 (baked shadow alternative)
    const plane3 = new THREE.Mesh(planeGeometry, material);
    plane3.rotation.x = -Math.PI / 2;
    plane3.position.x = 5;
    scene.add(plane3);

    // Lights
    // Shadows work only with directional, spot and point lights
    // -------------- ambient light
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.2);
    scene.add(ambientLight);

    // -------------- directional light
    const directionalLight = new THREE.DirectionalLight(0x00ffff, 1);
    directionalLight.position.set(2, 2, -1);
    scene.add(directionalLight);
    directionalLight.castShadow = true; // NEW
    // Use a power of 2 for the shadow map (mipmapping)
    directionalLight.shadow.mapSize.width = 1024; // NEW
    directionalLight.shadow.mapSize.height = 1024; // NEW
    directionalLight.shadow.camera.top = 2; // NEW
    directionalLight.shadow.camera.right = 2; // NEW
    directionalLight.shadow.camera.bottom = -2; // NEW
    directionalLight.shadow.camera.left = -2; // NEW
    directionalLight.shadow.camera.near = 1; // NEW
    directionalLight.shadow.camera.far = 6; // NEW
    directionalLight.shadow.radius = 10; // NEW doesn't work with PCFSoftShadowMap
    // ^^^ blur still the same no matter the distance between the light , the object and the shadow
    const directionalLightShadowCameraHelper = new THREE.CameraHelper(
      directionalLight.shadow.camera
    ); // NEW
    scene.add(directionalLightShadowCameraHelper); // NEW
    directionalLightShadowCameraHelper.visible = false; // NEW

    // -------------- spot light
    const spotLight = new THREE.SpotLight(0xffff00, 6);
    spotLight.castShadow = true; // NEW
    spotLight.shadow.mapSize.width = 1024 * 4; // NEW
    spotLight.shadow.mapSize.height = 1024 * 4; // NEW
    spotLight.shadow.camera.fov = 30; // NEW
    spotLight.shadow.camera.near = 1; // NEW
    spotLight.shadow.camera.far = 6; // NEW
    // ^^^ doesn't work with with the new version of threejs, it is the spotlight fov that is used
    spotLight.position.set(0, 2, 2);
    scene.add(spotLight);
    const sportLightShadowCameraHelper = new THREE.CameraHelper(
      spotLight.shadow.camera
    ); // NEW
    scene.add(sportLightShadowCameraHelper); // NEW
    sportLightShadowCameraHelper.visible = false; // NEW

    // -------------- point light
    const pointLight = new THREE.PointLight(0xff0000, 3, 5);
    pointLight.castShadow = true; // NEW
    pointLight.shadow.mapSize.width = 1024; // NEW
    pointLight.shadow.mapSize.height = 1024; // NEW
    pointLight.shadow.camera.near = 0.1; // NEW
    pointLight.shadow.camera.far = 2; // NEW
    pointLight.position.set(-1, 1, 0);
    scene.add(pointLight);

    const pointLightShadowCameraHelper = new THREE.CameraHelper(
      pointLight.shadow.camera
    ); // NEW
    scene.add(pointLightShadowCameraHelper); // NEW
    pointLightShadowCameraHelper.visible = false; // NEW

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 3;
    camera.position.y = 2;
    scene.add(camera);
    camera.lookAt(sphere.position);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.shadowMap.enabled = true; // NEW
    renderer.shadowMap.type = THREE.PCFSoftShadowMap; // NEW
    // ^^^ less performant but better quality and radius doesn't work with PCFSoftShadowMap
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // GUI
    const gui = new GUI();
    const guiAmbiantLight = gui.addFolder("ambient light");
    // -------------- ambient light
    guiAmbiantLight.add(ambientLight, "visible");
    guiAmbiantLight.add(ambientLight, "intensity").min(0).max(1).step(0.01);
    // -------------- directional light
    const guiDirectionalLight = gui.addFolder("directional light");
    guiDirectionalLight.add(directionalLight, "visible");
    guiDirectionalLight
      .add(directionalLightShadowCameraHelper, "visible")
      .name("helper");
    guiDirectionalLight
      .add(directionalLight, "intensity")
      .min(0)
      .max(10)
      .step(0.01);
    // -------------- spot light
    const guiSpotLight = gui.addFolder("spot light");
    guiSpotLight.add(spotLight, "visible");
    guiSpotLight.add(sportLightShadowCameraHelper, "visible").name("helper");
    guiSpotLight.add(spotLight, "intensity").min(0).max(10).step(0.01);
    // -------------- point light
    const guiPointLight = gui.addFolder("point light");
    guiPointLight.add(pointLight, "visible");
    guiPointLight.add(pointLightShadowCameraHelper, "visible").name("helper");
    guiPointLight.add(pointLight, "intensity").min(0).max(10).step(0.01);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const sphere3Multiplier = 4;
    const tick = () => {
      sphere.position.y = Math.sin(clock.getElapsedTime()) / 2 + 1;
      const mathSinSphere3 = Math.abs(Math.sin(clock.getElapsedTime() * sphere3Multiplier));
      sphere3.position.y = mathSinSphere3 + 0.5;
      sphere3SimpleShadow.scale.set(...new THREE.Vector3(1, 1, 1).multiplyScalar(1 - mathSinSphere3 / 2).toArray());
      backedShadowMaterialAlternative.opacity = 1 - mathSinSphere3 / 2;
      sphere3.position.x = Math.sin(clock.getElapsedTime()) + 5;
      sphere3.position.z = Math.cos(clock.getElapsedTime());
      sphere3SimpleShadow.position.x = sphere3.position.x;
      sphere3SimpleShadow.position.z = sphere3.position.z;
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
