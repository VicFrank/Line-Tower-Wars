magic_sentry = class({})
LinkLuaModifier("modifier_true_sight_aura", "abilities/buildings/magic_sentry.lua", LUA_MODIFIER_MOTION_NONE)

function magic_sentry:GetIntrinsicModifierName() return "modifier_true_sight_aura" end

modifier_true_sight_aura = class({})

function modifier_true_sight_aura:OnCreated()
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius")
    self.radius = radius
end

function modifier_true_sight_aura:IsAura()
    return true
end

function modifier_true_sight_aura:IsHidden()
    return true
end

function modifier_true_sight_aura:IsPurgable()
    return false
end

function modifier_true_sight_aura:GetAuraRadius()
    return self.radius
end

function modifier_true_sight_aura:GetModifierAura()
    return "modifier_truesight"
end
   
function modifier_true_sight_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_true_sight_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_true_sight_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_true_sight_aura:GetAuraDuration()
    return 0.1
end

function modifier_true_sight_aura:GetEffectName()
    return "particles/items2_fx/ward_true_sight.vpcf"
end

function modifier_true_sight_aura:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
