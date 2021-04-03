WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

function love.load()
    
    -- no blurriness
    love.graphics.setDefaultFilter('nearest','nearest')

    -- title of application window
    love.window.setTitle('Pong')
    
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('file.ttf',8)
    
    scoreFont = love.graphics.newFont('file.ttf',32)
    
    victoryFont = love.graphics.newFont('file.ttf',32)

    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('pong-11_sounds_paddle_hit.wav','static'),
        ['point_scored'] = love.audio.newSource('pong-11_sounds_score.wav','static'),
        ['wall_hit'] = love.audio.newSource('pong-11_sounds_wall_hit.wav','static')
    }
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    paddle1 = Paddle(5,20,5,20)
    paddle2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT-40, 5 , 20)
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)
    
    player1_score = 0
    player2_score = 0
    winningPlayer = 0
    servingPlayer = math.random(2) == 1 and 1 or 2

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = 'start'
end

function love.resize(w,h)
    push:resize(w, h)
end

function love.update(dt)

    if gameState == 'serve' then
        ball.dy = math.random(-50,50)

        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140,200)
        end

    elseif gameState == 'play' then
        if ball:collides(paddle1) then
            ball.dx = -ball.dx *1.03
            ball.x = paddle1.x +5 

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end       
        
        if ball:collides(paddle2) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150) 
            else
                ball.dy = math.random(10,150)
            end
            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()

        end

        if ball.y >= VIRTUAL_HEIGHT-4 then
            ball.y = VIRTUAL_HEIGHT-4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2_score = player2_score + 1
            sounds['point_scored']:play()

            if player2_score == 2 then
                winningPlayer = 2
                gameState = 'victory'
            else    
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1_score = player1_score + 1
            sounds['point_scored']:play()

            if player1_score == 2 then
                winningPlayer = 1
                gameState = 'victory'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end
    
    if love.keyboard.isDown('w') then
        paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then 
        paddle1.dy = PADDLE_SPEED
    else
        paddle1.dy = 0
    end

    if love.keyboard.isDown('up') then
        paddle2.dy = -PADDLE_SPEED 
    elseif love.keyboard.isDown('down') then
        paddle2.dy = PADDLE_SPEED
    else
        paddle2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end    

    paddle1:update(dt)
    paddle2:update(dt) 
end    


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1_score = 0
            player2_score = 0
            ball:reset()
        end
    end 
end

function love.draw()
    push:apply('start')

    -- background color of window
    love.graphics.clear(40/255, 45/255, 52/255, 255/255 )

    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to Pong!",0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("press Enter to Play", 0 , 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn" ,0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve", 0 , 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins",0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("press Enter to Restart", 0 , 52, VIRTUAL_WIDTH, 'center')
        ball:reset()
    elseif gameState == 'play' then
        ---
    end

    

    -- draw paddles
    paddle1:render()
    paddle2:render()

    -- drawing bars and ball
    ball:render()

    -- display FPS
    dispalyFPS()

    displayScore()
    
    push:apply('end')
end


function dispalyFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(smallFont)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()),40,20)
    love.graphics.setColor(1,1,1,1)
end

function displayScore()
    -- print score
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1_score), VIRTUAL_WIDTH/2 - 110, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2_score), VIRTUAL_WIDTH/2 + 80, VIRTUAL_HEIGHT/3)
end


