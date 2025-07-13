-- init.lua

-- scripts load
Duel.LoadScript("proc_lunar.lua")
Duel.LoadScript("proc_sealed.lua")

-- Custom Sets
SET_DOGS           = 0xc41

-- HelpFunction

function Card.IsSealedSummoned(c)
	return c:IsSummonType(SUMMON_TYPE_SEALED)
end

Debug.Message("Init message : ".. "Hello World")