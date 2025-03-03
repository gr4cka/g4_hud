<script lang="ts">
  import { fade } from 'svelte/transition';
  import { onMount } from 'svelte';

  import StatusBox from "./lib/Status.svelte";
  import Speedometer from "./lib/Speedometer.svelte";

  type Status = {
    disabled: boolean;
    value: number;
    color: string;
    icon: string;
  };

  type Statuses = Record<string, Status>;

  const statuses: Statuses = $state({
    health: {
      disabled: true,
      value: 0,
      color: "#f01647",
      icon: "mdi:heart"
    },
    armour: {
      disabled: true,
      value: 0,
      color: "#4589ef",
      icon: "mdi:shield"
    },
    hunger: {
      disabled: true,
      value: 0,
      color: "#ffb54b",
      icon: "mdi:food-drumstick"
    },
    thirst: {
      disabled: true,
      value: 0,
      color: "#60e3ec",
      icon: "mdi:water"
    },
    energy: {
      disabled: true,
      value: 0,
      color: "#5866de",
      icon: "mdi:lightning-bolt"
    },
    stress: {
      disabled: true,
      value: 0,
      color: "#5866de",
      icon: "mdi:head-snowflake"
    },
  });

  type Vehicle = {
    disabled: boolean;
    value: number;
    unit: string;
    fuel: number;
    color: string;
    icon: string;
  };

  const vehicle: Vehicle = $state({
    disabled: true,
    value: 0,
    unit: "km/h",
    fuel: 0,
    color: "#ffb54b",
    icon: "mdi:fuel-pump"
  });

  let hidden = $state(true);

  onMount(() => {
    // @ts-ignore
    fetch(`https://${GetParentResourceName()}/loaded`, {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json; charset=UTF-8',
      }
    })

    window.addEventListener('message', (e) => {
      let event = e.data.event;
      if (event === 'show') {
        hidden = false;
      } else if (event === 'hide') {
        hidden = true;
      } else if (event === 'updateStatus') {
        let data = e.data.data;
        let inVehicle = false;
        Object.entries(data).forEach(([id, value]: [string, any]) => {
          if (id === 'colors') {
            Object.entries(value).forEach(([key, color]) => {
              statuses[key].color = color as string;
            });
          } else {
            if (statuses[id]) {
              if (statuses[id].disabled) {
                statuses[id].disabled = false;
              }
              statuses[id].value = value;
            }
            if (id === 'vehicle') {
              inVehicle = true;
              if (vehicle.disabled) {
                vehicle.disabled = false;
              }
              if (typeof value === 'object') {
                vehicle.value = value.value || 0;
                vehicle.fuel = value.fuel || 0;
                vehicle.unit = value.unit || 'km/h';
              }
            }
          }
        });
        if (!inVehicle) {
          if (!vehicle.disabled) {
            vehicle.disabled = true;
          }
        }
      }
    });
  });
</script>

{#if !hidden}
<div class="flex gap-4" transition:fade={{ duration: 300 }}>
  {#each Object.entries(statuses).slice(0, Math.ceil(Object.entries(statuses).length / 2)) as [id, status]}
    <StatusBox {id} {...status} />
  {/each}
  {#if !vehicle.disabled}
    <div class="flex gap-4" transition:fade={{ duration: 100 }}>
      <Speedometer value={vehicle.value} unit={vehicle.unit} />
      <StatusBox id="fuel" value={vehicle.fuel} color={vehicle.color} icon={vehicle.icon} disabled={false} />
    </div>
  {/if}
  {#each Object.entries(statuses).slice(Math.ceil(Object.entries(statuses).length / 2)) as [id, status]}
    <StatusBox {id} {...status} />
  {/each}
</div>
{/if}