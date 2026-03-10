# 📱 Tip Calculator App — Requirements Document

---

## 1. App Overview

This app helps people figure out how much to tip at a restaurant or cafe. You type in the bill amount, pick how much you want to tip, and the app shows you the total right away. You can also split the bill between a group of friends. It's for anyone who wants a quick, easy tip calculator on their iPhone — no math needed!

---

## 2. Main Goals

1. Let users type in a bill amount quickly and easily.
2. Let users choose a tip percentage from some common options.
3. Show the tip amount and the total bill clearly on the screen.
4. Let users split the total between 2 or more people.
5. Keep the app simple — just open it and go, no setup needed.

---

## 3. User Stories

| ID | Story |
|----|-------|
| **US-001** | As a user, I want to type in my bill amount, so that the app knows how much the bill is. |
| **US-002** | As a user, I want to pick a tip percentage, so that I can decide how much to tip. |
| **US-003** | As a user, I want to see the tip amount and total bill, so that I know exactly how much to pay. |
| **US-004** | As a user, I want to split the bill between multiple people, so that everyone knows what they owe. |
| **US-005** | As a user, I want to type in my own tip percentage, so that I can use a number that isn't in the list. |
| **US-006** | As a user, I want to reset everything with one tap, so that I can start fresh for a new bill. |
| **US-007** | As a user, I want the app to work in dark mode, so that it looks good in a dim restaurant. |

---

## 4. Features

### F-001 — Bill Amount Input
- **What it does:** Shows a box where you type in the bill amount (numbers only, with cents).
- **When it appears:** Always visible at the top of the main screen.
- **If something goes wrong:** If the user types letters or leaves it blank, the app shows a friendly message like "Please enter a valid bill amount."

### F-002 — Tip Percentage Picker
- **What it does:** Shows 3 quick-pick buttons for common tip amounts: 15%, 18%, and 20%. The selected button is highlighted so you can see which one is active.
- **When it appears:** Right below the bill amount input on the main screen.
- **If something goes wrong:** If no percentage is selected, the tip defaults to 0% and the app still shows the totals correctly.

### F-003 — Custom Tip Percentage
- **What it does:** Lets the user type in their own tip percentage (like 22% or 12%) if none of the quick-pick buttons work for them.
- **When it appears:** Below the quick-pick buttons, always visible.
- **If something goes wrong:** If the user types something that isn't a number, the field clears itself and shows a placeholder like "Enter % here."

### F-004 — Tip and Total Display
- **What it does:** Shows three things clearly: the tip amount, the total bill (bill + tip), and the amount per person if splitting.
- **When it appears:** Updates live every time the user changes the bill amount, tip, or number of people.
- **If something goes wrong:** If no bill amount is entered, all totals show $0.00 so there's nothing confusing on screen.

### F-005 — Bill Splitter
- **What it does:** Lets the user choose how many people are splitting the bill. Shows + and – buttons to go up or down. Shows each person's share below.
- **When it appears:** Below the tip/total display on the main screen.
- **If something goes wrong:** The minimum number of people is 1 (can't go below 1). The app won't let the user tap the minus button past 1.

### F-006 — Reset Button
- **What it does:** Clears everything — bill amount, tip percentage, number of people — and starts fresh.
- **When it appears:** Always visible, at the bottom of the screen.
- **If something goes wrong:** Nothing can go wrong — it just resets everything to zero/default.

---

## 5. Screens

### S-001 — Main Screen (The Only Screen)
- **What's on it:**
  - App title at the top (e.g., "Tip Calculator")
  - Bill amount input box (F-001)
  - Tip percentage quick-pick buttons: 15%, 18%, 20% (F-002)
  - Custom tip percentage input box (F-003)
  - Tip amount display (F-004)
  - Total bill display (F-004)
  - Number of people picker with + and – buttons (F-005)
  - Amount per person display (F-004)
  - Reset button at the bottom (F-006)
- **How you get here:** This screen opens automatically when you launch the app. There are no other screens.

> 💡 This app only needs one screen. Everything happens in one place!

---

## 6. Data

| ID | What the app needs to remember |
|----|-------------------------------|
| **D-001** | The bill amount the user typed in (a number with up to 2 decimal places, like 42.75). |
| **D-002** | The tip percentage the user picked or typed in (a whole number like 18). |
| **D-003** | The number of people splitting the bill (a whole number, at least 1). |
| **D-004** | The calculated tip amount (worked out from D-001 and D-002). |
| **D-005** | The calculated total bill (D-001 + D-004). |
| **D-006** | The amount per person (D-005 divided by D-003). |

> 📝 None of this data needs to be saved after the app is closed. It's only needed while the app is open.

---

## 7. Extra Details

| Topic | Details |
|-------|---------|
| **Internet needed?** | No. The app works completely offline. |
| **Saves data on the device?** | No. When you close the app, everything resets. Nothing is saved. |
| **iPhone permissions needed?** | None. No camera, no location, no contacts — nothing like that. |
| **Dark mode?** | Yes. The app should look good in both light mode and dark mode automatically. SwiftUI handles this on its own. |
| **What iPhones does it work on?** | Any iPhone running iOS 16 or newer. |
| **Landscape mode (sideways)?** | No. The app only needs to work in portrait mode (upright). |
| **Minimum number of people to split?** | 1 person (which just shows the full total). |
| **Maximum tip %?** | No hard limit, but the custom input should only accept numbers from 0 to 100. |

---

## 8. Build Steps

| ID | What to build | Refers to |
|----|--------------|-----------|
| **B-001** | Create a new Xcode project using SwiftUI. Set the app name to "Tip Calculator." | — |
| **B-002** | Build the main screen layout (S-001) with placeholder text where each piece will go. Just get the screen structure in place first. | S-001 |
| **B-003** | Add the bill amount input box so the user can type in a number. Hook it up to a variable that stores the value. | F-001, D-001 |
| **B-004** | Add the three tip percentage quick-pick buttons (15%, 18%, 20%). Make the tapped button highlight so it's clear which one is selected. | F-002, D-002 |
| **B-005** | Add the custom tip percentage input box. Make sure only numbers 0–100 are accepted. | F-003, D-002 |
| **B-006** | Add the math logic that calculates the tip amount and total bill. Display these values on screen. They should update live as the user types. | F-004, D-003, D-004, D-005 |
| **B-007** | Add the people splitter with + and – buttons. Add the per-person amount display. Make sure it can't go below 1 person. | F-005, D-003, D-006 |
| **B-008** | Add the Reset button that clears all inputs and calculated values back to zero/default. | F-006 |
| **B-009** | Test dark mode. Make sure all text and backgrounds look good in both light and dark settings. | Extra Details |
| **B-010** | Do a full test run. Try edge cases like: blank bill amount, 0% tip, 1 person, and 100% tip. Fix anything that looks broken. | All features |

---