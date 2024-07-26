<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";
  import CANNON from "cannon"; // new version: use import * as CANNON from 'cannon-es';
  // ammo.js is best for web
  import GUI from "lil-gui";
  import { base } from "$app/paths";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;
  const RATIO = WIDTH / HEIGHT;

  function start() {
    const hitSound = new Audio(base + "/sounds/hit.mp3");
    const playHitSound = (collision: any) => {
      const impactStrength = collision.contact.getImpactVelocityAlongNormal();
      if (impactStrength > 1.5) {
        hitSound.currentTime = 0;
        hitSound.play();
      }
    };

    // Scene
    const scene = new THREE.Scene();

    // Physics
    const world = new CANNON.World();
    world.gravity.set(0, -9.82, 0); // NEW
    // Optimization:
    world.allowSleep = true; // NEW
    world.broadphase = new CANNON.SAPBroadphase(world); //  NEW
    // - NaiveBroadphase: default, test all objects with all objects
    // - GridBroadphase: use a grid to optimize the test
    // - SAPBroadphase: best optimization

    // *** materials
    // const concreteMaterial = new CANNON.Material("concrete");
    // const plasticMaterial = new CANNON.Material("plastic");

    // const contactConcretPlastic = new CANNON.ContactMaterial(
    //   concreteMaterial,
    //   plasticMaterial,
    //   {
    //     friction: 0.1,
    //     restitution: 0.7,
    //   }
    // );
    // world.addContactMaterial(contactConcretPlastic);
    const defaultMaterial = new CANNON.Material("default");
    const contactDefault = new CANNON.ContactMaterial(
      defaultMaterial,
      defaultMaterial,
      {
        friction: 0.1,
        restitution: 0.7,
      }
    );
    world.addContactMaterial(contactDefault);
    world.defaultContactMaterial = contactDefault; // NEW default material

    // --- sphere
    // const sphereShape = new CANNON.Sphere(0.5);
    // const sphereBody = new CANNON.Body({
    //   mass: 1,
    //   position: new CANNON.Vec3(0, 3, 0),
    //   shape: sphereShape,
    //   // material: plasticMaterial,
    //   // material: defaultMaterial
    // });
    // world.addBody(sphereBody);
    // sphereBody.applyLocalForce(
    //   new CANNON.Vec3(150, 0, 0),
    //   new CANNON.Vec3(0, 0, 0)
    // );

    // --- plan
    // plane is infinite
    const planShape = new CANNON.Plane();
    const planBody = new CANNON.Body();
    planBody.mass = 0; // mass == 0 makes the body static
    // ^^ 0 by default, but let's be explicit
    planBody.addShape(planShape);
    planBody.quaternion.setFromAxisAngle(
      new CANNON.Vec3(1, 0, 0),
      -Math.PI / 2
    );
    // planBody.material = concreteMaterial;
    // planBody.material = defaultMaterial;
    world.addBody(planBody);

    // Objects
    // --- plan
    const planMaterial = new THREE.MeshStandardMaterial({
      color: 0xffffff,
      metalness: 0.5,
      roughness: 0.5,
    });
    const plan = new THREE.Mesh(
      new THREE.PlaneGeometry(20, 20, 20, 20),
      planMaterial
    );
    plan.receiveShadow = true;
    plan.rotation.x = -Math.PI / 2;
    scene.add(plan);
    // --- sphere
    // const objectMaterial = new THREE.MeshStandardMaterial({
    //   color: 0xffff00,
    //   metalness: 0.5,
    //   roughness: 0.2,
    // });
    // const sphere = new THREE.Mesh(
    //   new THREE.SphereGeometry(0.5, 32, 32),
    //   objectMaterial
    // );
    // sphere.castShadow = true;
    // sphere.position.y = 0.5;

    // scene.add(sphere, plan);

    const objectSphereGeometry = new THREE.SphereGeometry(1, 32, 32);
    const objectMaterial = new THREE.MeshStandardMaterial({
      color: 0xffff00,
      metalness: 0.5,
      roughness: 0.2,
    });

    const objectsToUpdate: { mesh: THREE.Mesh; body: CANNON.Body }[] = [];
    const createSphere = (radius: number, position: THREE.Vector3) => {
      // Mesh
      const sphere = new THREE.Mesh(
        objectSphereGeometry,
        objectMaterial
      );
      sphere.scale.set(radius, radius, radius);
      sphere.castShadow = true;
      sphere.position.copy(position);
      scene.add(sphere);
      // Cannon
      const sphereShape = new CANNON.Sphere(radius);
      const sphereBody = new CANNON.Body({
        mass: 1,
        position: new CANNON.Vec3(position.x, position.y, position.z),
        shape: sphereShape,
        material: defaultMaterial,
      });
      sphereBody.addEventListener("collide", playHitSound);
      world.addBody(sphereBody);
      objectsToUpdate.push({ mesh: sphere, body: sphereBody });
    };

    createSphere(0.5, new THREE.Vector3(0, 3, 0));
    createSphere(0.5, new THREE.Vector3(0.0001, 1, 0));

    // --- box
    const boxGeometry = new THREE.BoxGeometry(1, 1, 1);

    const createBox = (width: number, height: number, depth: number, position: THREE.Vector3) => {
      // Mesh
      const box = new THREE.Mesh(boxGeometry, objectMaterial);
      box.scale.set(width, height, depth);
      box.castShadow = true;
      box.position.copy(position);
      scene.add(box);
      // Cannon
      const boxShape = new CANNON.Box(new CANNON.Vec3(width / 2, height / 2, depth / 2));
      // Dont forget to divide by 2
      const boxBody = new CANNON.Body({
        mass: 1,
        position: new CANNON.Vec3(position.x, position.y, position.z),
        shape: boxShape,
        material: defaultMaterial,
      });
      boxBody.addEventListener("collide", playHitSound);
      world.addBody(boxBody);
      objectsToUpdate.push({ mesh: box, body: boxBody });
    };

    // Camera
    const camera = new THREE.PerspectiveCamera(75, RATIO, 0.1, 100);

    camera.position.z = 7;
    camera.position.y = 4;
    scene.add(camera);

    // Camera controls
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;

    // Renderer
    const renderer = new THREE.WebGLRenderer({ canvas });
    renderer.shadowMap.enabled = true;
    renderer.setSize(WIDTH, HEIGHT);
    renderer.render(scene, camera);

    // Lights
    const ambientLight = new THREE.AmbientLight(0x00ffff, 0.5);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 8);
    directionalLight.position.set(10, 5, 5);
    directionalLight.castShadow = true;
    scene.add(directionalLight);

    // Debug
    const debugObject = {
      createSphere: () => {
        createSphere(
          Math.random() * 0.5,
          new THREE.Vector3(
            (Math.random() - 0.5) * 3,
            3,
            (Math.random() - 0.5) * 3
          )
        );
      },
      createBox: () => {
        createBox(
          Math.random() * 0.5,
          Math.random() * 0.5,
          Math.random() * 0.5,
          new THREE.Vector3(
            (Math.random() - 0.5) * 3,
            3,
            (Math.random() - 0.5) * 3
          )
        );
      },

      reset: () => {
        for (const object of objectsToUpdate) {
          object.body.removeEventListener("collide", playHitSound);
          world.remove(object.body);
          scene.remove(object.mesh);
        }
        objectsToUpdate.splice(0, objectsToUpdate.length)
      }
    };

    const gui = new GUI();
    gui.add(debugObject, "createSphere");
    gui.add(debugObject, "createBox");
    gui.add(debugObject, "reset");

    // Clock
    const clock = new THREE.Clock();
    let oldElapsedTime = 0;

    // Animation
    const tick = () => {
      const elapsedTime = clock.getElapsedTime();
      const deltaTime = elapsedTime - oldElapsedTime;
      oldElapsedTime = elapsedTime;

      // Physics
      const fps = 1 / 60; // NEW
      world.step(fps, deltaTime, 3); // NEW
      // console.log(sphereBody.position); // NEW
      // sphereBody.applyForce(new CANNON.Vec3(-0.5, 0, 0), sphereBody.position); // NEW

      // sphere.position.copy(sphereBody.position);

      for (const object of objectsToUpdate) {
        object.mesh.position.copy(object.body.position); // position
        object.mesh.quaternion.copy(object.body.quaternion); // rotation
      }

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
