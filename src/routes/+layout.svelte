<!-- ================================================= SCRIPT -->
<script lang="ts">
  import "../styles/reset.css";
  import "../styles/tailwind.css";
  import "../styles/main.css";

  import Header from "$lib/components/layout/header.svelte";
  import Footer from "$lib/components/layout/footer.svelte";
</script>

<!-- ================================================= CONTENT -->
<div id="global" class="w-full flex flex-col items-center">
  <Header />
  <main class="mb-auto flex flex-col items-center md:w-[900px] pb-10">
    <slot />
  </main>
  <!-- <Footer /> -->
</div>

<!-- ================================================= CSS -->
<style lang="postcss">
    #global {
        min-height: 100vh;
    }
</style>
