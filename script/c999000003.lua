-- c999000003.lua
-- Natsu The Dog

local s,id=GetID()

function s.initial_effect(c)

    Sealed.AddProcedure(c, s.sealedcon, 2) -- 2 DOGS monster

    -- atkup
    local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.TRUE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

    -- summon
    local e2 = Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetDescription(1175)
    e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, id)
    e2:SetCondition(s.sumcon)
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)

end

s.listed_series = {SET_DOGS}

function s.sealedcon(c)
    return c:IsSetCard(SET_DOGS)
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    return 800
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    return e:GetHandler()
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc = e:GetHandler()
    local e1 = Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT + RESET_LEAVE)
	tc:RegisterEffect(e1)
end

function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.sumfilter(c)
	return c:IsSetCard(SET_DOGS)
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_EXTRA, 0, 1, nil)
    end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, 0, 0, POS_FACEUP, ZONES_MMZ)
	end
end