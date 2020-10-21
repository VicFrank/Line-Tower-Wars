LinkLuaModifier("modifier_custom_invisibility", "abilities/creeps/invisibility.lua", LUA_MODIFIER_MOTION_NONE)

invisibility = class({})
function invisibility:GetIntrinsicModifierName() return "modifier_custom_invisibility" end

modifier_custom_invisibility = class({})

function modifier_custom_invisibility:CheckState() 
  return {
    [MODIFIER_STATE_INVISIBLE] = true,
  }
end

function modifier_custom_invisibility:DeclareFunctions() 
  return {
    MODIFIER_PROPERTY_INVISIBILITY_LEVEL
  }
end

function modifier_custom_invisibility:GetModifierInvisibilityLevel()
  if IsClient() then
    return 1
  end
end

function modifier_custom_invisibility:GetEffectName()
  return "particles/generic_hero_status/status_invisibility_start.vpcf"
end