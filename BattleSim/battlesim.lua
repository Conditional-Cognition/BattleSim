--// BATTLE SIM //--
InBattle = false

--// POSITIONING //--
local BATTLE_HALF_DISTANCE = 2.5 -- 5 blocks total separation

local function yawFromDirection(dx, dz)
	return math.deg(math.atan2(-dx, dz))
end

local function computeBattlePositions(posA, posB, opponentMoves)
	if opponentMoves == nil then opponentMoves = true end

	local away = posA - posB
	away.y = 0
	if away:length() < 0.001 then
		away = vec(1, 0, 0)
	end
	away = away:normalized()

	local yawA = yawFromDirection(-away.x, -away.z) -- A faces toward B
	local yawB = yawFromDirection(away.x, away.z)    -- B faces toward A

	if opponentMoves then
		local mid = (posA + posB) / 2
		local targetA = mid + away * BATTLE_HALF_DISTANCE
		local targetB = mid - away * BATTLE_HALF_DISTANCE
		targetA.y, targetB.y = mid.y, mid.y
		return targetA, yawA, targetB, yawB
	end

	local targetA = posB + away * (BATTLE_HALF_DISTANCE * 2)
	targetA.y = posB.y
	return targetA, yawA, posB, yawB
end
local function battlesimSetPosition(targetUUID, x, y, z, yaw)
	if not player:isLoaded() then return end
	if player:getUUID() ~= targetUUID then return end

	if not silly:cheatsEnabled() then
		host:setActionbar("BattleSim: can't position (needs creative/op/singleplayer)")
		return
	end

	silly:setPos(x, y, z)
	silly:setRot(0, yaw)
end

local challenger = nil
function battlesimStartPositioning(opponent, opponentMoves)
	if not host:isHost() then return end
	if opponentMoves == nil then opponentMoves = true end

	local posSelf, posOpp = player:getPos(), opponent:getPos()
	local targetSelf, yawSelf, targetOpp, yawOpp = computeBattlePositions(posSelf, posOpp, opponentMoves)

	BattlePos = vec(targetSelf.x, targetSelf.y, targetSelf.z)
	battlesimSetPosition(player:getUUID(), targetSelf.x, targetSelf.y, targetSelf.z, yawSelf)

	if opponentMoves then
		battlesimSetPosition(opponent:getUUID(), targetOpp.x, targetOpp.y, targetOpp.z, yawOpp)
	end

	InBattle = true
	challenger = opponent
end

function pings.promptOpponent(battle,opponent)
	InBattle = battle
	challenger = opponent
	avatar:store("battle_prompter",{challenge = InBattle, opponent = challenger})
end

--// POSITIONING TEST (armor stand) //--
local BATTLESIM_TEST_REACH = 5

local testKeybind = keybinds:newKeybind("BattleSim: Position", "key.keyboard.up")
local cancel = keybinds:newKeybind("BattleSim: Cancel", "key.keyboard.down")
function testKeybind.press()
	if not player:isLoaded() then return end

	local target = player:getTargetedEntity(BATTLESIM_TEST_REACH)
	if not target or target:getType() ~= "minecraft:player" then
		host:setActionbar("BattleSim: look at a player first")
		return
	end
	battlesimStartPositioning(target, false)
	pings.promptOpponent(InBattle,target)
	host:actionbar("BattleSim: You challenged ยง6"..challenger:getName().."!")
end
function cancel.press()
	InBattle = false
	pings.promptOpponent(InBattle,nil)
end

function events.render()
	--models.model.Waist.LeftArm.bone2.accessory:setVisible(InBattle)
	animations.model.battle_idle:setPlaying(InBattle)
end

function events.tick()
	if not player:isLoaded() then return end
	local opponent = world.getPlayers()[challenger]
	if opponent
	and opponent:getVariable()["battle_prompter"]
	and opponent:getVariable()["battle_prompter"][1]==player:getUUID()
	then
		host:actionbar("BattleSim: "..challenger.." is challnging you!")
		if opponent:getVariable()["battle_prompter"][2]==true then
			host:actionbar("BattleSim: You challenged"..challenger.."!")
		end
	end

	if InBattle and silly and host:isHost() then
		silly:setPos(BattlePos)
	end
	avatar:store("battle_prompter",{opponent = challenger, challenge = InBattle})
end
--///-- WIP --///--