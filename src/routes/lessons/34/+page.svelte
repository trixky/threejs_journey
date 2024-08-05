<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import shaderVertex from "$lib/shaders/firework/vertex.glsl";
  import shaderFragment from "$lib/shaders/firework/fragment.glsl";
  import { base } from "$app/paths";
  import gsap from "gsap";
  import GUI from 'lil-gui';
  import {Sky} from 'three/addons/objects/Sky.js';

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let createRandomFirework: () => void = () => {};
  let gui: GUI | null = null;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);

    // Texture loader
    const textureLoader = new THREE.TextureLoader();
    const textures: THREE.Texture[] = [
      textureLoader.load(base + "/textures/particles/1.png"),
      textureLoader.load(base + "/textures/particles/2.png"),
      textureLoader.load(base + "/textures/particles/3.png"),
      textureLoader.load(base + "/textures/particles/4.png"),
      textureLoader.load(base + "/textures/particles/5.png"),
      textureLoader.load(base + "/textures/particles/6.png"),
      textureLoader.load(base + "/textures/particles/7.png"),
      textureLoader.load(base + "/textures/particles/8.png"),
      textureLoader.load(base + "/textures/particles/9.png"),
      textureLoader.load(base + "/textures/particles/10.png"),
      textureLoader.load(base + "/textures/particles/11.png"),
      textureLoader.load(base + "/textures/particles/12.png"),
      textureLoader.load(base + "/textures/particles/13.png"),
    ];

    // Scene
    const scene = new THREE.Scene();

    // Debug
    gui = new GUI();

    // FireWork
    function createFirework(
      count: number,
      position: THREE.Vector3 = new THREE.Vector3(),
      size: number,
      texture: THREE.Texture,
      radius: number,
      color: THREE.Color
    ) {
      texture.flipY = false; // NEW
      // Geometry
      const positionArray = new Float32Array(count * 3);
      const sizeArray = new Float32Array(count);
      const timeMultiplierArray = new Float32Array(count);
      for (let i = 0; i < count; i++) {
        const i3 = i * 3;

        const spherical = new THREE.Spherical(
          radius * (0.75 + Math.random() * 0.25),
          Math.random() * Math.PI,
          Math.random() * Math.PI * 2
        );
        const position = new THREE.Vector3().setFromSpherical(spherical);

        positionArray[i3] = position.x;
        positionArray[i3 + 1] = position.y;
        positionArray[i3 + 2] = position.z;
        sizeArray[i] = Math.random();
        timeMultiplierArray[i] = 1 + Math.random();
      }
      const geometry = new THREE.BufferGeometry();
      geometry.setAttribute(
        "position",
        new THREE.BufferAttribute(positionArray, 3)
      );
      geometry.setAttribute("aSize", new THREE.BufferAttribute(sizeArray, 1));
      geometry.setAttribute(
        "aTimeMultiplier",
        new THREE.BufferAttribute(timeMultiplierArray, 1)
      );
      const material = new THREE.ShaderMaterial({
        vertexShader: shaderVertex,
        fragmentShader: shaderFragment,
        transparent: true,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        uniforms: {
          uSize: new THREE.Uniform(size),
          uResolution: new THREE.Uniform(
            new THREE.Vector2(WIDTH / pixelRatio, HEIGHT / pixelRatio)
          ),
          uTexture: new THREE.Uniform(texture),
          uColor: new THREE.Uniform(color),
          uProgress: new THREE.Uniform(0),
        },
      });
      const firework = new THREE.Points(geometry, material);
      firework.position.copy(position);
      scene.add(firework);

      function destroy() {
        console.log("destroy");
        scene.remove(firework);
        geometry.dispose();
        material.dispose();
      }

      gsap.to(material.uniforms.uProgress, {
        value: 1,
        duration: 3,
        ease: "linear",
        onComplete: destroy,
      });
    }

    createRandomFirework = () => {
      const count = Math.round(400 + Math.random() * 1000);
      const position = new THREE.Vector3(
        (Math.random() - 0.5) * 2,
        Math.random(),
        (Math.random() - 0.5) * 2
      );
      const size = 0.1 + Math.random() * 0.1;
      const texture = textures[Math.floor(Math.random() * textures.length)];
      const radius = 0.5 + Math.random();
      const color = new THREE.Color();
      color.setHSL(Math.random(), 1, 0.7);
      createFirework(count, position, size, texture, radius, color);
    }

    createRandomFirework();
    createRandomFirework();
    createRandomFirework();
    window.addEventListener("click", createRandomFirework);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    scene.add(camera);
    camera.position.z = 3;

    // Camera controls
    const controls = new OrbitControls(camera, canvas); // NEW
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);
    renderer.setPixelRatio(pixelRatio);

    // Clock
    const clock = new THREE.Clock();

    // Sky
    const sky = new Sky();
    sky.scale.setScalar(450000);
    scene.add(sky);

    const sun = new THREE.Vector3();

    const skyParameters = {
      turbidity: 10,
      rayleigh: 3,
      mieCoefficient: 0.005,
      mieDirectionalG: 0.95,
      elevation: -2.2,
      azimuth: 180,
      exposure: renderer.toneMappingExposure,
    };

    const updateSky = () => {
      const uniforms = sky.material.uniforms;
      uniforms["turbidity"].value = skyParameters.turbidity;
      uniforms["rayleigh"].value = skyParameters.rayleigh;
      uniforms["mieCoefficient"].value = skyParameters.mieCoefficient;
      uniforms["mieDirectionalG"].value = skyParameters.mieDirectionalG;

      const phi = THREE.MathUtils.degToRad(90 - skyParameters.elevation);
      const theta = THREE.MathUtils.degToRad(skyParameters.azimuth);

      sun.setFromSphericalCoords(1, phi, theta);

      uniforms["sunPosition"].value.copy(sun);

      renderer.toneMappingExposure = skyParameters.exposure;
      renderer.render(scene, camera);
    };

    gui.add(skyParameters, "turbidity", 0.0, 20.0, 0.1).onChange(updateSky);
    gui.add(skyParameters, "rayleigh", 0.0, 4, 0.001).onChange(updateSky);
    gui
      .add(skyParameters, "mieCoefficient", 0.0, 0.1, 0.001)
      .onChange(updateSky);
    gui
      .add(skyParameters, "mieDirectionalG", 0.0, 1, 0.001)
      .onChange(updateSky);
    gui.add(skyParameters, "elevation", 0, 90, 0.1).onChange(updateSky);
    gui.add(skyParameters, "azimuth", -180, 180, 0.1).onChange(updateSky);
    gui.add(skyParameters, "exposure", 0, 1, 0.0001).onChange(updateSky);

    updateSky();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
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
        window.removeEventListener("click", createRandomFirework);
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
