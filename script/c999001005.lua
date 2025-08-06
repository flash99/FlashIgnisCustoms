-- c999001005.lua
-- Trappe Control

local s,id = GetID()

function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

s.listed_series = {SET_TRAP_HOLE, SET_TRAPTRIX}

function s.TraptrixFilter(c)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsAbleToChangeControler()
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	local sc = eg:GetFirst()
	local p = e:GetHandlerPlayer()
	return sc:IsControler(1-p)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-ep) and chkc:IsFaceup() and c:IsAbleToChangeControler() end
	if chk == 0 then return Duel.IsExistingTarget(s.TraptrixFilter, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
	Duel.SetTargetCard(eg:GetFirst())
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc = eg:GetFirst()
	local g = Duel.SelectMatchingCard(1-tp, s.TraptrixFilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	local cc = g:GetFirst()
	if Duel.SwapControl(tc, cc, PHASE_END, 1) then
		Debug.Message(cc:GetType())
		if cc:IsType(TYPE_SYNCHRO) then
			local c = e:GetHandler()
			if not c:IsRelateToEffect(e) then return end
			if c:IsSSetable(true) then
				Duel.BreakEffect()
				c:CancelToGrave()
				Duel.ChangePosition(c, POS_FACEDOWN)
				Duel.RaiseEvent(c,EVENT_SSET, e, REASON_EFFECT, tp, tp, 0)
			end
		end
	end
end