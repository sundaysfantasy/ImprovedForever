# This fork

A personal fork of [markgravity/ImprovedForever](https://github.com/markgravity/ImprovedForever).
`main` follows upstream untouched; `custom` is upstream plus the changes below.

## Fixes

- **Immersion**: no more "attempt to compare a secret number value" in a fight
  (`HudLayout.lua`, `AuraLabels.lua`, `ChatView.lua`); a timeline stops at its first
  error instead of flooding the error handler (`BuffTimeline.lua`).
- **Quest Tracker**: a quest the game's watch list has twice is laid out once
  (`Tracker/Patch.lua`), a guard against "Cannot anchor to a region dependent on it"
  and the gap it left in the tracker. Cause not confirmed in game.

## Fine tuning (Immersion tab)

Sizes, places, times and limits that were fixed numbers, as sliders and lists in the
Immersion tab, each in the section it belongs to. All of it lives in
`ImprovedForever_Immersion/Custom.lua` (the fields, the defaults, `IN.Tune(key)`); a
module reads its value where it used its constant. Saved in `ImprovedForeverDB.interfaceTune`,
apart from upstream's own settings.

| Section | Setting | Default | Range | Applies |
|---|---|---|---|---|
| Target | Target out of reach: opacity | 35% | 10-100% | live |
| Target | Target buffs: icon size | 22 px | 14-40 px | /reload |
| Target | Target buffs: how many | 8 | 2-16 | /reload |
| Nameplates | Other nameplates: size | 80% | 50-100% | live |
| Nameplates | Other nameplates: opacity | 85% | 20-100% | live |
| Nameplates | Nameplate: lower | 34 px | 0-80 px | live |
| Nameplates | Nameplate debuffs: icon size | 16 px | 10-30 px | /reload |
| Nameplates | Nameplate debuffs: how many | 5 | 1-10 | /reload |
| Quests | Quest arrow: arrived within | 8 yd | 2-40 yd | live |
| Quests | Quest progress: shown for | 3 s | 1-10 s | live |
| Banners | Zone names: show | Zones and subzones | or New zones only | live |
| Banners | Zone names: shown for | 4 s | 1-15 s | live |
| Banners | Level ups: shown for | 5 s | 2-20 s | live |
| Cast bar | Cast bar: length | 460 px | 200-900 px | live |
| Cast bar | Cast bar: thickness | 3 px | 2-12 px | live |
| Player frame | Power line: shown | In a fight or not full | or Always | live |
| Player frame | Lines: stay after full | 0.8 s | 0-10 s | live |
| Action bar | Action bar: size | 100% | 60-150% | live, out of combat |
| Action bar | Action bar: right | 0 px | -1400 to 100 px | live, out of combat |
| Action bar | Action bar: up | 0 px | -30 to 700 px | live, out of combat |
| Buffs & cooldowns | Buff and cooldown rows: icon size | 75% | 40-130% | /reload |
| Buffs & cooldowns | Buff row: debuffs at most | 8 | 2-16 | /reload |
| Chat | Chat at rest: opacity | 22% | 0-100% | live |
| Chat | Chat: new line bright for | 10 s | 2-60 s | live |
| Chat | Chat: fade time | 3 s | 0-10 s | live |
| Fine tuning | Reset the fine tuning | | | |

Every default is upstream's own value, so nothing changes until a setting is moved.

## Keeping up with upstream

```
git checkout main && git pull upstream main && git push origin main
git checkout custom && git merge main
```

The fork's code is kept to one new file and one-line reads in upstream's files, so a
merge rarely conflicts. Upstream's `CHANGELOG.md`, versions and `docs/` are left as they
are: this file is the fork's own record.
