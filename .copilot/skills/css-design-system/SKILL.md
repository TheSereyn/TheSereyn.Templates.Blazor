---
name: "css-design-system"
description: "CSS architecture guidance for Blazor projects: design tokens, CUBE CSS methodology, cascade layers, and Blazor CSS isolation patterns"
---

# CSS Design System

## Overview

This skill teaches AI agents how to make CSS architecture decisions in a Blazor project. It is guidance for the AI — not a deployable CSS framework or library.

The architecture has three pillars:

1. **Design Tokens** — Every design value (colour, spacing, typography, radius, shadow) is a CSS custom property. No hardcoded values anywhere.
2. **CUBE CSS** — Global CSS organised into Composition, Utility, Block, and Exception layers using `@layer`.
3. **Blazor CSS Isolation** — Component-scoped styles in `.razor.css` files that reference global tokens via `var()`.

**Why this architecture:** It solves the "inconsistent panel" problem. When every component reads from shared tokens (`var(--space-md)`, `var(--font-size-body)`, `var(--color-text)`), inconsistent margins, padding, or text sizes become structurally impossible. Scoped styles enforce visual identity per component; tokens enforce consistency across components.

## Design Token Architecture

Design tokens are **non-negotiable**. Every colour, spacing value, font size, border radius, and shadow must be a CSS custom property defined in `_tokens.css`. Components reference tokens via `var(--token-name)` — they never hardcode values.

### Token Naming Convention

Pattern: `--{category}-{variant}`

| Category | Examples |
|----------|----------|
| Colour | `--color-primary`, `--color-surface`, `--color-danger` |
| Spacing | `--space-xs`, `--space-md`, `--space-2xl` |
| Typography | `--font-size-body`, `--font-weight-bold`, `--line-height-tight` |
| Borders & Radii | `--radius-sm`, `--radius-full`, `--border-width` |
| Shadows | `--shadow-sm`, `--shadow-md`, `--shadow-lg` |
| Transitions | `--transition-fast`, `--transition-normal` |

### Colour System

Use `oklch()` for all colour definitions. Use `color-mix()` to derive tints and shades from a base colour:

```css
--color-primary: oklch(55% 0.2 250);
--color-primary-light: color-mix(in oklch, var(--color-primary) 40%, white);
--color-primary-dark: color-mix(in oklch, var(--color-primary) 70%, black);
```

Never define colours using hex, `rgb()`, or `hsl()`.

### Reference Token Set

This is the complete token vocabulary. All tokens are defined on `:root` inside `@layer tokens`:

```css
@layer tokens {
  :root {
    /* Colour — oklch for perceptual uniformity */
    --color-primary: oklch(55% 0.2 250);
    --color-primary-light: color-mix(in oklch, var(--color-primary) 40%, white);
    --color-primary-dark: color-mix(in oklch, var(--color-primary) 70%, black);
    --color-surface: oklch(98% 0 0);
    --color-text: oklch(20% 0 0);
    --color-text-muted: oklch(45% 0 0);
    --color-border: oklch(85% 0 0);
    --color-danger: oklch(55% 0.2 25);
    --color-success: oklch(55% 0.15 145);

    /* Spacing scale */
    --space-3xs: 0.125rem;
    --space-2xs: 0.25rem;
    --space-xs: 0.5rem;
    --space-sm: 0.75rem;
    --space-md: 1rem;
    --space-lg: 1.5rem;
    --space-xl: 2rem;
    --space-2xl: 3rem;
    --space-3xl: 4rem;

    /* Typography */
    --font-family-body: system-ui, -apple-system, sans-serif;
    --font-family-mono: ui-monospace, 'Cascadia Code', 'Fira Code', monospace;
    --font-size-sm: 0.875rem;
    --font-size-body: 1rem;
    --font-size-lg: 1.25rem;
    --font-size-xl: 1.5rem;
    --font-size-2xl: 2rem;
    --font-weight-normal: 400;
    --font-weight-medium: 500;
    --font-weight-bold: 700;
    --line-height-tight: 1.25;
    --line-height-body: 1.6;

    /* Borders & Radii */
    --radius-sm: 0.25rem;
    --radius-md: 0.5rem;
    --radius-lg: 1rem;
    --radius-full: 9999px;
    --border-width: 1px;

    /* Shadows */
    --shadow-sm: 0 1px 2px oklch(0% 0 0 / 0.05);
    --shadow-md: 0 4px 6px oklch(0% 0 0 / 0.1);
    --shadow-lg: 0 10px 15px oklch(0% 0 0 / 0.15);

    /* Transitions */
    --transition-fast: 150ms ease;
    --transition-normal: 250ms ease;
  }
}
```

**Hard rule:** NEVER hardcode any design value. Always use `var(--token-name)`. If a needed token doesn't exist, add it to `_tokens.css` first.

## File Structure

```
wwwroot/
└── css/
    ├── app.css                ← Entry point. Imports all layers in order.
    ├── _tokens.css            ← Design tokens (custom properties on :root)
    ├── _base.css              ← Base element styles (reset, typography, links)
    ├── _compositions.css      ← Layout primitives (stack, cluster, sidebar, grid, center)
    └── _utilities.css         ← Small utility classes (visually-hidden, text-center, flow)

Components/
├── Layout/
│   ├── MainLayout.razor
│   └── MainLayout.razor.css   ← References tokens for app-level layout
├── Shared/
│   ├── NavMenu.razor
│   └── NavMenu.razor.css      ← Scoped component styles
└── Pages/
    ├── Home.razor
    └── Home.razor.css
```

### What goes in each file

| File | Purpose | Content |
|------|---------|---------|
| `app.css` | Entry point | `@layer` declaration and `@import` statements only |
| `_tokens.css` | Design vocabulary | All CSS custom properties on `:root` inside `@layer tokens` |
| `_base.css` | Element defaults | Reset, typography, links, form resets inside `@layer base` |
| `_compositions.css` | Layout primitives | CUBE CSS compositions (`.stack`, `.cluster`, etc.) inside `@layer compositions` |
| `_utilities.css` | Small helpers | Utility classes (`.visually-hidden`, `.flow`, etc.) inside `@layer utilities` |
| `*.razor.css` | Component styles | Scoped styles that reference global tokens via `var()` |

## CSS Cascade Layers (`@layer`)

`@layer` provides explicit specificity ordering. Layers declared first have the **lowest** priority. This eliminates specificity wars — the layer order, not selector specificity, determines which styles win.

### Required Layer Order

```css
@layer tokens, base, compositions, utilities;
```

This guarantees: tokens are overridden by base styles, base by compositions, compositions by utilities. Specificity within a layer works normally, but a higher layer always wins over a lower layer.

### `app.css` Import Pattern

```css
/* Layer order declaration — first has lowest priority */
@layer tokens, base, compositions, utilities;

@import '_tokens.css' layer(tokens);
@import '_base.css' layer(base);
@import '_compositions.css' layer(compositions);
@import '_utilities.css' layer(utilities);
```

**Rule:** Never add styles outside the declared layer order. All global CSS must belong to one of these layers.

## CUBE CSS Methodology

CUBE CSS organises CSS into four categories that map directly to how Blazor applications are structured.

### Composition

Layout primitives that control spatial relationships. These are reusable layout patterns applied via class names. They set up the context in which child elements are displayed.

```css
@layer compositions {
  /* Stack — vertical flow with consistent spacing */
  .stack {
    display: flex;
    flex-direction: column;
    gap: var(--stack-space, var(--space-md));
  }

  /* Cluster — horizontal wrapping group */
  .cluster {
    display: flex;
    flex-wrap: wrap;
    gap: var(--cluster-space, var(--space-sm));
    align-items: center;
  }

  /* Sidebar — content with fixed-width sidebar */
  .with-sidebar {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-lg);

    & > :first-child {
      flex-basis: var(--sidebar-width, 20rem);
      flex-grow: 1;
    }

    & > :last-child {
      flex-basis: 0;
      flex-grow: 999;
      min-inline-size: 50%;
    }
  }

  /* Center — constrain content width */
  .center {
    max-inline-size: var(--center-width, 70rem);
    margin-inline: auto;
    padding-inline: var(--space-md);
  }

  /* Grid — auto-fit responsive grid */
  .auto-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(min(var(--grid-min, 15rem), 100%), 1fr));
    gap: var(--space-md);
  }
}
```

### Utility

Small, single-purpose helper classes for common adjustments. Keep this set small — add a utility only when the pattern appears in 3+ places.

```css
@layer utilities {
  .visually-hidden {
    clip: rect(0 0 0 0);
    clip-path: inset(50%);
    height: 1px;
    overflow: hidden;
    position: absolute;
    white-space: nowrap;
    width: 1px;
  }

  .flow > * + * {
    margin-block-start: var(--flow-space, var(--space-md));
  }

  .text-center { text-align: center; }
  .text-end { text-align: end; }
  .font-bold { font-weight: var(--font-weight-bold); }
  .font-medium { font-weight: var(--font-weight-medium); }
}
```

### Block

Blocks are Razor components with their `.razor.css` scoped styles. Blazor CSS isolation handles scoping automatically — no naming conventions needed. Blocks reference global tokens and compose with layout primitives.

```css
/* Button.razor.css */
button {
  padding: var(--space-xs) var(--space-md);
  font-size: var(--font-size-body);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-sm);
  border: var(--border-width) solid var(--color-border);
  background-color: var(--color-surface);
  color: var(--color-text);
  transition: background-color var(--transition-fast);

  &:hover {
    background-color: color-mix(in oklch, var(--color-primary) 10%, var(--color-surface));
  }
}
```

### Exception

Modifier classes for rare variations of a block. Use data attributes or modifier classes applied to the component's root element:

```css
/* Button.razor.css */
button[data-variant="primary"] {
  background-color: var(--color-primary);
  color: white;
}

button[data-variant="danger"] {
  background-color: var(--color-danger);
  color: white;
}
```

## Blazor CSS Isolation Rules

### Every Component Has a `.razor.css` File

This is required, not optional. Every `.razor` file must have a corresponding `.razor.css` file with its scoped styles.

### How Isolation Works

1. Create `MyComponent.razor.css` alongside `MyComponent.razor`
2. At build time, Blazor rewrites selectors by appending a unique attribute `[b-{hash}]`
3. Styles in the `.razor.css` file only apply to elements rendered by that component
4. All scoped CSS is bundled into `{AssemblyName}.styles.css`

### Scoped Styles Reference Global Tokens

Scoped styles use `var()` to reference design tokens. Never hardcode values in `.razor.css` files:

```css
/* ✅ Correct */
.card { padding: var(--space-md); border-radius: var(--radius-md); }

/* ❌ Wrong */
.card { padding: 16px; border-radius: 8px; }
```

### `::deep` Is a Last Resort

`::deep` pierces isolation to style child component elements. It breaks encapsulation.

**Acceptable uses:**
- Styling third-party component internals that expose no other API
- Styling dynamically rendered HTML (e.g., Markdown output)

**Always prefer:** Passing CSS classes via parameters, using design tokens that cascade naturally, or restructuring the component hierarchy.

### Global Styles Must Not Contain Component-Specific CSS

If a style applies only to one component, it belongs in that component's `.razor.css` file — not in `_base.css`, `_compositions.css`, or `_utilities.css`.

### Token Cascade

CSS custom properties cascade through Blazor isolation boundaries. A token defined on `:root` is available in every `.razor.css` file. This is the mechanism that makes the design system work — tokens flow down the component tree without any special wiring.

## Modern CSS Features Reference

### CSS Nesting

Reduce repetition in `.razor.css` files. Nest related selectors using `&`:

```css
.card {
  padding: var(--space-md);

  & h2 { font-size: var(--font-size-xl); }
  &:hover { box-shadow: var(--shadow-md); }
}
```

**When to use:** Always in `.razor.css` files for related selectors.
**Baseline:** Chrome 120+, Firefox 117+, Safari 17.2+ (Dec 2023).

### Container Queries

Component-responsive design. A component adapts to its container's size, not the viewport. Prefer container queries over media queries for component-level responsiveness.

```css
.card-container {
  container-type: inline-size;
}

@container (width > 400px) {
  .card { grid-template-columns: 1fr 2fr; }
}
```

**When to use:** Any component that must adapt to where it's placed (sidebar, main content, modal).
**Baseline:** Chrome 105+, Firefox 110+, Safari 16+ (Feb 2023).

### `:has()` Selector

Parent-conditional styling without JavaScript. Select a parent based on its contents:

```css
.form-group:has(:invalid) {
  border-color: var(--color-danger);
}

.card:has(img) {
  grid-template-columns: 1fr 2fr;
}
```

**When to use:** Conditional styling that would otherwise require JS to toggle a class on a parent.
**Baseline:** Chrome 105+, Firefox 121+, Safari 15.4+ (Dec 2023).

### Logical Properties

Flow-relative alternatives to physical properties. Always prefer logical properties:

| Physical (avoid) | Logical (use) |
|-------------------|---------------|
| `margin-left` | `margin-inline-start` |
| `margin-right` | `margin-inline-end` |
| `padding-top` | `padding-block-start` |
| `width` | `inline-size` |
| `height` | `block-size` |

```css
.sidebar {
  padding-inline: var(--space-md);
  margin-block-end: var(--space-lg);
  border-inline-end: var(--border-width) solid var(--color-border);
}
```

**When to use:** Always. Use `margin-inline`, `padding-block`, `inline-size`, `block-size` instead of physical counterparts.
**Baseline:** All browsers since 2021.

### `oklch()` / `color-mix()`

Perceptually uniform colour model and colour blending:

```css
/* Define a base colour */
--color-primary: oklch(55% 0.2 250);

/* Derive tints and shades */
--color-primary-light: color-mix(in oklch, var(--color-primary) 40%, white);
--color-primary-dark: color-mix(in oklch, var(--color-primary) 70%, black);
```

**When to use:** All colour definitions use `oklch()`. Use `color-mix()` to generate variants from base colours.
**Baseline:** Chrome 111+, Firefox 113+, Safari 15.4+ (May 2023).

### `@property`

Typed custom properties with default values. Required for animating custom properties:

```css
@property --progress {
  syntax: "<percentage>";
  inherits: false;
  initial-value: 0%;
}

.progress-bar {
  background: linear-gradient(to right, var(--color-primary) var(--progress), transparent var(--progress));
  transition: --progress var(--transition-normal);
}
```

**When to use:** When a custom property needs to be animated or requires type checking.
**Baseline:** Chrome 85+, Firefox 128+, Safari 15.4+ (Jul 2024).

## Dark Theme Pattern

### Token Override Strategy

Dark theme works by overriding token values under a `[data-theme="dark"]` attribute on `:root`:

```css
@layer tokens {
  :root[data-theme="dark"] {
    --color-surface: oklch(15% 0 0);
    --color-text: oklch(90% 0 0);
    --color-text-muted: oklch(65% 0 0);
    --color-border: oklch(30% 0 0);
    --color-primary-light: color-mix(in oklch, var(--color-primary) 30%, white);
    --color-primary-dark: color-mix(in oklch, var(--color-primary) 80%, black);

    --shadow-sm: 0 1px 2px oklch(0% 0 0 / 0.2);
    --shadow-md: 0 4px 6px oklch(0% 0 0 / 0.3);
    --shadow-lg: 0 10px 15px oklch(0% 0 0 / 0.4);
  }
}
```

### Tokens That Change Between Light/Dark

| Token | Light | Dark |
|-------|-------|------|
| `--color-surface` | `oklch(98% 0 0)` | `oklch(15% 0 0)` |
| `--color-text` | `oklch(20% 0 0)` | `oklch(90% 0 0)` |
| `--color-text-muted` | `oklch(45% 0 0)` | `oklch(65% 0 0)` |
| `--color-border` | `oklch(85% 0 0)` | `oklch(30% 0 0)` |
| `--shadow-*` | Low alpha | Higher alpha |

Colour tokens like `--color-primary`, `--color-danger`, and `--color-success` typically remain unchanged — they are designed to work on both light and dark surfaces.

### System Preference as Initial Default

Respect the user's OS-level colour scheme as the initial default using `prefers-color-scheme`:

```css
@layer tokens {
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --color-surface: oklch(15% 0 0);
      --color-text: oklch(90% 0 0);
      --color-text-muted: oklch(65% 0 0);
      --color-border: oklch(30% 0 0);

      --shadow-sm: 0 1px 2px oklch(0% 0 0 / 0.2);
      --shadow-md: 0 4px 6px oklch(0% 0 0 / 0.3);
      --shadow-lg: 0 10px 15px oklch(0% 0 0 / 0.4);
    }
  }
}
```

The `:not([data-theme="light"])` selector ensures the system preference yields to an explicit user choice.

### Toggling via Blazor

Set the `data-theme` attribute on `<html>` via JS interop:

```csharp
// In a Blazor component or service
await JSRuntime.InvokeVoidAsync("document.documentElement.setAttribute", "data-theme", "dark");
```

Store the user's preference in `localStorage` and apply it on page load to prevent flash of incorrect theme.

## Accessibility

### WCAG 2.1 AA — Minimum Baseline

All CSS must meet WCAG 2.1 AA contrast requirements:

| Context | Minimum Contrast Ratio |
|---------|----------------------|
| Normal text (< 18pt / < 14pt bold) | **4.5:1** |
| Large text (≥ 18pt / ≥ 14pt bold) | **3:1** |
| UI components and graphical objects | **3:1** |

Use `oklch()` to achieve predictable contrast. The perceptual uniformity of OKLCH means lightness values directly correlate with visual lightness — a token with `oklch(20% ...)` on a `oklch(98% ...)` background will reliably meet 4.5:1.

### `prefers-reduced-motion`

Every animation or transition must respect the user's motion preference:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    transition-duration: 0.01ms !important;
    animation-duration: 0.01ms !important;
  }
}
```

Place this in `_base.css` inside `@layer base`. This is the one acceptable use of `!important` — it is a user-agent level accessibility override.

### Focus Indicators

Use `:focus-visible` for focus indicators, not `:focus`. This ensures keyboard users see focus rings while mouse users do not:

```css
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

:focus:not(:focus-visible) {
  outline: none;
}
```

## Hard Rules (MUST)

1. Never hardcode any design value — always use `var(--token-name)`.
2. If a needed token doesn't exist, add it to `_tokens.css` first.
3. Component styles go in `.razor.css` files — not in global CSS.
4. Global styles go in the appropriate layer file.
5. Use CSS Grid or Flexbox for all layout — no floats, no positional hacks.
6. Use logical properties (`margin-inline`, `padding-block`) over physical properties.
7. Use `oklch()` for colour definitions, `color-mix()` for tints/shades.
8. Respect `@layer` ordering — never add styles outside declared layers.
9. Every Razor component must have a `.razor.css` file.
10. Maintain WCAG 2.1 AA contrast ratios.

## Anti-Patterns (MUST NOT)

1. Do not import CSS frameworks (Bootstrap, Tailwind, Foundation, etc.).
2. Do not use `!important` (cascade layers eliminate the need — the only exception is `prefers-reduced-motion`).
3. Do not use BEM naming (Blazor CSS isolation handles scoping).
4. Do not use media queries for component-level responsiveness — use container queries.
5. Do not hardcode hex/rgb/hsl colours — use `oklch()` tokens.
6. Do not create inline styles.
7. Do not use `::deep` as a first option.
8. Do not use `@scope` yet (Baseline 2025 — too new; Blazor isolation already handles scoping).
9. Do not use anchor positioning (no Firefox support).

## CSS Code Review Checklist

- [ ] All design values use `var(--token-name)` — no hardcoded values
- [ ] New tokens added to `_tokens.css`, not ad-hoc in component files
- [ ] Component styles are in `.razor.css`, not global CSS
- [ ] `@layer` ordering is maintained
- [ ] Layout uses Grid or Flexbox only
- [ ] Logical properties used (`margin-inline` not `margin-left`)
- [ ] Colours are `oklch()` tokens
- [ ] Component-responsive design uses container queries, not media queries
- [ ] WCAG 2.1 AA contrast maintained
- [ ] `prefers-reduced-motion` respected for any animation/transition
- [ ] No CSS framework imports
- [ ] No `!important`

## References

### CSS Architecture & Methodology

- [CUBE CSS](https://cube.fyi/)
- [CUBE CSS — Andy Bell](https://piccalil.li/blog/cube-css/)
- [ITCSS (Xfive)](https://www.xfive.co/blog/itcss-scalable-maintainable-css-architecture/)
- [W3C Design Tokens Specification](https://www.w3.org/community/design-tokens/2025/10/28/design-tokens-specification-reaches-first-stable-version/)

### MDN References

- [CSS Custom Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)
- [Cascade Layers (`@layer`)](https://developer.mozilla.org/en-US/docs/Web/CSS/@layer)
- [`:has()` Selector](https://developer.mozilla.org/en-US/docs/Web/CSS/:has)
- [Container Queries](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment/Container_queries)
- [Logical Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values)
- [`color-mix()`](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/color-mix)
- [`oklch()`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/oklch)
- [CSS Nesting](https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Nesting)
- [CSS Grid](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_grid_layout)
- [Flexbox](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout)
- [`@scope`](https://developer.mozilla.org/en-US/docs/Web/CSS/@scope)

### Blazor CSS Isolation

- [Microsoft Learn — Blazor CSS Isolation](https://learn.microsoft.com/en-us/aspnet/core/blazor/components/css-isolation?view=aspnetcore-10.0)
- [Clean CSS Architecture for Blazor](https://codingwithdavid.blogspot.com/2025/04/structuring-css-in-blazor-applications.html)
- [Styling Blazor Child Components (::deep)](https://jonathancrozier.com/blog/styling-blazor-child-components-with-css-isolation-what-you-really-need-to-know)

### Learning Resources

- [web.dev Learn CSS](https://web.dev/learn/css)
- [MDN CSS Reference](https://developer.mozilla.org/en-US/docs/Web/CSS)

### Browser Support

- [Can I Use](https://caniuse.com/)
- [Baseline Browser Support](https://web.dev/baseline)
