-- c999001003.lua
-- Traptrix Sericaria

local s,id = GetID()

function s.initial_effect(c)

	-- Unaffected by "Hole" normal trap cards
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.immfilter)
	c:RegisterEffect(e1)

	-- Upon normal summon, add 1 "Traptrix" monster
	local e2 = Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.nscon)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)

	-- Add 1 Traptrix monster from GY
	local e3 = Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1, {id,1})
	e3:SetCondition(s.sscon)
	e3:SetOperation(s.ssop)
	c:RegisterEffect(e3)
end

s.listed_series = {SET_TRAP_HOLE, SET_HOLE, SET_TRAPTRIX}

function s.immfilter(e, te)
	local c = te:GetHandler()
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE, SET_TRAP_HOLE})
end

function s.nscon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsPlayerCanDraw(tp)
end

function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp, 1, REASON_EFFECT)
end

function s.ssfilter(c)
	return c:IsSetCard(SET_TRAPTRIX) and not c:IsCode(id)
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsExistingTarget(s.ssfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.SelectMatchingCard(tp, s.ssfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, 0)
	Duel.SendtoHand(g, tp, REASON_EFFECT)
	Duel.ConfirmCards(tp, g)
end