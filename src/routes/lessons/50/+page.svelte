<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { browser } from "$app/environment";
  import { base } from "$app/paths";
  import { onMount } from "svelte";
  import * as THREE from "three";
  import { OrbitControls } from "three/addons/controls/OrbitControls.js";

  let canvas: any = null;

  const WIDTH = 800;
  const HEIGHT = 600;

</script>

<!-- ================================================= CONTENT -->
<img src={base + "/blender/49/baked_result_2.jpg"} alt="blender portal img" width={WIDTH}>

<!-- ================================================= CSS -->
<style lang="postcss">
</style>
