--// BATTLE SIM //--
InBattle = false
function events.render()
	models.model.Waist.LeftArm.bone2.accessory:setVisible(InBattle)
	animations.model.battle_idle:setPlaying(InBattle)
end
--///-- WIP --///--