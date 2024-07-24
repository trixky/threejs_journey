<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import { Timer } from "three/addons/misc/Timer.js";
  import { base } from "$app/paths";
  import { Sky } from "three/addons/objects/Sky.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    // Scene
    const scene = new THREE.Scene();

    // Textures
    // EXRs are large but high quality // NEW
    // JPGs are compressed but lower quality // NEW
    // PNGs are less compressed and less lower quality // NEW
    // Use JPGs for most cases // NEW
    // Use PNGs for normal maps // NEW
    const textureLoader = new THREE.TextureLoader();
    // -------------- floor
    const floorAlphaTexture = textureLoader.load(
      base + "/textures/haunted-house/floor/alpha.jpg"
    );
    const floorColorTexture = textureLoader.load(
      base +
        "/textures/haunted-house/floor/coast_sand_rocks_02_1k/coast_sand_rocks_02_diff_1k.jpg"
    );
    const floorARMTexture = textureLoader.load(
      base +
        "/textures/haunted-house/floor/coast_sand_rocks_02_1k/coast_sand_rocks_02_arm_1k.jpg"
    );
    const floorNormalTexture = textureLoader.load(
      base +
        "/textures/haunted-house/floor/coast_sand_rocks_02_1k/coast_sand_rocks_02_nor_gl_1k.jpg"
    );
    const floorDisplacementTexture = textureLoader.load(
      base +
        "/textures/haunted-house/floor/coast_sand_rocks_02_1k/coast_sand_rocks_02_disp_1k.jpg"
    );

    floorColorTexture.repeat.set(8, 8);
    floorARMTexture.repeat.set(8, 8);
    floorNormalTexture.repeat.set(8, 8);
    floorDisplacementTexture.repeat.set(8, 8);

    floorColorTexture.colorSpace = THREE.SRGBColorSpace; // NEW don't forget to set the color space

    floorColorTexture.wrapS = THREE.RepeatWrapping;
    floorColorTexture.wrapT = THREE.RepeatWrapping;
    floorARMTexture.wrapS = THREE.RepeatWrapping;
    floorARMTexture.wrapT = THREE.RepeatWrapping;
    floorNormalTexture.wrapS = THREE.RepeatWrapping;
    floorNormalTexture.wrapT = THREE.RepeatWrapping;
    floorDisplacementTexture.wrapS = THREE.RepeatWrapping;
    floorDisplacementTexture.wrapT = THREE.RepeatWrapping;

    // -------------- wall
    const wallColorTexture = textureLoader.load(
      base +
        "/textures/haunted-house/wall/castle_brick_broken_06_1k/castle_brick_broken_06_diff_1k.jpg"
    );
    const wallARMTexture = textureLoader.load(
      base +
        "/textures/haunted-house/wall/castle_brick_broken_06_1k/castle_brick_broken_06_arm_1k.jpg"
    );
    const wallNormalTexture = textureLoader.load(
      base +
        "/textures/haunted-house/wall/castle_brick_broken_06_1k/castle_brick_broken_06_nor_gl_1k.jpg"
    );

    wallColorTexture.colorSpace = THREE.SRGBColorSpace; // NEW don't forget to set the color space

    // -------------- bushes
    const bushColorTexture = textureLoader.load(
      base +
        "/textures/haunted-house/bush/leaves_forest_ground_1k/leaves_forest_ground_diff_1k.jpg"
    );
    const bushARMTexture = textureLoader.load(
      base +
        "/textures/haunted-house/bush/leaves_forest_ground_1k/leaves_forest_ground_arm_1k.jpg"
    );
    const bushNormalTexture = textureLoader.load(
      base +
        "/textures/haunted-house/bush/leaves_forest_ground_1k/leaves_forest_ground_nor_gl_1k.jpg"
    );

    bushColorTexture.colorSpace = THREE.SRGBColorSpace;

    bushColorTexture.repeat.set(2, 1);
    bushARMTexture.repeat.set(2, 1);
    bushNormalTexture.repeat.set(2, 1);

    bushColorTexture.wrapS = THREE.RepeatWrapping;
    bushARMTexture.wrapS = THREE.RepeatWrapping;
    bushNormalTexture.wrapS = THREE.RepeatWrapping;

    // -------------- graves
    const graveColorTexture = textureLoader.load(
      base +
        "/textures/haunted-house/grave/plastered_stone_wall_1k/plastered_stone_wall_diff_1k.jpg"
    );
    const graveARMTexture = textureLoader.load(
      base +
        "/textures/haunted-house/grave/plastered_stone_wall_1k/plastered_stone_wall_arm_1k.jpg"
    );
    const graveNormalTexture = textureLoader.load(
      base +
        "/textures/haunted-house/grave/plastered_stone_wall_1k/plastered_stone_wall_nor_gl_1k.jpg"
    );

    graveColorTexture.colorSpace = THREE.SRGBColorSpace;

    graveColorTexture.repeat.set(0.3, 0.4);
    graveARMTexture.repeat.set(0.3, 0.4);
    graveNormalTexture.repeat.set(0.3, 0.4);

    // -------------- door
    const doorColorTexture = textureLoader.load(
      base + "/textures/haunted-house/door/color.jpg"
    );
    const doorAlphaTexture = textureLoader.load(
      base + "/textures/haunted-house/door/alpha.jpg"
    );
    const doorAmbientOcclusionTexture = textureLoader.load(
      base + "/textures/haunted-house/door/ambientOcclusion.jpg"
    );
    const doorHeightTexture = textureLoader.load(
      base + "/textures/haunted-house/door/height.jpg"
    );
    const doorNormalTexture = textureLoader.load(
      base + "/textures/haunted-house/door/normal.jpg"
    );
    const doorMetalnessTexture = textureLoader.load(
      base + "/textures/haunted-house/door/metalness.jpg"
    );
    const doorRoughnessTexture = textureLoader.load(
      base + "/textures/haunted-house/door/roughness.jpg"
    );

    doorColorTexture.colorSpace = THREE.SRGBColorSpace;

    // Objects
    // -------------- roof
    const roofColorTexture = textureLoader.load(
      base +
        "/textures/haunted-house/roof/roof_slates_02_1k/roof_slates_02_diff_1k.jpg"
    );
    const roofARMTexture = textureLoader.load(
      base +
        "/textures/haunted-house/roof/roof_slates_02_1k/roof_slates_02_arm_1k.jpg"
    );
    const roofNormalTexture = textureLoader.load(
      base +
        "/textures/haunted-house/roof/roof_slates_02_1k/roof_slates_02_nor_gl_1k.jpg"
    );

    roofColorTexture.colorSpace = THREE.SRGBColorSpace;

    roofColorTexture.repeat.set(3, 1);
    roofARMTexture.repeat.set(3, 1);
    roofNormalTexture.repeat.set(3, 1);

    roofColorTexture.wrapS = THREE.RepeatWrapping;
    roofARMTexture.wrapS = THREE.RepeatWrapping;
    roofNormalTexture.wrapS = THREE.RepeatWrapping;
    // -------------- floor
    const floor = new THREE.Mesh(
      new THREE.PlaneGeometry(20, 20, 100, 100),
      new THREE.MeshStandardMaterial({
        alphaMap: floorAlphaTexture,
        transparent: true, // Don't forget to set this to true for the alhpaMap
        map: floorColorTexture,
        aoMap: floorARMTexture,
        roughnessMap: floorARMTexture,
        metalnessMap: floorARMTexture,
        normalMap: floorNormalTexture,
        displacementMap: floorDisplacementTexture,
        displacementScale: 0.3,
        displacementBias: -0.2,
      })
    );
    floor.rotation.x = -Math.PI / 2;
    scene.add(floor);
    // -------------- house
    const house = new THREE.Group();
    scene.add(house);
    // **** walls
    const wallsGeometry = new THREE.BoxGeometry(4, 2.5, 4);
    const walls = new THREE.Mesh(
      wallsGeometry,
      new THREE.MeshStandardMaterial({
        map: wallColorTexture,
        aoMap: wallARMTexture,
        roughnessMap: wallARMTexture,
        metalnessMap: wallARMTexture,
        normalMap: wallNormalTexture,
      })
    );
    walls.material.metalness = 0.5;
    walls.position.y = 1.25;
    house.add(walls);
    // **** roof
    const roof = new THREE.Mesh(
      new THREE.ConeGeometry(3.5, 1.5, 4),
      new THREE.MeshStandardMaterial({
        map: roofColorTexture,
        aoMap: roofARMTexture,
        roughnessMap: roofARMTexture,
        metalnessMap: roofARMTexture,
        normalMap: roofNormalTexture,
      })
    );
    roof.position.y = 3.25;
    roof.rotation.y = Math.PI / 4;
    house.add(roof);
    // **** door
    const door = new THREE.Mesh(
      new THREE.PlaneGeometry(2.2, 2.2, 100, 100),
      new THREE.MeshStandardMaterial({
        map: doorColorTexture,
        transparent: true,
        alphaMap: doorAlphaTexture,
        aoMap: doorAmbientOcclusionTexture,
        displacementMap: doorHeightTexture,
        normalMap: doorNormalTexture,
        metalnessMap: doorMetalnessTexture,
        roughnessMap: doorRoughnessTexture,
        displacementScale: 0.15,
        displacementBias: -0.04,
      })
    );
    door.position.y = 1;
    door.position.z = 2.01;
    house.add(door);
    // **** bushes
    const busheGeometry = new THREE.SphereGeometry(1, 16, 16);
    const busheMaterial = new THREE.MeshStandardMaterial({
      color: "#ccffcc",
      map: bushColorTexture,
      aoMap: bushARMTexture,
      roughnessMap: bushARMTexture,
      metalnessMap: bushARMTexture,
      normalMap: bushNormalTexture,
    });
    // bush 1
    const bush1 = new THREE.Mesh(busheGeometry, busheMaterial);
    bush1.scale.set(0.5, 0.5, 0.5);
    bush1.position.set(0.8, 0.2, 2.2);
    bush1.rotation.x = -0.75;
    // bush 2
    const bush2 = new THREE.Mesh(busheGeometry, busheMaterial);
    bush2.scale.set(0.25, 0.25, 0.25);
    bush2.position.set(1.4, 0.1, 2.1);
    bush2.rotation.x = -0.75;
    // bush 3
    const bush3 = new THREE.Mesh(busheGeometry, busheMaterial);
    bush3.scale.set(0.4, 0.4, 0.4);
    bush3.position.set(-0.8, 0.1, 2.2);
    bush3.rotation.x = -0.75;
    // bush 4
    const bush4 = new THREE.Mesh(busheGeometry, busheMaterial);
    bush4.scale.set(0.15, 0.15, 0.15);
    bush4.position.set(-1, 0.05, 2.6);
    bush4.rotation.x = -0.75;
    house.add(bush1, bush2, bush3, bush4);
    // **** graves
    const graveGeometry = new THREE.BoxGeometry(0.6, 0.8, 0.2);
    const graveMaterial = new THREE.MeshStandardMaterial({
      map: graveColorTexture,
      aoMap: graveARMTexture,
      roughnessMap: graveARMTexture,
      metalnessMap: graveARMTexture,
      normalMap: graveNormalTexture,
    });
    const graves = new THREE.Group();
    for (let i = 0; i < 30; i++) {
      const angle = Math.random() * Math.PI * 2;
      const radius = 3 + Math.random() * 4;
      const x = Math.cos(angle) * radius;
      const z = Math.sin(angle) * radius;
      const y = Math.random() * 0.4;
      const xRotation = (Math.random() - 0.5) / 2;
      const yRotation = (Math.random() - 0.5) / 2;
      const zRotation = (Math.random() - 0.5) / 2;

      const grave = new THREE.Mesh(graveGeometry, graveMaterial);
      grave.position.set(x, y, z);
      grave.rotation.x = xRotation;
      grave.rotation.y = yRotation;
      grave.rotation.z = zRotation;
      graves.add(grave);
    }
    scene.add(graves);

    // Lights
    // -------------- ambient light
    const ambientLight = new THREE.AmbientLight(0x86cdff, 0.2);
    scene.add(ambientLight);
    // -------------- directional light
    const directionalLight = new THREE.DirectionalLight(0x86cdff, 0.4);
    directionalLight.position.set(0.5, 0.7, -1);
    scene.add(directionalLight);
    // -------------- door light
    const doorLight = new THREE.PointLight("#ff7d46", 3);
    doorLight.position.set(0, 2.2, 2.5);
    house.add(doorLight);

    // Ghosts (light)
    const ghost1 = new THREE.PointLight("#8800ff", 6);
    const ghost2 = new THREE.PointLight("#ff0088", 6);
    const ghost3 = new THREE.PointLight("#ff0000", 6);
    scene.add(ghost1, ghost2, ghost3);

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);
    camera.position.z = 8;
    camera.position.y = 3;
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Shadows cast and receive
    directionalLight.castShadow = true;
    ghost1.castShadow = true;
    ghost2.castShadow = true;
    ghost3.castShadow = true;

    walls.castShadow = true;
    walls.receiveShadow = true;
    roof.castShadow = true;
    floor.receiveShadow = true;
    graves.children.forEach((grave) => {
      grave.castShadow = true;
      grave.receiveShadow = true;
    });

    directionalLight.shadow.mapSize.width = 256;
    directionalLight.shadow.mapSize.height = 256;
    directionalLight.shadow.camera.top = 8;
    directionalLight.shadow.camera.right = 8;
    directionalLight.shadow.camera.bottom = -8;
    directionalLight.shadow.camera.left = -8;

    ghost1.shadow.mapSize.width = 256;
    ghost1.shadow.mapSize.height = 256;
    ghost2.shadow.mapSize.width = 256;
    ghost2.shadow.mapSize.height = 256;
    ghost3.shadow.mapSize.width = 256;
    ghost3.shadow.mapSize.height = 256;

    // Sky
    const sky = new Sky();
    scene.add(sky);
    sky.material.uniforms["turbidity"].value = 10;
    sky.material.uniforms["rayleigh"].value = 3;
    sky.material.uniforms["mieCoefficient"].value = 0.1;
    sky.material.uniforms["mieDirectionalG"].value = 0.95;
    sky.material.uniforms["sunPosition"].value.set(0.3, -0.038, -0.95);
    sky.scale.set(100, 100, 100)

    // Fog
    scene.fog = new THREE.FogExp2('#04343f', 0.1)

    // Timer // NEW
    // - need to be imported manually
    // - fix some bugs
    // - pause the time when the tab is not active
    // - need to be updated manually
    const timer = new Timer(); // NEW

    // Animation
    const tick = () => {
      timer.update(); // NEW
      const elapsedTime = timer.getElapsed();

      // ghosts
      ghost1.position.x = Math.sin(elapsedTime * 0.5) * 4;
      ghost1.position.z = Math.cos(elapsedTime * 0.5) * 4;
      ghost1.position.y =
        Math.sin(elapsedTime * 0.5) *
        Math.sin(elapsedTime * 2.34) *
        Math.sin(elapsedTime * 3.34);

      ghost2.position.x = Math.cos(elapsedTime * 0.5) * 5;
      ghost2.position.z = Math.sin(elapsedTime * 0.5) * 5;
      ghost2.position.y =
        Math.sin(elapsedTime * 0.6) *
        Math.sin(elapsedTime * 1.34) *
        Math.sin(elapsedTime * 2.34);

      ghost3.position.x = Math.sin(elapsedTime * 0.5) * 6;
      ghost3.position.z = Math.cos(elapsedTime * 0.5) * 6;
      ghost3.position.y =
        Math.sin(elapsedTime * 0.4) *
        Math.sin(elapsedTime * 3.34) *
        Math.sin(elapsedTime * 1.34);

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
