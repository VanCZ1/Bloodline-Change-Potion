ScriptName BLCP_Log Hidden

; --- Functions -------------------------------------------------------------------------------------------------------

Function Info(String asMsg) Global
	Debug.Trace("[BloodlineChangePotion] " + asMsg, 0)
EndFunction

Function Warn(String asMsg) Global
	Debug.Trace("[BloodlineChangePotion] " + asMsg, 1)
EndFunction

Function Error(String asMsg) Global
	Debug.Trace("[BloodlineChangePotion] " + asMsg, 2)
EndFunction

Function ErrorStack(String asMsg) Global
	Debug.TraceStack("[BloodlineChangePotion] " + asMsg, 2)
EndFunction
