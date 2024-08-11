<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
  import { DRACOLoader } from "three/addons/loaders/DRACOLoader.js";
  import GUI from "lil-gui";
  import gsap from "gsap";
  import particlesVertexShader from "$lib/shaders/morphing/vertex.glsl";
  import particlesFragmentShader from "$lib/shaders/morphing/fragment.glsl";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  const debugObject = {
    clearColor: "#160920",
  };

  let gui: GUI | null = null;

  function start() {
    gui = new GUI();
    const pixelRatio = Math.min(window.devicePixelRatio, 2);

    // Loaders
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath(base + "/draco/");
    const gltfLoader = new GLTFLoader();
    gltfLoader.setDRACOLoader(dracoLoader);

    // Scene
    const scene = new THREE.Scene();

    // Camera
    const camera = new THREE.PerspectiveCamera(35, RATIO, 0.1, 100);
    camera.position.set(0, 0, 8 * 2);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    renderer.setPixelRatio(pixelRatio);
    renderer.setSize(WIDTH, HEIGHT);
    gui!.addColor(debugObject, "clearColor").onChange(() => {
      renderer.setClearColor(debugObject.clearColor);
    });
    renderer.setClearColor(debugObject.clearColor);
    renderer.render(scene, camera);

    // Load models
    gltfLoader.load(base + "/morphing/models.glb", (gltf) => {
      /**
       * Particles
       */
      const particles = {
        geometry: null as THREE.BufferGeometry | null,
        material: null as THREE.ShaderMaterial | null,
        points: null as THREE.Points | null,
        positions: [] as Array<THREE.BufferAttribute>,
        index: 0,
        morph: (index: number) => {
          if (particles.geometry !== null && particles.material !== null) {
            // Update attributes
            particles.geometry.attributes.position =
              particles.positions[particles.index];
            particles.geometry.attributes.aPositionTarget =
              particles.positions[index];

            // Animate uProgress
            gsap.fromTo(
              particles.material.uniforms.uProgress,
              { value: 0 },
              { value: 1 }
            );

            particles.index = index;
          }
        },
        colorA: "#ff7300",
        colorB: "#0091ff",
      };

      // Morph functions animations
      const morphFunctions = {
        "Morph 1": () => particles.morph(0),
        "Morph 2": () => particles.morph(1),
        "Morph 3": () => particles.morph(2),
        "Morph 4": () => particles.morph(3),
      };
      gui!.add(morphFunctions, "Morph 1");
      gui!.add(morphFunctions, "Morph 2");
      gui!.add(morphFunctions, "Morph 3");
      gui!.add(morphFunctions, "Morph 4");

      const positions = (gltf.scene.children as Array<THREE.Mesh>).map(
        (child) => child.geometry.attributes.position
      ) as Array<THREE.BufferAttribute>;

      const maxPositionCount = Math.max(
        ...positions.map((position) => position.count)
      );

      for (const position of positions) {
        const originalArray = position.array;
        const newArray = new Float32Array(maxPositionCount * 3);

        for (let i = 0; i < maxPositionCount; i++) {
          const i3 = i * 3;
          if (i3 < originalArray.length) {
            newArray[i3] = originalArray[i3];
            newArray[i3 + 1] = originalArray[i3 + 1];
            newArray[i3 + 2] = originalArray[i3 + 2];
          } else {
            const randomIndex = Math.floor(position.count * Math.random()) * 3;
            newArray[i3] = originalArray[randomIndex];
            newArray[i3 + 1] = originalArray[randomIndex + 1];
            newArray[i3 + 2] = originalArray[randomIndex + 2];
          }
        }
        particles.positions.push(new THREE.Float32BufferAttribute(newArray, 3));
      }

      // Geometry
      const sizesArray = new Float32Array(maxPositionCount)
        .fill(0)
        .map(() => Math.random());
      particles.geometry = new THREE.BufferGeometry();
      particles.geometry.setAttribute(
        "position",
        particles.positions[particles.index]
      );
      particles.geometry.setAttribute(
        "aPositionTarget",
        particles.positions[3]
      );
      particles.geometry.setAttribute(
        "aSize",
        new THREE.BufferAttribute(sizesArray, 1)
      );
      particles.geometry.setIndex(null);

      // Material
      particles.material = new THREE.ShaderMaterial({
        vertexShader: particlesVertexShader,
        fragmentShader: particlesFragmentShader,
        uniforms: {
          uSize: new THREE.Uniform(0.4),
          uResolution: new THREE.Uniform(
            new THREE.Vector2(WIDTH * pixelRatio, HEIGHT * pixelRatio)
          ),
          uProgress: new THREE.Uniform(0),
          uColorA: new THREE.Uniform(new THREE.Color(particles.colorA)),
          uColorB: new THREE.Uniform(new THREE.Color(particles.colorB)),
        },
        // transparent: true,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      });

      // Points
      particles.points = new THREE.Points(
        particles.geometry,
        particles.material
      );
      // NEW frustumCulled property is set to the first geometry
      // to update the boundingSphere and/or fix the bug if we change the geometry (3 solutions):
      // 1) we can deactivate the frustumCulled property
      particles.points.frustumCulled = false;
      // 2) we can update the boundingSphere property directly in the geometry property
      // setTimeout(() => {
        // console.log(particles.points!.geometry.boundingSphere);
        // particles.points!.geometry.boundingSphere!.radius = 15;
        // }, 1000);
        // 3) we can ask to three.js to update the boundingSphere property but it's not performant
        scene.add(particles.points);

      // Tweak
      gui!
        .add(particles.material.uniforms.uSize, "value")
        .min(0)
        .max(0.8)
        .step(0.01)
        .name("Size");
      gui!
        .add(particles.material.uniforms.uProgress, "value")
        .min(0)
        .max(1)
        .step(0.01)
        .name("Progress")
        .listen();
      gui!
        .addColor(particles, "colorA")
        .name("Color A")
        .onChange(() => {
            particles.material!.uniforms.uColorA.value.set(particles.colorA);
        });
      gui!
        .addColor(particles, "colorB")
        .name("Color B")
        .onChange(() => {
            particles.material!.uniforms.uColorB.value.set(particles.colorB);
        });
    });

    // Clock
    const clock = new THREE.Clock();

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
