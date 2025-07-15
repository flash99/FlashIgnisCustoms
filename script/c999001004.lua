-- c999001004.lua
-- Traptrix Myrmeleonides

local s,id = GetID()

function s.initial_effect(c)

	-- Synchro summon
	Synchro.AddProcedure(c, aux.TRUE, 1, 1, Synchro.NonTuner(aux.FilterBoolFunctionEx(Card.IsSetCard, SET_TRAPTRIX)), 1, 1)
	c:EnableReviveLimit()

	-- Unaffected by "Hole" normal trap cards
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.immfilter)
	c:RegisterEffect(e1)
end

s.listed_series = {SET_TRAP_HOLE, SET_HOLE, SET_TRAPTRIX}

function s.immfilter(e, te)
	local c = te:GetHandler()
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE, SET_TRAP_HOLE})
end