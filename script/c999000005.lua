-- c999000005.lua
-- Lea The Dog

local s,id=GetID()

function s.initial_effect(c)

    -- pos
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(s.poscon)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
end

s.listed_series = {SET_DOGS}

function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsRelateToBattle()
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end