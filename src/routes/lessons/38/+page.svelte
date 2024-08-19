<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import earthVertexShader from "$lib/shaders/earth/globe/vertex.glsl";
  import earthFragmentShader from "$lib/shaders/earth/globe/fragment.glsl";
  import earthAtmosphereVertexShader from "$lib/shaders/earth/atmosphere/vertex.glsl";
  import earthAtmosphereFragmentShader from "$lib/shaders/earth/atmosphere/fragment.glsl";
  import GUI from "lil-gui";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);
    gui = new GUI();
    const textureLoader = new THREE.TextureLoader();

    // Scene
    const scene = new THREE.Scene();

    // Earth
    const earthParameters = {
      atmosphereDayColor: '#00aaff',
      atmosphereNightColor: '#ff6600',
    }

    gui.addColor(earthParameters, 'atmosphereDayColor').onChange(() => {
      earthMaterial.uniforms.uAtmosphereDayColor.value.set(earthParameters.atmosphereDayColor);
      atmosphereMaterial.uniforms.uAtmosphereDayColor.value.set(earthParameters.atmosphereDayColor);
    });

    gui.addColor(earthParameters, 'atmosphereNightColor').onChange(() => {
      earthMaterial.uniforms.uAtmosphereNightColor.value.set(earthParameters.atmosphereNightColor);
      atmosphereMaterial.uniforms.uAtmosphereNightColor.value.set(earthParameters.atmosphereNightColor);
    });

    const earthDayTexture = textureLoader.load(base + "/earth/day.jpg");
    earthDayTexture.colorSpace = THREE.SRGBColorSpace;
    earthDayTexture.anisotropy = 8;
    const earthNightTexture = textureLoader.load(base + "/earth/night.jpg");
    earthNightTexture.colorSpace = THREE.SRGBColorSpace;
    earthNightTexture.anisotropy = 8;
    const earthSpecularCloudsTexture = textureLoader.load(
      base + "/earth/specularClouds.jpg"
    );
    earthSpecularCloudsTexture.anisotropy = 8;

    const earthGeometry = new THREE.SphereGeometry(2, 64, 64);
    const earthMaterial = new THREE.ShaderMaterial({
      vertexShader: earthVertexShader,
      fragmentShader: earthFragmentShader,
      uniforms: {
        uDayTexture: new THREE.Uniform(earthDayTexture),
        uNightTexture: new THREE.Uniform(earthNightTexture),
        uSpecularCloudsTexture: new THREE.Uniform(earthSpecularCloudsTexture),
        uSunDirection: new THREE.Uniform(new THREE.Vector3(0, 0, 1)),
        uAtmosphereDayColor: new THREE.Uniform(
          new THREE.Color(earthParameters.atmosphereDayColor)
        ),
        uAtmosphereNightColor: new THREE.Uniform(
          new THREE.Color(earthParameters.atmosphereNightColor)
        ),
      },
    });
    const earth = new THREE.Mesh(earthGeometry, earthMaterial);
    scene.add(earth);

    // Atmosphere
    const atmosphereMaterial = new THREE.ShaderMaterial({
      side: THREE.BackSide,
      transparent: true,
      vertexShader: earthAtmosphereVertexShader,
      fragmentShader: earthAtmosphereFragmentShader,
      uniforms: {
        uSunDirection: new THREE.Uniform(new THREE.Vector3(0, 0, 1)),
        uAtmosphereDayColor: new THREE.Uniform(
          new THREE.Color(earthParameters.atmosphereDayColor)
        ),
        uAtmosphereNightColor: new THREE.Uniform(
          new THREE.Color(earthParameters.atmosphereNightColor)
        ),
      },
    });
    const atmosphere = new THREE.Mesh(earthGeometry, atmosphereMaterial);
    atmosphere.scale.set(1.04, 1.04, 1.04);
    scene.add(atmosphere);


    // Sun
    const sunSpherical = new THREE.Spherical(1, Math.PI / 2, 0.5);
    const sunDirection = new THREE.Vector3();

    const debugSun = new THREE.Mesh(
      new THREE.IcosahedronGeometry(0.1, 2),
      new THREE.MeshBasicMaterial({ color: 0xffffee })
    );
    scene.add(debugSun);

    const updateSun = () => {
      sunDirection.setFromSpherical(sunSpherical);
      // Debug
      debugSun.position.copy(sunDirection).multiplyScalar(5);
      // Uniforms
      earthMaterial.uniforms.uSunDirection.value.copy(sunDirection);
    };
    updateSun();

    gui.add(sunSpherical, "phi", 0, Math.PI, 0.01).onChange(updateSun);
    gui.add(sunSpherical, "theta", -Math.PI, Math.PI, 0.01).onChange(updateSun);

    // Camera
    const camera = new THREE.PerspectiveCamera(25, RATIO, 0.1, 100);
    camera.position.x = 12;
    camera.position.y = 5;
    camera.position.z = 4;
    scene.add(camera);

    // Camera controls // NEW
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true,
    });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.setPixelRatio(pixelRatio);
    renderer.setClearColor("#000011");
    renderer.render(scene, camera);

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      earth.rotation.y = elapsedTime * 0.1;
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
<div class="text-center my-2 text-white">
  <p>
    Thanks to <a
      class="link"
      href="https://x.com/solarsystscope"
      target="_blank">@SolarSystScope</a
    >
    for the planet textures under
    <a class="link" href="https://creativecommons.org/licenses/by/4.0/"
      >CC Attribution 4.0 license</a
    >.
    <br />
    Check the
    <a class="link" href="https://www.solarsystemscope.com/textures/"
      >Solar System Scope</a
    > website.
  </p>
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
