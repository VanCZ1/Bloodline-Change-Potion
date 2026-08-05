ScriptName BLCP_BloodlineChangeEffect Extends ActiveMagicEffect

; --- Properties ------------------------------------------------------------------------------------------------------

; BloodlineState:
; 0 = human
; 1 = werewolf
; 2 = vampire
; 3 = vampire lord
Int Property BloodlineState = -1 Auto
Spell Property ChangeGuardAbility Auto

BLCP_PlayerBloodlineManager Property PlayerBloodlineManager Auto

Float Property ChangeDelay = 3.0 AutoReadonly Hidden

; --- Events ----------------------------------------------------------------------------------------------------------

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If BloodlineState < 0 || BloodlineState > 3
		BLCP_Log.Error("BloodlineState must be 0 - 3.")
		Return
	EndIf

	If akTarget == Game.GetPlayer()
		TryChangePlayerBloodline()
	Else
		BLCP_Log.Info("Cannot change bloodline for NPC.")
	EndIf
EndEvent

; --- Functions -------------------------------------------------------------------------------------------------------

Function TryChangePlayerBloodline()
	If !PlayerBloodlineManager.CanChangePlayerBloodline()
		Debug.Notification("$BLCP_ChangeRejected")
		BLCP_Log.Info("Player state is not allowed.")
		Return
	EndIf
	If !IsPlayerControlsEnabled()
		Debug.Notification("$BLCP_ChangeRejected")
		BLCP_Log.Info("Player control is not enabled.")
		Return
	EndIf

	Actor playerRef = Game.GetPlayer()
	If !AcquireChangeGuard(playerRef)
		Debug.Notification("$BLCP_ChangeRepeated")
		Return
	EndIf
	Debug.Notification("$BLCP_ChangeStart")
	SwitchPlayerControls(False)

	Utility.Wait(ChangeDelay)
	Bool isSuccess = PlayerBloodlineManager.ChangePlayerBloodline(BloodlineState)

	SwitchPlayerControls(True)
	If isSuccess
		Debug.Notification("$BLCP_ChangeCompleted")
	Else
		Debug.Notification("$BLCP_ChangeFailed")
	EndIf
	ReleaseChangeGuard(playerRef)
EndFunction

Bool Function IsPlayerControlsEnabled()
	Return Game.IsMovementControlsEnabled() && Game.IsFightingControlsEnabled() && Game.IsSneakingControlsEnabled() \
	&& Game.IsMenuControlsEnabled() && Game.IsActivateControlsEnabled()
EndFunction

Function SwitchPlayerControls(Bool abEnable)
	If abEnable
		Game.EnablePlayerControls(abMovement = True, abFighting = True, abCamSwitch = False, abLooking = False, \
		abSneaking = True, abMenu = True, abActivate = True, abJournalTabs = False, aiDisablePOVType = 0)
	Else
		Game.DisablePlayerControls(abMovement = True, abFighting = True, abCamSwitch = False, abLooking = False, \
		abSneaking = True, abMenu = True, abActivate = True, abJournalTabs = False, aiDisablePOVType = 0)
	EndIf
EndFunction

Bool Function AcquireChangeGuard(Actor akTarget)
	If !akTarget
		Return False
	EndIf
	If akTarget.HasSpell(ChangeGuardAbility)
		Return False
	EndIf

	Return akTarget.AddSpell(ChangeGuardAbility, False)
EndFunction

Function ReleaseChangeGuard(Actor akTarget)
	If akTarget
		akTarget.RemoveSpell(ChangeGuardAbility)
	EndIf
EndFunction
