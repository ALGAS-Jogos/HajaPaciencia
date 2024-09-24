love.graphics.setDefaultFilter("linear","linear",10)

--to rework this game.

require("utils.json")
require("store.store")
require("utils.draw")
require("utils.utils")
require("utils.settings")
require("utils.cards")
require("utils.vars")
require("utils.card")

local actualVersion = "1.5" --change the version
local standard = 392 --my phone width


function love.load()
    local temp = readSave()
    if temp~=nil then
        save=temp        
        if save.version~=actualVersion then --put new shit in updates on the store!!!!
            local items = loadStoreItems()
            if #storeItems<#items then
                for i=#storeItems,#items do
                    table.insert(storeItems,items[i])
                end
            end
            local backs = loadStoreBacks()
            if #storeBacks<#backs then
                for i=#storeBacks,#backs do
                    table.insert(storeBacks,backs[i])                    
                end
            end
            local cb = loadStoreCB()
            if #storeCB<#cb then
                for i=#storeCB,#cb do
                    table.insert(storeCB,i)                    
                end
            end
            save.version=actualVersion
        end
        local time = split(save.currentTime,":")
        currentMins=time[1]
        currentSecs=time[2]
        love.audio.setVolume(settings.volume.value/100)
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
        local wait=true
        while wait do
            love.window.maximize()
            local tx, ty = love.graphics.getDimensions()
            if ty>tx then wait=false end
        end
        screenw, screenh = love.graphics.getDimensions()
        local scale = screenw/standard
        suitSize=suitSize/1.8*scale
        cardw=cardw/2*scale
        cardh=cardh/2*scale
        round = 3*scale
        androidSpacing=50*scale
        androidOverhead=50*scale
        androidSmall=0.03*scale
        androidInterSpacing=5*scale
        cardfontsize=math.floor(cardfontsize/1.5)*scale
        cardfont=love.graphics.newFont(cardfontsize)
        storeRows=3
    end
    resetAllFonts()
    resetImages()
    settingsAllowed = calculateSettingsToShow()
    settingsPages = math.floor(settingsLen/settingsAllowed)+1
    if settingsLen==settingsAllowed then settingsPages=settingsPages-1 end
    startGame()
end

function love.update(dt)
    local mousex,mousey = love.mouse.getPosition()
    if love.mouse.isDown(1)==false then
        if cardonhand==nil then
        else
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
                    if string.match(cardonhand.lastlist,"pile") then
                        local pile = tonumber(string.sub(cardonhand.lastlist,5)) or 1
                        local actualPile = cardpile[pile]
                        if actualPile then
                            if not (#actualPile>0) then table.remove(cardpile,pile) end
                        end
                    end
                    if checkIfPileLast(cardonhand.lastlist) then addPoints(2) end
                    cardonhand=nil                    
                    playSound("move")
                else
                    cardonhand = returnCard()                
                end
            elseif pile and #cardonhand==1 and cardonhand.lastlist~="pile"..pile then
                if cardpile[pile] then
                    local lastCardPile = cardpile[pile][#cardpile[pile]]
                    if lastCardPile then --checa se a ultima carta não é nula
                        if cardonhand[1].suit==lastCardPile.suit and checkIfPost(lastCardPile.number,cardonhand[1].number) and #cardonhand==1 then
                            cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
                            
                            local behindHidden = makeVisible()
                            putLastMove(cardonhand.lastlist,"pile"..pile,#cardonhand,0,behindHidden)
                            checkVictory()
                            if not string.match(cardonhand.lastlist,"pile") then addPoints(15) end
                            playSound("move")
                            cardonhand=nil
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
                        if not string.match(cardonhand.lastlist,"pile") then addPoints(15) end
                        cardonhand=nil
                        playSound("move")
                    else
                        cardonhand = returnCard()
                    end
                end
            elseif baselist and cardonhand.lastlist~=baselist then
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

    if cardonhand~=nil then clickSendCD = clickSendCD+dt end
    pileCheckCD=pileCheckCD+dt

    if winning then
        winningCD=winningCD+dt
        if winningCD>=0.1 then
            winningCD=winningCD-0.1
            allVisibleMakeMove()
            checkVictory()
        end
    end

    if inVictory==false and inStats==false and inStore==false and wonGame==false and inSettings==false and (love.window.hasMouseFocus() or love.window.hasFocus()) and settingsEraseAll==false then
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

        if pileCheckCD>=0.8 then
            checkNullPiles()
            pileCheckCD=pileCheckCD-0.8
        end
    end
    cardAnimationCD=cardAnimationCD+dt
    if cardAnimationCD>=0.001 then
        for w,v in pairs(cardAnimate) do
            local x = v.x
            local y = v.y
            local width=v.width*1.1
            local height=v.height*1.1
            v.cardx=v.cardx+width
            v.cardy=v.cardy+height
            if v.cardx+cardw/2 >= x and v.cardx <= x+cardw/2 and v.cardy+cardh/2 >= y and v.cardy <= y+cardh/2 then
                cardAnimate[w]=nil
            end
        end
        cardAnimationCD=cardAnimationCD-0.001
    end
end

function love.mousepressed(x, y, button, istouch)
    mouseReleasedPos=nil
    if button == 1 then 
        if inStats==false and inStore==false and inVictory==false and inSettings==false and settingsEraseAll==false then
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
                            save.moves=save.moves+1
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
                    playSound("menu")
                end
            end
        end
    end
 end

function love.draw()
    local mousex, mousey = love.mouse.getPosition()

    local scaleBackX, scaleBackY = backgroundImg:getDimensions()
    scaleBackX = screenw/scaleBackX
    scaleBackY = screenh/scaleBackY
    love.graphics.setColor(settings.backColor.possible[settings.backColor.value])
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
            if cardAnimate["list"..k..":"..i]==nil then
                if card.visible then 
                    drawCard(card.number,card.suit,x,y)
                else
                    drawBack(x,y)
                end
            else
                break
            end
        end
    end

    for i=1,4 do
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = cardh-cardh+cardfontsize+5 + androidOverhead
        if cardpile[i] then
            local card = cardpile[i][#cardpile[i]]
            if cardAnimate["pile"..i]==nil then
                if card then
                    drawCard(card.number,card.suit,x,y)
                end
            else
                local card = cardpile[i][#cardpile[i]-1]
                if card then
                    drawCard(card.number,card.suit,x,y)
                end
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

    for k,v in pairs(cardAnimate) do
        for i,card in ipairs(v.cards) do
            local y = v.cardy + ((i-1)*(cardh-cardh+cardfontsize+5))
            drawCard(card.number,card.suit,v.cardx,y)
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
    if allVisible and winning==false then drawAllVisible() end
    if inSettings then drawSettings() end
    if settingsEraseAll then drawSettingsEraseAll() end
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
    local x =  7 * (cardw+androidInterSpacing) - androidSpacing
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
        local y = screenh - buttonHeight - 10
        for i, btn in ipairs(buttons) do
            local x = xStart + (i - 1) * (buttonWidth + totalPadding)
            if mx >= x and mx <= x+buttonWidth and my >= y and my <= y+buttonHeight then            
                return i
            end
        end
        local x = 15
        y = y - buttonHeight-10
        if mx >= x and mx <= x+buttonWidth and my >= y and my <= y+buttonHeight then            
            return 6
        end
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

--A organizer function to handle button presses
function pressButton(btn)
    if btn==1 and wonGame==false then --UNDO
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
    elseif btn==5 and wonGame==false then --REDO
        getRedo()
    elseif btn==6 then
        settingsButton()
    end
end

--Inverts inStore
function storeButton()
    storePage=1
    if storeState==1 then
        storePages=math.ceil(#storeItems/(storeMax*storeRows))
    elseif storeState==2 then
        storePages=math.ceil(#storeCB/(storeMax*storeRows))
    elseif storeState==3 then
        storePages=math.ceil(#storeBacks/(storeMax*storeRows))
    end
    inStore = not inStore
end

function settingsButton()
    inSettings = not inSettings
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
    svFile = json.encode(settings)
    local success5, message = love.filesystem.write("config",svFile)
    
    return success and success1 and success2 and success3 and success4 and success5
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
        tmp = love.filesystem.read("config")
        settings = json.decode(tmp)
        return json.decode(temp)
    else
        return nil
    end
end

function eraseSave()
    love.filesystem.remove("save")
    love.filesystem.remove("storeItems")
    love.filesystem.remove("storeBacks")
    love.filesystem.remove("storeCB")
    love.filesystem.remove("config")
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
    
    settings = loadSettings()
    storeItems=loadStoreItems()
    storeCB=loadStoreCB()
    storeBacks=loadStoreBacks()
    backgroundImg = love.graphics.newImage(save.backImg)
    cardBack = love.graphics.newImage(save.backCard)
    resetAllFonts()
    resetImages()
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

function love.mousereleased(x,y)
    mouseReleasedPos = {x=x,y=y}
end