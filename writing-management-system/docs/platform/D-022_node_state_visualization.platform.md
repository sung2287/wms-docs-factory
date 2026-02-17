# D-022: Node State Visualization Platform Design

## 1. Icon & Style Implementation
- **EMPTY:** `lucide-circle` (Outline), Color: `slate-400`.
- **COMPLETED:** `lucide-check-circle-2` (Filled), Color: `green-600`.
- **REVIEW_REQUIRED:** `lucide-alert-triangle`, Color: `amber-500`.
- **DIRTY:** `lucide-pencil` (Small overlay) or `*` suffix.

## 2. Reactive Store Integration
- The platform should use a reactive state management system (e.g., MobX, Redux, or Vue Reactivity).
- **Memoization:** The `VisualStatus` should be derived via a selector to prevent unnecessary DOM updates.

## 3. High-Density Tree Performance
- For trees with >500 nodes, the status icons must be rendered using SVG paths directly or a font-icon system to minimize memory footprint.
- Lazy-rendering (Virtual Scroll) should be used in the Tree Explorer to handle nodes that are out of the viewport.

## 4. Accessibility
- All icons must include `aria-label` or `title` tags (e.g., `<svg aria-label="Review Required" ...>`).
- Color-blind friendly palettes must be used (e.g., combining icons with colors).
