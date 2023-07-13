
ordem = {"K","Q","J",10,9,8,7,6,5,4,3,2,"A"}

cardlists = {}
cardstacks = {}
cardpile = {}
cardonhand = nil
suits = love.graphics.newImage("img/suits.png")
spades = love.graphics.newQuad(0,0,100,119,420,119)
diamonds = love.graphics.newQuad(110,0,90,119,420,119)
clubs = love.graphics.newQuad(220,0,90,119,420,119)
hearts = love.graphics.newQuad(330,0,90,119,420,119)
naipes = {spades=spades,diamonds=diamonds,clubs=clubs,hearts=hearts}
suitSize = 0.45
cardfontsize = 24
cardfont = love.graphics.newFont(cardfontsize)
cardw,cardh = 100,150
cardColor = {love.math.colorFromBytes(255, 240, 214)}


love.graphics.setBackgroundColor(0,0,0)

function love.load()
    --cardlists[#cardlists+1] = {{number="2",suit="diamonds"},{number="A",suit="spades"}}
    --cardlists[#cardlists+1] = {{number="K",suit="clubs"},{number="Q",suit="hearts"}}
    addCardToList(1,"7","spades")
    addCardToList(1,"6","hearts")
    addCardToList(1,"5","clubs")
    addCardToList(1,"4","diamonds")
    addCardToList(1,"3","spades")
    addCardToList(1,"2","hearts")
    addCardToList(1,"A","clubs")   
    addCardToList(2,"7","hearts")
    addCardToList(2,"6","spades")
    addCardToList(2,"5","diamonds")
    addCardToList(2,"4","clubs")
    addCardToList(2,"3","hearts")
    addCardToList(2,"2","spades")
    addCardToList(2,"A","hearts")
    addCardToList(3,"7","hearts")
    addCardToList(3,"6","spades")
    addCardToList(3,"5","diamonds")
    addCardToList(3,"4","clubs")
    addCardToList(3,"3","hearts")
    addCardToList(3,"2","spades")
end

function love.update(dt)
    local mousex,mousey = love.mouse.getPosition()
    if love.mouse.isDown(1)==false then
        if cardonhand==nil then
        else
            local card,list,index = checkCollision(mousex,mousey)
            if card then
                if checkOpposite(card.suit,cardonhand.suit) and checkIfPost(cardonhand.number,card.number) then
                    cardlists[list][index+1]=cardonhand
                    cardonhand=nil
                else
                    local index = #cardlists[cardonhand.lastlist]
                    cardlists[cardonhand.lastlist][index+1]=cardonhand
                    cardonhand=nil
                end
            else
                local index = #cardlists[cardonhand.lastlist]
                cardlists[cardonhand.lastlist][index+1]=cardonhand
                cardonhand=nil
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
                cardlists[list][index]=nil
            end
        else
            local card,list,index = checkCollision(x,y)
            if card then
                if checkOpposite(card.suit,cardonhand.suit) and checkIfPost(cardonhand.number,card.number) then
                    cardlists[list][index+1]=cardonhand
                    cardonhand=nil
                end
            end
        end
    end
 end

function love.draw()
    local mousex, mousey = love.mouse.getPosition()
    for k,v in ipairs(cardlists) do
        local x = k * (cardw+10)
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5)
            drawCard(card.number,card.suit,x,y)
        end
    end
    if cardonhand then        
        drawCard(cardonhand.number,cardonhand.suit,mousex-cardw/2,mousey-cardh/2)
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
    love.graphics.rectangle("line",x,y,cardw,cardh,7)
    love.graphics.setColor(cardColor)
    love.graphics.rectangle("fill",x,y,cardw,cardh,7)    
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
    love.graphics.draw(suits,naipes[suit],x+(cardw/2)-(95*insideSuitSize/2),y+(cardh/2)-(119*(insideSuitSize-0.1)/2),0,insideSuitSize,insideSuitSize-0.1)
    love.graphics.setColor(1,1,1)
end

function addCardToList(listnumber,number,suit)
    local index=0
    if cardlists[listnumber] then
        index = #cardlists[listnumber]
    else
        cardlists[listnumber] = {}
    end
    cardlists[listnumber][index+1] = {number=number,suit=suit}
end

function checkCollision(mx,my)
    for k,v in ipairs(cardlists) do
        local x = k * (cardw+10)
        for i,card in ipairs(v) do
            local y = i * (cardh-cardh+cardfontsize+5)
            if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh and i==#v then
                return card,k,i
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
    if xi>yi then return true else return false end
end

