<!-- ================================================= SCRIPT -->
<script lang="ts">
  import { base } from "$app/paths";

  const NUMBER_OF_LESSONS = 67;
  const lessons: number[] = new Array(NUMBER_OF_LESSONS)
    .fill(0)
    .map((_, i) => i + 1);
  const skiped_lessons: number[] = [1, 2, 13, 26];
  const finished_lessons: number[] = [
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
  ];
</script>

<!-- ================================================= CONTENT -->
<header class="text-center my-10 select-none flex flex-col items-center gap-8">
  <h1>Three.js Journey Course</h1>
  <p class="max-w-96 text-neutral-700">
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
        {@const chap2 = lesson >= 14 && lesson <= 19}
        {@const chap3 = lesson >= 20 && lesson <= 26}
        {@const chap4 = lesson >= 27 && lesson <= 44}
        {@const chap5 = lesson >= 45 && lesson <= 48}
        {@const chap6 = lesson >= 49 && lesson <= 53}
        <li
          class:disabled={skiped}
          class:finished
          class:chap2
          class:chap3
          class:chap4
          class:chap5
          class:chap6
        >
          {#if finished}
            <a href={base + `/lessons/${lesson}`}><p>{content}</p></a>
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

  li:not(.finished) {
    @apply opacity-20;
  }

  li.finished {
    @apply bg-green-200 hover:bg-green-300;
  }

  li.chap2.finished {
    @apply bg-blue-200 hover:bg-blue-300;
  }

  li.chap3.finished {
    @apply bg-purple-200 hover:bg-purple-300;
  }

  li.chap4.finished {
    @apply bg-red-200 hover:bg-red-300;
  }

  li.chap5.finished {
    @apply bg-yellow-200 hover:bg-yellow-300;
  }

  li.chap6.finished {
    @apply bg-orange-200 hover:bg-orange-300;
  }

  li:not(.finished) {
    @apply cursor-not-allowed;
  }
</style>
