-- c999001001.lua
-- Traptrix Carniflora

local s,id = GetID()

function s.initial_effect(c)

    -- Sealed summon method
	c:EnableReviveLimit()
    Sealed.AddProcedure(c, s.sealedcon, 2) -- 2 level 4 insect and/or plant monster

    -- Unaffected by trap effects if a "trap hole" normal trap card is in GY, continuous effect
    local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

    -- Set "trap hole" normal trap
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	-- Summon
	local e3 = Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1, id)
	e3:SetCondition(s.sumcon)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)

end

s.listed_series = {SET_TRAP_HOLE, SET_TRAPTRIX}

-- sealed condition
function s.sealedcon(c)
    return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_INSECT) or c:IsRace(RACE_PLANT)) and c:IsLevel(4)
end

-- If this card was link summoned and if there is at least 1 "trap hole" normal trap card in GY
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
    local tc = e:GetHandler()
    local tp = tc:GetOwner()
	return tc:IsSealedSummoned() and Duel.IsExistingMatchingCard(s.immfilter, tp, LOCATION_GRAVE, 0, 1, nil)
end

-- Check for "Trap Hole" normal trap
function s.immfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsNormalTrap() and c:IsSetCard(SET_TRAP_HOLE)
end

-- Unaffected by trap effects
function s.efilter(e, te)
	return te:IsTrapEffect()
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local tc = e:GetHandler()
    local ep = tc:GetOwner() -- ep = effect player
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(ep) and Duel.IsExistingMatchingCard(s.setfilter, ep, LOCATION_GRAVE, 0, 1, nil)
end

-- Check for "Trap Hole" normal trap
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsNormalTrap() and c:IsSetCard(SET_TRAP_HOLE) and c:IsSSetable()
end

-- Activation legality
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then
        return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
end

-- Performing the effect of setting 1 "Trap Hole" normal trap from deck to S/T zones
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
        local tc = g:GetFirst()
		Duel.SSet(tp, tc)

        local e1 = Effect.CreateEffect(tc)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_DISABLE)
	    e1:SetRange(LOCATION_MZONE)
	    e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	    e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
	    tc:RegisterEffect(e1)
	end
end

-- filter for "Traptrix" monster in GY
function s.sumfilter(c, tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_TRAPTRIX) and not c:IsCode(id)
end


function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
    local tc = e:GetHandler()
    local tp = tc:GetOwner()
	return tc:IsSealedSummoned() and Duel.GetUsableMZoneCount(tp) > 0 and Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_GRAVE, 0, 1, nil, tp)
end


function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end


function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_GRAVE, 0, 1, 2, nil)
	if #g > 0 then
        Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, 0, 0, POS_FACEUP)
	end
end