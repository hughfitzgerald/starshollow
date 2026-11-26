# Stars Hollow Showdown — Roadmap

*Built from the "Gilmore Girls Pinball table ideas" doc, last full check against `hughfitzgerald/starshollow` @ `acda9b4` (Nov 23, 2026); Inbox triaged @ `07ea223`; commits through `1d1a3dc` reviewed (T1, T7, T11, T18, B2, B12, I7, O1, O2, O5). "Done" means the code or assets show it. Items marked "verify" look handled in the code, but only playing the table will confirm it.*

**Priority key:** **P1** = before this week's playtest · **P2** = nice if there's time · **P3** = after the trip

---

## How this file works

- **IDs:** T = todo, B = bug, I = idea, D = done, R = rejected, O = observation. IDs never get reused; a moved item keeps its number and notes where it came from (e.g. "B2 → D".)
- **Inbox:** anything new goes here first, in Stephen's words. Triage moves each item into a list.
- **Checks:** every status from a code check says which commit it was checked at, e.g. "verified @ acda9b4".
- **Corrections from Stephen win.** They're marked "(per Stephen)", and a later code check doesn't overwrite them; it just flags a disagreement.
- **Commands:** "Idea: …", "Check T1, B2", "Correction: …", "Triage" (Inbox + the Google Doc), "Re-check verify items".

## Inbox

*(empty — triaged @ 07ea223)*

---

## 1. Prioritized TODO list

### P1 — before this week's playtest
- **T1** → moved to D38 (done @ 1d433ea)
- **T2** → moved to D33 (per Stephen)
- **T18** → moved to D43 (done @ 65d18aa)
- **T3** → moved to D34 (done @ 7147986)

### P2 — if there's time this week
- **T4** **Character modes: add rewards and points** *(first line of doc)*. The rewards are the unlocks in **I5** (per Stephen); collecting them is **I19**, and Kirk's Super Jets is **I21**. Progress, slides and callouts exist, and the mode priority (230) is already below the mission modes (660+), so the callout-priority half is done. Completing a character currently awards nothing: `<name>_complete` only plays a slide (`characters.vbs` line 41) @ 7147986.
- **T5** **Find a home for Babette's meteorologists callout** *(bold)*. Registered but never played @ 7147986. Candidates: the secret skill shot (I20) or the tilt warning (O10).
- **T7** → moved to D39 (done @ 1d433ea)
- **T8** **Post-ball callouts**: "No more talking…" and "I can't talk to you when you're like this…". Neither clip exists yet.
- **T9** **Status report**: not started (suggestion: O11).

### P3 — after the trip
- **T6** **Unused sounds: find a place for them or remove them** (per Stephen, most may never be used). The list is now in section 7, Sound inventory.
- **T10** **Change which mode is about to start** *(bold, "slings?"; see O12)*. Keep the random pick, but let the flippers change it while the ball is in the plunger lane (per Stephen). Catch: no minigame is picked until skillshots stop, which keeps a mode from starting after the secret skill shot (it ends in the scoop). So the selection has to start with base mode, with conditions that block the minigame and mystery from starting after a secret skill shot. Today `choose_new_minigame` picks at random @ 7147986.
- **T11** **More mystery awards**: video mode, hold bonus X. Done already: extra ball, add-a-ball, Jess/Dean MB, advance Logan, bonus X, scores. Existing awards now have conditions @ 1d433ea (`_scores.vbs` line 199): Lite EB only if one isn't already lit, Add-a-Ball and Jess/Dean MB not during either multiball, Increase Bonus only below 8X, Advance Logan only at qualify stage ≤ 1. Those conditions never fired as first written (GLF ignores `{conditions}` on posted events). They're now on the random pick instead @ a317590 (`mystery.vbs` line 99); verify on the table. Dropped Grandparents' hurry-up, quick 2-ball and Super Jets (per Stephen; Super Jets is now the Kirk reward, I21).
- **T12** **Founder's Day Punch jackpots**: a cross-table super jackpot (Luke's → Mansion; same thing as the "combo jackpot", per Stephen) and a roaming jackpot. Today the mode is plain Luke's/Mansion/orbit scoring.
- **T13** **Town Meeting: more topics** *(bold)*. Done: deer, cart/kiosk, coffee IV, punctuality. Not done: Taylor's wig, greenhouse, sores-and-boils alley, gnome banishing, Kirk leaving his mom's, "I'm a-gin it", Kirk under the sheet.
- **T14** **Kim's Antiques**: callouts for Lane, plus Mrs. Kim lines when you run into her (per Stephen).
- **T15** **Arrow insert in front of the captive ball** so it's clearer when it's lit.
- **T16** → moved to D35 (per Stephen)
- **T17** **Sookie "math" line during the EOB tally**. The tally itself is done.
- **T20** **List the interactions that should get light shows, big and small** (Inbox, Nov 25). Today shows exist for spinners, JESS/DEAN letters, bumpers 1 and 5, scoop eject, mystery, Dance Marathon intro, EOB sweep and attract (`base.vbs` lines 645–734); the Mansion shot has none (I25) @ 07ea223.
- **T19** (was R1) **Attract extras still wanted** (per Stephen): a champion for each mode, "SAY NO TO DRUGS", and maybe a second title slide or animation.

---

## 2. Prioritized bug list

| ID | P | Bug (from doc) | Status in code |
|---|---|---|---|
| B1 | **P1** | "Lock Away Logan" rectangle still flashes on the next ball | **Likely still open.** `llmb_minigame` (l22) doesn't set `.Persist`, and GLF shots persist by default. Nothing resets it when the next ball restores Logan to stage 2 (`logan_back_to_2`). |
| B2 | — | Hurry-up slide overwrites other things | → moved to D41 (fixed @ 658829a) |
| B3 | **P1** | Mode insert lights flash wrongly when Logan or Jess/Dean is lit or running *(bold)* | **Partial.** Minigames won't *start* during either multiball, but the selected minigame insert keeps flashing through the multiball, and no new one is picked when the multiball ends. |
| B4 | P2 | Mystery during a mode traps the ball forever | **Verify.** After the mystery show, `check_minigame` should now release the scoop during single-ball modes. |
| B5 | P2 | Mystery in Jess/Dean ejected the ball immediately | **Explained, not a bug now.** Mystery is excluded during both multiballs (see O2). |
| B6 | P2 | Logan qualified but not started: the captive ball isn't back before the drop target resets, or `captive_ball_is_home` never fires | **Verify.** Basement now posts `captive_ball_is_home` off the captive switch, and qualify releases a held ball on `mode_base_stopping`. |
| B7 | P2 | During a minigame, lock isn't lit but the ramp diverter is open | **Verify.** JD qualify now posts `lock_unlit` and `close_ramp_diverter` whenever it stops for a mode. |
| B8 | P2 | Mode that ends by drain resumes base music instead of EOB music | **Verify.** `bonus_start` stops base music, and modes only restart it when their timer or post-mode finishes. |
| B9 | P3 | Sound priority: can one sound on a bus cut off another? | **Mostly done.** `mus`/`sfx`/`voc` buses exist, `voc` plays one sound at a time, and GLF ranks sounds by mode priority. |
| B10 | — | Scoop sometimes ejects at the Dance Marathon intro on ball 2 *(bold)* | **Fixed.** You moved `scoop_hold` to basement, and it's there now. |
| B11 | — | Kim's Antiques doesn't award any shots *(bold)* | **Fixed.** Unlit shots score `KimsAntiquesShotScore`. |
| B12 | — | Mystery Jess/Dean MB starts during a minigame | → moved to D45 (fixed @ 1d1a3dc) |
| B13 | **P1** | Hurry-up doesn't end when the ball ends, and its slide covers the EOB bonus slide (Inbox, Nov 25) | **Open, cause found.** GLF bonus starts on `ball_ending`, but hurry-up only stops on `mode_base_stopping`, which comes with `ball_ended` after the tally (`hurryup.vbs` line 15, `base.vbs` line 33). So it keeps running at priority 1100 over `eob_bonus`, which plays at the EOB mode's default priority (`eob-bonus.vbs` line 236). Fix: add `bonus_start` to hurry-up's `StopEvents`, as every minigame does @ 07ea223. |

---

## 3. Ideas not yet implemented (no commitment)

**Modes and features**
- **I1** Wizard mode: Emily vs. Trix, or some kind of Luke/Lorelai mode (per Stephen)
- **I2** Video modes: egg hunt, driving the Jeep and dodging deer, Lorelai running from fiancés
- **I3** Egg-hunt mode (find hidden shots, then a final shot)
- **I4** → moved to R11 (per Stephen)
- **I5** Character unlocks: Kirk = super pops (Super Jets, I21), Paris = playfield multiplier. These are the T4 rewards (per Stephen), collected per I19.
- **I6** Character toys that light up and move with progress: Lane's drum and sticks, Sookie's spoon and bowl, Luke's sign flipping to "Kirk's". The code has a comment saying you still like the idea.
- **I7** → moved to D44 (built @ c7aac63)
- **I8** → moved to D36 (per Stephen)
- **I19** Collect a completed character's reward (T4/I5) at Luke's rather than the scoop, with a new insert in front of Luke's to show a reward is ready (there's more room there than in front of the scoop) (per Stephen).
- **I20** Secret skill shot (`s_skillshot` → scoop, `skillshots.vbs` line 33): besides points, play a random funny minor-character callout, e.g. Babette's meteorologists (registered, unused; T5) or Tom's "I'm more of a suit guy" (no clip yet; see I15), and later a small DMD cartoon or animation of that character.
- **I21** (was R9) Super Jets as the Kirk reward (T4/I5) treats the bumper-area slingshot as a bumper; maybe do the same in Logan multiball (per Stephen). Nothing for Super Jets exists @ 7147986.
- **I22** (was R10) A light above the captive ball for some Logan feature (per Stephen). A Logan multiball insert has already been added among the mode inserts (per Stephen).
- **I24** **Outlane special** (from Inbox, Nov 24): Stephen has insert lights on the outlanes. Light one for a special bonus when you drain down that outlane, with conditions for lighting it and for rotating which side is lit (e.g. on slings or a lane change), and give it its own callout instead of the usual drain callout. Today `outlane_drain` always plays the poodles callouts and `sfx_lowtrill` (`base.vbs` lines 308 and 387); nothing drives the outlane inserts @ 02e5871. A natural rotate trigger is the flipper lane change (see O12).
- **I25** **Mansion shot light show** (Inbox, Nov 25): a small localized flash of inserts/GI or a sweep outward from the Mansion, maybe a little bulb in the chimney. The shot (`s_HiddenUpperRightKicker_active`, `base.vbs` line 65) only scores and plays a callout; no show, and I found no chimney light in the parts @ 07ea223. Part of T20.
- **I27** **Multiballs keep progress within a game** (Inbox, Nov 25): restarting Jess/Dean MB picks up where it left off. Today the ramp and sign shots reset on `multiball_jdmb_started` (`jd-multiball.vbs` ~line 427), so every start is fresh; Logan MB already saves its qualify stage (D9) @ 07ea223.
- **I28** **Hurry-up to resume Jess/Dean MB** (Inbox, Nov 25): after the multiball ends, a timed shot to restart it. Builds on I27; not started @ 07ea223.
- **I23** Work the weird old TV Guide ads into the table somehow (Instagram post: https://www.instagram.com/p/DeEsFYYAcWr/?img_index=5).

**Callouts and DMD**
- **I9** Logan: hospital-bed image, "Hit bumpers to bash Logan" DMD, "You slow down, you die, Ace", "I'd beat the crap out of myself"
- **I10** Paris making a face at mopey Rory (DMD), "Complain to God, not to me", forest-animals quote
- **I11** Dean lines: "Why, you wanna dance?" (Richard), the psychologist line, Rory/Lorelai "Dean?"/"Rory" role-play
- **I12** Lorelai's "woman of mystery" for mystery
- **I13** Kirk "pink ribbon", "Kirk, sit down…"; Lane drummer and music-taste lines
- **I14** More Rory and Lorelai talking *about* Dean, Jess and Logan
- **I15** Loose quotes list: Zoltan Kamenei, Cat Kirk, "That's your cross to bear", "I'm in escarow", "Jess, are you a gigolo?", "Really? Cause I'm more of a suit guy" (see I20), Trix "You are bad", Kirk "We're not supposed to be arguing, Taylor…"
- **I26** **Mansion shot DMD image** (Inbox, Nov 25): a slide when you make the Mansion. None exists; the shot only plays a callout @ 07ea223. Pairs with I25.
- **I16** Cannonball line ("broke through the floor…")

**SFX**
- **I17** → moved to D37 (plates and cups) and R12 (crowd talking), per Stephen
- **I18** Scoop eject, spinner, "something started" and "something achieved" SFX (`sfx_victory` exists but isn't used)

---

## 4. Ideas you've implemented

**Modes**
- **D1** All six minigames exist and rotate: Dance Marathon, Town Meeting, Friday Night Dinner, Kim's Antiques, Luke Breaks the Bells, Founder's Day Punch
- **D2** Kim's Antiques uses the "only Miss Kim is solid" idea: avoid her, and the other shots score (reworked, see D44)
- **D3** Friday Night Dinner: shoot the orbits, with a hidden-kicker jackpot
- **D4** Town Meeting: flashing shots, then a trip to Luke's for coffee, plus a timer and deer and cart/kiosk sub-topics
- **D5** Luke Breaks the Bells: one lit bell at a time, chimes cut off on a hit, a breaking SFX, Luke's how-to intro, "Oh thank God"
- **D6** Dance Marathon: big light-show intro (`psc_dance_intro`), GI off, rotating shots
- **D7** Jess vs. Dean: To The Death: a ramp each, four hits on one ramp wins, jackpot then super jackpot
- **D8** Lock Away Logan: bumpers bash him, then return him to the captive spot to win; Rory's insult list plays on captive-ball hits
- **D9** Logan progress saved between balls as stages 0–3, without saving `logan_qualify_complete`, exactly as your note planned
- **D10** JESS/DEAN targets persist across balls and score a bank bonus when completed; all eight light the lock
- **D11** Hurry-up counts up and is collected at Luke's
- **D12** Skip intros with both flippers
- **D33** (was T2) Intro-skip reminder / trimming long intros: not pursuing further, closed (per Stephen)
- **D36** (was I8) Orbit catch into the bonus lanes / left-orbit rubber: something similar is already done (per Stephen)

**Table and presentation**
- **D13** Signs above each ramp with four lights each (`JessSign`/`DeanSign`, red and green)
- **D14** Grandparents' house named "Gilmore Mansion"
- **D15** Flasher warning before scoop ejects (`play_scoop_eject_show` on FL5)
- **D16** Shot themes: Luke's drop target says "We're closed", the diner door sound, Mansion callouts, stars "Stars"/"Hollow", slings "COPPER! BOOM!", drain "Oy with the poodles", "Coffee coffee coffee" on launch
- **D17** EOB tally of coffee cups, Luke's meals, Grandparents visits and fast-talking quips
- **D18** Attract carousel: last scores with credits or FREE PLAY, title, insert coins, grand champion, high scores, replay, game over (a Gilmore-styled image). Slides are built live, so new high scores show up.
- **D19** Initials: "We've got magic to do" music, "I've been calling him Truman!" on the award slide, and the music keeps going
- **D20** Sound buses with priorities
- **D32** (was R1) Most of the Twilight Zone–style attract details (per Stephen); the rest is T19
- **D34** (was T3) Inserting a coin shows the insert-coins slide: `credits_added` → `show_insert_coins` (`attract.vbs` line 47) @ 7147986; verify on the table
- **D38** (was T1) Mode timers pause while the scoop holds the ball: every mode timer (`dinner_mode`, `tm_mode`, `tm_lukes`, `kims_antiques_mode`, `move_miss_kim`, `lbtb_mode`, `shuffle_bells`, `fd_punch_mode`, `dm_mode`, `dm_shot`) pauses on `balldevice_scoop_ball_entered` and starts on `scoop_eject_show_complete` @ 1d433ea. **Verify:** the `start` also fires on the mode's own intro eject and on any scoop eject after the timer has finished (e.g. during `*_post_mode`). Check on the table that a finished timer doesn't start again.
- **D39** (was T7) Mystery slides outrank mode slides: mystery mode moved from priority 580 to 1200 (above both multiballs), and its slides are set to priority 1200 (`mystery.vbs` lines 6 and 90) @ 1d433ea
- **D40** Quick scoop re-shots now count as new entries: `EjectTimeout` dropped from 2000 to 300 ms (`_configuration.vbs` line 439) @ 1d433ea. **Verify** that a ball falling back out of a weak eject isn't counted as a new entry.
- **D41** (was B2) Hurry-up no longer overwrites mode panels: it has its own `hurryup` slide, updated every tick, and the mode moved from priority 240 to 1100, so it shows above both multiballs (`hurryup.vbs` lines 57–70, `display_config.vbs` line 236) @ 658829a. This also settles O1. **Verify** on the table that the mode panel comes back when the hurry-up ends or is collected.
- **D42** Mode timers pause during the hurry-up count: every timer in D38 pauses on `start_hurryup_timer` and starts again on `hurryup_is_over` @ 658829a. **Verify** the same edge as D38: a mode whose timer has already finished shouldn't start it again when `hurryup_is_over` fires.
- **D43** (was T18) Jess/Dean MB start slide rewritten to "SHOOT RAMPS TO SCORE", which also removes the TEAM LOGAN typo (`jd-multiball.vbs` line 37) @ 65d18aa
- **D44** (was I7) Kim's Antiques rework @ c7aac63: Miss Kim roams the six shots every 5 s, with the next shot flashing for 1 s first, and hitting her ends the mode. The right ramp is a jackpot (10X) while the Dean sign chases; collecting it unlights it, and any other safe shot scores 2X and relights it. Playfield scoring is 3X for the mode, and the survival award rose to 20X. Base mode now resets `scoring_multiplier` at every ball start.**Verify** the 3X on the table.
- **D45** (was B12) Mystery Jess/Dean MB can't start during a minigame: the `jd` award's condition now also requires `dance_marathon`, `town_meeting`, `dinner`, `kims_antiques`, `lbtb` and `fd_punch` to be inactive (`_scores.vbs` line 211) @ 1d1a3dc. Add-a-Ball is unchanged, and the lock path was already safe (`jd-multiball-qualify.vbs` line 17). **Verify** on the table that a mystery during a minigame never gives Jess/Dean MB.
- **D35** (was T16) Gameplay music separated from attract/EOB music; the loudness scripts live outside the repo (per Stephen)

**Callouts and music (one line per mode)**
- **D21** **Jess/Dean MB:** every clip in your bold lists exists and is wired (start, lock, lose, target, complete, ramp, win), plus `voc_tall`/`voc_exboyfriend`
- **D22** **Lock Away Logan:** every listed clip is wired (captive hit, 60 seconds, MB intro, progress, beat him, return him, lose); has its own music
- **D23** **Friday Night Dinner:** 10 shot callouts, 3 jackpot callouts, including "two glasses of wine" and "I'm not a bee"; has music
- **D24** **Founder's Day Punch:** 17 callouts, including "This is tasty", "fall in a hole", "his face to my face", "spank"; has music
- **D25** **Kim's Antiques:** 5 Mrs. Kim lines plus shared dance lines; has music
- **D26** **Town Meeting:** deer, cart/kiosk, gavel and more; has music
- **D27** **Luke Breaks the Bells:** 11 bell callouts, bell loop and guitar music
- **D28** **Dance Marathon:** dance callouts, Neeson, "flip all you want"; has music
- **D29** **Characters:** Sookie 4, Kirk 8 (including "naked" and "pants"), Lane 5, Paris 4
- **D30** **Base music rotation:** Go, Happy, Alternate, Book, How Much Longer, Maybe Next Week, Popcorn
- **D31** **Shoo** plays under the EOB bonus, and "Your enthusiasm shocks me" is on the hurry-up
- **D37** (was I17) Plates and cups clinking SFX (per Stephen)

*I can't tell from filenames which song each `mus_` file is. If your bold picks (One Line, Hero Takes a Fall, One Step Beyond, Time Bomb) are what's in those files, the music section is done.*

---

## 5. Ideas you've effectively chosen not to do

- **R1** → moved to D32 (done part) and T19 (still wanted), per Stephen
- **R2** **Kim's Antiques as "shoot the ramps"**. Replaced by "avoid Miss Kim".
- **R3** **Single-digit segment displays for the Jess v. Dean score**. Replaced by four-bulb signs.
- **R4** **Town Meeting "after N shots, go to Luke's"**. You built a 20-second timer instead.
- **R5** **"Coffee coffee coffee" on the spinner**. It plays on launch instead, and the spinner version is commented out.
- **R6** **Saving `logan_qualify_complete` between balls**. Rejected in the doc itself (no autofire to clear the captive ball).
- **R7** **Taylor gavel toy**. Your own note says "probably not".
- **R8** **Unpicked music alternatives**: Oh My Love, Hit Me With Your Best Shot, Girl From Mars, a Hep Alien clip
- **R9** → moved to I21 (not rejected, per Stephen)
- **R10** → moved to I22 (not rejected, per Stephen)
- **R11** (was I4) **Kirk & Lulu mode** (per Stephen)
- **R12** (was I17) **Crowd-talking SFX** (per Stephen)

---

## 6. My observations and answers to your questions

- **O1** **"Hurry-up slide overwrites a lot of stuff — why?!"** Hurry-up plays the shared `mode` slide at priority 1000 (`hurryup.vbs` line 58), and `star_light_group_on_complete` starts it even while a minigame or multiball is running. So it takes over that mode's own panel. Fix: don't start it while `modes.<minigame>.active` or either multiball is active, or give it its own slide at a priority below the mode slides. **Update @ 658829a:** it now has its own slide (D41).
- **O2** **"When I allow mystery in Jess/Dean, it immediately shot out the ball — why?"** `jd-multiball.vbs` (priority 1020) posts `release_scoop_hold` on every scoop entry, before mystery (580) ever sees it. **Update @ 1d433ea:** mystery is now priority 1200, so it hears the scoop entry before Jess/Dean MB (1020). Its `select_random_mystery` handler still requires both multiballs to be inactive (`mystery.vbs` line 15), so keep that condition if you ever want mystery allowed during multiball.
- **O3** **"Do I need conditions in minigame.vbs so minigames don't start?"** They're already there: every `start_<minigame>` requires both multiballs to be inactive.
- **O4** **"Can I stop the flashing minigame during multiball and pick a new one after?"** Yes. Post `clear_selected_minigame` on `mode_jd_multiball_started`/`mode_ll_multiball_started`, and `minigame_select_delay` on their `_stopped` events, the same way single-ball modes already do.
- **O5** **"Just pause the timer whenever the ball is in the hold."** GLF timers take `.Action = "pause"`. Add one control event on scoop entry and one `start` on the eject. Using `scoop_eject_show_complete` for the eject means the flasher warning doesn't eat clock. (Done this way @ 1d433ea; see D38.)
- **O6** **"Is the scoop-hold bug in GLF or in my usage?"** I can't be sure from the code. The symptom (the hold stops hearing `ball_enter` after its mode restarts) looks like a listener that isn't re-registered when the mode restarts, not a config mistake. Since you maintain a GLF fork, a minimal two-ball repro would settle it.
- **O7** **"Game Over in the Gilmore Girls font at low res?"** You've already done it: attract uses `game_over_128x32_gray.png`.
- **O8** **"Is that sneaking guitar cue Sam Phillips?"** Almost certainly. She scored the show, and those "la la" guitar cues are hers.
- **O9** **"Find a spot for How Much Longer."** It's already in the base-music rotation. If the sneaking guitar cue goes to the EOB tally instead, Shoo could move to post-ball.
- **O10** **Babette's meteorologists**: put it on the tilt warning. "Funny meteorologists" works as a joke about shaking the table, and the tilt path has no callout yet. The hurry-up start is a second choice. (I20, the secret skill shot, is now another option.)
- **O11** **Status report**: the usual convention is holding a flipper about 2 s during play. Both flippers together are taken by intro skip, so use one.
- **O12** **Changing the next mode with slings**: slings fire constantly, so they'd shuffle the mode nonstop. Most games use the lane-change flipper button or an inlane rollover. Your inlanes already light mystery, so a flipper press while the ball is in the plunger lane may be the cleanest choice. (That's now the plan in T10.)
- **O13** **Spotted in passing, worth a 10-second fix before the demo:** the Jess/Dean MB start slide says **"TEAM JESS: LEFT RAMP - TEAM LOGAN: RIGHT RAMP"** (`jd-multiball.vbs` line 37). It should say TEAM DEAN. (Fixed with the T18 rewrite, D43.)
- **O14** **The doc repeats itself.** The POST-BALL callouts, the Sookie math line and "we've got magic to do" each appear twice. Once these lists move here, the doc could shrink to a raw quotes inbox.

---

## 7. Sound inventory: registered but unused

*Checked @ 7147986. Every `voc_`/`sfx_`/`mus_` file in `starshollow/sounds` is registered in `_configuration.vbs`, and every registration has a file (256 of each). Of those, 21 are never played by any mode. Each one either gets a home or gets removed (T6).*

| Sound | Notes |
|---|---|
| `voc_babette_meteorologists` | T5; candidates I20, O10 |
| `voc_dean_causeidkillyou` | |
| `voc_youaimedforme` | |
| `voc_tm_central_nervous_system` | Town Meeting |
| `voc_tm_gavel_twinkle` | Town Meeting |
| `voc_jess_areyouupset` | |
| `voc_jess_asyouwish` | |
| `voc_jess_didntbringasmiletoyourface` | |
| `voc_jess_innocentboylikeme` | |
| `voc_jess_manipulator` | |
| `voc_jess_missyaleeditor` | |
| `voc_jess_shegotyouuncleluke` | |
| `voc_jess_wemadefunofguyslikethis` | |
| `voc_jess_westsidestorydean` | |
| `voc_jess_whatdoyouthinksgoingtohappen` | |
| `voc_jess_youcancountonmenow` | |
| `voc_jess_yougilmores` | |
| `voc_jess_yourhairlooksdifferent` | |
| `sfx_victory` | I18 ("something achieved") |
| `mus_magictodo1` | Initials use `mus_magictodo3` |
| `mus_magictodo2` | Initials use `mus_magictodo3` |
