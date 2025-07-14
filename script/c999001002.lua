-- c999001002.lua
-- Traptrix Apex 

local s,id = GetID()

function s.initial_effect(c)

    -- Sealed summon method
	c:EnableReviveLimit()
    Sealed.AddProcedure(c, s.sealedcon, 1) -- 5 level 4 insect and/or plant monster

    -- Unaffected by opponent effects, continuous effect
    local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.immcon)
	e1:SetValue(aux.TRUE)
	c:RegisterEffect(e1)

    -- Activate "trap hole" normal trap from deck
    local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0, TIMING_STANDBY_PHASE | TIMING_MAIN_END | TIMING_BATTLE_START | TIMING_MSET | TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(s.effcost)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)

	-- Negate the effects of all face-up monsters the opponent controls
	local e3a=Effect.CreateEffect(c)
	e3a:SetCategory(CATEGORY_DISABLE)
	e3a:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_DESTROYED)
	e3a:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
	e3a:SetTarget(s.distg)
	e3a:SetOperation(s.disop)
	c:RegisterEffect(e3a)
end

s.listed_names={id}
s.listed_series={SET_TRAPTRIX, SET_TRAP_HOLE, SET_HOLE}

-- sealed condition
function s.sealedcon(c)
    return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_INSECT) or c:IsRace(RACE_PLANT)) and c:IsLevel(4)
end

-- If this card was link summoned and if there is at least 1 "trap hole" normal trap card in GY
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSealedSummoned()
end

function s.copyfilter(c)
	return c:IsNormalTrap() and c:IsSetCard({SET_HOLE, SET_TRAP_HOLE}) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false, true, true) ~= nil
end

function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then
		--Storing the legal group before detaching due to rulings (Q&A #16286)
		local g=Duel.GetMatchingGroup(s.copyfilter, tp, LOCATION_DECK, 0, nil)
		e:SetLabelObject(g)
		return #g > 0
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local sc=e:GetLabelObject():Select(tp, 1, 1, nil):GetFirst()
	e:SetLabelObject(sc)
	Duel.SendtoGrave(sc, REASON_COST)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te, ceg, cep, cev, cre, cr, crp = table.unpack(e:GetLabelObject())
		return te and te:GetTarget() and te:GetTarget()(e, tp, ceg, cep, cev, cre, cr, crp, chk, chkc)
	end
	if chk==0 then
		local res = e:GetLabel()==-100
		e:SetLabel(0)
		return res
	end
	local sc = e:GetLabelObject()
	local te, ceg, cep, cev, cre, cr, crp = sc:CheckActivateEffect(true, true, true)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg = te:GetTarget()
	if tg then
		e:SetProperty(te:GetProperty())
		tg(e, tp, ceg, cep, cev, cre, cr, crp, 1)
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
		Duel.ClearOperationInfo(0)
	end
	e:SetLabel(0)
	e:SetLabelObject({te, ceg, cep, cev, cre, cr, crp})
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local te, ceg, cep, cev, cre, cr, crp = table.unpack(e:GetLabelObject())
	if not te then return end
	local op = te:GetOperation()
	if op then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		op(e, tp, ceg, cep, cev, cre, cr, crp)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsNegatableMonster() end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsNegatableMonster, tp, 0, LOCATION_MZONE, 1, nil) end
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)

	local count = Duel.GetTargetCount(Card.IsNegatableMonster, tp, 0, LOCATION_MZONE, 1, nil)

	local g = Duel.GetMatchingGroup(Card.IsNegatableMonster, tp, 0, LOCATION_MZONE, 1, nil)

	-- local g = Duel.SelectTarget(tp, Card.IsNegatableMonster, tp, 0, LOCATION_MZONE, count, count, nil)
	Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, count, 0, 0)
	local pos = e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsPreviousPosition(POS_FACEDOWN) and POS_FACEDOWN or 0
	Duel.SetTargetParam(pos)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local g = Duel.GetMatchingGroup(Card.IsNegatableMonster, tp, 0, LOCATION_MZONE, 1, nil)

	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
			Duel.NegateRelatedChain(tc, 0)
			--Negate its effects
			local e1 = Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			-- e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)

			local e2 = Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			-- e2:SetValue(RESET_TURN_SET)
			-- e2:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e2)

			local pos = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)

			if c:IsRelateToEffect(e) and pos & POS_FACEDOWN > 0 then
				Duel.BreakEffect()
				c:RegisterFlagEffect(id, RESET_CHAIN, 0, 0)
				-- --Negate Spell/Trap effects in the same column
				-- local e3=Effect.CreateEffect(c)
				-- e3:SetType(EFFECT_TYPE_FIELD)
				-- e3:SetCode(EFFECT_DISABLE)
				-- e3:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
				-- e3:SetTarget(s.distg)
				-- e3:SetReset(RESET_PHASE|PHASE_END)
				-- e3:SetLabel(c:GetSequence())
				-- Duel.RegisterEffect(e3,tp)
				-- local e4=e3:Clone()
				-- e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				-- Duel.RegisterEffect(e4,tp)
				-- local e5=Effect.CreateEffect(c)
				-- e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				-- e5:SetCode(EVENT_CHAIN_SOLVING)
				-- e5:SetOperation(s.disop)
				-- e5:SetReset(RESET_PHASE|PHASE_END)
				-- e5:SetLabel(c:GetSequence())
				-- Duel.RegisterEffect(e5,tp)
				-- local zone=1<<(c:GetSequence()+8)
				-- Duel.Hint(HINT_ZONE,tp,zone)
			end
		end
	end
end