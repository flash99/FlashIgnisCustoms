-- c999000002.lua

local s,id=GetID()

function s.initial_effect(c)

    Sealed.AddProcedure(c, s.sealedcon, 1) -- 1 normal monster
end

function s.sealedcon(c)
    return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_NORMAL)
end