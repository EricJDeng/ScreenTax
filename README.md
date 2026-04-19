# ScreenTax

**ScreenTax turns screen-time limits into real financial stakes.** Every minute you go over your daily limit costs you real money — paid to friends in your accountability group, or donated to charity if you're flying solo.

It stacks three proven behavior-change levers on top of each other — loss aversion, social accountability, and purposeful giving — and points all of them at the thing actually eating your time.

## The problem

Everyone sets screen-time limits. Everyone taps "Ignore Limit for Today" the second it pops up. The override is free, so nobody respects the limit. Other apps try to add friction — a breathing exercise, a feed blur, a shame timer — but friction is one tap away from being gone.

ScreenTax is the only app that makes the override *cost you something*.

## How it works

1. **Set a daily budget.** How many minutes you're willing to spend on the apps that eat your day.
2. **Set a rate.** How much every minute of overage costs — 25¢, 50¢, a dollar. You pick.
3. **Pick the apps you want watched.** Instagram, TikTok, YouTube, Reddit, Snapchat, Netflix, Discord.
4. **Pick where the money goes.**
   - **Accountability mode** — your overage gets split across your friend group. They literally profit from your slip-ups.
   - **Charity mode** — your overage is donated to a cause you care about (Red Cross, Doctors Without Borders, UNICEF, WWF, Feeding America, Teach For All).
5. **Live.** A home-screen card shows your progress in indigo while you're under budget, flips red the moment you cross the limit, and tallies what you owe in real time. When it's time to settle up, one tap.

## What's in the repo

This is an iOS client, SwiftUI-only, no backend yet.

```
App/
  Home/              Home tab — hero card, settings, watched apps, settle/pay card
  Friends/           Accountability tab — friends list, charity picker, mode switch
  Assets.xcassets/   App icon + SVG company logos (AppLogos/)
  AppIconView.swift  Rounded-square app tile used throughout the UI
  ContentView.swift  TabView root
  DemoSession.swift  Timer-based usage simulator for demos (1s = 1 simulated minute)
  MockAppCatalog.swift
  ScreenTaxApp.swift
Shared/
  LimitSettings.swift    Daily minutes, rate, watched app ids
  OverageLedger.swift    UserDefaults-backed ledger of owed cents
  PayoutSettings.swift   Friend list, payout mode, selected charity
project.yml              xcodegen spec — the xcodeproj is generated from this
```

## Architecture

The iOS client is split into three concerns:

- **`LimitSettings` / `PayoutSettings`** — user-owned preferences, persisted through `UserDefaults` with `Codable` models.
- **`OverageLedger`** — the single source of truth for money owed. Everything that might charge or clear the user goes through here. In the production build this role moves to a backend service; the device can't be trusted as the authoritative ledger for money-relevant state.
- **`DemoSession`** — the timer-driven stand-in for Apple's Screen Time APIs. In the production build this is replaced by a `DeviceActivityMonitor` app extension observing real usage against a `FamilyControls` selection.

The UI is SwiftUI only, built around a stack of cards: hero → settle → settings → watched apps → payout destination. `@Observable` stores feed the views; `.onChange` handlers persist back to `UserDefaults`.

