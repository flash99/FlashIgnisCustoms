-- c999000004.lua
-- Bob The Dog

local s,id=GetID()

function s.initial_effect(c)

    -- tohand
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1, id)
	e1:SetCondition(aux.TRUE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

    -- summon
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1, id)
	e2:SetCondition(aux.TRUE)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_series = {SET_DOGS}

local LOCATION_HDG = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE

function s.thfilter(c)
	return c:IsSetCard(SET_DOGS) and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_HDG, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HDG)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_HDG, 0, 1, 1, nil)
	if #g > 0 then
        Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, 0, 0, POS_FACEUP)
	end
end