love.graphics.setDefaultFilter("linear","linear",10)

--to rework this game.

require("utils.json")
require("store.store")
require("utils.draw")
require("utils.utils")
require("utils.settings")

ordem = {"K","Q","J",10,9,8,7,6,5,4,3,2,"A"}
cnaipes = {"spades","diamonds","clubs","hearts"}

local actualVersion = "1.5"
local standard = 392 --my phone width

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
settingsImg = love.graphics.newImage("img/settings.png")

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
inSettings = false

wonGame = false
allVisible = false
winning = false
winningCD = 0

pileCheckCD = 0

victoryCoins = 0

storeItems = {}
storeCB = {}
storeBacks = {}

storeButtons = {"Cartas","Versos","Fundos"}
storeState = 1
storePage = 1
storePages = 1
storeMax = 6
storeRows = 2

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
    backCard="cards/back1.png",
    version="1.3"
}

settings, settingsLen = loadSettings()
settingsEraseAll = false
settingsAllowed = 2
settingsPage = 1
settingsPages = math.floor(#settings/settingsAllowed)

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

cardAnimate = {}
cardAnimationCD = 0

love.graphics.setBackgroundColor(0.2,0.05,0.2)

love.math.setRandomSeed(os.time())
random = love.math.random

sounds = {
    move = love.audio.newSource("sfx/newmove.mp3","static"),
    new = love.audio.newSource("sfx/new.mp3","static"),
    victory = love.audio.newSource("sfx/victory.mp3","static"),
    menu = love.audio.newSource("sfx/menu.mp3","static"),
    error = love.audio.newSource("sfx/error.mp3","static")
}

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
                    print("bascshere")
                end
            end
            local cb = loadStoreCB()
            if #storeCB<#cb then
                for i=#storeCB,#cb do
                    table.insert(storeCB,i)
                    print("CBhere")
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
                    if checkIfPileLast(cardonhand.lastlist)==false then addPoints(2) end
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
        elseif inStore then
            if inStorePrompt==nil then
                local whatButton = storeCollision(x,y)
                playSound("menu")
                if whatButton=="outside" then
                    inStore=false
                elseif whatButton==1 or whatButton==2 or whatButton==3 then
                    storeState=whatButton
                    storePage=1
                    if storeState==1 then
                        storePages=math.ceil(#storeItems/(storeMax*storeRows))
                    elseif storeState==2 then
                        storePages=math.ceil(#storeCB/(storeMax*storeRows))
                    elseif storeState==3 then
                        storePages=math.ceil(#storeBacks/(storeMax*storeRows))
                    end
                elseif whatButton=="nextPage" then
                    storePage=math.min(storePage+1,storePages)
                elseif whatButton=="prevPage" then
                    storePage=math.max(storePage-1,1)
                end
            else
                local whatButton = storePromptCollision(x,y)
                playSound("menu")
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
            playSound("menu")
            if whatButton=="outside" then
                inStats=false
            end
        elseif inVictory then
            local whatButton = victoryCollision(x,y)
            playSound("menu")
            if whatButton=="new" then
                pressButton(3)
                inVictory=false
            elseif whatButton=="outside" then
                inVictory=false
            end
        elseif inSettings then
            local whatButton = settingsCollision(x,y)
            playSound("menu")
            if whatButton=="outside" then
                inSettings=false
            elseif whatButton=="eraseSave" then
                --eraseSave()
                --inSettings=false
                settingsEraseAll=true
                inSettings=false
            elseif whatButton=="nextPage" then
                settingsPage=math.min(settingsPage+1,settingsPages)
            elseif whatButton=="prevPage" then
                settingsPage=math.max(settingsPage-1,1)
            end
            if whatButton.action == "plus" then
                if whatButton.name=="Cor do fundo" then
                    switchNext(settings.backColor)
                elseif whatButton.name=="Dificuldade" then
                    switchNext(settings.hardSetting)
                elseif whatButton.name=="Vel. Animação" then
                    stepSetting(settings.animationSpeed,1)
                elseif whatButton.name=="Volume" then
                    stepSetting(settings.volume,1)
                    love.audio.setVolume(settings.volume.value/100)
                end
            elseif whatButton.action=="minus" then
                if whatButton.name=="Cor do fundo" then
                    switchPrior(settings.backColor)
                elseif whatButton.name=="Dificuldade" then
                    switchPrior(settings.hardSetting)
                elseif whatButton.name=="Vel. Animação" then
                    stepSetting(settings.animationSpeed,-1)
                elseif whatButton.name=="Volume" then
                    stepSetting(settings.volume,-1)
                    love.audio.setVolume(settings.volume.value/100)
                end
            end
        elseif settingsEraseAll then
            local whatButton=settingEraseCollision(x,y)
            if whatButton=="outside" then
                settingsEraseAll=false
                playSound("menu")
            elseif whatButton=="erase" then
                playSound("menu")
                eraseSave()
                settingsEraseAll=false
                startGame()
                playSound("new")
            end
        end
    end
    if allVisible then
        local whatButton = allVisibleCollision(x,y)
        if whatButton=="clicked" and checkAllVisible() then
            winning=true
            allVisible=false
            winningCD=0
        else
            allVisible=false
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

function addCardToListGen(listnumber,number,suit,visible)
    if cardlists[listnumber] then
    else
        cardlists[listnumber] = {}
    end
    local obj={{number=number,suit=suit,visible=visible}}
    for k,v in ipairs(cardlists[listnumber]) do
        obj[#obj+1] = v
    end
    cardlists[listnumber]=obj
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

--Collision of the store
function storeCollision(mx,my)
    local width = screenw-(screenw/8)
    local height = screenh-(screenh/3.5)
    local dockh = height/8

    local nw = cardfont:getWidth(storeButtons[1])+15
    local totalWidth = nw*3
    local spacing = (screenw-totalWidth)/4
    local y = screenh/2-height/2+5
    local nh = cardfontsize+10
    for i=1,3 do
        local x = (i-1)*(nw+spacing)+spacing
        if mx >= x and mx <= x+nw and my >= y and my <= y+nh then 
            return i
        end
    end
    local ySpacing = cardfontsize+5

    if storeState==1 then
        local y = screenh/2-height/2 + height/25+ySpacing
        for k=1,#storeItems do            
            local itr = k
            local spacing = ((width-cardw*storeMax))/storeMax
            local otherSpacing = ((screenw/2-width/2+(storeMax)*(cardw+spacing))-width)/storeMax
            if k>storeMax*storeRows then break end
            if k%(storeMax+1)==0 then 
                y=y+(cardh+cardfontsize+16)*math.floor(k/storeMax)
            end
            if k>storeMax then itr=k%storeMax end
            if itr==0 then itr=storeMax end
            local x = screenw/2-width/2+(itr-1)*(cardw+spacing) + otherSpacing
            local v = storeItems[k+(storeMax*storeRows*(storePage-1))]
            if v==nil then break end
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then 
                v["index"] = k+((storeMax*storeRows)*(storePage-1))
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
        local y = screenh/2-height/2 + height/25+ySpacing
        for k=1,#storeCB do            
            local itr = k
            local spacing = ((width-cardw*storeMax))/storeMax
            local otherSpacing = ((screenw/2-width/2+(storeMax)*(cardw+spacing))-width)/storeMax
            if k>storeMax*storeRows then break end
            if k%(storeMax+1)==0 then 
                y=y+(cardh+cardfontsize+16)*math.floor(k/storeMax)
            end
            if k>storeMax then itr=k%storeMax end
            if itr==0 then itr=storeMax end
            local x = screenw/2-width/2+(itr-1)*(cardw+spacing) + otherSpacing
            local v = storeCB[k+(storeMax*storeRows*(storePage-1))]
            if v==nil then break end
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then 
                v["index"] = k+((storeMax*storeRows)*(storePage-1))
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
        local y = screenh/2-height/2 + height/25+ySpacing
        for k=1,#storeBacks do            
            local itr = k
            local spacing = ((width-cardw*storeMax))/storeMax
            local otherSpacing = ((screenw/2-width/2+(storeMax)*(cardw+spacing))-width)/storeMax
            if k>storeMax*storeRows then break end
            if k%(storeMax+1)==0 then 
                y=y+(cardh+cardfontsize+16)*math.floor(k/storeMax)
            end
            if k>storeMax then itr=k%storeMax end
            if itr==0 then itr=storeMax end
            local x = screenw/2-width/2+(itr-1)*(cardw+spacing) + otherSpacing
            local v = storeBacks[k+(storeMax*storeRows*(storePage-1))]
            if v==nil then break end
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then 
                v["index"] = k+((storeMax*storeRows)*(storePage-1))
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

    local nw = cardfont:getWidth(">")+15
    local nh = cardfontsize+10
    local x = screenw/2+width/2-nw-15
    local y = screenh/2-height/2+height-dockh
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "nextPage"
    end
    nw = cardfont:getWidth(storePage.."/"..storePages)+15
    x = x-nw-5
    nw = cardfont:getWidth("<")+15
    x = x-nw-5
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "prevPage"
    end

    x = screenw/2-width/2
    y = screenh/2-height/2
    if mx >= x and mx <= x+width and my >= y and my <= y+height then 
    else
        return "outside"
    end
    return "nothing"
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

function settingsCollision(mx,my)
    --grey the background out
    love.graphics.setColor(0,0,0,0.3)
    love.graphics.rectangle('fill',0,0,screenw,screenh)
    --draw the base rectangle and its border
    local cellFactor = 2.8
    if system=="Android" then cellFactor=2.4 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    local x = screenw/2-width/2
    local y = screenh/2-height/2+15
    local ySpacing = cardfont:getHeight()-10
    y=y+cardfontsize+ySpacing
    local count = 0
    local objective = settingsPage*settingsAllowed-settingsAllowed
    for i,v in pairs(settings) do
        count=count+1
        if count>settingsAllowed*settingsPage then break end
        if count>objective then
            y=y+ySpacing+ySpacing+10
            local nw = cardfont:getWidth("+")+30
            local nh = cardfont:getHeight()+5
            local nx = x+width-nw-15
            --o mais
            if mx >= nx and mx <= nx+nw and my >= y and my <= y+nh then
                return {name=v.name,action="plus"}
            end
            nx=x+10
            if mx >= nx and mx <= nx+nw and my >= y and my <= y+nh then
                return {name=v.name,action="minus"}
            end
            y=y+cardfontsize+ySpacing+5
        end
    end

    local nw = cardfont:getWidth("Apagar dados")+30
    local nh = cardfont:getHeight()+5
    local nx = x+15
    y=screenh/2+height/2-nh-15-nh-15
    if mx >= nx and mx <= nx+nw and my >= y and my <= y+nh then
        return "eraseSave"
    end
    nw = cardfont:getWidth("Voltar")+30
    nh = cardfont:getHeight()+5
    nx = x+15
    y=screenh/2+height/2-nh-15
    if mx >= nx and mx <= nx+nw and my >= y and my <= y+nh then
        return "outside"
    end

    local nw = cardfont:getWidth(">")+15
    local nh = cardfontsize+10
    local x = screenw/2+width/2-nw-15
    local y = screenh/2-height/2+height-nh-15
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "nextPage"
    end
    nw = cardfont:getWidth(settingsPage.."/"..settingsPages)+15
    x = x-nw-5
    nw = cardfont:getWidth("<")+15
    x = x-nw-5
    if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
        return "prevPage"
    end



    x = screenw/2-width/2
    y = screenh/2-height/2
    if mx >= x and mx <= x+width and my >= y and my <= y+height then 
    else
        return "outside"
    end
    return "ok"
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

function settingEraseCollision(mx,my)
        --grey the background out
        
        --draw the base rectangle and its border
        local cellFactor = 2
        if system=="Android" then cellFactor=1.60 end
        local width = screenw-(screenw/4)
        local height = screenh-(screenh/cellFactor)
        local x = screenw/2-width/2
        local y = screenh/2-height/2
        if mx >= x and mx <= x+width and my >= y and my <= y+height then
        else
            return "outside"
        end

        local text = "Não"
        local nw = cardfont:getWidth(text)+30
        local nh = height/6
        local x = screenw/2-width/2+nw/2+5
        local y = screenh/2+height/2-nh-15
        if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
            return "outside"
        end

    
        local text = "SIM"
        local nw = cardfont:getWidth(text)+30
        local nh = height/6
        local x = screenw/2+width/2-nw-nw/2-5
        local y = screenh/2+height/2-nh-15
        if mx >= x and mx <= x+nw and my >= y and my <= y+nh then
            return "erase"
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

--Returns the cardonhand to where it used to be, 
-- used when the cardonhand lands on a bad spot
function returnCard()
    local mx, my = love.mouse.getPosition()
    local speed = settings.animationSpeed.value
    if clickSendCD<0.5 then
        local pile = checkPiles(cardonhand)
        local list = checkLists(cardonhand)
        if pile~=false and cardonhand.lastlist~="pile"..pile then
            cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
            local behindHidden = makeVisible()
            putLastMove(cardonhand.lastlist,"pile"..pile,#cardonhand,0,behindHidden)
            checkVictory()
            if not string.match(cardonhand.lastlist,"pile") then addPoints(15) end
            playSound("move")
            clickSendCD=0
            local x = pile * (cardw+androidInterSpacing) - androidSpacing
            local y = cardh-cardh+cardfontsize+5 + androidOverhead
            local m = math.atan2(y-(my-cardonhand.cardy),x-(mx-cardonhand.cardx))
            local width=speed*math.cos(m)
            local height=speed*math.sin(m)
            local temp = {cards=cardonhand,cardx=mx-cardonhand.cardx,cardy=my-cardonhand.cardy,x=x,y=y,width=width,height=height}
            cardAnimate["pile"..pile] = temp    
            return nil
        elseif list~=false and cardonhand.lastlist~=list then
            local index = #cardlists[list]
            local newIndex = index+1
            for i,v in ipairs(cardonhand) do
                v.visible=true
                cardlists[list][index+i] = v
            end
            local behindHidden = makeVisible()
            putLastMove(cardonhand.lastlist,list,#cardonhand,newIndex,behindHidden)
            if checkIfPileLast(cardonhand.lastlist)==false then addPoints(2) end
            playSound("move")
            clickSendCD=0
            local x = tonumber(list) * (cardw+androidInterSpacing) - androidSpacing
            local y = tonumber(newIndex) * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
            local m = math.atan2(y-(my-cardonhand.cardy),x-(mx-cardonhand.cardx))
            local width=speed*math.cos(m)
            local height=speed*math.sin(m)
            local temp = {cards=cardonhand,cardx=mx-cardonhand.cardx,cardy=my-cardonhand.cardy,x=x,y=y,width=width,height=height}
            cardAnimate["list"..list..":"..newIndex] = temp
            if string.match(cardonhand.lastlist,"pile") then
                local pile = tonumber(string.sub(cardonhand.lastlist,5)) or 1
                local actualPile = cardpile[pile]
                if actualPile then
                    if not (#actualPile>0) then table.remove(cardpile,pile) end
                end
            end
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
    playSound("error")
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
    else
        playSound("error")
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

--Checks all the piles for Kings in their last positions
function checkVictory()
    local comply = 0
    for k,v in ipairs(cardpile) do
        if v[#v]==nil then return false end
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
    --if unusedAddCards()==false then return true end
    local cards = allCards()
    local limit = 28
    local hardSetting = settings.hardSetting.possible[settings.hardSetting.value]
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
            addCardToListGen(column,card.number,card.suit,isVisible)
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
                local x = pile * (cardw+androidInterSpacing) - androidSpacing
                local y = cardh-cardh+cardfontsize+5 + androidOverhead
                local cardx = k * (cardw+androidInterSpacing) - androidSpacing
                local cardy = #v * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
                local m = math.atan2(y-(cardy),x-(cardx))
                local width=35*math.cos(m)
                local height=35*math.sin(m)
                local temp = {cards={card},cardx=cardx,cardy=cardy,x=x,y=y,width=width,height=height}
                cardAnimate["pile"..pile] = temp
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
                local tempx = (5+#cardlitter%3+1) * (cardw+androidInterSpacing) - androidSpacing
                local x = pile * (cardw+androidInterSpacing) - androidSpacing
                local y = cardh-cardh+cardfontsize+5 + androidOverhead
                local cardx = tempx - (#cardlitter%3+1)*cardw*0.75 - (100-androidSpacing)
                local cardy = cardh-cardh+cardfontsize+5 + androidOverhead
                if system=="Android" then cardx=cardx+screenw/10 end
                local m = math.atan2(y-(cardy),x-(cardx+cardw/2))
                local width=35*math.cos(m)
                local height=35*math.sin(m)
                local temp = {cards={card},cardx=cardx+cardw/2,cardy=cardy,x=x,y=y,width=width,height=height}
                cardAnimate["pile"..pile] = temp
                table.remove(cardlitter,#cardlitter)
                break
            elseif list~=false then
                local index = #cardlists[list]
                local newIndex = index+1
                for i,v in ipairs({card}) do
                    v.visible=true
                    cardlists[list][index+i] = v
                end
                addPoints(2)
                playSound("move")
                clickSendCD=0
                local tempx = (5+#cardlitter%3+1) * (cardw+androidInterSpacing) - androidSpacing
                local cardx = tempx - (#cardlitter%3+1)*cardw*0.75 - (100-androidSpacing)
                local cardy = cardh-cardh+cardfontsize+5 + androidOverhead
                local x = tonumber(list) * (cardw+androidInterSpacing) - androidSpacing
                local y = tonumber(newIndex) * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
                if system=="Android" then cardx=cardx+screenw/10 end
                local m = math.atan2(y-(cardy),x-(cardx+cardw/2))
                local width=35*math.cos(m)
                local height=35*math.sin(m)
                local temp = {cards={card},cardx=cardx+cardw/2,cardy=cardy,x=x,y=y,width=width,height=height}
                cardAnimate["list"..list..":"..newIndex] = temp
                table.remove(cardlitter,#cardlitter)
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

function checkNullPiles()
    for i=1,4 do
        if cardpile[i] then
            if #cardpile[i] == 0 then
                table.remove(cardpile,i)
            else
                local localSuit = ""
                for k,v in ipairs(cardpile[i]) do
                    if k==1 then localSuit=v.suit end
                    if v.suit~=localSuit then
                        table.insert(cardstacks,v)
                        table.remove(cardpile[i],k)
                    end
                end
            end
        end
    end
    collectgarbage()
end

function checkIfPileLast(lastlist)
    if string.match(lastlist,"pile") or lastlist=="litter" then return false else return true end
end



