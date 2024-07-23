<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { RectAreaLightHelper } from "three/examples/jsm/helpers/RectAreaLightHelper.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Lights
    // ----------------- ambient light // NEW
    const ambientLight = new THREE.AmbientLight();
    ambientLight.color = new THREE.Color(0xffffff);
    ambientLight.intensity = 0.1;
    scene.add(ambientLight);

    // ----------------- directional light // NEW
    // parrallel light everywhere (not realistic)
    // or like the sun
    const directionalLight = new THREE.DirectionalLight();
    directionalLight.color = new THREE.Color(0x00ff00);
    directionalLight.intensity = 1;
    // to change the angle of the light vvv
    // change the position of the light
    directionalLight.position.set(1, 0.25, 0);
    scene.add(directionalLight);

    const directionalLightHelper = new THREE.DirectionalLightHelper(
      directionalLight,
      0.2
    );
    scene.add(directionalLightHelper);

    // ----------------- hemisphere light // NEW
    // light from the sky
    const hemisphereLight = new THREE.HemisphereLight();
    hemisphereLight.color = new THREE.Color("red");
    hemisphereLight.groundColor = new THREE.Color("yellow");
    hemisphereLight.intensity = 1;
    scene.add(hemisphereLight);

    const hemisphereLightHelper = new THREE.HemisphereLightHelper(
      hemisphereLight,
      0.2
    );
    scene.add(hemisphereLightHelper);

    // ----------------- point light // NEW
    // light from a point
    // distance of the light is important
    // it is possible to change the intensity of the light and the distance
    const pointLight = new THREE.PointLight();
    pointLight.color = new THREE.Color(0x0ff0ff);
    pointLight.distance = 3;
    pointLight.intensity = 1;
    pointLight.position.set(0, 0, 1);
    scene.add(pointLight);

    const pointLightHelper = new THREE.PointLightHelper(pointLight, 0.2);
    scene.add(pointLightHelper);

    // ----------------- rect area light // NEW
    // light from a rectangle
    // work only with MeshStandardMaterial and MeshPhysicalMaterial
    const rectAreaLight = new THREE.RectAreaLight(0x4e00ff, 20, 1, 1);
    rectAreaLight.position.set(-1.5, 0, 1.5);
    rectAreaLight.lookAt(0, 0, 0);
    scene.add(rectAreaLight);

    const rectAreaLightHelper = new RectAreaLightHelper(rectAreaLight);
    scene.add(rectAreaLightHelper);

    // ----------------- sport light // NEW
    // light from a point like a flashlight
    // distance of the light is important
    // it is possible to change the intensity of the light and the distance
    const spotLight = new THREE.SpotLight(
      0xff0000,
      2, // intensity
      10, // distance
      Math.PI * 0.1, // angle
      0.1, // sharpness
      1 // distance
    );
    spotLight.position.set(0, 0, 2);
    spotLight.target.position.set(0.5, 0, 0);
    scene.add(spotLight);
    scene.add(spotLight.target);

    const spotLightHelper = new THREE.SpotLightHelper(spotLight);
    scene.add(spotLightHelper);

    // Objects
    const material = new THREE.MeshStandardMaterial();
    // material.color = new THREE.Color(0xff0000);
    material.metalness = 0.7;
    material.roughness = 0.2;
    // MeshStandardMaterial need light to be visible
    // ----------------- cube
    const geometry = new THREE.BoxGeometry(1, 1, 1);
    const mech = new THREE.Mesh(geometry, material);
    scene.add(mech);
    // ----------------- sphere
    const sphereGeometry = new THREE.SphereGeometry(0.5, 32, 32);
    const sphere = new THREE.Mesh(sphereGeometry, material);
    sphere.position.x = -2;
    scene.add(sphere);
    // ----------------- taurus
    const taurusGeometry = new THREE.TorusGeometry(0.3, 0.2, 16, 32);
    const taurus = new THREE.Mesh(taurusGeometry, material);
    taurus.position.x = 2;
    scene.add(taurus);
    // ----------------- plane
    const planeGeometry = new THREE.PlaneGeometry(5, 5);
    const plane = new THREE.Mesh(planeGeometry, material);
    plane.rotation.x = -Math.PI / 2;
    plane.position.y = -1;
    scene.add(plane);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 3;
    scene.add(camera);
    camera.position.z = 3;
    camera.lookAt(mech.position);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);

    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      mech.rotation.x = (elapsedTime * Math.PI) / 2;
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
