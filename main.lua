
ordem = {"K","Q","J",10,9,8,7,6,5,4,3,2,"A"}
cnaipes = {"spades","diamonds","clubs","hearts"}

cardlists = {}
cardstacks = {}
cardpile = {}
cardlitter = {}
cardonhand = nil
suits = love.graphics.newImage("img/suits.png")
spades = love.graphics.newQuad(0,0,100,119,420,119)
diamonds = love.graphics.newQuad(110,0,90,119,420,119)
clubs = love.graphics.newQuad(220,0,90,119,420,119)
hearts = love.graphics.newQuad(330,0,90,119,420,119)
naipes = {spades=spades,diamonds=diamonds,clubs=clubs,hearts=hearts}
suitSize = 0.45
cardfontsize = 24
round = 7
cardfont = love.graphics.newFont(cardfontsize)
cardw,cardh = 100,150
cardColor = {1,1,1}
androidSpacing = 100
androidInterSpacing = 10
androidSmall = 0.1

system = love.system.getOS()

love.graphics.setBackgroundColor(0.2,0.05,0.2)

love.math.setRandomSeed(os.time())
random = love.math.random

function love.load()
    --cardlists[#cardlists+1] = {{number="2",suit="diamonds"},{number="A",suit="spades"}}
    --cardlists[#cardlists+1] = {{number="K",suit="clubs"},{number="Q",suit="hearts"}}
    if system~="Android" then
        love.window.setMode(800,600)
    else
        suitSize=suitSize/1.8
        cardw=cardw/2
        cardh=cardh/2
        round = 3
        androidSpacing=50
        androidSmall=0.03
        androidInterSpacing=5
        cardfontsize=cardfontsize/2
        cardfont=love.graphics.newFont(cardfontsize)
    end
    startGame()
end

function love.update(dt)
    local mousex,mousey = love.mouse.getPosition()
    --print(checkPile(mousex,mousey))
    if love.mouse.isDown(1)==false then
        if cardonhand==nil then
        else
            local pile = checkPile(mousex,mousey)
            local baselist = checkForList(mousex,mousey)
            local fconhand = cardonhand[1][1]
            local nconhand = #cardonhand            
            local card,list,index = checkCollisionTwo(mousex,mousey)
            
            if card then          
                if checkOpposite(card.suit,cardonhand[1].suit) and checkIfPost(cardonhand[1].number,card.number) then                    
                    for i,v in ipairs(cardonhand) do
                        v.visible=true
                        cardlists[list][index+i] = v
                    end
                    if cardonhand.lastlist~="litter" then                        
                        if #cardlists[cardonhand.lastlist]>0 then                            
                            cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible = true
                        end
                    end
                    cardonhand=nil
                else
                    if cardonhand.lastlist=="litter" then
                        cardlitter[#cardlitter+1]=cardonhand[1]
                        cardonhand=nil
                    else
                        local index = #cardlists[cardonhand.lastlist]
                        for i,v in ipairs(cardonhand) do
                            cardlists[cardonhand.lastlist][index+i] = v
                        end
                        cardonhand=nil
                    end                    
                end
            elseif pile then
                if cardpile[pile] then
                    local lastCardPile = cardpile[pile][#cardpile[pile]]
                    if cardonhand[1].suit==lastCardPile.suit and checkIfPost(lastCardPile.number,cardonhand[1].number) then
                        cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
                        if cardonhand.lastlist~="litter" then
                            if #cardlists[cardonhand.lastlist]>0 then
                                cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible = true
                            end
                        end
                        cardonhand=nil
                    else
                        if cardonhand.lastlist=="litter" then
                            cardlitter[#cardlitter+1]=cardonhand[1]
                            cardonhand=nil
                        else
                            local index = #cardlists[cardonhand.lastlist]
                            for i,v in ipairs(cardonhand) do
                                cardlists[cardonhand.lastlist][index+i] = v
                            end
                            cardonhand=nil
                        end 
                    end
                else
                    cardpile[pile] = {}
                    if cardonhand[1].number=="A" then
                        cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
                        if cardonhand.lastlist~="litter" then
                            if #cardlists[cardonhand.lastlist]>0 then
                                cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible = true
                            end
                        end
                        cardonhand=nil
                    end
                end
            elseif baselist then
                if cardonhand[1].number=="K" then
                    for i,v in ipairs(cardonhand) do                        
                        addCardToList(baselist,v.number,v.suit,true)
                    end
                    if cardonhand.lastlist~="litter" then                        
                        if #cardlists[cardonhand.lastlist]>0 then                            
                            cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible = true
                        end
                    end
                    cardonhand=nil
                end
            else
                if cardonhand.lastlist=="litter" then
                    cardlitter[#cardlitter+1]=cardonhand[1]
                    cardonhand=nil
                else
                    local index = #cardlists[cardonhand.lastlist]
                    for i,v in ipairs(cardonhand) do
                        cardlists[cardonhand.lastlist][index+i] = v
                    end
                    cardonhand=nil
                end 
            end
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
        if cardonhand==nil then
            local card,list,index = checkCollision(x,y)
            if card then
                cardonhand=card
                cardonhand.lastlist=list
                for i=index,index+#card-1 do
                    cardlists[list][i]=nil
                end
            else
                if checkStack(x,y) then
                    if #cardstacks>0 then
                        local card = cardstacks[#cardstacks]
                        cardlitter[#cardlitter+1] = card
                        table.remove(cardstacks,#cardstacks)
                    else
                        cardstacks = cardlitter
                        cardlitter = {}
                    end
                else
                    local card = checkLitter(x,y)
                    if card then
                        cardonhand=card
                        cardonhand.lastlist="litter"
                        table.remove(cardlitter,#cardlitter)
                    end
                end
            end
            local button = checkForButtons(x,y)
            if button then
                
        end
    end
 end

function love.draw()
    local mousex, mousey = love.mouse.getPosition()
    for i=1,7 do -- drawing the bottom of the lists
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = (cardh-cardh+cardfontsize+5) + (cardh + 40)
        love.graphics.setColor(1,1,1,0.3)
        love.graphics.rectangle("fill",x,y,cardw,cardh,7)
        love.graphics.setColor(1,1,1,1)
    end
    for i=1,4 do --drawing the bottom of the piles
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = cardh-cardh+cardfontsize+5
        love.graphics.setColor(1,1,1,0.3)
        love.graphics.rectangle("fill",x,y,cardw,cardh,7)
        love.graphics.setColor(1,1,1,1)
    end
    
    --drawing the bottom of the stack
    love.graphics.setColor(1,1,1,0.3)
    love.graphics.rectangle("fill",7*(cardw+10)-100,cardh-cardh+cardfontsize+5,cardw,cardh,7)
    love.graphics.setColor(1,1,1,1)

    for k,v in ipairs(cardlists) do
        local x = k * (cardw+androidInterSpacing) - androidSpacing
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5) + (cardh + 40)
            if card.visible then 
                drawCard(card.number,card.suit,x,y)
            else
                drawBack(x,y)
            end
        end
    end

    for i=1,4 do
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = cardh-cardh+cardfontsize+5
        if cardpile[i] then
            local card = cardpile[i][#cardpile[i]]
            drawCard(card.number,card.suit,x,y)
        end
    end
    local max=#cardlitter
    if max>3 then max=3 end    
    for i=1,max do
        local tempx = (5+i) * (cardw+androidInterSpacing) - androidSpacing
        local x = tempx - i*cardw*0.75 - (100-androidSpacing)
        local y = cardh-cardh+cardfontsize+5
        if cardlitter[#cardlitter-max+i] then
            local card = cardlitter[#cardlitter-max+i]
            drawCard(card.number,card.suit,x,y)
        end
    end    
    if #cardstacks>0 then
        drawBack(7*(cardw+10)-100,cardh-cardh+cardfontsize+5)
    end
    if cardonhand then
        for i,v in ipairs(cardonhand) do
            local x = mousex-cardw/2
            local y = mousey-cardh/2 + i * (cardh-cardh+cardfontsize+5)
            drawCard(v.number,v.suit,x,y)
        end
    end
end

function drawCard(number,suit,x,y)
    local colortext = {0,0,0}
    local colorsuit = {1,1,1}
    if suit=="diamonds" or suit=="hearts" then
        colortext={0.6,0,0}
        colorsuit={1,0,0}
    end
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line",x,y,cardw,cardh,round)
    love.graphics.setColor(cardColor)
    love.graphics.rectangle("fill",x,y,cardw,cardh,round)    
    love.graphics.setColor(colortext)
    love.graphics.print(tostring(number),cardfont,x+2,y)
    love.graphics.printf(tostring(number),cardfont,x,y+cardh-cardfontsize-3,cardw-2,"right")
    love.graphics.setColor(colorsuit)

    local smallSuitSize = suitSize-(suitSize*0.6)
    local offset = cardfont:getWidth(number)
    local lineheight = cardfontsize
    love.graphics.draw(suits,naipes[suit],x+2+offset+2,y+((119*smallSuitSize)/2)-lineheight/2+lineheight/6,0,smallSuitSize,smallSuitSize-(smallSuitSize*0.2))

    local insideSuitSize = suitSize
    if suit=="spades" and number=="A" then
        insideSuitSize=insideSuitSize+0.20
        y=y-5
    end
    love.graphics.draw(suits,naipes[suit],x+(cardw/2)-(95*insideSuitSize/2),y+(cardh/2)-(119*(insideSuitSize-0.1)/2),0,insideSuitSize,insideSuitSize-androidSmall)
    love.graphics.setColor(1,1,1)
end

function drawBack(x,y)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line",x,y,cardw,cardh,round)
    love.graphics.setColor(love.math.colorFromBytes(204, 204, 255))
    love.graphics.rectangle("fill",x,y,cardw,cardh,round)
    love.graphics.setColor(1,1,1)
end

function addCardToList(listnumber,number,suit,visible)
    local index=0
    if cardlists[listnumber] then
        index = #cardlists[listnumber]
    else
        cardlists[listnumber] = {}
    end
    cardlists[listnumber][index+1] = {number=number,suit=suit,visible=visible}
end

function checkCollision(mx,my)
    for k,v in ipairs(cardlists) do
        local x = k * (cardw+androidInterSpacing) - androidSpacing
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5) + (cardh + 40)
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

function checkCollisionTwo(mx,my)
    for k,v in ipairs(cardlists) do
        local x = k * (cardw+androidInterSpacing) - androidSpacing
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5) + (cardh + 40)
            if i==#v then
                if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then
                    return card,k,i
                end
            end
        end
    end
    return nil
end

function checkForList(mx,my)
    for i=1,7 do
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = (cardh-cardh+cardfontsize+5) + (cardh + 40)
        if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then
            return i
        end
    end
end

function checkPile(mx,my)
    for i=1,4 do --drawing the bottom of the piles
        local x = i * (cardw+androidInterSpacing) - androidSpacing
        local y = cardh-cardh+cardfontsize+5
        if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then            
            return i
        end
    end
    return nil
end

function checkStack(mx,my)
    local x = 7*(cardw+10)-100
    local y = cardh-cardh+cardfontsize+5
    if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then            
        return true
    end
    return false
end

function checkLitter(mx,my)
    local max=#cardlitter
    if max>3 then max=3 end    
    for i=1,max do
        local tempx = (5+i) * (cardw+androidInterSpacing) - androidSpacing
        local x = tempx - i*cardw*0.75 - (100-androidSpacing)
        local y = cardh-cardh+cardfontsize+5
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

function checkOpposite(suitx,suity)
    local xcolor = 0
    local ycolor = 0
    if suitx=="clubs" or suitx=="spades" then xcolor=1 else xcolor=2 end
    if suity=="clubs" or suity=="spades" then ycolor=1 else ycolor=2 end
    if xcolor~=ycolor then return true else return false end
end

function checkIfPost(xnumber,ynumber)
    local xi,yi=0,0
    for i,v in ipairs(ordem) do
        if v==xnumber then xi=i end
        if v==ynumber then yi=i end
    end
    if xi>yi and xi<yi+2 then return true else return false end
end

function startGame()
    leftToAdd = allCards()
    for column=1,7 do
        for row=1,column do
            local cardID = random(1,#leftToAdd)
            local card = leftToAdd[cardID]
            local isVisible = false
            if row==column then isVisible=true end
            addCardToList(column,card.number,card.suit,isVisible)
            table.remove(leftToAdd,cardID)
        end
    end
    for i=1,#leftToAdd do
        local cardID = random(1,#leftToAdd)
        local card = leftToAdd[cardID]
        cardstacks[#cardstacks+1] = card
        table.remove(leftToAdd,cardID)
    end
end

function allCards()
    local obj = {}
    for i=1,#ordem do
        for j=1,#cnaipes do
            obj[#obj+1] = {number=ordem[i],suit=cnaipes[j]}
        end
    end
    return obj
end

