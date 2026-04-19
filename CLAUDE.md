# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ScreenTax is an iOS app that turns screen-time limits into real financial stakes: every minute a user goes over their daily limit costs real money, paid either to friends in an accountability group or donated to charity when used solo. The product thesis combines social accountability, loss aversion, and purposeful giving into a behavior-change tool.

## Repository state

This repo is pre-scaffolding. As of the initial commit it contains only `README.md` and a Swift/Xcode `.gitignore` — **no Xcode project, no source files, no backend**. Before assuming build/test commands exist, check whether the iOS project and any backend have actually been created. If they haven't, the first task is scaffolding them rather than editing nonexistent files.

## Architectural shape (once scaffolded)

The product description implies the following subsystems will need to exist. Treat this as a map for where new code should live, not as a description of code that's already there:

- **iOS client (Swift)** — Uses Apple's Screen Time APIs (`FamilyControls`, `DeviceActivity`, `ManagedSettings`) to observe app/category usage against a user-set daily limit. These APIs require the Family Controls entitlement and run much of their logic in a `DeviceActivityMonitor` app extension, not the main app process — keep that extension boundary in mind when designing state flow.
- **Overage accounting** — When usage crosses the limit, the app must compute owed amounts (per-minute rate × overage) and persist them durably. This is the core correctness path; off-by-one-minute or double-counting bugs translate directly into charging users the wrong amount.
- **Payments / payouts** — Two modes: (a) peer-to-peer transfers within an accountability group, (b) charitable donation when solo. Both require a payments provider integration and a ledger of owed vs. settled amounts.
- **Accountability groups** — Multi-user state (membership, per-group rules, who-owes-whom) implies a backend service with auth, not a purely local app.

When a feature spans the client and a backend, be explicit about which side owns the source of truth for money-relevant state — the device cannot be trusted as the authoritative ledger.
