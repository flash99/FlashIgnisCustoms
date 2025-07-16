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

	-- Set trap
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.IsSyncSum)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	-- Negate Effect
	local e3 = Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, id)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)

	-- to hand
	local e4 = Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.IsSyncSum)
	e4:SetTarget(s.tohandtg)
	e4:SetOperation(s.tohandop)
	c:RegisterEffect(e4)
end

s.listed_series = {SET_TRAP_HOLE, SET_HOLE, SET_TRAPTRIX}

function s.immfilter(e, te)
	local c = te:GetHandler()
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE, SET_TRAP_HOLE})
end

function s.setfilter(c)
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE, SET_TRAP_HOLE}) and c:IsSSetable()
end

function s.IsSyncSum(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSynchroSummoned()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil) end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SSet(tp, g:GetFirst())
	end
end

function s.disfilter(c)
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE, SET_TRAP_HOLE}) and c:IsAbleToRemoveAsCost()
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.disfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk == 0 then return Duel.IsExistingTarget(Card.IsNegatable, tp, 0, LOCATION_ONFIELD, 1, nil) end
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local ToRemoveG = Duel.SelectMatchingCard(tp, s.disfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
	local ToDisableG = Duel.SelectMatchingCard(tp, Card.IsNegatable, tp, 0, LOCATION_ONFIELD, 1, 1, nil)

	Duel.Remove(ToRemoveG, POS_FACEUP, REASON_EFFECT)

	tc = ToDisableG:GetFirst()
	if not tc:IsCanBeDisabledByEffect(e) then return end
	Duel.NegateRelatedChain(tc, 0)
			
	--Negate its effects
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)

	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	e2:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e2)

	local pos = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
	if c:IsRelateToEffect(e) and pos & POS_FACEDOWN > 0 then
		Duel.BreakEffect()
		c:RegisterFlagEffect(id, RESET_CHAIN, 0, 0)
	end
end

function s.tohandfilter(c)
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE, SET_TRAP_HOLE})
end

function s.tohandtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.tohandfilter, tp, LOCATION_REMOVED, 0, 1, nil) end
end

function s.tohandop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	local g = Duel.SelectMatchingCard(tp, s.tohandfilter, tp, LOCATION_REMOVED, 0, 1, 1, nil)
	Duel.SendtoHand(g, tp, REASON_EFFECT)
	Duel.ConfirmCards(tp, g)
end