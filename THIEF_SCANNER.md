# How pickpocketing works TLDR
Game implements pickpocketing mechanic purely as info scripts (infos) which are, simplifying, dialogue choices. 

Each info encapsulates information such as:
- NPC associated with the given dialogue option
- condition script/function to determine if given info can be picked by the player; 
- script/function to run when dialogue choice is selected; this usually just makes NPCs say appropriate dialogue lines in correct order but can also display a sub-choice (for example: attempt pickpocketing or back off) or execute the actual pickpocketing;
- Description i.e. text player see in the dialogue choices box
- Other metadata like whether info is known to Hero already, whether info is permanent i.e. can be selected multiple times as long as its condition is met or a number used for ordering dialogue choices

While this implementation makes total sense from developer's perspective, using such a generic abstraction for pickpocketing makes extracting useful information for plugins difficult.

# Problems, challenges and solutions
## How to determine if info is pickpocketing one?
Infos don't have any property to clearly identify them as pickpocketing one. Thankfully most of them follow the convention of ending with `_PICKPOCKET` suffix. However, because of "reasons", Cassia's `DIA_Cassia_PICKPOCKET` info is an exception and is actually responsible for the "teach me pickpocketing skill" dialogue... Her actual pickpocketing info is `DIA_Cassia_PICKME`. One exception is managable but if the plugin is used together with any mods introducing new content/NPCs which can be pickpocketed, and the mod deviates from the convention, then it breaks plugin's functionality.
### Solution
Things are kept simple, whenever init function is called, all infos ending with `_PICKPOCKET` or `_PICKME` are scanned and lookup table NPC to Info is built. The latter suffix is prioritized.

## How to determine if NPC was pickpocketed before?
This one is actually easy - there's an AI var `AIV_PlayerHasPickedMyPocket` which is set on successful pickpocket.

## How to determine if player meets the requirements for pickpocketing?
All interesting stuff like dexterity requirements or pickpocketable item are buried in the **source code** of pickpocket scripts. Dexterity thresholds are hardcoded and not exposed in any constants.

### Solution
One could maybe parse game's script source to extract these but it feels a bit too complex to even bother trying... Instead, a different heuristic is used.

Since plugin has an easy access to info's condition function, it can be called to make some kind of educated guess. 
From my observations, pickpocketing dialogue choice is shown as soon as Hero is **at most** 10 dexterity points (or to be precise, value of `TheftDiff` constant) short to succeed. If hero's dexterity is temporarly lowered by 10 just before calling the condition and it still returns true, then plugin assumes Hero has enough dex to rob given NPC. 

However, software is never easy, and turns out some (and what's worse - not all) NPCs whose dex requirements is less or equal 20 points, can be pickpocketed with as little as 10 dexterity... This seems like a bug in the original game scripts; either way - in the case Hero's dexterity is less or equal 20, plugin will assume that success of pickpocketing attempt is indeterminable.

This information is exposed to XPNPCLocator so whenever NPC is processed, if they are still pickpocketable (info was found and AI var is false), pickpocket tracker is used and color is determined based on the above algorithm.

## What about NPCs player can still keys or quest items from?
Majority of pickpockets reward Hero with gold that gets spawned out of thin air in NPC pockets. However, some NPCs only allow stealing a specific item. 
Condition scripts do check if the item is held by NPC in their inventory. If player knocks such NPC and loots the item then they will lock themselves from pickpocketing. 
### Solution
To detect such cases and keep the feature as generic as possible (no hard coding allowed) NPCs with pickpocket infos are scanned as follows:
1. If NPC was pickpocketed (AI var) then NPC is skipped;
2. If NPC is dead and alert wasn't triggered yet then failure alert is displayed
3. Otherwise Hero's dexterity gets temporarly boosted to 9999 (so dexterity requirements are no longer a factor)
4. Condition function is called;
    - If it returns true then it's all right
    - If it returns false then
        - If NPC is scanned for the first time then it gets added to the lookup of NPCs who were not observed to be pickpocketable
        - Otherwise plugin assumes NPC was looted and issues a warning alert (unless the lookup above contains the NPC)
5. Hero's dexterity is restored back to where it was.

The special lookup is used because of some exceptional/bugged NPCs like Edda who must be given an item first (Edda's Innos Status) in order to become pickpocketable (however, in the vanilla game that statue cannot be obtained) or Igaraz who can have chest key pickpocketed during the quest to retrieve Babo's pictures.

One may wonder if tampering with player's dexterity won't cause any issues. 
My thinking is it should be fine because zEngine processes all logic on a single thread and parser doesn't interrupt execution of scripts (unless they explicitly yield). Hence the temporarly set state should never leak outside of the plugin's function call.

## What about NPCs player can no longer/never talk to?
Cases like when Ehnim/Egil are turned against each other and later refuse to speak with Hero are currently **not supported**. I am not sure if this can be done by any other way than collecting a full list of all cases when this can happen (*insert sad face here*). And even that is not straightforward because conditions for those infos require NPCs being in ZS_Talk state and I'd rather not tamper with temporarly setting NPCs state (might interrupt want they're currently doing and lead to bugs).

There're NPCs that cannot be talked to at all like Sonja, Vanja (unless Hero joins the militia and does the weed quest), Skinner, Edda (bugged). For those NPCs blacklist is used.