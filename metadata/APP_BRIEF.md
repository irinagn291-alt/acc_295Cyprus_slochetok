<!-- gf-brief source=e2f906d5d7fbad637929ddb1d68ed2ff860f79dbf17cb222a81af420562c587d written=2026-10-09T13:25:21+03:00 -->
# Slochetok
## What it is
Slochetok is a session notebook for coaches and therapists. You keep a client roster on this device, run each visit on a 0-to-10 scale, write Outcome, Know-how, and Action, then Review to file the note.

The name under the icon and on the listing is Slochetok. On-screen labels still say Stile in Settings and in the system permission text. It is for people who work with named clients, give each one a desk code, and want the visit to stay on the device.

## Launch and onboarding
Cold launch shows the system launch screen (no copy), then a brief white screen, then either onboarding (first run, after Reset, or after “Run onboarding again”) or the home session.

Onboarding is three pages. “Skip” is on every page and ends onboarding. The primary button is “Next” on the first two pages and “Continue” on the last. VoiceOver on that primary button says “Writes the starting ladder and opens the session.” Ending onboarding opens home. It does not add a client or open a visit.

1. “Session notes stay on this phone.” / “Set the scale, harvest the visit, and file it here.” Buttons: “Next”, “Skip”.
2. “Set the scale first.” / “Drag the bead from 0 to 10, then tap Set.” Buttons: “Next”, “Skip”.
3. “Review files the ladder.” / “Know-how and Action seat together before the note freezes.” Buttons: “Continue”, “Skip”.

A later launch that already finished onboarding goes straight to home. If a client was already chosen, that visit is still there.

## Screens
### Today
Home is the open visit. There is no tab bar. The top band title is the selected client’s name, or “Today” when none is selected.

The line under the title is one of:
- “Open the roster, then tap Set.” (no visit)
- “Open. Drag the bead, then tap Set.”
- “Scaled. Know-how and the next lane can take ink.”
- “Harvested. Tap Review and stamp confidence.”
- “Reviewed. The next visit is open.”

Four icon buttons (VoiceOver: “Clients”, “Progress”, “Settings”, “Scan”) open those screens. Clients, Progress, and Settings arrive as sheets. Scan is full screen.

With no visit and a status line (for example after Reset), the page also shows “No visit is open.”, “Open the roster, then tap Set.”, and “Open roster” (opens Clients). After a normal first onboarding there is no status line, so you only get the “Today” band and those four buttons until you add a client.

When a visit is open:
- A vertical scale marked 10 at the top through 0 at the bottom. The bead starts on 6. VoiceOver: “Scale bead”, value is the number. Drag (or swipe the bead in VoiceOver) to choose 0–10. After Set the bead will not move.
- “Outcome” (or “Outcome, written” once there is text). “Write the change this visit is for.” or “Edit it if the change is wrong.” Field placeholder: “Write the outcome”.
- A grouped pair: while the scale is unset, “Next writing step, after Set: know-how, then the action.” After Set: “Both lanes need ink before Harvest.” Fields “Know-how” and “Action” (same words as placeholders). Those fields stay dim and ignore taps until Set.
- “Confidence” with five buttons showing 1, 2, 3, 4, and 5 (VoiceOver: “Confidence 1” through “Confidence 5”). 3 starts selected. This is the stamp Review will use.
- If this client already has a filed note: the note’s date (device medium date), the Outcome text from that note, and “N days since that note.” (always the word “days”).
- “Set”, “Harvest”, and “Review” in one row (stacked if the row will not fit). Only the current step is tappable; the others look faded.
- “Retract” only after a Review while the next visit is still blank. It asks “Retract this review?” / “The filed note comes off and this visit returns to harvested.” Buttons: “Retract”, “Keep it”.
- Keyboard: “Done” dismisses the keyboard.

Status lines on this page, when they appear:
- “Scaled. Bead N.”
- “Void. The top lane needs ink before Set.”
- “Harvested. Both lanes are seated.”
- “Harvest is waiting. Both lanes need ink.”
- “That lane is locked.”
- “Reviewed. Confidence N. Next visit is open.”
- “Hollow. The action lane is empty.”
- “Retracted. This visit is harvested again.”
- “The ladder could not be saved. Stay here and try the mark again.”
- “The ladder is still on screen. Saving to disk failed. Try again before leaving.”
- “The latest save could not be read. The previous ladder is back. You can keep working.”
- “The saved ladder could not be read. The ladder on screen is unchanged. Reset from Settings if you need a blank start.”
- “The saved ladder could not be read. Start again with a blank ladder. Reset from Settings if a file is still in the way.”

A status line that came from a save or load problem includes “Try again”.

### Clients
Title: “Clients”. Close control (X, VoiceOver “Close”). Keyboard: “Done”.

First time (and again after Reset): “Clients are sealed.” / “Unlock, then pick one.” Button: “Continue”. That is the only in-app step before the system Face ID prompt, which says “Stile uses Face ID to open the client roster on this device.” After a successful unlock the roster stays open on later visits; Face ID is not asked again unless you reset.

If Face ID cannot run: “Face ID is unavailable. Open Settings to turn it on, then return here.” Buttons: “Open Settings”, “Continue”.
If Face ID fails: “Face ID did not confirm. Try again, or open Settings.” Same two buttons.

Empty roster: “No clients on this device.” / “Add a name and a desk code to open a visit.” Then the add form.

Filled roster: each row is the client name and “Desk” plus that client’s code. Tap a row to open that visit and close the sheet. Rows do not delete a client.

Add form (empty and filled):
- “Client name”
- “Desk code” (number pad, digits only)
- “Add to roster” — on success, that visit opens and the sheet closes. On failure: “Add failed. Use a name and an 8 to 14 digit desk code.”

If the roster cannot be read: “The roster could not be read.” plus the status line and “Try again”.

### Progress
Title: “Progress”. Close control (X, VoiceOver “Close”). This sheet is for the client currently selected on Today. With no client, it is empty.

Empty: “No reviews filed.” / “Harvest and review a visit to read the trend.” Button: “Back to today” (closes the sheet).

Filled:
- “N day since the latest note.” or “N days since the latest note.”
- “Scale” — a bar for each set scale, labeled with that 0–10 number. If reviews exist but no scale bars: “No scale yet.”
- A list of filed reviews: each row is the date and “Confidence N”.

If Progress cannot be read: “Progress could not be read.” plus the status line and “Try again”.

### Settings
Title: “Settings”. Close control (X, VoiceOver “Close”). Keyboard: “Done”.

If there are no clients and no filed notes: “Nothing stored yet.” / “A saved visit will show up here after the first review.”

A status line, when present, includes “Try again”. After Reset, Settings can still be open and show “Ladder cleared. Add a client to start again.” (or “The ladder on screen is clear. A file could not be removed. Reset again from Settings.”).

Section “On this device”:
- “Export visit JSON” opens the system share sheet with preview title “Visit export”. If export cannot be built: “Export failed. The visit is still on screen.”
- “Run onboarding again” closes Settings and shows the three onboarding pages. Clients and notes stay. “Skip” or “Continue” returns to home.

Section “Clear this device”:
- “Typing Stile removes every name, visit, and note. This cannot be undone.”
- Field: “Type Stile”
- “Reset all data” stays disabled until the field is exactly `Slochetok` (not `Stile`). Reset clears every name, visit, and note, forgets the Face ID unlock, and sends you through onboarding again after you leave Settings.

“Contact Stile” opens the support page.

### Scan
Title: “Scan”. Close control (X, VoiceOver “Close”). Keyboard: “Done”.

Before camera permission: “Scan a desk QR to open that visit.” Button: “Continue”. That is the only in-app step before the system camera dialog. The desk-code field is already on this screen, so you can open a visit by typing without using the camera.

If camera is denied or off: “Camera is off.” / “Scan needs the camera. Open Settings, then return to this cover.” Button: “Open Settings”.

When the camera is on: live finder plus “Point at the desk QR, or enter the code.”

If the camera cannot start: “Scan failed. Try again.” and “Try again”.

Always on this screen, below the camera state:
- “Desk code” (number pad)
- “Open visit” — opens the matching client and closes Scan. A code that is missing, the wrong length, or not on the roster replaces the hint with “Scan failed. Try again.”

A matching QR does the same as “Open visit” and closes Scan.

## Features
- Session notes that stay on this phone
- Client roster with a name and a desk code
- Face ID to unseal “Clients”
- Open visit on a vertical 0–10 scale bead
- Write “Outcome”, then “Set”
- Write “Know-how” and “Action”, then “Harvest”
- Stamp “Confidence” 1–5 and “Review” to file the visit
- Automatic next blank visit after Review
- “Retract” to take the last filed note off while the next visit is still blank
- “Progress” scale bars and filed Confidence list for the selected client
- “Scan” a desk QR, or type the desk code, to open that visit
- “Export visit JSON”
- “Run onboarding again”
- “Reset all data”
- “Contact Stile”

## Behaviours that can look like bugs
- After onboarding, home is “Today” with “Open the roster, then tap Set.” and no visit until you add or pick a client from “Clients” (or “Open roster” when that button is showing).
- “Clients are sealed.” / “Unlock, then pick one.” “Continue” does nothing useful until Face ID succeeds. If Face ID is off: “Face ID is unavailable. Open Settings to turn it on, then return here.” then use “Open Settings”. If it fails: “Face ID did not confirm. Try again, or open Settings.”
- “Add to roster” refuses a blank name or a desk code that is not 8 to 14 digits: “Add failed. Use a name and an 8 to 14 digit desk code.”
- A 12-digit desk code is stored and shown with a leading 0 on the “Desk …” line.
- There is no per-client delete. The roster only grows until “Reset all data”.
- “Set” stays tappable while the visit is Open, but refuses an empty Outcome: “Void. The top lane needs ink before Set.” Write the Outcome, then Set.
- Before Set, “Know-how” and “Action” stay dim and ignore taps. The hint is “Next writing step, after Set: know-how, then the action.”
- After Set, Outcome still says “Edit it if the change is wrong.” Further edits do not keep: “That lane is locked.”
- “Harvest” is tappable after Set even if a lane is empty. That shows “Harvest is waiting. Both lanes need ink.” Fill both lanes, then Harvest.
- After Harvest you can still edit “Know-how” and “Action”. If you clear Action and then Review: “Hollow. The action lane is empty.” Put Action back, then Review.
- “Set”, “Harvest”, and “Review” that are not the current step look faded and do not advance.
- “Review” files the note and immediately opens a new blank visit. The just-finished text is gone from the fields; it is on “Progress” and on the recent-note card. The banner is “Reviewed. Confidence N. Next visit is open.”
- Right after Review the recent-note line can read “0 days since that note.” That line always uses the word “days”, even for 1. Progress uses “day” or “days”.
- “Retract” is missing once you write anything on the next visit.
- “Retract this review?” — “Keep it” leaves the filed note in place.
- “Reset all data” stays faded until the field is exactly `Slochetok`. The field still says “Type Stile”, and the line above still says “Typing Stile removes every name, visit, and note. This cannot be undone.”
- “Scan” “Continue” only reaches the finder after the system camera dialog is allowed. Denied: “Camera is off.” then “Open Settings”. You can still type a desk code and tap “Open visit”.
- “Open visit” or a QR that is not an 8-to-14-digit desk code on the roster: “Scan failed. Try again.” Add the client first, then scan or type the same code.
- “Progress” is “No reviews filed.” until that client has a Review. “Back to today” just closes the sheet.
- The roster and the Progress list grow as you add clients and file reviews. Reset clears both.
- Save or load problems show a banner and “Try again”. Work can stay on screen even when a save failed.

## Starter content and resume
None.

Unfinished visits resume. The Outcome, scale, Know-how, Action, and step (Open / Scaled / Harvested) come back. Picking the same client opens today’s visit if one exists, otherwise the last unfinished visit, otherwise a new blank visit. Finished onboarding and a successful Face ID unlock stay in place until Reset. “Run onboarding again” only replays the three pages.

## Permissions
- Camera, when you tap “Continue” on Scan. Usage: “Stile scans desk QR codes to open a client session ladder.”
- Face ID, when you tap “Continue” on “Clients are sealed.” Usage: “Stile uses Face ID to open the client roster on this device.”

## Absent
Login or accounts, in-app purchase, ads, analytics, account deletion flow, App Tracking Transparency prompt.

People do type their own client names, desk codes, and session text. There is no account to delete; “Reset all data” after typing `Slochetok` clears what is on this device.

## Data and support
Names, visits, and notes stay on this device. “Export visit JSON” can share a copy if you choose. “Contact Stile” (Settings) opens the support page.

## Scanning and health
Scan expects a desk QR (or the same digits in “Desk code”) that matches a roster desk code, 8 to 14 digits. A 12-digit code is stored with a leading 0. It is not a product or barcode shopper.

The 0–10 scale and 1–5 Confidence are session marks. The app does not show health, medical, or product-health information and has no citations.

## Platform
English copy. Dates and numbers follow the device region (medium date; whole numbers). No in-app region lock. Portrait only, light appearance, iPhone and iPad, full screen. Minimum iOS 17.0.

## Category
Productivity
