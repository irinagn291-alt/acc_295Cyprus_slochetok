# Stile — Build Specification

> Portfolio app 200, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Keep OSKAR session ladders and notes for each client on this device.

| Field | Value |
| --- | --- |
| Product name | Stile |
| Bundle identifier | `com.stile.ladder` |
| Domain | https://stile-ladder.pro |
| Contact URL | https://stile-ladder.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `stl_` |
| User-Agent | `Stile/1.0 (iOS; +https://stile-ladder.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Stile -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A solution-focused coach sets the session scale on an OSKAR ladder, harvests know-how and action, and reviews the rung so the visit files on the device.

### 2.1 User flow

1. Unlock the roster with Face ID and tap a client to open today's OSKAR ladder with Outcome already inked.
2. Drag the scale bead to today's 0–10 number and tap Set to lock Know-how and Action.
3. Fill Know-how and Action, then tap Harvest to seat both rungs.
4. Tap Review, choose confidence 1–5, and file the SessionNote as the next blank ladder opens.
5. Open Progress from the ladder chrome to read ReviewMarks and scale trend for that client.
6. Scan a desk QR from the cover sheet to jump straight to a client ladder when the room is ready.

### 2.2 Essential behaviour

- Client roster with Face ID store lock and per-client ladder history
- Vertical OSKAR ladder with Outcome, draggable scale, Know-how, and Action rungs
- Set, Harvest, and Review marks with Rush, Hollow, and Unripe refusal marks
- SessionNote freeze on Review with confidence stamp and Retract on an empty successor ladder
- Progress sheet with ReviewMark timeline and scale sparkline
- Local JSON export from Settings; no account and no network sync

---

## 3. Uniqueness assignment for Stile

| Axis | Assigned value |
| --- | --- |
| Architecture | **OSKAR ADT fold (Open | Scaled | Harvested | Reviewed); the ladder is a fold over Rungs; Set writes a ScaleMark on the chosen 0–10 rung and folds Open to Scaled; Harvest writes a HarvestMark when KnowHow and Action both hold ink and folds Scaled to Harvested; Review writes a ReviewMark, freezes SessionNote, and folds Harvested to Reviewed; Set with empty Outcome writes VoidMark; KnowHow or Action edits before Scaled write RushMark; Review with empty Action writes HollowMark; Review before Harvest writes UnripeMark; Retract peels the last ReviewMark while the successor ladder is empty; a second Set on Scaled is refused; empty ladder writes Bare** |
| UI approach | **SwiftUI Metal shaders · spritekit-accent** |
| Naming convention | **Solution-focused / OSKAR lexicon** |
| File organization | **By ladder role (Ladder, Rung, Outcome, ScaleMark, KnowHow, Action, ReviewMark, Client, RushMark, HollowMark, UnripeMark)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **lingo · cream-band · branded** |
| Typography | **Avenir Next** |
| Navigation pattern | **Ladder-locked chrome (the OSKAR ladder never leaves; Clients, Progress and Settings arrive as sheets; set, harvest and review fuse on Ladder; Face ID gates the roster; no tab bar)** |
| AI art style | **Bauhaus geometric · collage** |
| Functional twist | **Scale-then-harvest (Outcome must hold ink; Set writes ScaleMark before KnowHow and Action unlock; Harvest requires both; Review freezes SessionNote and opens the next ladder; RushMark on pre-Scale lane edits; HollowMark on Review without Action; UnripeMark on Review before Harvest; seed inks Outcome so Set is the first live tap)** |
| Persistence | **UserDefaults+Codable · one Ladder root record holding Clients, Rungs, SessionNotes and Marks, encoded under a single key with debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — session_notes

**Core** — A solution-focused coach sets the session scale on an OSKAR ladder, harvests know-how and action, and reviews the rung so the visit files on the device.

**Audience** — Coaches and therapists who run OSKAR or solution-focused sessions and keep notes off the cloud.

**User flow**

1. Unlock the roster with Face ID and tap a client to open today's OSKAR ladder with Outcome already inked.
2. Drag the scale bead to today's 0–10 number and tap Set to lock Know-how and Action.
3. Fill Know-how and Action, then tap Harvest to seat both rungs.
4. Tap Review, choose confidence 1–5, and file the SessionNote as the next blank ladder opens.
5. Open Progress from the ladder chrome to read ReviewMarks and scale trend for that client.
6. Scan a desk QR from the cover sheet to jump straight to a client ladder when the room is ready.

**Essential features**

- Client roster with Face ID store lock and per-client ladder history
- Vertical OSKAR ladder with Outcome, draggable scale, Know-how, and Action rungs
- Set, Harvest, and Review marks with Rush, Hollow, and Unripe refusal marks
- SessionNote freeze on Review with confidence stamp and Retract on an empty successor ladder
- Progress sheet with ReviewMark timeline and scale sparkline
- Local JSON export from Settings; no account and no network sync

**Twist** — Scale-then-harvest. Home is the open OSKAR ladder for the selected client. Outcome accepts ink in Open. Set writes a ScaleMark on the chosen 0–10 rung and folds Open to Scaled; Know-how and Action stay dim until Scaled. Harvest writes a HarvestMark when both lanes hold text and folds Scaled to Harvested. Review writes a ReviewMark, freezes a SessionNote, stamps confidence from 1 to 5, and opens the next blank ladder. Set with an empty Outcome writes VoidMark. Know-how or Action edits before Scaled write RushMark. Review with empty Action writes HollowMark. Review before Harvest writes UnripeMark. Retract peels the last ReviewMark while the new ladder is still empty. A second Set on Scaled is refused. Seed already inks Outcome so the opening tap is Set. Home verbs: set-the-scale and review-the-ladder, not sign-the-chart or ground-the-reality. Local only.

**Why this is not a repeat** — Paraph files SOAP charts on Sign; Gradus files GROW canvases on Seal after Ground and Options. This app files OSKAR ladders on Review after a mandatory scale Set and a Harvest of know-how plus action, with a draggable 0–10 home mechanic and ladder-locked chrome instead of segments or quadrants.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Split view: clients | note timeline. Face ID gate.
- Invariant: SOAP/GROW/DAP: sections.count must match titles. Mood+progress 1…5. Next-session summary = latest note + days since.
- Never: No ThreadRecall quiz as a product tab. Local only.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

A Ladder is a fold of Open, Scaled, Harvested, or Reviewed over the Rungs of one Client for one daykey, an Int in YYYYMMDD form taken from Calendar.current.startOfDay. Set on Open writes a ScaleMark on the chosen rung from 0 through 10 and folds Open to Scaled. Set with an empty Outcome writes VoidMark and leaves the ladder Open, and a second Set while Scaled is refused. Harvest writes a HarvestMark only when KnowHow and Action both hold text and folds Scaled to Harvested, while a KnowHow or Action edit before Scaled writes RushMark and leaves those lanes dim. Review on Harvested writes a ReviewMark, freezes a SessionNote whose section count equals the titled lanes Outcome, KnowHow, Action, and Review, stamps confidence as an Int from 1 through 5, folds Harvested to Reviewed, and opens the next blank ladder. Review before a HarvestMark writes UnripeMark, Review after Harvest with an empty Action writes HollowMark, Retract peels the last ReviewMark and its frozen SessionNote only while the successor ladder is still empty and restores Harvested, an empty ladder writes Bare, and the next-session line is the latest SessionNote plus the count of days since its daykey.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

The interface is SwiftUI. Custom drawing stays on the Ladder hero alone: a Metal shader paints the vertical rung field and the scale bead, and a SpriteKit accent plays one snap of flat geometric chips on that same surface after a successful Set or Harvest. Clients, Progress, Settings, onboarding, and Scan chrome use stock List, Form, Button, TextField, and sheet. The scan preview is a single UIViewRepresentable around AVCaptureVideoPreviewLayer. A cream band resets the Ladder, then Set, Harvest, and Review sit in one fused row of Buttons, each at least 44 points, with the chrome inside the label and a contentShape on the fill. Primary buttons use one ButtonStyle with default, pressed, disabled, and loading. Retract uses the destructive variant. Press scales to 0.97 for 140 to 180 milliseconds ease-out, sheets scale from 0.96 to 1 and fade, and accessibilityReduceMotion keeps the fade only. The scale bead is adjustable for VoiceOver. The ladder is one vertical mechanic, with status as a noun plus a state, such as Scaled. Know-how can take ink.

### 3.3 Naming contract

Convention: Solution-focused / OSKAR lexicon.

Examples to follow: `Ladder`, `ScaleMark`, `setTheScale(rung:)`, `reviewTheLadder(confidence:)`

### 3.4 Dependency contract

Zero external dependencies. project.yml has no packages key, no CocoaPods, and no vendored source. System frameworks are SwiftUI, Metal, SpriteKit, AVFoundation, LocalAuthentication, UIKit for the capture preview, and Core Graphics. URLSession stays unused, and the assigned cgi search endpoint is unused, because every note stays on this device.

### 3.5 Navigation contract

The OSKAR ladder is the root and it stays on screen. Clients, Progress, and Settings arrive as sheets. Set, Harvest, and Review are fused buttons on the Ladder, not routes. Face ID through LocalAuthentication gates the Clients sheet, with the usage string Stile uses Face ID to open the client roster on this device. Scan is a full-screen cover that dismisses onto the matched client ladder. There is no tab bar. After onboarding, ReviewLaunch reads ProcessInfo arguments once: today shows the Ladder, log shows Progress, goals shows Clients, and the extra keys settings and scan open those screens.

### 3.6 Screen composition contract

Ladder-root fused OSKAR (Ladder holds the vertical rungs, scale bead, and fused set, harvest, and review controls; Clients and Progress arrive as sheets; Settings as a sheet; Scan is a full-screen cover for desk QR client pick; Face ID before roster; no TabView). Physical screens are Onboarding, Ladder, Clients, Progress, Settings, and Scan. Session is the Ladder, and the twist has no screen of its own. Onboarding is three or four pages, Continue or Next is full width at the bottom, and skip still writes defaults and the completion flag. The Simulator seed stl.demo.v1 runs once, marks onboarding complete, and never runs on a device. Ladder fills the phone and the iPad width: cream band, vertical rungs, draggable bead, Outcome ink, Know-how and Action dim until Scaled, and fused Set, Harvest, and Review. The seed opens a used ladder whose Outcome already holds several lines, with Set enabled, plus two earlier reviewed notes so Progress is populated. Clients is a sheet. Before the roster, a full-page empty state shows generated art, the headline "Client records are sealed.", the line "Unlock, then pick a client.", and a full-width Continue button. The system Face ID prompt is the only biometric ask. Denied biometrics explains the state and offers Open Settings. On Simulator the demo seed records the gate as passed so review keys can show the roster. Progress is a sheet of ReviewMarks and a SwiftUI scale sparkline, with its own full-page empty state. Settings holds local JSON export, resetAllData confirmed by name and consequence, re-run onboarding, and https://stile-ladder.pro/contact-us. Scan uses AVCaptureMetadataOutput with .qr, pulls 8 to 14 digit runs from the QR or URL, pads a 12-digit code with a leading 0, matches a Client desk code, and opens that ladder. The button before requestAccess reads Continue or Next. NSCameraUsageDescription is exactly Stile scans desk QR codes to open a client session ladder. Denied camera explains the state and opens Settings. Simulator shows code chips plus a manual field. The session stops on disappear and on background.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By ladder role (Ladder, Rung, Outcome, ScaleMark, KnowHow, Action, ReviewMark, Client, RushMark, HollowMark, UnripeMark)**

```
Stile/
  Ladder/Ladder.swift
Ladder/LadderView.swift
Ladder/HarvestMark.swift
Ladder/VoidMark.swift
Ladder/SessionNote.swift
Ladder/Retract.swift
Ladder/LadderStore.swift
Ladder/OnboardingView.swift
Ladder/SettingsSheet.swift
Rung/Rung.swift
Outcome/Outcome.swift
ScaleMark/ScaleMark.swift
KnowHow/KnowHow.swift
Action/Action.swift
ReviewMark/ReviewMark.swift
ReviewMark/ProgressSheet.swift
Client/Client.swift
Client/ClientSheet.swift
Client/ScanCover.swift
RushMark/RushMark.swift
HollowMark/HollowMark.swift
UnripeMark/UnripeMark.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Clients
A first-class screen for **Clients**. Must render empty, populated and error states.

### 5.3 Session
A first-class screen for **Session**. Must render empty, populated and error states.

### 5.4 Progress
A first-class screen for **Progress**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Client** — named per this app's convention.
- **SessionNote** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **lingo · cream-band · branded**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#FFFFFF` | Screen background |
| `surface` | `#FFFFFF` | Cards, rows, sheets |
| `ink` | `#3C3C3C` | Primary text and icons |
| `accent` | `#BE59FF` | Primary action, key figure, progress fill |
| `muted` | `#6E6E6E` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Stile/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Avenir Next**

Avenir Next through one accessor. AvenirNext-DemiBold is the single display weight. AvenirNext-Regular carries every other step. Home uses those two weights only: DemiBold for the short client name and the scale figure, Regular for lane ink at body size near 17pt and for captions. At most six steps sit behind that accessor: display, title, headline, body, caption, micro. Sizes use ScaledMetric and track Dynamic Type, and headlines stay intact at the largest size. Scale values from 0 through 10, confidence from 1 through 5, and day counts go through NumberFormatter. Day edges use Calendar.current.startOfDay before the YYYYMMDD Int.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **18pt** for cards, sheets and primary surfaces; **8pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **bordered prominent** — primary actions use `.buttonStyle(.borderedProminent)` or an equivalent filled, bordered shape.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI Metal shaders · spritekit-accent**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI Metal shaders · spritekit-accent** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **warm** (Warm soft: friendly radii, comfortable pad, one playful moment.)

Reference system: **lingo** — steal rhythm and restraint, not their colours or logos.

Mood: **Playful, minimal design with bright colors, rounded shapes, tactile 3D borders, and friendly illustrations for approachable interfaces.**.

Home rhythm (`cream-band`, comfortable): A cream band resets the page, then the verb.

Warm soft: friendly radii, comfortable pad, one playful moment. Layout `cream-band`, density comfortable. Kit 18/8, shadow, bordered prominent. Palette recipe `branded`. Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: One display size, then caption. No third weight on home. Reference type feel: warm.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`tactical`): Status-first. Noun plus state. 'Scan failed. Try again.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Ladder root record holding Clients, Rungs, SessionNotes and Marks, encoded under a single key with debounced save after each mark**

One Codable Ladder root, schemaVersion 1, holds Clients, Rungs, SessionNotes, and every Mark, including ScaleMark, HarvestMark, ReviewMark, VoidMark, RushMark, HollowMark, and UnripeMark. JSONEncoder writes that document to UserDefaults under the single key stl.ladder.root. The in-memory Ladder is the source of truth. Saves debounce after each mark and flush when scenePhase leaves active, after Retract, and inside resetAllData(), which removes that key and is reachable from Settings. A decode failure restores the in-memory root when it exists, otherwise starts Bare and shows a plain error with a way forward. Each Client keeps an 8 to 14 digit desk code. Day keys are Ints in YYYYMMDD form. The Simulator seed stl.demo.v1 writes four clients, inks Outcome on today's Open ladder so Set is enabled, and files two earlier SessionNotes. It never runs on a device. Face ID gates the roster sheet and does not split the document. Settings export writes that same JSON for the user to share. There is no account and no network sync.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Stile/1.0 (iOS; +https://stile-ladder.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.productivity`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.productivity
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Scale-then-harvest (Outcome must hold ink; Set writes ScaleMark before KnowHow and Action unlock; Harvest requires both; Review freezes SessionNote and opens the next ladder; RushMark on pre-Scale lane edits; HollowMark on Review without Action; UnripeMark on Review before Harvest; seed inks Outcome so Set is the first live tap)

Home is the open OSKAR ladder for the selected client, and the persisted verbs on that surface are set-the-scale and review-the-ladder. Outcome already holds ink on the seeded Open ladder, so the first live tap is Set, which writes a ScaleMark for the dragged bead from 0 through 10 and only then lets Know-how and Action accept text. Harvest writes a HarvestMark when both lanes hold text and folds Scaled to Harvested, and Review writes a ReviewMark, freezes the SessionNote, stamps confidence from 1 to 5, and opens the next blank ladder. A Know-how or Action edit before Scaled writes RushMark, Review before a HarvestMark writes UnripeMark, and Review after Harvest with an empty Action writes HollowMark. Retract peels the last ReviewMark while the successor ladder is still empty, and a second Set on Scaled is refused. Unit tests cover that path: the SessionNote section count matches the titled lanes, confidence stays in 1 through 5, and the next-session summary is the latest SessionNote plus the days since its daykey.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Bauhaus geometric · collage**


Base prompt, reused and extended for every asset:

```
Bauhaus geometric collage. Flat cut-paper planes with hard edges. Circle, square, and triangle overlap in an asymmetric stack. Visible paper grain, matte surface, studio-flat light. Tall frames keep a quiet middle band. No letters, numerals, or words.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `stl_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `stl_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `stl_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `stl_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `stl_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `stl_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `stl_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `stl_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `stl_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `stl_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `stl_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Scale-then-harvest (Outcome must hold ink; Set writes ScaleMark before KnowHow and Action unlock; Harvest requires both; Review freezes SessionNote and opens the next ladder; RushMark on pre-Scale lane edits; HollowMark on Review without Action; UnripeMark on Review before Harvest; seed inks Outcome so Set is the first live tap)' feature screen. |
| 11 | `stl_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `stl_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`stl_AppIcon`** — 1024x1024

```
A Bauhaus geometric collage emblem of a vertical ladder reduced to three stacked rectangles and one solid circle bead, filling the canvas edge to edge, fully opaque, no letters, no numerals, no rounded mask, subject kept inside the middle of the canvas.
```

**`stl_Splash`** — 1290x2796

```
A tall Bauhaus collage of overlapping geometric planes with a calm uncluttered center band, filling the frame edge to edge, no letters and no numerals.
```

**`stl_Onboarding1`** — 1024x1536

```
A solid paper-collage ladder standing in the center, one plaque on the top rung, Bauhaus circle square and triangle, fully opaque subject.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_Onboarding2`** — 1024x1536

```
A solid hand sliding a circular bead along a vertical geometric scale, mid gesture, Bauhaus cut paper, opaque subject in the center.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_Onboarding3`** — 1024x1536

```
A solid stacked paper folio with a round stamp seated on the top sheet, Bauhaus collage, opaque subject in the center.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_EmptyHome`** — 1024x1024

```
A solid closed ladder case of folded board, Bauhaus geometry, fully opaque, calm and waiting, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_EmptyList`** — 1024x1024

```
A solid closed client folio, a thick paper stack with a geometric clasp, Bauhaus collage, fully opaque, subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_CardBackdrop`** — 1200x800

```
An abstract Bauhaus collage of overlapping planes, quiet enough to sit behind type, filling the canvas edge to edge, no focal emblem, no letters.
```

**`stl_ControlFace`** — 512x512

```
The face of a scale bead: a solid circle with a smaller square inlay, painted board, Bauhaus, opaque and centered, a filled object rather than a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_TwistHero`** — 1024x1024

```
A solid vertical ladder with a bead seated on a middle rung and two paper slips tucked on the lower rungs, Bauhaus geometric collage, opaque subject centered.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_SuccessMark`** — 512x512

```
A solid filled square of metal or ceramic with a circle seated on its face, occupying the middle of the canvas, Bauhaus, a filled mass rather than a thin outline or a hollow ring.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`stl_HeaderDecor`** — 1200x600

```
A wide solid frieze of one circle, one square, and one triangle locked into a single Bauhaus ornament, opaque subject, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`stl.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `StileTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Stile/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Stile -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **OSKAR ADT fold (Open | Scaled | Harvested | Reviewed); the ladder is a fold over Rungs; Set writes a ScaleMark on the chosen 0–10 rung and folds Open to Scaled; Harvest writes a HarvestMark when KnowHow and Action both hold ink and folds Scaled to Harvested; Review writes a ReviewMark, freezes SessionNote, and folds Harvested to Reviewed; Set with empty Outcome writes VoidMark; KnowHow or Action edits before Scaled write RushMark; Review with empty Action writes HollowMark; Review before Harvest writes UnripeMark; Retract peels the last ReviewMark while the successor ladder is empty; a second Set on Scaled is refused; empty ladder writes Bare** with no leakage across layers.
- [ ] UI approach matches **SwiftUI Metal shaders · spritekit-accent**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Ladder-locked chrome (the OSKAR ladder never leaves; Clients, Progress and Settings arrive as sheets; set, harvest and review fuse on Ladder; Face ID gates the roster; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Avenir Next** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Stile
xcodegen generate
xcodebuild build-for-testing -scheme Stile -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.stile.ladder/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Stile -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.stile.ladder/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Stile -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.stile.ladder/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
