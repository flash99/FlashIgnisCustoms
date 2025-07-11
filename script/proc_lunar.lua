-- proc_lunar.lua

if not aux.LunarProcedure then
    aux.LunarProcedure = {}
    Lunar = aux.LunarProcedure
end
if not Lunar then
    Lunar = aux.LunarProcedure
end

-- CUSTOM CONSTANTS
TYPE_LUNAR          = 0x20000000
SUMMON_TYPE_LUNAR   = 0x21000000
REASON_LUNAR        = 0x22000000
SET_LUNAR           = 0xc40
-- Zones dec :
--    32 |   | 64
-- 1 | 2 | 4 | 8 | 16
ZONES_LUNAR         = 0x11


-- Procedure Lunar

-- c    = card
-- mc   = magic count (number of magic to discard)

function Lunar.AddProcedure(c, mc)
    -- Lunar Procedure
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(1175)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Lunar.Condition(c, mc))
    e1:SetTarget(Lunar.Target(c, mc))
    e1:SetOperation(Lunar.Operation(c, mc))
    e1:SetValue(Lunar.SpValue())
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_DISABLE_FIELD)
    e2:SetOperation(Lunar.disop)
    c:RegisterEffect(e2)
end

function Lunar.SpValue()
    return  function(e,tp,eg,ep,ev,re,r,rp,c)
                return SUMMON_TYPE_LUNAR, ZONES_LUNAR
            end
end

function Card.IsCanBeLunarMaterial(c)
    return c:IsType(TYPE_SPELL) and c:IsLocation(LOCATION_HAND)
end

function Lunar.Condition(ac, mc)
    return    function(e,tp,eg,ep,ev,re,r,rp)
                if ac == nil then return false end
				if ac:IsType(TYPE_PENDULUM) and ac:IsFaceup() then return false end -- excludes extra deck pendulum
                local tp = ac:GetControler()
                if not ac:IsCanBeSpecialSummoned(e, 0, tp, tp, false, false, POS_FACEUP_ATTACK) then return false end
                return Duel.IsExistingMatchingCard(Card.IsCanBeLunarMaterial, tp, LOCATION_HAND, 0, mc, nil)
            end
end

function Lunar.Target(ac, mc)
    return  function(e,tp,eg,ep,ev,re,r,rp)
                if not ac then return false end
                local sg = Duel.SelectMatchingCard(tp, Card.IsCanBeLunarMaterial, tp, LOCATION_HAND, 0, mc, mc, nil)
                sg:KeepAlive()
                e:SetLabelObject(sg)
                return true
            end
end

function Lunar.Operation(ac, mc)
    return  function(e,tp,eg,ep,ev,re,r,rp,c)
                local sg = e:GetLabelObject()
                ac:SetMaterial(sg)
				Duel.SendtoGrave(sg, REASON_MATERIAL + REASON_LUNAR)
				sg:DeleteGroup(e, c)
            end
end

function Lunar.disop(e,tp,eg,ep,ev,re,r,rp)
	return ZONES_LUNAR - (1 << e:GetHandler():GetSequence())
end