<script lang="ts">
    let { value = 0, unit = "km/h" } = $props();

    import Icon from "@iconify/svelte";
</script>

<main class="h-16 w-24 rounded-md flex justify-center items-center relative z-0 transition-all">
    <div class="z-10 text-white flex items-center gap-2">
        <div class="flex flex-col items-center">
            <div class="text-4xl font-bold leading-none transition-all" class:opacity-50={value == 0} style="text-shadow: #00000040 0 0 0.2em;">{value}</div>
            <div class="text-sm font-medium opacity-50" style="text-shadow: #00000040 0 0 0.2em;">{unit.toUpperCase()}</div>
        </div>
    </div>
</main>