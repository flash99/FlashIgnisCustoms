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
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

end

s.listed_series = {SET_TRAP_HOLE}

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
    local tp = tc:GetOwner()
	return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_GRAVE, 0, 1, nil)
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
	    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	    e1:SetRange(LOCATION_MZONE)
	    e1:SetCode(EFFECT_IMMUNE_EFFECT)
	    e1:SetCondition(s.immcon)
	    e1:SetValue(s.efilter)
	    tc:RegisterEffect(e1)
	end
end