<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <div class="bg-blue-200">
    <nav class="p-4">
      <RouterLink class="px-4" to="/">Home</RouterLink>
      <RouterLink to="/about">About</RouterLink>
      <RouterLink class="px-4" to="/trade">Trade</RouterLink>
    </nav>
  </div>

  <RouterView />
</template>