-- c42424242.lua

local s,id=GetID()

function s.initial_effect(c)
    -- Win the duel
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(0) -- "Gagnez le Duel"
    e1:SetCategory(CATEGORY_DRAW) -- Placeholder
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F + EFFECT_TYPE_FIELD + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCondition(aux.TRUE)
    e1:SetTarget(s.wintg)
    e1:SetOperation(s.winop)
    c:RegisterEffect(e1)
end

function s.wintg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return true end
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Win(tp, REASON_EFFECT)
end