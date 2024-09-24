ordem = {"K","Q","J",10,9,8,7,6,5,4,3,2,"A"}
cnaipes = {"spades","diamonds","clubs","hearts"}

suits = love.graphics.newImage("img/naipes.png")
spades = love.graphics.newQuad(0,0,100,119,420,119)
diamonds = love.graphics.newQuad(110,0,90,119,420,119)
clubs = love.graphics.newQuad(220,0,90,119,420,119)
hearts = love.graphics.newQuad(330,0,90,119,420,119)
naipes = {spades=spades,diamonds=diamonds,clubs=clubs,hearts=hearts}

suitSize = 0.45
cardfontsize = 32
cardfont = love.graphics.newFont(cardfontsize)
cardw,cardh = 100,150

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

function drawCard(number,suit,x,y)
    local colortext = cardStyle.textcolor
    local colorsuit = cardStyle.suitcolor

    if suit=="diamonds" or suit=="hearts" then
        colortext=cardStyle.casered
        colorsuit=cardStyle.casered
    end
    
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line",x,y,cardw,cardh,round)
    love.graphics.setColor(cardStyle.color)
    love.graphics.rectangle("fill",x,y,cardw,cardh,round)
    
    if cardStyle.backImg then
        local imgw, imgh = cardStyle.backImg:getDimensions()
        local scaleX = cardw/imgw
        local scaleY = cardh/imgh
        love.graphics.draw(cardStyle.backImg,x,y,0,scaleX,scaleY)
    end

    love.graphics.setColor(colortext)
    love.graphics.print(tostring(number),cardStyle.font,x+cardfontsize/10,y-cardfontsize/6)
    love.graphics.printf(tostring(number),cardStyle.font,x,y+cardh-cardfontsize-3,cardw-2,"right")
    love.graphics.setColor(colorsuit)

    local smallSuitSize = suitSize-(suitSize*0.6)
    if system=="Android" then smallSuitSize=smallSuitSize+0.05 end
    local offset = 95*smallSuitSize
    local lineheight = cardfontsize
    love.graphics.draw(suits,naipes[suit],x+cardw-offset-(cardw*smallSuitSize/10),y+((119*smallSuitSize)/2)-lineheight/2+lineheight/4,0,smallSuitSize,smallSuitSize-(smallSuitSize*0.2))

    local insideSuitSize = suitSize
    if suit=="spades" and number=="A" then
        insideSuitSize=insideSuitSize+0.20
        if system=="Android" then insideSuitSize=insideSuitSize-0.15 end
        y=y-5
    end

    love.graphics.draw(suits,naipes[suit],x+(cardw/2)-(95*insideSuitSize/2),y+(cardh/2)-(119*(insideSuitSize-0.1)/2),0,insideSuitSize,insideSuitSize-androidSmall)
    love.graphics.setColor(1,1,1)
end

--Same as drawCard but it also takes a cardStyle input
function drawCardStyle(number,suit,x,y,insideCardStyle,index)
    if insideCardStyle==nil then return nil end
    local colortext = insideCardStyle.textcolor
    local colorsuit = insideCardStyle.suitcolor
    if suit=="diamonds" or suit=="hearts" then
        colortext=insideCardStyle.casered
        colorsuit=insideCardStyle.casered
    end
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line",x,y,cardw,cardh,round)
    love.graphics.setColor(insideCardStyle.color)
    love.graphics.rectangle("fill",x,y,cardw,cardh,round)
    if insideCardStyle.backImg then
        local imgw, imgh = insideCardStyle.backImg:getDimensions()
        local scaleX = cardw/imgw
        local scaleY = cardh/imgh
        love.graphics.draw(insideCardStyle.backImg,x,y,0,scaleX,scaleY)
    end
    love.graphics.setColor(colortext)
    love.graphics.print(tostring(number),insideCardStyle.font,x+cardfontsize/10,y-cardfontsize/6)
    love.graphics.printf(tostring(number),insideCardStyle.font,x,y+cardh-cardfontsize-3,cardw-2,"right")
    love.graphics.setColor(colorsuit)

    local smallSuitSize = suitSize-(suitSize*0.6)
    if system=="Android" then smallSuitSize=smallSuitSize+0.05 end
    local offset = 95*smallSuitSize
    local lineheight = cardfontsize
    love.graphics.draw(suits,naipes[suit],x+cardw-offset-(cardw*smallSuitSize/10),y+((119*smallSuitSize)/2)-lineheight/2+lineheight/4,0,smallSuitSize,smallSuitSize-(smallSuitSize*0.2))

    local insideSuitSize = suitSize
    if suit=="spades" and number=="A" then
        insideSuitSize=insideSuitSize+0.20
        y=y-5
    end
    love.graphics.draw(suits,naipes[suit],x+(cardw/2)-(95*insideSuitSize/2),y+(cardh/2)-(119*(insideSuitSize-0.1)/2),0,insideSuitSize,insideSuitSize-androidSmall)
    love.graphics.setColor(1,1,1)
end

-- Helper function to get all the possible cards in a deck
function allCards()
    local obj = {}
    for i=1,#cnaipes do
        for j=1,#ordem do
            obj[#obj+1] = {number=ordem[#ordem-j+1],suit=cnaipes[i]}
        end
    end
    return obj
end

-- Collision detector for a card,
-- returns {collides: true|false, offsetx: number, offsety: number}
function checkCollisionCard(x,y,mx,my,mw,mh)
    mw = mw or 0
    mh = mh or 0
    if mx+mw >= x and mx <= x+cardw and my+mh >= y and my <= y+cardh then
        return {collides=true,offsetx=mx-x,offsety=my-y}
    end
    return {collides=false}
end

-- Returns true if the suits are equal
function checkEqualSuits(suitx,suity)
    return (suitx==suity)
end