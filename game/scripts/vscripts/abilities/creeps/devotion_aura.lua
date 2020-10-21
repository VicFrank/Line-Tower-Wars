devotion_aura = class({})

LinkLuaModifier("modifier_devotion_aura", "abilities/creeps/devotion_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_devotion_aura_buff", "abilities/creeps/devotion_aura", LUA_MODIFIER_MOTION_NONE)

function devotion_aura:GetIntrinsicModifierName()
    return "modifier_devotion_aura"
end

--------------------------------------------------------------------------------

modifier_devotion_aura = class({})

function modifier_devotion_aura:IsAura()
    return true
end

function modifier_devotion_aura:IsHidden()
    return true
end

function modifier_devotion_aura:IsPurgable()
    return false
end

function modifier_devotion_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_devotion_aura:GetModifierAura()
    return "modifier_devotion_aura_buff"
end

function modifier_devotion_aura:GetEffectName()
    return "particles/custom/aura_devotion.vpcf"
end

function modifier_devotion_aura:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
   
function modifier_devotion_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_devotion_aura:GetAuraEntityReject(target)
    return IsCustomBuilding(target)
end

function modifier_devotion_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_devotion_aura:GetAuraDuration()
    return 0.5
end

--------------------------------------------------------------------------------

modifier_devotion_aura_buff = class({})

function modifier_devotion_aura_buff:OnCreated()
    self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_devotion_aura_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_devotion_aura_buff:GetModifierPhysicalArmorBonus()
    return self.bonus_armor
end

function modifier_devotion_aura_buff:IsPurgable()
    return false
end

function modifier_devotion_aura_buff:GetTexture()
    return "blue_dragonspawn_overseer_devotion_aura"
end