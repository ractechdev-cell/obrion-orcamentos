---
name: Safety Industrial
colors:
  surface: '#faf9f7'
  surface-dim: '#dadad8'
  surface-bright: '#faf9f7'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f1'
  surface-container: '#efeeec'
  surface-container-high: '#e9e8e6'
  surface-container-highest: '#e3e2e0'
  on-surface: '#1a1c1b'
  on-surface-variant: '#554337'
  inverse-surface: '#2f3130'
  inverse-on-surface: '#f1f1ef'
  outline: '#887365'
  outline-variant: '#dbc2b1'
  surface-tint: '#924c00'
  primary: '#8f4a00'
  on-primary: '#ffffff'
  primary-container: '#b35e00'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb780'
  secondary: '#1b6d24'
  on-secondary: '#ffffff'
  secondary-container: '#a0f399'
  on-secondary-container: '#217128'
  tertiary: '#5a5c5e'
  on-tertiary: '#ffffff'
  tertiary-container: '#737577'
  on-tertiary-container: '#fcfcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdcc4'
  primary-fixed-dim: '#ffb780'
  on-primary-fixed: '#2f1400'
  on-primary-fixed-variant: '#6f3800'
  secondary-fixed: '#a3f69c'
  secondary-fixed-dim: '#88d982'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005312'
  tertiary-fixed: '#e2e2e5'
  tertiary-fixed-dim: '#c6c6c9'
  on-tertiary-fixed: '#1a1c1e'
  on-tertiary-fixed-variant: '#454749'
  background: '#faf9f7'
  on-background: '#1a1c1b'
  surface-variant: '#e3e2e0'
  safety-amber: '#C2680A'
  success-green: '#2E7D32'
  warning-orange: '#ED6C02'
  error-red: '#D32F2F'
  surface-outline: '#C4C7C5'
typography:
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-sm:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  title-lg:
    fontFamily: Hanken Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  headline-md-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  touch-target: 48px
---

## Brand & Style

The design system is engineered for **Obrion Orçamentos**, targeting solo service providers like masons, electricians, and painters. The brand personality is **pragmatic, rugged, and reliable**. It prioritizes utility over decoration, ensuring that the interface remains fully functional in high-glare environments (construction sites) where users may have limited dexterity or focus.

The chosen design style is **Corporate / Modern** with a lean toward **High-Contrast**. It utilizes a "Utility-First" approach, characterized by generous touch targets, clear containment, and an absence of complex shadows that might wash out under direct sunlight. The visual language conveys professionalism and industrial durability.

## Colors

This design system is **strictly Light Mode**. The color palette is optimized for maximum legibility under outdoor lighting conditions.

- **Primary (Safety Amber):** Used for critical actions, brand identity, and active states. It provides high visibility without causing eye fatigue.
- **Secondary (Success Green):** Reserved for positive financial indicators (profits), "Accepted" statuses, and completion confirmations.
- **Tertiary/Neutral:** We use a near-black for high-contrast text and a warm-tinted off-white for backgrounds to reduce glare while maintaining a clean "professional paper" feel.
- **Semantic Colors:** Warning and Error hues are saturated and distinct to ensure alerts are noticed immediately.

## Typography

We use **Hanken Grotesk** for its exceptional clarity and modern, industrial feel. The weight distribution is intentional:
- **Headlines are Bold (700):** Ensures immediate information hierarchy even at a glance.
- **Titles are SemiBold (600):** Distinguishes UI headers and card titles from body content.
- **Body is Regular (400):** Maintains high legibility for long descriptions and line items.

On mobile devices, headlines scale down slightly to prevent awkward text wrapping in narrow columns.

## Layout & Spacing

The layout follows a **fluid grid** model with a focus on single-column efficiency for mobile use. 

- **Standard Margin:** 16px (md) for side gutters on mobile.
- **Grid Strategy:** Summary metrics use a 2-column grid with 8px (sm) gaps. Main lists use a 1-column layout to allow for full-width readability of service descriptions.
- **Touch Targets:** A strict minimum of 48px is maintained for all interactive elements to accommodate users with gloves or "dirty hands" typical of the trade.
- **Rhythm:** Vertical spacing between cards or major sections is set to 24px (lg) to provide clear visual separation.

## Elevation & Depth

This system intentionally avoids complex shadows and ambient blurs which can disappear or look like smudges in bright sunlight.

- **Outlined Containment:** Hierarchy is established through high-contrast borders and tonal differentiation.
- **Tonal Layers:** The app uses `surfaceContainerLow` (light gray/amber tint) to define section backgrounds, while primary content sits on pure `#FFFFFF` surfaces.
- **Zero Elevation:** Cards and inputs do not use shadows. Instead, a 1px solid border (`surface-outline`) provides the necessary definition.

## Shapes

The shape language balances modern aesthetics with a structured, sturdy feel.
- **Cards:** Use a 12px radius (`rounded-lg`) to soften the interface while maintaining a professional containment box.
- **Buttons:** Use an 8px radius. This sharper corner compared to cards gives buttons a more "tool-like" and functional appearance.
- **Inputs:** Use an 8px radius to match buttons, creating a cohesive form-entry experience.
- **Status Pills:** Badges and chips remain fully rounded (pill-shaped) to distinguish them clearly from interactive buttons.

## Components

### Buttons
- **Primary:** Solid `#C2680A` background with white text. Height must be exactly 48px for reachability.
- **Outlined:** 1px border using the primary color. Used for secondary actions (e.g., "Cancel", "Save Draft").

### Cards
- **Style:** Outlined. 1px border using `#C4C7C5`. 
- **Padding:** Internal padding of 16px (md) for content.

### Input Fields
- **Style:** Filled. Background is a subtle tint of the primary color or a light gray.
- **Borders:** No borders. A thick 2px indicator bar at the bottom appears only on focus.
- **Height:** 56px minimum to ensure the touch area is generous for data entry.

### Lists & Chips
- **List Items:** Separated by 8px (sm) gaps.
- **Status Chips:** Use secondary (Success) or semantic colors with low-opacity backgrounds and high-saturation text for readability (e.g., Green text on Light Green background).

### Additional Components
- **Step Wizard:** A simplified progress bar at the top of the screen for the 4-step quoting process.
- **Bottom Sheets:** Used for quick-add actions, with a 28px top radius and a prominent drag handle.