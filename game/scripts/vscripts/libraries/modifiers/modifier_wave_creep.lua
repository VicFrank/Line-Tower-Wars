modifier_wave_creep = class({})

function modifier_wave_creep:CheckState() 
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_wave_creep:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_wave_creep:IsHidden()
    return true
end

function modifier_wave_creep:IsPurgable()
    return false
end