# K2-Dent Design Patterns & Component Reference

## Quick Visual Reference for Case Management UI

### Color System
```css
/* Primary Actions */
--primary: #0066FF;           /* Main blue - buttons, highlights */
--primary-dark: #0052CC;      /* Hover state for primary */

/* States & Feedback */
--secondary: #00C896;         /* Success, positive, completed */
--danger: #FF3B30;            /* Alerts, errors, urgent */
--warning: #FF9500;           /* Caution, pending review */
--success: #34C759;           /* Confirmations */
--purple: #8B5CF6;            /* Premium/AI features */

/* Backgrounds */
--bg-main: #0A0E1A;           /* Page background (dark) */
--bg-card: #141B2D;           /* Card/component background */
--bg-hover: #1E2740;          /* Hover state background */
--border: #2A3347;            /* Subtle borders */

/* Text */
--text-primary: #FFFFFF;      /* Main text (dark mode) */
--text-secondary: #8B92A8;    /* Muted text, labels */

/* Shadows */
--shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
```

### Layout Grid
```
Desktop: Grid 280px (sidebar) + 1fr (main)
Tablet:  Single column, collapsible sidebar
Mobile:  100% width, bottom navigation
```

### Card Component
```css
.card {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 16-20px;
  padding: 24-32px;
  
  /* Hover effect */
  transition: all 0.3s;
  &:hover {
    border-color: var(--primary);
    transform: translateY(-2px);
    box-shadow: 0 12px 40px rgba(0, 102, 255, 0.2);
  }
}
```

### Button States
```
Primary:    bg: #0066FF,    color: white,   size: 14px
Secondary:  bg: transparent, border: 1px #0066FF
Success:    bg: #34C759,    color: white
Danger:     bg: #FF3B30,    color: white
Disabled:   opacity: 0.5,   cursor: not-allowed
```

### Typography
```css
Font Family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Inter'

H1: 28px, weight 700, line-height 1.1
H2: 24px, weight 700, line-height 1.2
H3: 20px, weight 600, line-height 1.3
Body: 14px, weight 500, line-height 1.6
Label: 12px, weight 600, text-transform: uppercase
```

### Status Badge Styles
```
Status       | Color  | Icon | Meaning
─────────────┼────────┼──────┼─────────────────────
Healthy      | Green  | 🟢   | No issues
Active       | Blue   | 🔵   | In progress
Pending      | Orange | 🟡   | Awaiting action
Completed    | Green  | ✓    | Finished
Critical     | Red    | 🔴   | Urgent attention
AI-Powered   | Purple | ⚡   | ML-generated
```

### Spacing System
```
xs: 4px      (tight spacing)
sm: 8px      (compact)
md: 12px     (default)
lg: 16px     (standard)
xl: 24px     (section spacing)
xxl: 32px    (major sections)
```

### Responsive Breakpoints
```
Mobile:  < 768px   (single column, full-width)
Tablet:  768-1024px (2 column, flexible)
Desktop: > 1024px   (full layout, 3+ columns)
```

---

## Component Examples for Case Management

### Patient Header Card Component
```html
<div class="patient-header-card">
  <div class="patient-avatar-large">👤</div>
  <div class="patient-info">
    <h2>Patient Name</h2>
    <div class="patient-meta">
      DOB: 15/03/1979 | Age: 45 | ID: #12345
    </div>
    <div class="patient-status">
      Last Visit: 2 days ago
      Next Appt: Jun 28, 2024
      <span class="badge badge-warning">⚠️ Overdue</span>
    </div>
  </div>
  <div class="patient-alerts">
    <div class="alert allergy">🚫 Penicillin Allergy</div>
    <div class="alert risk">⚠️ High Risk Patient</div>
  </div>
</div>
```

### Case Overview Widget
```html
<div class="case-overview card">
  <div class="card-header">
    <h3>🎯 Active Case #CASE-2024-001</h3>
    <span class="badge badge-primary">In Progress</span>
  </div>
  
  <div class="progress-bar">
    <div class="progress-fill" style="width: 60%"></div>
    <span class="progress-text">60% Complete</span>
  </div>
  
  <div class="case-meta">
    <span>Started: May 15, 2024</span>
    <span>Est. End: Aug 15, 2024</span>
  </div>
  
  <div class="case-details">
    <p><strong>Chief Complaint:</strong> Smile makeover</p>
    <p><strong>Diagnosis:</strong> 5 cavities, gum inflammation</p>
  </div>
</div>
```

### Timeline Event Component
```html
<div class="timeline-event">
  <div class="event-time">14:30</div>
  <div class="event-marker" style="background: var(--primary)"></div>
  <div class="event-content">
    <h4>Root Canal Treatment</h4>
    <p class="event-details">
      Tooth #16 | Dr. Smith | Clinic 1
    </p>
    <span class="event-status badge badge-primary">Active</span>
  </div>
</div>
```

### Modular Widget Component
```html
<div class="widget card" data-widget="periodontal">
  <div class="widget-header">
    <h4>📊 Periodontal Status</h4>
    <button class="widget-expand">↕️</button>
  </div>
  
  <div class="widget-content">
    <div class="stat-line">
      <span class="stat-label">AAP Classification:</span>
      <span class="stat-value">Stage 2, Grade B</span>
    </div>
    <div class="stat-line">
      <span class="stat-label">BOP:</span>
      <span class="stat-value">35%</span>
    </div>
    <div class="stat-line">
      <span class="stat-label">Trending:</span>
      <span class="stat-value">↗ Improving</span>
    </div>
  </div>
</div>
```

### AI Insights Widget
```html
<div class="widget card widget-ai">
  <div class="widget-header">
    <h4>⚡ AI Recommendations</h4>
  </div>
  
  <div class="widget-content">
    <div class="insight-item">
      <span class="confidence">94%</span>
      <p>
        Schedule prophylaxis in 2 weeks for follow-up.
        Patient showing good healing patterns.
      </p>
    </div>
    <div class="insight-item">
      <span class="confidence">87%</span>
      <p>
        Consider sealant on #3, #4 based on cavity pattern
        and patient age group statistics.
      </p>
    </div>
  </div>
</div>
```

### Quick Actions Sidebar
```html
<div class="quick-actions-sidebar">
  <h3>🚀 Quick Actions</h3>
  
  <div class="action-buttons">
    <button class="btn btn-primary">
      ⏰ Schedule Appointment
    </button>
    <button class="btn btn-secondary">
      📝 Add Note
    </button>
    <button class="btn btn-secondary">
      💊 Prescribe
    </button>
    <button class="btn btn-secondary">
      💬 Send Message
    </button>
  </div>
  
  <hr />
  
  <div class="case-stats">
    <h4>📊 Statistics</h4>
    <div class="stat">
      <span>Total Visits</span>
      <strong>8</strong>
    </div>
    <div class="stat">
      <span>Total Cost</span>
      <strong>€1,240</strong>
    </div>
  </div>
</div>
```

### Dental Chart Mini Component
```html
<div class="dental-chart-mini">
  <div class="quadrant" id="quad1">
    <!-- Quad 1 teeth -->
    <div class="tooth" data-tooth="18" style="background: #34C759">
      18
      <span class="tooth-status">✓</span>
    </div>
    <div class="tooth" data-tooth="17" style="background: #FF9500">
      17
      <span class="tooth-status">🟡</span>
    </div>
    <!-- more teeth -->
  </div>
  
  <div class="tooth-legend">
    🟢 Healthy | 🟡 Treated | 🔴 Cavity | 🟣 Root Canal | ⚫ Implant
  </div>
</div>
```

---

## Animation & Transition Guidelines

### Standard Transitions
```css
/* Quick interactions */
transition: all 0.2s ease;

/* Smooth movements */
transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);

/* Lazy animations (modals, sidebars) */
transition: all 0.3s ease-out;
```

### Hover Effects
```css
/* Lift effect */
&:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 40px rgba(0, 102, 255, 0.2);
}

/* Highlight effect */
&:hover {
  background: var(--bg-hover);
  border-color: var(--primary);
}

/* Scale effect */
&:hover {
  transform: scale(1.02);
}
```

### Status Change Animations
```css
/* Checkmark animation */
@keyframes checkmark {
  0% { transform: scale(0); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

/* Status dot pulse */
@keyframes pulse-dot {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
.status-dot.critical {
  animation: pulse-dot 1.5s infinite;
}
```

---

## Responsive Design Patterns

### Desktop Layout (3-column)
```
[Sidebar 280px] | [Patient List 22%] | [Case Detail 50%] | [Timeline 28%]
```

### Tablet Layout (2-column)
```
[Sidebar collapsible] | [Patient List 30%] | [Case Detail 70%]
Timeline in expandable drawer
```

### Mobile Layout (1-column)
```
[Top Navigation Bar]
[Content Area - Tabs]
  - [Overview] - key info + actions
  - [Timeline] - event history
  - [Details] - full clinical data
  - [Medical] - prescriptions, notes

[Bottom Action Bar - Quick access]
```

---

## Dark Mode Implementation
```css
:root {
  /* Dark theme (default) */
  --bg-main: #0A0E1A;
  --bg-card: #141B2D;
  --text-primary: #FFFFFF;
}

[data-theme="light"] {
  --bg-main: #F5F7FA;
  --bg-card: #FFFFFF;
  --text-primary: #1A1D29;
  --text-secondary: #6B7280;
  --border: #E5E7EB;
}
```

---

## Accessibility Checklist
- [ ] All buttons have 44x44px minimum touch target
- [ ] Color not used alone to convey status (also use icons/text)
- [ ] Keyboard navigation works throughout (Tab, Enter, Escape)
- [ ] Focus indicators visible on all interactive elements
- [ ] Alt text on all images and icons
- [ ] WCAG AA contrast ratio (4.5:1 for text)
- [ ] Screen reader support (semantic HTML)
- [ ] Tooltips on hover for truncated text

---

## Performance Targets
- Initial load: < 2s on 4G
- Time to interactive: < 3s
- Largest Contentful Paint: < 2.5s
- JS bundle size: < 500KB (for case module)
- API response time: < 200ms
- Animation frame rate: 60fps (no jank)

