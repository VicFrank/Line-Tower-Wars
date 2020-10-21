LinkLuaModifier("modifier_custom_evasion", "abilities/creeps/custom_evasion.lua", LUA_MODIFIER_MOTION_NONE)

custom_evasion = class({})
function custom_evasion:GetIntrinsicModifierName() return "modifier_custom_evasion" end

modifier_custom_evasion = class({})

function modifier_custom_evasion:IsHidden() return true end

function modifier_custom_evasion:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_EVASION_CONSTANT,
    MODIFIER_EVENT_ON_ATTACK_FAIL,
  }
  return funcs
end

function modifier_custom_evasion:GetModifierEvasion_Constant()
  return self:GetAbility():GetSpecialValueFor("evasion")
end

function modifier_custom_evasion:OnAttackFail(keys)
  local fail_type = keys.fail_type
  local target = keys.target
  local attacker = keys.attacker

  if target == self:GetParent() then
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_MISS, attacker, 0, nil)
  end
end