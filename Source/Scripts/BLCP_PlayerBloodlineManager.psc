ScriptName BLCP_PlayerBloodlineManager Extends Quest

; --- Properties ------------------------------------------------------------------------------------------------------

EffectShader Property HumanChangeFXS Auto
Sound Property HumanChangeSound Auto

Race Property WerewolfBeastRace Auto
Spell Property WerewolfPower Auto
Spell Property WerewolfImmunity Auto
Spell Property WerewolfCureDisease Auto

Keyword Property VampireKeyword Auto
Spell Property VampireDiseaseSpell Auto

Race Property VampireLordRace Auto
Spell Property VampireLordPower Auto
Perk Property VampireTurnPerk Auto

CompanionsHousekeepingScript Property C00 Auto
PlayerWerewolfChangeScript Property PlayerWerewolfQuest Auto

PlayerVampireQuestScript Property PlayerVampireQuest Auto

DLC1PlayerVampireChangeScript Property DLC1PlayerVampireQuest Auto
DLC1VampireTrackingQuest Property VampireTrackingQuest Auto

; --- Functions -------------------------------------------------------------------------------------------------------

Bool Function ChangePlayerBloodline(Int aiBloodlineState)
	If aiBloodlineState < 0 || aiBloodlineState > 3
		Return False
	EndIf

	If !CanChangePlayerBloodline()
		Return False
	EndIf

	If aiBloodlineState == 0
		ChangePlayerToHuman()
	ElseIf aiBloodlineState == 1
		ChangePlayerToWerewolf()
	ElseIf aiBloodlineState == 2
		ChangePlayerToVampire()
	ElseIf aiBloodlineState == 3
		ChangePlayerToVampireLord()
	EndIf

	Return True
EndFunction

Bool Function CanChangePlayerBloodline()
	Actor playerRef = Game.GetPlayer()
	If playerRef.IsDead()
		Return False
	EndIf
	If playerRef.IsBleedingOut() || playerRef.IsInKillMove() || playerRef.IsOnMount()
		Return False
	EndIf
	If IsPlayerInBeastForm() || IsPlayerBeastFormTransitioning()
		Return False
	EndIf

	Return True
EndFunction

Function ChangePlayerToHuman()
	CurePlayerWerewolf()
	CurePlayerVampire()

	Actor playerRef = Game.GetPlayer()

	; werewolf, vampire don't need this, their scripts already has FX
	HumanChangeFXS.Play(playerRef, 1.5)
	HumanChangeSound.Play(playerRef)
EndFunction

Function ChangePlayerToWerewolf()
	CurePlayerVampire()

	Actor playerRef = Game.GetPlayer()

	WerewolfCureDisease.Cast(playerRef)
	playerRef.AddSpell(WerewolfImmunity, False)
	playerRef.AddSpell(WerewolfPower, True)
	C00.TempUnderforgeAccess = True
	C00.PlayerHasBeastBlood = True
	playerRef.SendLycanthropyStateChanged(True)

	C00.PlayerOriginalRace = playerRef.GetRace()
EndFunction

Function ChangePlayerToVampire()
	CurePlayerWerewolf()

	Actor playerRef = Game.GetPlayer()

	If !IsVampireRace(playerRef)
		PlayerVampireQuest.VampireChange(playerRef)
	EndIf
	playerRef.RemoveSpell(VampireLordPower)
EndFunction

Function ChangePlayerToVampireLord()
	CurePlayerWerewolf()

	Actor playerRef = Game.GetPlayer()

	If !IsVampireRace(playerRef)
		PlayerVampireQuest.VampireChange(playerRef)
	EndIf
	playerRef.AddSpell(VampireLordPower, True)
	playerRef.AddPerk(VampireTurnPerk) ; Unused perk, vanilla cure doesn't remove it

	VampireTrackingQuest.PlayerRace = playerRef.GetRace()
EndFunction

Function CurePlayerWerewolf()
	If C00.PlayerHasBeastBlood
		C00.CurePlayer()
	EndIf

	Actor playerRef = Game.GetPlayer()
	playerRef.RemoveSpell(WerewolfPower)
	playerRef.RemoveSpell(WerewolfImmunity)

	C00.PlayerOriginalRace = None
EndFunction

Function CurePlayerVampire()
	Actor playerRef = Game.GetPlayer()

	If IsVampireRace(playerRef)
		PlayerVampireQuest.VampireCure(playerRef)
	EndIf
	playerRef.RemoveSpell(VampireDiseaseSpell)
	playerRef.RemoveSpell(VampireLordPower)

	VampireTrackingQuest.PlayerRace = None
EndFunction

Bool Function IsPlayerInBeastForm()
	Race playerRace = Game.GetPlayer().GetRace()
	If !playerRace
		Return False
	EndIf

	If playerRace == WerewolfBeastRace || playerRace == VampireLordRace
		Return True
	EndIf

	Return False
EndFunction

Bool Function IsPlayerBeastFormTransitioning()
	If PlayerWerewolfQuest.IsRunning()
		Int werewolfStage = PlayerWerewolfQuest.GetStage()
		If werewolfStage < 10 || werewolfStage >= 100
			Return True
		EndIf
	EndIf

	If DLC1PlayerVampireQuest.IsRunning()
		Int vampireLordStage = DLC1PlayerVampireQuest.GetStage()
		If vampireLordStage < 10 || vampireLordStage >= 100
			Return True
		EndIf
	EndIf

	Return False
EndFunction

Function RevertPlayerBeastForm()
	If PlayerWerewolfQuest.IsRunning()
		If PlayerWerewolfQuest.GetStage() < 100
			PlayerWerewolfQuest.SetStage(100)
		EndIf
	EndIf

	If DLC1PlayerVampireQuest.IsRunning()
		If DLC1PlayerVampireQuest.GetStage() < 100
			DLC1PlayerVampireQuest.SetStage(100)
		EndIf
	EndIf
EndFunction

Bool Function IsVampireRace(Actor akTarget)
	If !akTarget
		Return False
	EndIf

	Race targetRace = akTarget.GetRace()
	If !targetRace
		Return False
	EndIf

	Return targetRace.HasKeyword(VampireKeyword)
EndFunction
