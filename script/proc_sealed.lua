-- proc_sealed.lua

if not aux.SealedProcedure then
    aux.SealedProcedure = {}
    Sealed = aux.SealedProcedure
end
if not Sealed then
    Sealed = aux.SealedProcedure
end

-- CUSTOM CONSTANTS
TYPE_SEALED          = 0x40000000
SUMMON_TYPE_SEALED   = 0x41000000
REASON_SEALED        = 0x42000000

-- Procedure Sealed

-- c    = card
-- f   = filter (like 2 dragon card)

function Sealed.AddProcedure(c, f, count)
    -- Sealed Procedure
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(1176)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(Sealed.Condition(c, f, count))
    e1:SetTarget(Sealed.Target(c, f, count))
    e1:SetOperation(Sealed.Operation(c))
    c:RegisterEffect(e1)
end

function Sealed.SpValue(value)
    return  function(e,tp,eg,ep,ev,re,r,rp,c)
                return SUMMON_TYPE_SEALED, ZONES_EMZ + ZONES_MMZ - value
            end
end

function Sealed.Condition(c, f, count)
    return    function(e,tp,eg,ep,ev,re,r,rp)
                if c == nil then return false end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end -- excludes extra deck pendulum
                local tp = c:GetControler()
                if not c:IsCanBeSpecialSummoned(e, 0, tp, tp, false, false, POS_FACEUP_ATTACK) then return false end
                return Duel.IsExistingMatchingCard(f, tp, LOCATION_MZONE, 0, count, nil)
            end
end

function Sealed.Target(c, f, count)
    return  function(e,tp,eg,ep,ev,re,r,rp)
                if not c then return false end
                local sg = Duel.SelectMatchingCard(tp, f, tp, LOCATION_MZONE, 0, count, count, nil)
                sg:KeepAlive()
                e:SetLabelObject(sg)
                return true
            end
end

function Sealed.Operation(c)
    return  function(e,tp,eg,ep,ev,re,r,rp,c)
                local sg = e:GetLabelObject()
                c:SetMaterial(sg)

                local value = 0

                for tc in aux.Next(sg) do
                    value = value + (1 << tc:GetSequence())
				    Duel.SendtoGrave(tc, REASON_MATERIAL + REASON_SEALED)
                end

                e:SetValue(
                    function(e,tp,eg,ep,ev,re,r,rp,c)
                        return SUMMON_TYPE_SEALED, ZONES_EMZ + ZONES_MMZ - value
                    end)

				sg:DeleteGroup(e, c)

                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_FIELD)
                e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetRange(LOCATION_MZONE)
                e1:SetCode(EFFECT_DISABLE_FIELD)
                e1:SetCondition(
                    function()
                        return e:GetHandler():IsFaceup()
                    end)
                e1:SetOperation(
                    function()
                        return value
                    end)
                e1:SetReset(RESET_EVENT + RESET_LEAVE)
                c:RegisterEffect(e1)
            end
end