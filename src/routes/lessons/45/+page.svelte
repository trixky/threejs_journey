<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import GUI from "lil-gui";
  import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { base } from "$app/paths";
  import { EffectComposer } from "three/examples/jsm/postprocessing/EffectComposer.js";
  import { RenderPass } from "three/examples/jsm/postprocessing/RenderPass.js";
  import { DotScreenPass } from "three/examples/jsm/postprocessing/DotScreenPass.js";
  import { GlitchPass } from "three/examples/jsm/postprocessing/GlitchPass.js";
  import { UnrealBloomPass } from "three/examples/jsm/postprocessing/UnrealBloomPass.js";
  import { ShaderPass } from "three/examples/jsm/postprocessing/ShaderPass.js";
  import { RGBShiftShader } from "three/examples/jsm/shaders/RGBShiftShader.js";
  import { GammaCorrectionShader } from "three/examples/jsm/shaders/GammaCorrectionShader.js";
  import { SMAAPass } from "three/examples/jsm/postprocessing/SMAAPass.js";
  import TintShaderVertex from "$lib/shaders/post-processing/tint/vertex.glsl";
  import TintShaderFragment from "$lib/shaders/post-processing/tint/fragment.glsl";
  import DisplacementShaderVertex from "$lib/shaders/post-processing/displacement/vertex.glsl";
  import DisplacementShaderFragment from "$lib/shaders/post-processing/displacement/fragment.glsl";
  import FuturisticShaderVertex from "$lib/shaders/post-processing/futuristic/vertex.glsl";
  import FuturisticShaderFragment from "$lib/shaders/post-processing/futuristic/fragment.glsl";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  let gui: GUI | null = null;

  function start() {
    const pixelRatio = Math.min(window.devicePixelRatio, 2);
    // Scene
    const scene = new THREE.Scene();

    /**
     * Loaders
     */
    const gltfLoader = new GLTFLoader();
    const cubeTextureLoader = new THREE.CubeTextureLoader();
    const textureLoader = new THREE.TextureLoader();

    /**
     * Update all materials
     */
    const updateAllMaterials = () => {
      scene.traverse((child) => {
        if (
          child instanceof THREE.Mesh &&
          child.material instanceof THREE.MeshStandardMaterial
        ) {
          child.material.envMapIntensity = 2.5;
          child.material.needsUpdate = true;
          child.castShadow = true;
          child.receiveShadow = true;
        }
      });
    };

    /**
     * Environment map
     */
    const environmentMap = cubeTextureLoader.load([
      base + "/post-processing/textures/environmentMaps/0/px.jpg",
      base + "/post-processing/textures/environmentMaps/0/nx.jpg",
      base + "/post-processing/textures/environmentMaps/0/py.jpg",
      base + "/post-processing/textures/environmentMaps/0/ny.jpg",
      base + "/post-processing/textures/environmentMaps/0/pz.jpg",
      base + "/post-processing/textures/environmentMaps/0/nz.jpg",
    ]);

    scene.background = environmentMap;
    scene.environment = environmentMap;

    /**
     * Models
     */
    gltfLoader.load(
      base + "/post-processing/models/DamagedHelmet/glTF/DamagedHelmet.gltf",
      (gltf) => {
        gltf.scene.scale.set(2, 2, 2);
        gltf.scene.rotation.y = Math.PI * 0.5;
        scene.add(gltf.scene);

        updateAllMaterials();
      }
    );

    /**
     * Lights
     */
    const directionalLight = new THREE.DirectionalLight("#ffffff", 3);
    directionalLight.castShadow = true;
    directionalLight.shadow.mapSize.set(1024, 1024);
    directionalLight.shadow.camera.far = 15;
    directionalLight.shadow.normalBias = 0.05;
    directionalLight.position.set(0.25, 3, -2.25);
    scene.add(directionalLight);

    // Base camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.set(4, 1, -4);
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({
      canvas: canvas,
      antialias: true,
    });
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFShadowMap;
    renderer.toneMapping = THREE.ReinhardToneMapping;
    renderer.toneMappingExposure = 1.5;
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.setPixelRatio(pixelRatio);
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Post processing
    // Render target
    const renderTarget = new THREE.WebGLRenderTarget(WIDTH, HEIGHT, {
      samples: pixelRatio > 1 ? 0 : 2,
    });
    // renderTarget is automatically resized when the renderer is resized
    // is used to put back anti-aliasing with samples: 2 for example
    // Anti-aliasing is not useful if pixelRatio is more than 1
    // renderTarget work only with webgl2

    const effectComposer = new EffectComposer(renderer, renderTarget);
    effectComposer.setPixelRatio(pixelRatio);
    effectComposer.setSize(WIDTH, HEIGHT);

    const renderPass = new RenderPass(scene, camera);
    effectComposer.addPass(renderPass);

    const dotScreenPass = new DotScreenPass();
    dotScreenPass.enabled = false;
    effectComposer.addPass(dotScreenPass);

    const glitchPass = new GlitchPass();
    glitchPass.goWild = true;
    glitchPass.enabled = false;
    effectComposer.addPass(glitchPass);

    const rgbShiftPass = new ShaderPass(RGBShiftShader);
    rgbShiftPass.enabled = false;
    effectComposer.addPass(rgbShiftPass);

    const unrealBloomPass = new UnrealBloomPass(
      new THREE.Vector2(WIDTH, HEIGHT),
      1.5,
      0.8,
      0.2
    );
    unrealBloomPass.enabled = false;
    effectComposer.addPass(unrealBloomPass);

    const gammaCorrectionPass = new ShaderPass(GammaCorrectionShader); // colors comeback (more light)
    effectComposer.addPass(gammaCorrectionPass); // colors comeback (more light)

    // Custom pass
    const tintColorDebug = {
      color: "#ff0000",
    };
    const TintShader: THREE.ShaderMaterial = new THREE.ShaderMaterial({
      uniforms: {
        tDiffuse: { value: null }, // Used to put the previous pass texture
        uTint: { value: new THREE.Color(tintColorDebug.color) },
        uColorAlpha: { value: 0.2 },
        uColorOverride: { value: 0 },
      },
      vertexShader: TintShaderVertex,
      fragmentShader: TintShaderFragment,
    });
    const tintPass = new ShaderPass(TintShader);
    tintPass.enabled = false;
    effectComposer.addPass(tintPass);

    const displacementShader: THREE.ShaderMaterial = new THREE.ShaderMaterial({
      uniforms: {
        tDiffuse: { value: null }, // Used to put the previous pass texture
        uTime: { value: 0 },
        uSpeed: { value: 1 },
        uXAmplitude: { value: 0.3 },
        uYAmplitude: { value: 0.3 },
        uXFrequency: { value: 1 },
        uYFrequency: { value: 1 },
      },
      vertexShader: DisplacementShaderVertex,
      fragmentShader: DisplacementShaderFragment,
    });
    const displacementPass = new ShaderPass(displacementShader);
    displacementPass.enabled = false;
    effectComposer.addPass(displacementPass);

    const futuristicShader: THREE.ShaderMaterial = new THREE.ShaderMaterial({
      uniforms: {
        tDiffuse: { value: null }, // Used to put the previous pass texture
        uNormal: { value: null },
        uNormalStrength: { value: 0.1 },
        uBrightnessStrength: { value: 1.0 },
      },
      vertexShader: FuturisticShaderVertex,
      fragmentShader: FuturisticShaderFragment,
    });
    const futuristicPass = new ShaderPass(futuristicShader);
    futuristicPass.enabled = false;
    futuristicShader.uniforms.uNormal.value = textureLoader.load(
      base + "/post-processing/textures/interfaceNormalMap.png"
    );
    effectComposer.addPass(futuristicPass);

    if (pixelRatio === 1 && !renderer.capabilities.isWebGL2) {
      const smaapass = new SMAAPass(WIDTH, HEIGHT);
      effectComposer.addPass(smaapass);
    }

    // Debug
    gui = new GUI();
    const folderDotScreen = gui.addFolder("Dot Screen");
    folderDotScreen.add(dotScreenPass, "enabled").name("Enable");
    const folderGlitch = gui.addFolder("Glitch");
    folderGlitch.add(glitchPass, "enabled").name("Enable");
    folderGlitch.add(glitchPass, "goWild").name("Wild");
    const folerRGBShift = gui.addFolder("RGB Shift");
    folerRGBShift.add(rgbShiftPass, "enabled").name("Enable");

    const folderUnrealBloom = gui.addFolder("Unreal Bloom");
    folderUnrealBloom.add(unrealBloomPass, "enabled").name("Enable");
    folderUnrealBloom
      .add(unrealBloomPass, "strength", 0, 2, 0.01)
      .name("strength");
    folderUnrealBloom.add(unrealBloomPass, "radius", 0, 2, 0.01).name("radius");
    folderUnrealBloom
      .add(unrealBloomPass, "threshold", 0, 1, 0.01)
      .name("threshold");
    const folerTint = gui.addFolder("Tint");
    folerTint.add(tintPass, "enabled").name("Enable");
    folerTint
      .addColor(tintColorDebug, "color")
      .name("Color")
      .onChange(() => {
        tintPass.material.uniforms.uTint.value.set(tintColorDebug.color);
      });
    folerTint
      .add(tintPass.material.uniforms.uColorAlpha, "value", -1, 1, 0.01)
      .name("Alpha");
    folerTint
      .add(tintPass.material.uniforms.uColorOverride, "value", 0, 1, 0.01)
      .name("Override");
    const folderDisplacement = gui.addFolder("Displacement");
    folderDisplacement
      .add(displacementPass, "enabled")
      .name("Enable");
    folderDisplacement
      .add(displacementPass.material.uniforms.uSpeed, "value", 0, 3, 0.01)
      .name("Speed");
    folderDisplacement
      .add(displacementPass.material.uniforms.uXAmplitude, "value", 0, 2, 0.01)
      .name("X Amplitude");
    folderDisplacement
      .add(displacementPass.material.uniforms.uYAmplitude, "value", 0, 2, 0.01)
      .name("Y Amplitude");
    folderDisplacement
      .add(displacementPass.material.uniforms.uXFrequency, "value", 0, 10, 0.01)
      .name("X Frequency");
    folderDisplacement
      .add(displacementPass.material.uniforms.uYFrequency, "value", 0, 10, 0.01)
      .name("Y Frequency");
    const folderFuturistic = gui.addFolder("Futuristic");
    folderFuturistic
      .add(futuristicPass, "enabled")
      .name("Enable");
    folderFuturistic
      .add(
        futuristicPass.material.uniforms.uNormalStrength,
        "value",
        0,
        1,
        0.01
      )
      .name("Strength");
    folderFuturistic
      .add(
        futuristicPass.material.uniforms.uBrightnessStrength,
        "value",
        0,
        3,
        0.01
      )
      .name("brightness");

    // Clock
    const clock = new THREE.Clock();

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();

      // Update pass
      displacementPass.material.uniforms.uTime.value = elapsedTime;

      controls.update();
      // renderer.render(scene, camera);
      effectComposer.render();
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
