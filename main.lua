function love.load()
    love.window.setTitle("Zombie Killer")
    sprites = {
        background = love.graphics.newImage('sprites/background.png'),
        bullet = love.graphics.newImage('sprites/bullet.png'),
        player = love.graphics.newImage('sprites/player.png'),
        zombie = love.graphics.newImage('sprites/zombie.png')
    }

    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getWidth() / 2,
        speed = 180
    }

    zombies = {}

    bullets = {}
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown('a') then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown('s') then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown('d') then
        player.x = player.x + player.speed * dt
    end

    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(getZombieRotation(z)) * z.speed * dt)
        z.y = z.y + (math.sin(getZombieRotation(z)) * z.speed * dt) 
        
        if getDistanceBetween(z.x, player.x, z.y, player.y) < 20 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
            end
        end
    end

    for i, b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction) * b.speed * dt)
    end

    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.x < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

    for i,z in ipairs(zombies) do
        for i, b in ipairs(bullets) do
            if getDistanceBetween(z.x, b.x, z.y, b.y) < 20 then
                z.dead = true
                b.dead = true
            end
        end
    end

    for i=#zombies, 1, -1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies, i)
        end
    end

    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets, i)
        end
    end
end

function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed(x,y, key)
    if key == 1 then
        spawnBullet()
    end
end

function love.draw()
    love.graphics.draw(sprites.background)
    love.graphics.draw(sprites.player, player.x, player.y, getMouseRotation(), nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2)
    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, getZombieRotation(z), nil, nil, sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end
    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, 0.3, 0.3, sprites.bullet:getWidth() / 2, sprites.bullet:getHeight() / 2)
    end
end

function getMouseRotation()
    atan2 = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
    return atan2
end

function spawnZombie()
    local zombie = {
        x = math.random(0, love.graphics.getWidth()),
        y = math.random(0, love.graphics.getHeight()),
        dead = false,
        speed = math.random(60, 250)
    }
    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {
        x = player.x,
        y = player.y,
        speed = 500,
        dead = false,
        direction = getMouseRotation()
    }
    table.insert(bullets, bullet)
end

function getZombieRotation(zombie)
    local atan = math.atan2(player.y - zombie.y, player.x - zombie.x)
    return atan
end

function getDistanceBetween(x1, x2, y1, y2)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end