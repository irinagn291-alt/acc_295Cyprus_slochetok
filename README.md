# Stile

Stile is a session notebook for coaches and therapists who run OSKAR or solution-focused visits and keep the notes on the device. The coach sets a 0 to 10 scale, harvests know-how and action, then reviews the ladder so the visit files locally.

## Architecture

A ladder is an algebraic fold: Open, Scaled, Harvested, or Reviewed over one client's rungs for one day. That suits this product because the visit is a sequence of irreversible marks, not a form you can fill in any order. Set writes a ScaleMark and folds Open to Scaled. Harvest writes a HarvestMark only when Know-how and Action both hold ink, and folds Scaled to Harvested. Review writes a ReviewMark, freezes a SessionNote, and folds Harvested to Reviewed while opening the next blank ladder. Empty ladders are Bare. Refusal marks (Void, Rush, Hollow, Unripe) leave the phase where it was. Retract peels the last ReviewMark only while the successor ladder is still empty. The screen talks to `LadderStore`. The store projects one Codable root into UserDefaults and an Application Support file.

## Scale, then harvest

Home is the open ladder, not a list of notes. Outcome can take ink while the ladder is Open. The seeded visit already holds an outcome, so the first live tap is Set. Know-how and Action stay dim until Scaled. A lane edit before that writes RushMark. Review before Harvest writes UnripeMark. Review with an empty Action writes HollowMark. A second Set on Scaled is refused. Progress reads ReviewMarks and the scale trend for that client.

## Art

Style: Bauhaus geometric collage. Flat cut-paper planes, hard edges, circle square and triangle, matte grain, no letters or numerals. Assets are filled in a later generate step. The prompts are the section 13 prompts in SPEC.md, one per `stl_` image set (AppIcon, Splash, Onboarding1, Onboarding2, Onboarding3, EmptyHome, EmptyList, CardBackdrop, ControlFace, TwistHero, SuccessMark, HeaderDecor).

## How it differs

Paraph files SOAP charts on Sign. Gradus files GROW canvases on Seal after Ground and Options. Stile files OSKAR ladders on Review after a mandatory scale Set and a harvest of know-how plus action. The home mechanic is a vertical 0 to 10 bead. Clients, Progress, and Settings are sheets. There is no tab bar.

## Build

```
xcodegen generate
xcodebuild build-for-testing -scheme Stile -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
```

No packages. System frameworks only.
