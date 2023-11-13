love.graphics.setDefaultFilter("linear","linear",10)

require("utils.json")
require("store.store")
require("utils.draw")
require("utils.utils")

ordem = {"K","Q","J",10,9,8,7,6,5,4,3,2,"A"}
cnaipes = {"spades","diamonds","clubs","hearts"}

cardlists = {}
cardstacks = {}
cardpile = {}
cardlitter = {}
cardonhand = nil
suits = love.graphics.newImage("img/out.png")
spades = love.graphics.newQuad(0,0,100,119,420,119)
diamonds = love.graphics.newQuad(110,0,90,119,420,119)
clubs = love.graphics.newQuad(220,0,90,119,420,119)
hearts = love.graphics.newQuad(330,0,90,119,420,119)
naipes = {spades=spades,diamonds=diamonds,clubs=clubs,hearts=hearts}
suitSize = 0.45
cardfontsize = 32
round = 7
cardfont = love.graphics.newFont(cardfontsize)
cardw,cardh = 100,150
androidSpacing = 100
androidInterSpacing = 10
androidOverhead = 0
androidSmall = 0.1

coinImg = love.graphics.newImage("img/coin.png")

buttons = {
    {img=love.graphics.newImage("img/undo.png")},
    {img=love.graphics.newImage("img/stats.png")},
    {img=love.graphics.newImage("img/new.png")},
    {img=love.graphics.newImage("img/market.png")},
    {img=love.graphics.newImage("img/redo.png")}
}

lastMoves = {}
lastMovesIndex = 1
forwardMoves = {}

system = love.system.getOS()

oldThick = love.graphics.getLineWidth()

inStore = false
inStorePrompt = nil
inStats = false
inVictory = false

wonGame = false
allVisible = false
winning = false
winningCD = 0

victoryCoins = 0

storeItems = {}
storeCB = {}
storeBacks = {}

storeButtons = {"Cartas","Versos","Fundos"}
storeState = 1

save = {
    coins=500,
    highScore=0,
    highTime="0:00",
    lowTime="0:00",
    totalTime="0:00",
    totalGames=0,
    totalWins=0,
    totalLoss=0,
    points=0,
    currentTime="0:00",
    moves=0,
    backImg="backgrounds/back1.jpg",
    backCard="cards/back1.png"
}

currentSecs = 0
currentMins = 0
currentCD = 0
timePunish = 0

clickSendCD = 0

cardStyle = {
    color={1,1,1},
        textcolor={0,0,0},
        suitcolor={0,0,0},
        casered={0.6,0,0},
        backImg=nil,
        fontName="fonts/Bricolage.ttf",
        font="fonts/Bricolage.ttf",
        bought=true,
        price=0,
        name="Default"
}

love.graphics.setBackgroundColor(0.2,0.05,0.2)

love.math.setRandomSeed(os.time())
random = love.math.random

sounds = {
    move = love.audio.newSource("sfx/newmove.mp3","static"),
    new = love.audio.newSource("sfx/new.mp3","static"),
    victory = love.audio.newSource("sfx/victory.mp3","static")
}

function love.load()
    local temp = readSave()
    if temp~=nil then 
        save=temp
        local time = split(save.currentTime,":")
        currentMins=time[1]
        currentSecs=time[2]
    else
        storeItems=loadStoreItems()
        storeCB=loadStoreCB()
        storeBacks=loadStoreBacks()
    end
    backgroundImg = love.graphics.newImage(save.backImg)
    cardBack = love.graphics.newImage(save.backCard)
    
    if system~="Android" then
        love.window.setMode(800,750)
        screenw, screenh = love.graphics.getDimensions()
    else
        suitSize=suitSize/1.8
        cardw=cardw/2
        cardh=cardh/2
        round = 3
        androidSpacing=50
        androidOverhead=50
        androidSmall=0.03
        androidInterSpacing=5
        cardfontsize=math.floor(cardfontsize/1.5)
        cardfont=love.graphics.newFont(cardfontsize)
        --love.window.maximize()
        --love.window.setFullscreen(true)
        local wait=true
        while wait do

            --love.timer.sleep(0.01)
            --love.window.setFullscreen(true)
            love.window.maximize()
            local tx, ty = love.graphics.getDimensions()
            if ty>tx then wait=false end
        end
        screenw, screenh = love.graphics.getDimensions()
    end
    resetAllFonts()
    resetImages()
    startGame()
end

function love.update(dt)
    local mousex,mousey = love.mouse.getPosition()
    --print(checkPile(mousex,mousey))
    if love.mouse.isDown(1)==false then
        if cardonhand==nil then
        else
            clickSendCD = clickSendCD+dt
            local pile = checkPile(mousex,mousey)
            local baselist = checkForList(mousex,mousey)
            local card,list,index = checkCollisionTwo(mousex,mousey)
            if card and list~=cardonhand.lastlist then
                if checkOpposite(card.suit,cardonhand[1].suit) and checkIfPost(cardonhand[1].number,card.number) then                    
                    local newIndex = index+1
                    for i,v in ipairs(cardonhand) do
                        v.visible=true
                        cardlists[list][index+i] = v
                    end
                    local behindHidden = makeVisible()
                    putLastMove(cardonhand.lastlist,list,#cardonhand,newIndex,behindHidden)
                    cardonhand=nil
                    addPoints(2)
                    playSound("move")
                else
                    cardonhand = returnCard()                
                end
            elseif pile and #cardonhand==1 then
                if cardpile[pile] then
                    local lastCardPile = cardpile[pile][#cardpile[pile]]
                    if lastCardPile then --checa se a ultima carta não é nula
                        if cardonhand[1].suit==lastCardPile.suit and checkIfPost(lastCardPile.number,cardonhand[1].number) and #cardonhand==1 then
                            cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
                            
                            local behindHidden = makeVisible()
                            putLastMove(cardonhand.lastlist,"pile"..pile,#cardonhand,0,behindHidden)
                            cardonhand=nil
                            checkVictory()
                            addPoints(15)
                            playSound("move")
                        else
                            cardonhand = returnCard()
                        end
                    else
                        cardonhand = returnCard()
                    end
                else                    
                    if cardonhand[1].number=="A" then
                        cardpile[pile] = {}
                        cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
                        local behindHidden = makeVisible()
                        putLastMove(cardonhand.lastlist,"pile"..pile,#cardonhand,0,behindHidden)
                        cardonhand=nil
                        addPoints(15)
                        playSound("move")
                    else
                        cardonhand = returnCard()
                    end
                end
            elseif baselist then
                if cardonhand[1].number=="K" then
                    if #cardlists[baselist]==0 then
                        for i,v in ipairs(cardonhand) do                        
                            addCardToList(baselist,v.number,v.suit,true)
                        end
                        local behindHidden = makeVisible()
                        putLastMove(cardonhand.lastlist,baselist,#cardonhand,1,behindHidden)
                        cardonhand=nil
                        playSound("move")
                    else
                        cardonhand = returnCard()
                    end
                else
                    cardonhand = returnCard()
                end
            else
                cardonhand = returnCard()
            end
        end
    end

    if winning then
        winningCD=winningCD+dt
        if winningCD>=0.1 then
            winningCD=winningCD-0.1
            allVisibleMakeMove()
            checkVictory()
        end
    end

    if inVictory==false and inStats==false and inStore==false and wonGame==false then
        currentCD=currentCD+dt
        timePunish=timePunish+dt
        if currentCD>=1 then
            currentCD=currentCD-1
            updateTime()
            saveGame()
        end
        if timePunish>=10 then
            timePunish=timePunish-10
            deductPoints(2)
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then 
        if inStats==false and inStore==false and inVictory==false and allVisible==false then
            if cardonhand==nil then
                if wonGame==false then
                    clickSendCD=0
                    local card,list,index = checkCollision(x,y)
                    local pile = checkPile(x,y)
                    if card then
                        cardonhand=card
                        cardonhand.lastlist=list
                        cardx, cardy = whereClicked("list",list,index)
                        cardonhand.cardx = cardx
                        cardonhand.cardy = cardy
                        for i=index,index+#card-1 do
                            cardlists[list][i]=nil
                        end
                    elseif pile then
                        local pileToTake = cardpile[pile]
                        if pileToTake then
                            if #pileToTake>0 then
                                cardx, cardy = whereClicked("pile",pile)
                                cardonhand = {cardpile[pile][#cardpile[pile]]}              
                                table.remove(pileToTake,#pileToTake)
                                if #cardpile[pile]==0 then cardpile[pile] = nil end
                                cardonhand.lastlist="pile"..pile
                                cardonhand.cardx = cardx
                                cardonhand.cardy = cardy
                            end
                        end
                    else
                        if checkStack(x,y) then
                            if #cardstacks>0 then
                                local card = cardstacks[#cardstacks]
                                cardlitter[#cardlitter+1] = card
                                table.remove(cardstacks,#cardstacks)
                                local move = "stack"
                                lastMoves[#lastMoves+1] = move
                                lastMovesIndex = #lastMoves+1
                                forwardMoves = {}
                            else
                                cardstacks = invertTable(cardlitter)
                                cardlitter = {}
                                local move = "restack"
                                lastMoves[#lastMoves+1] = move
                                lastMovesIndex = #lastMoves+1
                                forwardMoves = {}
                                deductPoints(100)
                            end
                            playSound("move")
                        else
                            local card = checkLitter(x,y)                    
                            if card then
                                cardx, cardy = whereClicked("litter")
                                cardonhand=card
                                cardonhand.lastlist="litter"
                                cardonhand.cardx = cardx
                                cardonhand.cardy = cardy
                                table.remove(cardlitter,#cardlitter)
                            end
                        end
                    end
                end
                local button = checkForButtons(x,y)
                if button then
                    pressButton(button)
                end
            end
        elseif inStore then
            if inStorePrompt==nil then
                local whatButton = storeCollision(x,y)
                if whatButton=="outside" then
                    inStore=false
                elseif whatButton==1 or whatButton==2 or whatButton==3 then
                    storeState=whatButton
                end
            else
                local whatButton = storePromptCollision(x,y)
                if whatButton=="buy" then
                    if save.coins>=inStorePrompt.price then
                        if storeState==1 then
                            cardStyle=inStorePrompt
                            storeItems[inStorePrompt.index].bought = true
                        elseif storeState==2 then
                            cardBack=inStorePrompt.img
                            save.backCard=inStorePrompt.imgName
                            storeCB[inStorePrompt.index].bought=true
                        elseif storeState==3 then
                            changeBack(inStorePrompt.img)
                            save.backImg=inStorePrompt.imgName
                            storeBacks[inStorePrompt.index].bought=true
                        end
                        save.coins=save.coins-inStorePrompt.price
                        inStorePrompt=nil
                        inStore=false                        
                    end
                elseif whatButton=="outside" then
                    inStorePrompt=nil
                end
            end
        elseif inStats then
            local whatButton = statsCollision(x,y)
            if whatButton=="outside" then
                inStats=false
            end
        elseif inVictory then
            local whatButton = victoryCollision(x,y)
            if whatButton=="new" then
                pressButton(3)
                inVictory=false
            elseif whatButton=="outside" then
                inVictory=false
            end
        elseif allVisible then
            local whatButton = allVisibleCollision(x,y)
            if whatButton=="clicked" then
                winning=true
                allVisible=false
                winningCD=0
            end
        end
    end
 end

function love.draw()
    local mousex, mousey = love.mouse.getPosition()

    local scaleBackX, scaleBackY = backgroundImg:getDimensions()
    scaleBackX = screenw/scaleBackX
    scaleBackY = screenh/scaleBackY
    love.graphics.draw(backgroundImg,0,0,0,scaleBackX,scaleBackY)


    for i=1,7 do -- drawing the bottom of the lists
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
        love.graphics.setColor(1,1,1,0.3)
        love.graphics.rectangle("fill",x,y,cardw,cardh,round)
        love.graphics.setColor(1,1,1,1)
    end
    for i=1,4 do --drawing the bottom of the piles
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = cardh-cardh+cardfontsize+5 + androidOverhead
        love.graphics.setColor(1,1,1,0.3)
        love.graphics.rectangle("fill",x,y,cardw,cardh,round)
        love.graphics.setColor(1,1,1,1)
    end
    
    --drawing the bottom of the stack
    love.graphics.setColor(1,1,1,0.3)
    love.graphics.rectangle("fill",7 * (cardw+androidInterSpacing) - androidSpacing,cardh-cardh+cardfontsize+5+androidOverhead,cardw,cardh,round)
    love.graphics.setColor(1,1,1,1)

    for k,v in ipairs(cardlists) do
        local x = k * (cardw+androidInterSpacing) - androidSpacing
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
            if card.visible then 
                drawCard(card.number,card.suit,x,y)
            else
                drawBack(x,y)
            end
        end
    end

    for i=1,4 do
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = cardh-cardh+cardfontsize+5 + androidOverhead
        if cardpile[i] then
            local card = cardpile[i][#cardpile[i]]
            if card then
                drawCard(card.number,card.suit,x,y)
            end
        end
    end
    local max=#cardlitter
    if max>3 then max=3 end    
    for i=1,max do
        local tempx = (5+i) * (cardw+androidInterSpacing) - androidSpacing
        local x = tempx - i*cardw*0.75 - (100-androidSpacing)
        local y = cardh-cardh+cardfontsize+5 + androidOverhead
        if system=="Android" then x=x+screenw/10 end
        if cardlitter[#cardlitter-max+i] then
            local card = cardlitter[#cardlitter-max+i]
            drawCard(card.number,card.suit,x,y)
        end
    end    
    if #cardstacks>0 then
        drawBack(7 * (cardw+androidInterSpacing) - androidSpacing,cardh-cardh+cardfontsize+5+androidOverhead)
    end

    if cardonhand then
        for i,v in ipairs(cardonhand) do
            local x = mousex-cardonhand.cardx
            local y = mousey-cardonhand.cardy + ((i-1)*(cardh-cardh+cardfontsize+5))
            drawCard(v.number,v.suit,x,y)
        end
    end

    --draw points :D
    drawPoints()

    --draw time :D
    drawTime()

    --draw the moves counter :D
    drawMoves()

    --draw buttons
    drawButtons()

    if inStore then drawStore() end
    if inStorePrompt then drawStorePrompt() end
    if inStats then drawStats() end
    if inVictory then drawVictory() end
    if allVisible then drawAllVisible() end
end

--Adds a card at the bottom of a list
function addCardToList(listnumber,number,suit,visible)
    local index=0
    if cardlists[listnumber] then
        index = #cardlists[listnumber]
    else
        cardlists[listnumber] = {}
    end
    cardlists[listnumber][index+1] = {number=number,suit=suit,visible=visible}
end

--Collision for the lists
--No cardonhand
function checkCollision(mx,my)
    for k,v in ipairs(cardlists) do
        local x = k * (cardw+androidInterSpacing) - androidSpacing
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
            if card.visible and i~=#v then
                if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh-cardh+cardfontsize+5 then
                    local obj={}
                    for index=i,#v do
                        obj[#obj+1] = v[index]
                    end
                    return obj,k,i
                end
            end
            if i==#v then
                if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then
                    return {card},k,i
                end
            end
        end
    end
    return nil
end

--Separate collision for the card lists
--with cardonhand
function checkCollisionTwo(mx,my)
    --calculate the cardonhand rectangle
    local cx = mx-cardonhand.cardx
    local cy = my-cardonhand.cardy-- + ((i-1)*(cardh-cardh+cardfontsize+5))
    local cw = cardw
    local ch = cardh

    for k,v in ipairs(cardlists) do
        local x = k * (cardw+androidInterSpacing) - androidSpacing
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
            if i==#v and checkOpposite(cardonhand[1].suit,card.suit) and checkIfPost(cardonhand[1].number,card.number) then
                if cx+cw >= x and cx <= x+cardw and cy+ch >= y and cy <= y+cardh then
                    return card,k,i
                end
            end
        end
    end
    return nil
end

--Collision on the list bottom (for kings)
function checkForList(mx,my)
    if cardonhand~=nil then
        --calculate the cardonhand rectangle
        local cx = mx-cardonhand.cardx
        local cy = my-cardonhand.cardy-- + ((i-1)*(cardh-cardh+cardfontsize+5))
        local cw = cardw
        local ch = cardh

        for i=1,7 do
            local x = i * (cardw+androidInterSpacing) - androidSpacing
            local y = (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
            if cx+cw >= x and cx <= x+cardw and cy+ch >= y and cy <= y+cardh and #cardlists[i]==0 then
                return i
            end
        end
    else
        for i=1,7 do
            local x = i * (cardw+androidInterSpacing) - androidSpacing
            local y = (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then
                return i
            end
        end
    end
end

--Collision on the pile
function checkPile(mx,my)
    --calculate the cardonhand rectangle
    if cardonhand~=nil then
        local cx = mx-cardonhand.cardx
        local cy = my-cardonhand.cardy-- + ((i-1)*(cardh-cardh+cardfontsize+5))
        local cw = cardw
        local ch = cardh

        for i=1,4 do --drawing the bottom of the piles
            local x = i * (cardw+androidInterSpacing) - androidSpacing
            local y = cardh-cardh+cardfontsize+5 + androidOverhead
            if cardpile[i]==nil then
                if cx+cw >= x and cx <= x+cardw and cy+ch >= y and cy <= y+cardh then
                    if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then
                        return i
                    end
                end
            else
                if cx+cw >= x and cx <= x+cardw and cy+ch >= y and cy <= y+cardh and cardonhand[1].suit==cardpile[i][#cardpile[i]].suit then
                    return i
                end
            end
        end
    else
        for i=1,4 do --drawing the bottom of the piles
            local x = i * (cardw+androidInterSpacing) - androidSpacing
            local y = cardh-cardh+cardfontsize+5 + androidOverhead
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then
                return i
            end
        end
    end
    return nil
end

--Collision on the stack
function checkStack(mx,my)
    local x = 7*(cardw+10)-100
    local y = cardh-cardh+cardfontsize+5 + androidOverhead
    if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then            
        return true
    end
    return false
end

--Collision on the litter
function checkLitter(mx,my)
    local max=#cardlitter
    if max>3 then max=3 end    
    for i=1,max do
        local tempx = (5+i) * (cardw+androidInterSpacing) - androidSpacing
        local x = tempx - i*cardw*0.75 - (100-androidSpacing)
        local y = cardh-cardh+cardfontsize+5 + androidOverhead
        if system=="Android" then x=x+screenw/10 end
        if cardlitter[#cardlitter-max+i] then
            local card = cardlitter[#cardlitter-max+i]
            if i==max then
                if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then            
                    return {card}
                end
            end
        end
    end  
    return nil
end

--Collision of the main buttons
function checkForButtons(mx,my)        
        local androidFactor = 0.25
        if system=="Android" then androidFactor=0.15 end    
        local buttonWidth = 256*androidFactor -- Largura dos botões (ajuste conforme necessário)
        local buttonHeight = 256*androidFactor -- Altura dos botões (ajuste conforme necessário)
        local minPadding = 10 -- Espaçamento entre os botões (ajuste conforme necessário)
        local numButtons = #buttons
    
         -- Calcula o total de largura ocupada pelos botões
        -- Calcula a largura total ocupada pelos botões
        local totalButtonsWidth = numButtons * buttonWidth
    
        -- Calcula o padding necessário para centralizar os botões
        local totalPadding = math.max((screenw - totalButtonsWidth) / (numButtons + 1), minPadding)
    
        -- Calcula a posição x inicial para o primeiro botão
        local xStart = (screenw - (totalButtonsWidth + totalPadding * (numButtons - 1))) / 2
    
    
        -- Calcula a posição y dos botões colados na parte inferior da tela
        local y = screenh - buttonHeight - 20
        for i, btn in ipairs(buttons) do
            local x = xStart + (i - 1) * (buttonWidth + totalPadding)
            if mx >= x and mx <= x+buttonWidth and my >= y and my <= y+buttonHeight then            
                return i
            end
        end
end

--Collision of the store
function storeCollision(mx,my)
    local width = screenw-(screenw/8)
    local height = screenh-(screenh/3)
    if storeState==1 then
        for k,v in ipairs(storeItems) do
            local itr = k
            local spacing = ((width-cardw*6))/6
            local otherSpacing = ((screenw/2-width/2+(6)*(cardw+spacing))-width)/6
            --if k>1 then otherSpacing=0 end
            local y = screenh/2-height/2 + height/25
            if k>6 then y=y+(cardh+cardfontsize+16)*math.floor(k/6);itr=k%6 end
            local x = screenw/2-width/2+(itr-1)*(cardw+spacing) + otherSpacing
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then 
                v["index"] = k
                if v.bought then
                    cardStyle=v
                    inStore=false
                    return "card"
                end
                inStorePrompt=v
                return "card"
            end
        end
    elseif storeState==2 then
        for k,v in ipairs(storeCB) do
            local itr = k
            local spacing = ((width-cardw*6))/6
            local otherSpacing = ((screenw/2-width/2+(6)*(cardw+spacing))-width)/6
            --if k>1 then otherSpacing=0 end
            local y = screenh/2-height/2 + height/25
            if k>6 then y=y+(cardh+cardfontsize+16)*math.floor(k/6);itr=k%6 end
            local x = screenw/2-width/2+(itr-1)*(cardw+spacing) + otherSpacing
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then 
                v["index"] = k
                if v.bought then
                    cardBack=v.img
                    save.backCard=v.imgName
                    inStore=false
                    return "card"
                end
                inStorePrompt=v
                return "card"
            end
        end
    elseif storeState==3 then
        for k,v in ipairs(storeBacks) do
            local itr = k
            local spacing = ((width-cardw*6))/6
            local otherSpacing = ((screenw/2-width/2+(6)*(cardw+spacing))-width)/6
            --if k>1 then otherSpacing=0 end
            local y = screenh/2-height/2 + height/25
            if k>6 then y=y+(cardh+cardfontsize+16)*math.floor(k/6);itr=k%6 end
            local x = screenw/2-width/2+(itr-1)*(cardw+spacing) + otherSpacing
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then 
                v["index"] = k
                if v.bought then
                    changeBack(v.img)
                    save.backImg=v.imgName
                    inStore=false
                    return "card"
                end
                inStorePrompt=v
                return "card"
            end
        end
    end
    local x = screenw/2-width/2
    local y = screenh/2-height/2
    if mx >= x and mx <= x+width and my >= y and my <= y+height then 
    else
        return "outside"
    end
    for i=1,3 do
        local nw = cardfont:getWidth(storeButtons[1])+15
        local nh = cardfontsize+10
        local x = screenw/2+width/2-nw-5
        local dockh=height/8
        local y = screenh/2-height/2+height-dockh-(nh+5)*(i-1)
        if mx >= x and mx <= x+nw and my >= y and my <= y+nh then 
            return i
        end
    end
    
end

--Collision of the storePrompt
function storePromptCollision(mx,my)
    local cellFactor = 2
    if system=="Android" then cellFactor=1.60 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    local text = "Comprar"
    if save.coins<inStorePrompt.price then text="Sem dinheiro" end
    local nw = cardfont:getWidth(text)+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "buy"
    end
    x = screenw/2-width/2
    y = screenh/2-height/2
    if mx >= x and mx <= x+width and my >= y and my <= y+height then 
    else
        return "outside"
    end
end

--Collision of the victory screen
function victoryCollision(mx,my)
    local cellFactor = 2.60
    if system=="Android" then cellFactor=2 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    local nw = cardfont:getWidth("Jogar denovo")+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "new"
    end
    x = screenw/2-width/2
    y = screenh/2-height/2
    if mx >= x and mx <= x+width and my >= y and my <= y+height then 
    else
        return "outside"
    end
end

--Collision for the stats screen
function statsCollision(mx,my)
    local cellFactor = 3
    if system=="Android" then cellFactor=2 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    local nw = cardfont:getWidth("Voltar")+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "outside"
    end
    x = screenw/2-width/2
    y = screenh/2-height/2
    if mx >= x and mx <= x+width and my >= y and my <= y+height then 
    else
        return "outside"
    end
end

function allVisibleCollision(mx,my)
    local androidFactor = 0.25
    if system=="Android" then androidFactor=0.15 end    
    local buttonHeight = 256*androidFactor -- Altura dos botões (ajuste conforme necessário)
    local text = "Ganhar"
    local nw = cardfont:getWidth(text)+45
    local nh = cardfont:getHeight()+15
    local x = screenw/2-nw/2
    local y = screenh-nh-buttonHeight-20-15
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "clicked"
    end
    return ""
end

--Checks if the suits are opposite colors
function checkOpposite(suitx,suity)
    local xcolor = 0
    local ycolor = 0
    if suitx=="clubs" or suitx=="spades" then xcolor=1 else xcolor=2 end
    if suity=="clubs" or suity=="spades" then ycolor=1 else ycolor=2 end
    if xcolor~=ycolor then return true else return false end
end

--Checks if the xnumber is bigger than the ynumber in the solitaire order
function checkIfPost(xnumber,ynumber)
    local xi,yi=0,0
    for i,v in ipairs(ordem) do
        if v==xnumber then xi=i end
        if v==ynumber then yi=i end
    end
    if xi>yi and xi<yi+2 then return true else return false end
end

--Determines where the mouse was in relation to the card being clicked, 
--useful when drawing cardonhand
function whereClicked(check, ...)
    local mx, my = love.mouse.getPosition()
    if check=="list" then
        list, index = ...
        local x = list * (cardw+androidInterSpacing) - androidSpacing
        local y = index * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
        return mx-x,my-y
    elseif check=="pile" then
        pile = ...
        local x = pile * (cardw+androidInterSpacing) - androidSpacing
        local y = cardh-cardh+cardfontsize+5 + androidOverhead
        return mx-x,my-y
    elseif check=="litter" then
        local max = math.min(#cardlitter,3)
        local tempx = (5+max) * (cardw+androidInterSpacing) - androidSpacing
        local x = tempx - max*cardw*0.75 - (100-androidSpacing)
        local y = cardh-cardh+cardfontsize+5 + androidOverhead
        if system=="Android" then x=x+screenw/10 end
        return mx-x, my-y
    else
        return 0,0
    end
end

--A neat function to reset the game
function startGame()
    resetCards()
    addCards()
    save.points=0
    save.currentTime="0:00"
    currentSecs=0
    currentMins=0
    currentCD=0
    timePunish=0
    save.moves=0
    allVisible=false
    winning=false
end

--Wipes the board
function resetCards()
    cardlists = {}
    cardlitter = {}
    cardonhand = nil
    cardpile = {}
    cardstacks = {}

    forwardMoves={}
    lastMoves={}
    lastMovesIndex=1
end

--Helper function to get all the possible cards in a deck
function allCards()
    local obj = {}
    for i=1,#cnaipes do
        for j=1,#ordem do
            obj[#obj+1] = {number=ordem[#ordem-j+1],suit=cnaipes[i]}
        end
    end
    return obj
end

--Helper function to invert a table (move this)
function invertTable(list)
    local obj = {}
    for i=1,#list do
        obj[#list-i+1] = list[i]
    end
    return obj
end

--A organizer function to handle button presses
function pressButton(btn)
    if btn==1 then --UNDO
        getUndo()
    elseif btn==2 then --STATS
        statsButton()
    elseif btn==3 then --NEW
        playSound("new")
        if wonGame==false then save.totalLoss=save.totalLoss+1 end
        save.totalGames=save.totalGames+1
        wonGame=false
        startGame()
    elseif btn==4 then --STORE
        storeButton()
    elseif btn==5 then --REDO
        getRedo()
    end
end

--Returns the cardonhand to where it used to be, 
-- used when the cardonhand lands on a bad spot
function returnCard()
    if clickSendCD<0.5 then
        local pile = checkPiles(cardonhand)
        local list = checkLists(cardonhand)
        if pile~=false then
            cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
            local behindHidden = makeVisible()
            putLastMove(cardonhand.lastlist,"pile"..pile,#cardonhand,0,behindHidden)
            cardonhand=nil
            checkVictory()
            addPoints(15)
            playSound("move")
            clickSendCD=0
            return nil
        elseif list~=false then
            local index = #cardlists[list]
            local newIndex = index+1
            for i,v in ipairs(cardonhand) do
                v.visible=true
                cardlists[list][index+i] = v
            end
            local behindHidden = makeVisible()
            putLastMove(cardonhand.lastlist,list,#cardonhand,newIndex,behindHidden)
            cardonhand=nil
            addPoints(2)
            playSound("move")
            clickSendCD=0
            return nil
        end
    end
    if cardonhand.lastlist=="litter" then
        cardlitter[#cardlitter+1]=cardonhand[1]
    elseif string.match(cardonhand.lastlist,"pile") then
        local pile = tonumber(string.sub(cardonhand.lastlist,5)) or 1
        local actualPile = cardpile[pile]
        if actualPile then
            actualPile[#actualPile+1] = cardonhand[1]
        else
            cardpile[pile] = {}
            cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
        end
    else
        local index = #cardlists[cardonhand.lastlist]
        for i,v in ipairs(cardonhand) do
            cardlists[cardonhand.lastlist][index+i] = v
        end
    end
    clickSendCD=0
    return nil
end

--checks if cardonhand can move to any pile
function checkPiles(ch)
    if #ch>1 then return false end
    local coh = ch[1]
    if coh.number=="A" then
        cardpile[#cardpile+1] = {}
        return #cardpile
    end
    for k,v in ipairs(cardpile) do
        local card = v[#v]
        print(card.number)
        if checkIfPost(card.number,coh.number) and coh.suit==card.suit then
            return k
        end
    end
    return false
end

--checks if cardonhand can move to a list
function checkLists(ch)
    local coh = ch[1]
    local last = ch.lastlist or "pass"
    for k,v in ipairs(cardlists) do
        if #v>0 then
            local card = v[#v]
            if checkIfPost(coh.number,card.number) and checkOpposite(card.suit,coh.suit) and (last=="pass" or last~=k) then
                return k
            end
        elseif coh.number=="K" then
            return k
        end
    end
    return false
end

--Makes the last card of the last list of the cardonhand visible
function makeVisible()
    local vis = true
    if cardonhand.lastlist~="litter" and not string.match(cardonhand.lastlist,"pile") then
        if #cardlists[cardonhand.lastlist]>0 then
            vis = cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible
            cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible = true
        end
    end
    allVisible = checkAllVisible()
    return vis
end

--Saves the last move made on a table and resets the forwardMoves table
function putLastMove(oldLocation,newLocation,size,index,behindHidden)
    local move = oldLocation.."|"..newLocation.."|"..size.."|"..index.."|"..tostring(behindHidden)
    lastMoves[#lastMoves+1] = move
    lastMovesIndex = #lastMoves+1
    forwardMoves = {}
    save.moves=save.moves+1
end

--Gets the undo and does the funky bits
function getUndo()
    if lastMovesIndex>1 then
        local undoObj = lastMoves[lastMovesIndex-1]
        local move = ""
        if undoObj=="stack" then
            stackMove("backward")
            move = "stack"
            lastMovesIndex = lastMovesIndex - 1
        elseif undoObj=="restack" then
            cardlitter=invertTable(cardstacks)
            cardstacks={}
            move = "restack"
            lastMovesIndex = lastMovesIndex - 1
        else
            lastMovesIndex = lastMovesIndex - 1
            local splitted = split(undoObj,"|")
            local from = splitted[2]
            local to = splitted[1]
            local size = tonumber(splitted[3])
            local index = tonumber(splitted[4])
            local behindHidden = splitted[5]
            index = execMove(from,to,size,index,"undo",behindHidden)
            move = from.."|"..to.."|"..size.."|"..index.."|"..tostring(behindHidden)
        end
        forwardMoves[#forwardMoves+1] = move
        table.remove(lastMoves,lastMovesIndex)
        deductPoints(10)
        save.moves=save.moves+1
    end
end

--Gets the redo and does the funky bits
function getRedo()
    if #forwardMoves>0 then
        local redoObj = forwardMoves[#forwardMoves]
        local move = ""
        if redoObj=="stack" then
            stackMove("forward")
            move = "stack"
        elseif redoObj=="restack" then
            cardstacks=invertTable(cardlitter)
            cardlitter={}
            move = "restack"
        else
            local splitted = split(redoObj,"|")
            local from = splitted[2]
            local to = splitted[1]
            local size = tonumber(splitted[3])
            local index = tonumber(splitted[4])
            index = execMove(from,to,size,index,"redo")
            move = from.."|"..to.."|"..size.."|"..index
        end
        lastMoves[#lastMoves+1] = move
        lastMovesIndex = #lastMoves+1
        table.remove(forwardMoves,#forwardMoves)
        save.moves=save.moves+1
    end
end

--Executes a move, used with Undo/Redo
function execMove(from,to,size,index,operation,behindHidden)
    --get card
    local card = {}
    if string.match(from,"pile") then
        local pile = tonumber(string.sub(from,5)) or 1
        local actualPile = cardpile[pile]
        card = {actualPile[#actualPile]}
        table.remove(actualPile,#actualPile)
        if #actualPile==0 then cardpile[pile] = nil end
    elseif from=="litter" then
        card = {cardlitter[#cardlitter]}
        table.remove(cardlitter,#cardlitter)
    else
        from = tonumber(from)        
        for i=index,#cardlists[from] do
            card[#card+1] = cardlists[from][i]
        end
        for i=index,#cardlists[from] do
            table.remove(cardlists[from],index)
        end
        if cardlists[from][#cardlists[from]] then cardlists[from][#cardlists[from]].visible=true end 
    end

    --put card
    if string.match(to,"pile") then
        local pile = tonumber(string.sub(to,5)) or 1
        local actualPile = cardpile[pile]
        if actualPile==nil then cardpile[pile] = {}; actualPile=cardpile[pile] end
        actualPile[#actualPile+1] = card[1]
        return #actualPile
    elseif to=="litter" then
        cardlitter[#cardlitter+1] = card[1]
        return #cardlitter
    else
        to = tonumber(to)
        for i=1,#card do
            cardlists[to][#cardlists[to]+1] = card[i]
        end
        --print(behindHidden)
        if cardlists[to][#cardlists[to]-size] and operation=="undo" and behindHidden=="false" then cardlists[to][#cardlists[to]-size].visible = false end
        return #cardlists[to]-size+1
    end
end

--Moves cards from or to the stack
function stackMove(where)
    if where=="backward" then
        cardstacks[#cardstacks+1] = cardlitter[#cardlitter]
        table.remove(cardlitter,#cardlitter)
    else
        cardlitter[#cardlitter+1] = cardstacks[#cardstacks]
        table.remove(cardstacks,#cardstacks)
    end
end

--Inverts inStore
function storeButton()
    inStore = not inStore
end

--Inverts inStats
function statsButton()
    inStats = not inStats
end

--Resets all fonts to a new font size
function resetAllFonts()
    cardStyle.font = love.graphics.newFont(cardStyle.fontName,cardfontsize)
    for k,v in ipairs(storeItems) do
        v.font = love.graphics.newFont(v.fontName,cardfontsize)
    end
    for k,v in ipairs(storeCB) do
        v.font = love.graphics.newFont(v.fontName,cardfontsize)
    end
    for k,v in ipairs(storeBacks) do
        v.font = love.graphics.newFont(v.fontName,cardfontsize)
    end
end

function resetImages()
    for k,v in ipairs(storeCB) do
        v.img = love.graphics.newImage(v.imgName)
    end
    for k,v in ipairs(storeBacks) do
        v.img = love.graphics.newImage(v.imgName)
    end
end

--Changes the background image
function changeBack(img)
    backgroundImg=img
end

--Checks all the piles for Kings in their last positions
function checkVictory()
    local comply = 0
    for k,v in ipairs(cardpile) do
        if v[#v].number == "K" then comply=comply+1 end
    end
    if comply==4 then
        calculateVictory()
        statsUpdate()
        save.totalWins=save.totalWins+1
        wonGame=true
        winning=false
        allVisible=false
        playSound("victory")
        inVictory=true
    end
end

--Calculate the victory coins
function calculateVictory()
    --calculate the total coins
    local timeBonus = 0
    local movBonus = 0
    local totalSecs = currentMins*60+currentSecs
    if totalSecs<=150 then
        timeBonus=15
    elseif totalSecs>=240 and totalSecs<=480 then
        timeBonus=-5
    elseif totalSecs>480 then
        timeBonus=-15
    end
    if save.moves<=100 then
        movBonus=15
    elseif save.moves>300 then
        movBonus=-25
    end
    victoryCoins = math.floor(math.max(50,(save.points*0.45)+timeBonus+movBonus))
    save.coins=save.coins+victoryCoins
end

--Update the timer including the 0 in the seconds
function updateTime()
    currentSecs=currentSecs+1
    if currentSecs>59 then
        currentSecs=0
        currentMins=currentMins+1
    end
    if currentSecs>9 then
        save.currentTime=currentMins..":"..currentSecs
    else
        save.currentTime=currentMins..":0"..currentSecs
    end
end

--Does all the funky stuff and shuffles the deck and sets a new board
function addCards()
    local cards = allCards()
    local limit = 28
    local hardSetting = 50
    for i=1,#cards do
        local toWhere = random(1,100)
        local card = cards[i]
        if toWhere<=hardSetting and i==#cards-limit then toWhere=100 end
        if limit==0 then toWhere=1 end
        if toWhere>hardSetting and limit>0 then
            local trying = true
            local column = random(1,7)
            while trying do
                column = random(1,7)
                if cardlists[column] then
                    if #cardlists[column]<column then trying=false end
                else
                    trying=false
                end
            end
            local isVisible=false
            addCardToList(column,card.number,card.suit,isVisible)
            limit=limit-1
        else
            cardstacks[#cardstacks+1] = card
        end
    end

    --shuffle the stacks
    local obj = cardstacks
    cardstacks={}
    for i=1,#obj do
        local cardID = random(1,#obj)
        cardstacks[#cardstacks+1] = obj[cardID]
        table.remove(obj,cardID)
    end

    for i=1,7 do
        cardlists[i][#cardlists[i]].visible=true
    end
end

function love.quit()
    local success = saveGame()
    if success then
        return false
    else
        return true
    end
end

function saveGame()
    local svFile = json.encode(save)
    local success, message = love.filesystem.write("save",svFile)
    svFile = json.encode(storeItems)
    local success1, message = love.filesystem.write("storeItems",svFile)
    svFile = json.encode(storeCB)
    local success2, message = love.filesystem.write("storeCB",svFile)
    svFile = json.encode(storeBacks)
    local success3, message = love.filesystem.write("storeBacks",svFile)
    svFile = json.encode(cardStyle)
    local success4, message = love.filesystem.write("cardStyle",svFile)
    return success and success1 and success2 and success3 and success4
end

function readSave()
    local check = love.filesystem.getInfo("save") 
    if check then
        local temp, size = love.filesystem.read("save")
        local tmp = love.filesystem.read("storeItems")
        storeItems = json.decode(tmp)
        tmp = love.filesystem.read("storeCB")
        storeCB = json.decode(tmp)
        tmp = love.filesystem.read("storeBacks")
        storeBacks = json.decode(tmp)
        tmp = love.filesystem.read("cardStyle")
        cardStyle = json.decode(tmp)
        return json.decode(temp)
    else
        return nil
    end
end

function statsUpdate()
    local lowest = split(save.lowTime,":")
    if (save.lowTime=="0:00") then
        save.lowTime=currentMins..":"..formatSecs(currentSecs)
    else
        if currentMins<tonumber(lowest[1]) then
            save.lowTime=currentMins..":"..formatSecs(currentSecs)
        elseif currentMins==tonumber(lowest[1]) and currentSecs<tonumber(lowest[2]) then
            save.lowTime=currentMins..":"..formatSecs(currentSecs)
        end
    end
    local highest = split(save.highTime,":")
    if (save.highTime=="0:00") then
        save.highTime=currentMins..":"..formatSecs(currentSecs)
    else
        if currentMins>tonumber(highest[1]) then
            save.highTime=currentMins..":"..formatSecs(currentSecs)
        elseif currentMins==tonumber(highest[1]) and currentSecs>tonumber(highest[2]) then
            save.highTime=currentMins..":"..formatSecs(currentSecs)
        end
    end
    local totalTime = split(save.totalTime,":")
    totalTime[1]=tonumber(totalTime[1])+currentMins
    totalTime[2]=tonumber(totalTime[2])+currentSecs
    if totalTime[2]>=60 then totalTime[2]=totalTime[2]-60;totalTime[1]=totalTime[1]+1 end
    save.totalTime=totalTime[1]..":"..formatSecs(totalTime[2])

    if save.points>save.highScore then save.highScore=save.points end
end

function allVisibleMakeMove()
    for k,v in ipairs(cardlists) do
        if #v>0 then
            local card=v[#v]
            local pile = checkPiles({card})
            if pile~=false then
                cardpile[pile][#cardpile[pile]+1] = card
                addPoints(15)
                playSound("move")
                save.moves=save.moves+1
                table.remove(v,#v)
                break
            end
        end
    end
    for i=1, #cardstacks+#cardlitter do
        if #cardlitter>0 then
            local card = cardlitter[#cardlitter]
            local pile = checkPiles({card})
            local list = checkLists({card})
            if pile~=false then
                cardpile[pile][#cardpile[pile]+1] = card
                addPoints(15)
                playSound("move")
                save.moves=save.moves+1
                table.remove(cardlitter,#cardlitter)
                break
            else
                if #cardstacks>0 then
                    local card = cardstacks[#cardstacks]
                    cardlitter[#cardlitter+1] = card
                    table.remove(cardstacks,#cardstacks)
                    playSound("move")
                    save.moves=save.moves+1
                    break
                else
                    cardstacks = invertTable(cardlitter)
                    cardlitter = {}
                    save.moves=save.moves+1
                    deductPoints(100)
                end
            end
        elseif #cardstacks>0 then
            local card = cardstacks[#cardstacks]
            cardlitter[#cardlitter+1] = card
            table.remove(cardstacks,#cardstacks)
            playSound("move")
            save.moves=save.moves+1
            break
        else
            cardstacks = invertTable(cardlitter)
            cardlitter = {}
            deductPoints(100)
            save.moves=save.moves+1
        end
    end
end

function unusedAddCards()
    local cards = allCards()
    for i=1,4 do
        for j=1,13 do
            local naipe = (i+j)%4
            local number = j
            if naipe==0 then naipe=4 end
            print(ordem[number], cnaipes[naipe])
            if j<9 then
                if cardlists[i%4+1] then
                    addCardToList(i%4+1,ordem[number],cnaipes[naipe],true)
                else
                    cardlists[i%4+1] = {}
                    addCardToList(i%4+1,ordem[number],cnaipes[naipe],true)
                end
            else
                cardstacks[#cardstacks+1] = {number=ordem[number],suit=cnaipes[naipe]}
            end
            if i==4 and j==13 then
                return false
            end
        end
    end
end



