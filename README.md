# SimpleShake (Camera Shake Module)

SimpleShake is a lightweight, highly optimized camera shake module for Roblox. It provides preset shake profiles and allows developers to create custom shakes with minimal math. Designed for client use and easy plug and play integration.

<details>
<summary><strong>Features</strong></summary>

- ✅ Preset shake profiles for common scenarios (explosions, footsteps, recoil, etc.)
- ✅ Customizable shake profiles with amplitude, frequency, duration, and fade settings
- ✅ Auto-managed render loop that binds/unbinds depending on active shakes
- ✅ Smooth fade-in and fade-out transitions
- ✅ Simple API for playing/stopping shakes

</details>

<details>
<summary><strong>Installation</strong></summary>

1. Place the `SimpleShake` module folder inside your project (e.g., `ReplicatedStorage` or `StarterPlayerScripts`).
2. Require the module from a LocalScript where you want to use camera shakes.

```lua
local SimpleShake = require(path.to.SimpleShake)
```

</details>

<details>
<summary><strong>Usage</strong></summary>

### Playing a Shake

You can start a shake using a preset name or providing a custom profile.

```lua
-- Using a preset
local shake = SimpleShake.Play("Explosion")

-- Custom profile
local customShake = SimpleShake.Play({
    Amplitude = 2,
    Frequency = 30,
    Duration = 0.5,
    FadeIn = 0.1,
    FadeOut = 0.3,
})

-- Override specific properties
local overriddenShake = SimpleShake.Play("Recoil_Light", {
    Duration = 0.2,
    FadeOut = 0.05,
})
```

Each call returns a `ShakeInstance` you can control further.

### Stopping a Shake

To stop an individual shake with a fade-out:

```lua
overriddenShake:Stop(0.2) -- optional override fade-out time
```

To stop all active shakes immediately:

```lua
SimpleShake.StopAll()
```

</details>

<details>
<summary><strong>Presets</strong></summary>

Built-in presets include:

- `Explosion`
- `Footstep_Heavy`
- `Footstep_Light`
- `Melee_Hit`
- `Earthquake`
- `Heartbeat`
- `Recoil_Light`
- `Recoil_Heavy`
- `Vehicle_Rumble`
- `Landing`

Each preset defines a `ShakeProfile` with `Amplitude`, `Frequency`, `Duration`, `FadeIn`, and `FadeOut` values.

</details>

## API Reference

### `SimpleShake.Play(profile, overrides?)`

- `profile`: `string` preset name or `table` custom profile
- `overrides`: optional table to override profile properties
- **Returns**: `ShakeInstance`

### `SimpleShake.StopAll()`

Immediately begins fade-out for all active shakes.

### `ShakeInstance` methods

- `Stop(fadeOutOverride?)` – begins fade-out for this shake instance

<details>
<summary><strong>Types</strong></summary>

`ShakeProfile`:
```lua
{
    Amplitude: number?,
    Frequency: number?,
    Duration: number?,
    FadeIn: number?,
    FadeOut: number?,
}
```

`PresetName`: one of the preset strings listed above.

`ShakeInstance`: object returned by `Play` containing state and methods.

</details>

<details>
<summary><strong>Notes</strong></summary>

- The module binds to `RunService.RenderStepped` automatically and unbinds when no shakes are active.
- Camera is manipulated directly, so ensure your scripts run on the client.
- The shake math uses Perlin noise for smooth, natural movement.

</details>

<details>
<summary><strong>License</strong></summary>

Feel free to use and modify this module for your own projects. Attribution is appreciated but not required.

</details>

---

Created by `@theonlyflare`
