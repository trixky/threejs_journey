<!-- ================================================= SCRIPT -->
<script lang="ts">
  const NUMBER_OF_LESSONS = 67;
  const lessons: number[] = new Array(NUMBER_OF_LESSONS)
    .fill(0)
    .map((_, i) => i + 1);
  const skiped_lessons: number[] = [1, 2];
  const finished_lessons: number[] = [3, 4];
</script>

<!-- ================================================= CONTENT -->
<header class="text-center my-10 select-none flex flex-col items-center gap-8">
  <h1>Three.js Journey Course</h1>
  <p class="max-w-96">
    This is my personal implementations of each lessons from the Three.js
    Journey course by Bruno Simon.
  </p>
  <!-- <div>
    <button>&lt;&nbsp;prev</button>
    <button>see all</button>
    <button>next&nbsp;&gt;</button>
  </div> -->
  <nav>
    <ol>
      {#each lessons as lesson}
        {@const skiped = skiped_lessons.includes(lesson)}
        {@const finished = finished_lessons.includes(lesson)}
        {@const content = lesson.toString().padStart(2, "0")}
        <li class:disabled={skiped} class:finished>
          {#if finished}
            <a href={`/lessons/${lesson}`}><p>{content}</p></a>
          {:else}
            <p>{content}</p>
          {/if}
        </li>
      {/each}
    </ol>
  </nav>
</header>

<!-- ================================================= CSS -->
<style lang="postcss">
  /* ol is a grid of 10 column */
  ol {
    @apply gap-x-3 gap-y-2 w-fit;
    display: grid;
    grid-template-columns: repeat(10, 1fr);
    padding: 0;
    margin: 0;
    list-style-type: none;
  }

  li {
    @apply border border-solid px-1 bg-neutral-100 transition-colors duration-200 w-9 h-9 flex items-center justify-center;
  }

  li.disabled {
    @apply invisible;
  }

  li.finished {
    @apply bg-green-200 hover:bg-green-300;
  }

  li:not(.finished) {
    @apply cursor-not-allowed;
  }
</style>
