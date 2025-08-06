-- c999002001.lua
-- Poupée Truquée Manipulateur Souterrain

local s,id = GetID()

function s.initial_effect(c)
    -- Sealed summon method
    c:EnableReviveLimit()
    Sealed.AddProcedure(c, s.sealedcon, 2) -- 2 level 4 Gimmick Puppet

    --Attach 1 Special Summoned monster to this card
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    --e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

s.listed_series = {SET_PUPPET}

-- sealed condition
function s.sealedcon(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_PUPPET)
end

function s.filter(c)
    return c:IsPosition(POS_FACEUP) and c:IsAbleToChangeControler()
        and not c:IsType(TYPE_TOKEN) and c:IsSpecialSummoned()
end

function s.setfilter(c)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_PUPPET)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_MZONE, 0, 1, nil) --e:GetHandler():IsSealedSummoned()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil)
		and e:GetHandler():IsSealedSummoned()
		and Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_MZONE, 0, 1, nil)
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc = Duel.GetFirstTarget()
    local g = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    if #g > 0 and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        Duel.Overlay(g:GetFirst(),tc,true)
    end
end