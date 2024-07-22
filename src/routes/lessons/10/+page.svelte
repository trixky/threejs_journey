<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Texture // NEW
    // Texture color = albedo // NEW
    // Texture alpha = opacity (white = visible / black = invisible) // NEW
    // Texture height = displacement (white = up, black = down, perfect grey = normal) // NEW
    // ^ move the vertex up or down // NEW
    // Texture normal = light reflection // NEW
    // Texture ambient occlusion = shadow // NEW
    // Texture metalness = metalness (reflection) // NEW
    // Texture roughness = roughness (reflection: white = rough / black = smooth,normal perfect reflection) // NEW
    // ^ light dissipation (present when metalness it's most of the time)// NEW
    // PBR = Physically Based Rendering // NEW
    // https://3dtextures.me/2019/04/16/door-wood-001/

    // const image = new Image(); // NEW
    // const texture = new THREE.Texture(image); // NEW
    // texture.colorSpace = THREE.SRGBColorSpace // NEW Don't forget to set the color space to sRGB

    // image.onload = () => {
    //   // NEW
    //   console.log("image loaded"); // NEW
    //   texture.needsUpdate = true; // NEW
    //   console.log(texture); // NEW
    // };
    // image.src = `${base}/door_wood/Door_Wood_001_basecolor.jpg`; // NEW

    const loadingManager = new THREE.LoadingManager(); // NEW

    loadingManager.onStart = () => { // NEW
      console.log('manager > start'); // NEW
    }; // NEW
    loadingManager.onProgress = () => { // NEW
      console.log('manager > progress'); // NEW
    }; // NEW
    loadingManager.onError = () => { // NEW
      console.log('manager > error'); // NEW
    }; // NEW

    const textureLoader = new THREE.TextureLoader(loadingManager); // NEW
    const colorTexture = textureLoader.load(
      `${base}/door_wood/color.jpg`,
      () => {console.log('load')},
      () => {console.log('progress')},
      () => {console.log('error')}
    ); // NEW
    colorTexture.colorSpace = THREE.SRGBColorSpace // NEW Don't forget to set the color space to sRGB
    const alphaTexture = textureLoader.load(`${base}/door_wood/alpha.jpg`); // NEW
    const heightTexture = textureLoader.load(`${base}/door_wood/height.png`); // NEW
    // normal texture need to be in png to avoid artefact from compression // NEW
    const normalTexture = textureLoader.load(`${base}/door_wood/normal.jpg`); // NEW
    const ambientTexture = textureLoader.load(`${base}/door_wood/ambient.jpg`); // NEW
    const metalnessTexture = textureLoader.load(`${base}/door_wood/metalness.jpg`); // NEW
    const roughnessTexture = textureLoader.load(`${base}/door_wood/roughness.jpg`); // NEW

    // UV unwrapping // NEW
    // colorTexture.repeat.x = 2; // NEW
    // colorTexture.repeat.y = 3; // NEW
    // colorTexture.wrapS = THREE.MirroredRepeatWrapping; // NEW
    // colorTexture.wrapS = THREE.RepeatWrapping; // NEW
    // colorTexture.wrapT = THREE.RepeatWrapping; // NEW

    // colorTexture.offset.x = 0.5; // NEW

    // colorTexture.rotation = Math.PI / 4; // NEW
    // colorTexture.center.x = 0.5; // NEW
    // colorTexture.center.y = 0.5; // NEW

    // Blur // NEW
    // minFilter // NEW
    // NearestFilter have better performance because no mip mapping is required // NEW
    // colorTexture.generateMipmaps = false; // NEW
    // colorTexture.minFilter = THREE.NearestFilter; // NEW
    // colorTexture.minFilter = THREE.LinearFilter; // NEW
    // ...
    // magFilter // NEW
    // colorTexture.magFilter = THREE.NearestFilter; // NEW

    // Object
    const geometry = new THREE.BoxGeometry(1, 1, 1);
    const material = new THREE.MeshBasicMaterial({ map: colorTexture });
    const mech = new THREE.Mesh(geometry, material);
    scene.add(mech);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    scene.add(camera);
    camera.position.z = 2;
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
      mech.rotation.y = (elapsedTime * Math.PI) / 8;
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
