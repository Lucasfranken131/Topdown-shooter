function love.load()
    math.randomseed(os.time())

    gameState = 1 -- 1 = Menu, 2 = Jogo
    maxTime = 3
    timer = maxTime
    points = 0

    sounds = {
        music = love.audio.newSource('sounds/music.mp3', 'static'),
        shot = love.audio.newSource('sounds/shot.ogg', 'static')
    }

    sounds.music:setLooping(true)
    sounds.shot:setVolume(0.1)
    sounds.music:setVolume(0.05)
    love.audio.play(sounds.music)

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

    myFont = love.graphics.newFont(30)

    zombies = {}
    bullets = {}
end

function love.update(dt)
    if gameState == 2 then
        if love.keyboard.isDown('w') and player.y > 10 then
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown('a') and player.x > 10 then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown('s') and player.y < love.graphics.getHeight() - 10 then
            player.y = player.y + player.speed * dt
        end
        if love.keyboard.isDown('d') and player.x < love.graphics.getWidth() - 10 then
            player.x = player.x + player.speed * dt
        end
    end

    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(getZombieRotation(z)) * z.speed * dt)
        z.y = z.y + (math.sin(getZombieRotation(z)) * z.speed * dt) 
        
        if getDistanceBetween(z.x, player.x, z.y, player.y) < 20 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
                gameState = 1
                player.x = love.graphics.getWidth() / 2
                player.y = love.graphics.getHeight() / 2 
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
                points = points + 1
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

    if gameState == 2 then
        timer = timer - dt
        if timer <0 then
            spawnZombie()
            maxTime = maxTime * 0.95
            timer = maxTime
        end  
    end
end

function love.mousepressed(x,y, key)
    if key == 1 and gameState == 2 then
        spawnBullet()
        love.audio.stop(sounds.shot)
        love.audio.play(sounds.shot)
    elseif key == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        points = 0
    end
end

function love.draw()
    love.graphics.draw(sprites.background)
    love.graphics.setFont(myFont)
    if gameState == 1 then
        love.graphics.printf("Clique em qualquer lugar para começar", 0, 50, love.graphics.getWidth(), "center")
    elseif gameState == 2 then
        love.graphics.print("Pontos: ".. points, 5, 5)
    end
    love.graphics.draw(sprites.player, player.x, player.y, getMouseRotation(), nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2)
    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, getZombieRotation(z), nil, nil, sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end
    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, 0.3, 0.3, sprites.bullet:getWidth() / 2, sprites.bullet:getHeight() / 2)
    end
end

function getMouseRotation()
    if gameState == 2 then
        atan2 = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
        return atan2
    end
end

function spawnZombie()
    local zombie = {
        x = 0,
        y = 0,
        dead = false,
        speed = math.random(60, 250)
    }

    local side = math.random(1, 4)
    if side == 1 then --cima
        zombie.y = -30
    elseif side == 2 then --esquerda
        zombie.x = -30
    elseif side == 3 then --baixo
        zombie.y = love.graphics.getHeight() + 30
    elseif side == 4 then --direita
        zombie.x = love.graphics.getWidth() + 30
    end

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