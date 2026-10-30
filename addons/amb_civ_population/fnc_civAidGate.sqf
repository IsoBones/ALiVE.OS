#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civAidGate);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civAidGate
Description:
    Visibility predicate for the Give Food / Give Water entries that the
    `allowAidAnyone` Eden attribute adds to the ACE civilian branch
    (`addons/sys_acemenu/fnc_aceMenuCiv.sqf`) and to the scroll-wheel
    actions (`fnc_addCivilianInteraction.sqf`).

    Returns true only when:
      - the civInteractHandler exists and Allow Anyone To Give Aid is on, and
      - the local player carries an item from the module's Humanitarian Items
        list for the given type (or either type when none is given), matched
        without regard to case as case "giveItem" in fnc_civInteract does.

    Deliberately ignores `limitInteraction`: that list keeps the dialog
    (questions, commands, intel) to the listed players, while this option
    opens aid to everyone.

Parameters:
    _this select 0: STRING - "humratItems", "waterItems" or "" for either
                             (optional, default "")

Returns:
    BOOL - true if the aid entry should be shown

See Also:
    ALIVE_fnc_civInteract case "giveAid", ALIVE_fnc_civAceAuthGate

Author:
    Bones
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_itemType", "", [""]]];

if (isNil "ALiVE_civInteractHandler") exitWith { false };
if !([ALiVE_civInteractHandler, "allowAidAnyone", false] call ALiVE_fnc_hashGet) exitWith { false };

private _humanitarian = [ALiVE_civInteractHandler, "humanitarianData"] call ALiVE_fnc_hashGet;
if (isNil "_humanitarian") exitWith { false };

private _items = if (_itemType == "") then {
    ([_humanitarian, "humratItems", []] call ALiVE_fnc_hashGet) + ([_humanitarian, "waterItems", []] call ALiVE_fnc_hashGet)
} else {
    [_humanitarian, _itemType, []] call ALiVE_fnc_hashGet
};
if (_items isEqualTo []) exitWith { false };

private _wanted = _items apply { toLower _x };
(((vestItems player) + (uniformItems player) + (backpackItems player)) findIf { (toLower _x) in _wanted }) > -1
