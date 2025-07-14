-- c999001002.lua
-- Traptrix Apex Predatrix

local s,id = GetID()

function s.initial_effect(c)

    -- Sealed summon method
	c:EnableReviveLimit()
    Sealed.AddProcedure(c, s.sealedcon, 5) -- 5 level 4 insect and/or plant monster

    -- Untargetable by opponent effects, continuous effect
    local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.issealedcon)
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
	local e3a = Effect.CreateEffect(c)
	e3a:SetCategory(CATEGORY_DISABLE)
	e3a:SetDescription(aux.Stringid(id, 0))
	e3a:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_DESTROYED)
	e3a:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
	e3a:SetTarget(s.distg)
	e3a:SetOperation(s.disop)
	c:RegisterEffect(e3a)

	-- Discard opponent cards for each "trap hole" normal trap on GY
	local e3b = Effect.CreateEffect(c)
	e3b:SetCategory(CATEGORY_TOGRAVE)
	e3b:SetDescription(aux.Stringid(id, 1))
	e3b:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e3b:SetProperty(EFFECT_FLAG_DELAY)
	e3b:SetCode(EVENT_DESTROYED)
	e3b:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
	e3b:SetTarget(s.togravetg)
	e3b:SetOperation(s.tograveop)
	c:RegisterEffect(e3b)
end

s.listed_names={id}
s.listed_series={SET_TRAPTRIX, SET_TRAP_HOLE, SET_HOLE}

-- sealed condition
function s.sealedcon(c)
    return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_INSECT) or c:IsRace(RACE_PLANT)) and c:IsLevel(4)
end

-- If this card was link summoned and if there is at least 1 "trap hole" normal trap card in GY
function s.issealedcon(e,tp,eg,ep,ev,re,r,rp)
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
		local g = Duel.GetMatchingGroup(s.copyfilter, tp, LOCATION_DECK, 0, nil)
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
	if not e:GetHandler():IsSealedSummoned() then return false end
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsNegatable() end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsNegatable, tp, 0, LOCATION_ONFIELD, 1, nil) end
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
	local g = Duel.GetMatchingGroup(Card.IsNegatable, tp, 0, LOCATION_ONFIELD, 1, nil)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local g = Duel.GetMatchingGroup(Card.IsNegatable, tp, 0, LOCATION_ONFIELD, 1, nil)

	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
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
	end
end

-- "trap hole" trap filer
function s.trapfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsNormalTrap() and c:IsSetCard(SET_TRAP_HOLE)
end

function s.togravetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD + LOCATION_HAND)
	local og = Duel.GetFieldGroup(tp, LOCATION_GRAVE, 0)
	local fg = og:Filter(s.trapfilter, nil)
	if chk == 0 then return #fg > 0 and g:IsExists(Card.IsAbleToGrave, 1, nil, 1-tp, POS_FACEUP, REASON_RULE) end
end

function s.tograveop(e,tp,eg,ep,ev,re,r,rp) -- debug that now
	local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD + LOCATION_HAND)
	local og = Duel.GetFieldGroup(tp, LOCATION_GRAVE, 0)
	local fg = og:Filter(s.trapfilter, nil)
	if #fg > 0 then
		Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_TOGRAVE)
		local sg = g:FilterSelect(1-tp, Card.IsAbleToGrave, #fg, #fg, nil, 1-tp, POS_FACEUP, REASON_RULE)
		Duel.SendtoGrave(sg, REASON_RULE, PLAYER_NONE, 1-tp)
	end
end