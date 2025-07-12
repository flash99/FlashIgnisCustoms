-- c999001001.lua
-- Traptrix Carniflora

local s,id=GetID()

function s.initial_effect(c)

    Sealed.AddProcedure(c, s.sealedcon, 2) -- 2 level 4 insect and/or plant monster
end

function s.sealedcon(c)
    return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_INSECT) or c:IsRace(RACE_PLANT)) and c:IsLevel(4)
end