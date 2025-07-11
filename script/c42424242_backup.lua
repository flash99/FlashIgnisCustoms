-- c42424242.lua
-- Script pour la carte "Victoire Instantanée"

-- Définition de l'ID de la carte et de la table de fonctions
local s_card = {id = 42424242}

-- Fonction principale pour initialiser la carte
function s_card.initial_effect(c)
    -- Enregistre un effet qui se déclenche lorsque la carte est invoquée
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(s_card.id, 0)) -- <-- MODIFICATION ICI : utilise s_card.id
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F + EFFECT_TYPE_FIELD)
    e1:SetCode(EVENT_SUMMON_SUCCESS) -- Gardons EVENT_SUMMON_SUCCESS pour la polyvalence
    e1:SetCondition(s_card.wincon)
    e1:SetTarget(s_card.wintg)
    e1:SetOperation(s_card.winop)
    c:RegisterEffect(e1)
end

-- Condition de l'effet : toujours vrai si la carte est invoquée
function s_card.wincon(e, tp, eg, ep, ev, re, r, rp)
    return true
end

-- Cible de l'effet (ici, pas de cible spécifique, juste une vérification)
function s_card.wintg(e, tp, eg, ep, ev, re, r, rp, chk, chklen, bfd, mtg, bff)
    if chk == 0 then return true end
end

-- Opération de l'effet : Gagner le duel
function s_card.winop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Win(tp)
end