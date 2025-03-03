<script lang="ts">
    let { id = "", disabled = true, value = 0, color = "#000", icon = "mdi:question-mark-box" } = $props();

    import Icon from "@iconify/svelte";
</script>

{#if !disabled}
<main class="h-16 w-16 rounded-md flex justify-center items-center overflow-hidden relative z-0 shadow-lg transition-all" style="background-color: {color}40;">
    <div class="absolute w-full bottom-0 transition-all" style="background-color: {color}; height: {value}%"></div>
    <div class="z-10" class:flash={value <= 10 && value > 0} class:opacity-75={value == 0}>
        <Icon icon={id == "health" && value == 0 ? "mdi:skull" : icon} class="text-4xl text-white" />
    </div>
</main>
{/if}

<style>
    .flash {
        animation: flash 1s infinite ease-in-out;
    }

    @keyframes flash {
        0% {
            opacity: 1;
        }

        50% {
            opacity: 0.75;
        }

        100% {
            opacity: 1;
        }
    }
</style>