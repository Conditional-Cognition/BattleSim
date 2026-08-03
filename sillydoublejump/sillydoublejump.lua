--// jump particles //--
local canDoubleJump = true

jump = keybinds:fromVanilla("key.jump")

function jump.press()
    if player:isOnGround() then
        canDoubleJump = true
        return
    end

    if not canDoubleJump then
        return
    end

    canDoubleJump = false

    particles:newParticle("minecraft:campfire_cosy_smoke", player:getPos())
    local horizontalSpeed = 0.05
    for i = 1, 6 do
        local angle = math.random() * 2 * math.pi
        local vx = math.cos(angle) * horizontalSpeed
        local vz = math.sin(angle) * horizontalSpeed
        local vy = 0.005

        local velocity = vectors.vec(vx, vy, vz)
        particles:newParticle("minecraft:campfire_cosy_smoke", player:getPos(), velocity)
    end

    silly:setVel(player:getVelocity().x * 1.05, 0.5, player:getVelocity().z * 1.05)
end
--// MADE BY Cdtnl_Cognition //--