function drawTime()
    local text = "Tempo: "..save.currentTime
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill",screenw-cardfont:getWidth(text)-10,-5,cardfont:getWidth(text)+15,cardfontsize+7,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(text,cardfont,screenw-cardfont:getWidth(text)-5,0)
end

function drawMoves()
    local text = "Movs: "..save.moves
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill",screenw/2-cardfont:getWidth(text)/2-10,-5,cardfont:getWidth(text)+15,cardfontsize+7,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(text,cardfont,screenw/2-cardfont:getWidth(text)/2-5,0)
end

function drawPoints()
    local text = "Pontos: "..save.points
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill",-5,-5,cardfont:getWidth(text)+7,cardfontsize+7,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(text,cardfont,0,0)
    
end

function drawButtons()
    --love.graphics.setColor(0,0,0,0.5)
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

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, y, screenw, screenh-y)
    love.graphics.setColor(1, 1, 1, 1)

    for i, btn in ipairs(buttons) do
        local x = xStart + (i - 1) * (buttonWidth + totalPadding)
        love.graphics.draw(btn.img, x, y + 10, 0, androidFactor)
    end
end

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

function drawBack(x,y)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line",x,y,cardw,cardh,round)
    love.graphics.setColor(1,1,1)
    GLOBALBACKX, GLOBALBACKY = x,y
    love.graphics.stencil(stencilRounded)
    love.graphics.setStencilTest("greater",0)
    local scaleX,scaleY = cardBack:getDimensions()
    scaleX=cardw/scaleX
    scaleY=cardh/scaleY
    love.graphics.draw(cardBack,x,y,0,scaleX,scaleY)
    love.graphics.setStencilTest()
    love.graphics.setColor(1,1,1)
end

function stencilRounded()
    love.graphics.rectangle("fill",GLOBALBACKX,GLOBALBACKY,cardw,cardh,round)
end

function drawStore()
    --grey the background out
    love.graphics.setColor(0,0,0,0.8)
    love.graphics.rectangle('fill',0,0,screenw,screenh)
    --draw the base rectangle and its border
    local width = screenw-(screenw/8)
    local height = screenh-(screenh/3)
    love.graphics.setLineWidth(7)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",screenw/2-width/2,screenh/2-height/2,width,height,5)
    love.graphics.setColor(love.math.colorFromBytes(24, 135, 54))
    love.graphics.rectangle("fill",screenw/2-width/2,screenh/2-height/2,width,height,5)
    love.graphics.setLineWidth(oldThick)
    if storeState==1 then
        local y = screenh/2-height/2 + height/25
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
            storeDrawCard("K","spades",x,y,v)
            love.graphics.setLineWidth(4)
            love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
            love.graphics.rectangle("line",x,y+cardh+2,cardw,cardfontsize+6,round)
            love.graphics.setColor(0, 0.239, 0.063)
            love.graphics.rectangle("fill",x,y+cardh+2,cardw,cardfontsize+6,round)
            love.graphics.setColor(1,1,1,1)
            love.graphics.setLineWidth(oldThick)
            if v.bought==false then
                love.graphics.printf(tostring(v.price),cardfont,x,y+cardh+3,cardw,"center")
            else
                love.graphics.printf(";D",cardfont,x,y+cardh+3,cardw,"center")
            end
        end
    elseif storeState==2 then
        local y = screenh/2-height/2 + height/25
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
            storeDrawBack(x,y,v.img)
            love.graphics.setLineWidth(4)
            love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
            love.graphics.rectangle("line",x,y+cardh+2,cardw,cardfontsize+6,round)
            love.graphics.setColor(0, 0.239, 0.063)
            love.graphics.rectangle("fill",x,y+cardh+2,cardw,cardfontsize+6,round)
            love.graphics.setColor(1,1,1,1)
            love.graphics.setLineWidth(oldThick)
            if v.bought==false then
                love.graphics.printf(tostring(v.price),cardfont,x,y+cardh+3,cardw,"center")
            else
                love.graphics.printf(";D",cardfont,x,y+cardh+3,cardw,"center")
            end
        end
    elseif storeState==3 then
        local y = screenh/2-height/2 + height/25
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
            storeDrawBack(x,y,v.img)
            love.graphics.setLineWidth(4)
            love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
            love.graphics.rectangle("line",x,y+cardh+2,cardw,cardfontsize+6,round)
            love.graphics.setColor(0, 0.239, 0.063)
            love.graphics.rectangle("fill",x,y+cardh+2,cardw,cardfontsize+6,round)
            love.graphics.setColor(1,1,1,1)
            love.graphics.setLineWidth(oldThick)
            if v.bought==false then
                love.graphics.printf(tostring(v.price),cardfont,x,y+cardh+3,cardw,"center")
            else
                love.graphics.printf(";D",cardfont,x,y+cardh+3,cardw,"center")
            end
        end
    end
    
    --Dock render
    love.graphics.setColor(0,0,0,0.8)
    local imgw, imgh = coinImg:getDimensions()
    local scale = (height/8-10)/imgh
    local dockw,dockh = cardfont:getWidth(tostring(save.coins))+(imgw*scale)+15,height/8
    local dockx,docky = screenw/2-width/2+15, screenh/2-height/2+height-dockh-15
    love.graphics.rectangle("fill",dockx,docky,dockw,dockh,10)
    love.graphics.setColor(0.7,0.7,0.2,1)
    love.graphics.draw(coinImg, dockx+5, docky+5, 0, scale)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(tostring(save.coins),cardfont,dockx+(coinImg:getWidth()*scale)+5,docky+(math.abs(cardfontsize-dockh))/2)

    --Buttons
    for i=1,3 do
        local nw = cardfont:getWidth(storeButtons[1])+15
        local nh = cardfontsize+10
        local x = screenw/2+width/2-nw-5
        local y = screenh/2-height/2+height-dockh-(nh+5)*(i-1)
        if i==storeState then
            love.graphics.setLineWidth(6)
            love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
            love.graphics.rectangle("line",x,y,nw,nh,5)
        end
        love.graphics.setColor(0, 0.239, 0.063)
        love.graphics.rectangle("fill",x,y,nw,nh,5)
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf(storeButtons[i],cardfont,x,y+(math.abs(nh-cardfontsize)/2),nw,"center")
    end

    --pages
    local nw = cardfont:getWidth("<")+15
    local nh = cardfontsize+10
    local x = screenw/2-nw-5
    local y = screenh/2-height/2+height-dockh
    love.graphics.setLineWidth(6)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",x,y,nw,nh,5)
    love.graphics.setColor(0, 0.239, 0.063)
    love.graphics.rectangle("fill",x,y,nw,nh,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("<",cardfont,x,y+(math.abs(nh-cardfontsize)/2),nw,"center")
    x = x+nw+5
    nw = cardfont:getWidth(storePage.."/"..storePages)+15
    love.graphics.printf(storePage.."/"..storePages,cardfont,x,y+(math.abs(nh-cardfontsize)/2),nw,"center")
    x = x+nw+5
    nw = cardfont:getWidth(">")+15
    love.graphics.setLineWidth(6)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",x,y,nw,nh,5)
    love.graphics.setColor(0, 0.239, 0.063)
    love.graphics.rectangle("fill",x,y,nw,nh,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(">",cardfont,x,y+(math.abs(nh-cardfontsize)/2),nw,"center")


    love.graphics.setLineWidth(oldThick)
end

function drawStorePrompt()
    --grey the background out
    love.graphics.setColor(0,0,0,0.3)
    love.graphics.rectangle('fill',0,0,screenw,screenh)
    --draw the base rectangle and its border
    local cellFactor = 2
    if system=="Android" then cellFactor=1.60 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    love.graphics.setLineWidth(7)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",screenw/2-width/2,screenh/2-height/2,width,height,5)
    love.graphics.setColor(love.math.colorFromBytes(24, 135, 54))
    love.graphics.rectangle("fill",screenw/2-width/2,screenh/2-height/2,width,height,5)

    love.graphics.setLineWidth(oldThick)
    if storeState==1 then
        local naipesDraw = {"spades","hearts","clubs","diamonds"}
        for k,v in ipairs(naipesDraw) do
            local spacing = ((width-cardw*4))/4
            local otherSpacing = ((screenw/2-width/2+(4)*(cardw+spacing))-width)/4
            --if k>1 then otherSpacing=0 end
            local x = screenw/2-width/2+(k-1)*(cardw+spacing) + otherSpacing
            local y = screenh/2-height/2 + height/10
            storeDrawCard("A",v,x,y,inStorePrompt)
        end
    elseif storeState==2 then
        local x = screenw/2-cardw/2
        local y = screenh/2-height/2 + height/10
        storeDrawBack(x,y,inStorePrompt.img)
    elseif storeState==3 then
        local x = screenw/2-cardw/2
        local y = screenh/2-height/2 + height/10
        storeDrawBack(x,y,inStorePrompt.img)
    end

    local text = "Comprar"
    if save.coins<inStorePrompt.price then text="Sem dinheiro" end
    local nw = cardfont:getWidth(text)+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    love.graphics.setLineWidth(5)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",x,y,nw,nh,5)
    love.graphics.setColor(0, 0.239, 0.063)
    love.graphics.rectangle("fill",x,y,nw,nh,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(text,cardfont,x,y+(nh-cardfontsize)/2,nw,"center")


    local newColor = {inStorePrompt.color[1],inStorePrompt.color[2],inStorePrompt.color[3]}
    y=y-nh*1.5
    nw=inStorePrompt.font:getWidth(inStorePrompt.name)+30
    x = screenw/2-nw/2
    love.graphics.setLineWidth(5)
    love.graphics.setColor(inStorePrompt.textcolor)
    love.graphics.rectangle("line",x,y,nw,nh,5)
    love.graphics.setColor(newColor)
    love.graphics.rectangle("fill",x,y,nw,nh,5)
    love.graphics.setColor(inStorePrompt.textcolor)
    love.graphics.printf(inStorePrompt.name,inStorePrompt.font,x,y+(nh-cardfontsize)/2,nw,"center")
    love.graphics.setLineWidth(oldThick)
end

function drawAllVisible()
    local androidFactor = 0.25
    if system=="Android" then androidFactor=0.15 end    
    local buttonHeight = 256*androidFactor -- Altura dos botões (ajuste conforme necessário)
    local text = "Ganhar"
    local nw = cardfont:getWidth(text)+45
    local nh = cardfont:getHeight()+15
    local x = screenw/2-nw/2
    local y = screenh-nh-buttonHeight-20-15
    love.graphics.setLineWidth(5)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",x,y,nw,nh,5)
    love.graphics.setColor(0, 0.239, 0.063)
    love.graphics.rectangle("fill",x,y,nw,nh,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(text,cardfont,x,y+(nh-cardfontsize)/2,nw,"center")
    love.graphics.setLineWidth(oldThick)
end

function drawVictory()
    --grey the background out
    love.graphics.setColor(0,0,0,0.3)
    love.graphics.rectangle('fill',0,0,screenw,screenh)
    --draw the base rectangle and its border
    local cellFactor = 2.60
    if system=="Android" then cellFactor=2 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    love.graphics.setLineWidth(7)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",screenw/2-width/2,screenh/2-height/2,width,height,5)
    love.graphics.setColor(love.math.colorFromBytes(24, 135, 54))
    love.graphics.rectangle("fill",screenw/2-width/2,screenh/2-height/2,width,height,5)

    --some of the calculus
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

    --victory label
    local x = screenw/2-width/2
    local y = screenh/2-height/2+15
    local ySpacing = 12
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Vitória!",cardfont,x,y,width,"center")
    y=y+cardfontsize+ySpacing
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("fill",x+10,y,width-20,5,5)
    y=y+ySpacing
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Tempo",cardfont,x+10,y,width,"left")
    local sec=tostring(currentSecs)
    if tonumber(sec)<10 then sec="0"..sec end
    local text = currentMins..":"..sec
    if timeBonus>0 then text = "+"..timeBonus.." "..text end
    if timeBonus<0 then text = timeBonus.." "..text end
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("fill",x+10,y,width-20,5,5)
    y=y+ySpacing
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Movimentos",cardfont,x+10,y,width,"left")
    local text = save.moves
    if movBonus>0 then text = "+"..movBonus.." "..text end
    if movBonus<0 then text = movBonus.." "..text end
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("fill",x+10,y,width-20,5,5)
    y=y+ySpacing
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Pontos",cardfont,x+10,y,width,"left")
    local text = save.points
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("fill",x+10,y,width-20,5,5)
    y=y+ySpacing
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Moedas",cardfont,x+10,y,width,"left")
    local text = "+"..victoryCoins
    love.graphics.printf(text,cardfont,x,y,width-10,"right")

    --botão de jogar denovo
    local nw = cardfont:getWidth("Jogar denovo")+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    love.graphics.setLineWidth(5)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",x,y,nw,nh,5)
    love.graphics.setColor(0, 0.239, 0.063)
    love.graphics.rectangle("fill",x,y,nw,nh,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("Jogar denovo",cardfont,x,y+(nh-cardfontsize)/2,nw,"center")
    love.graphics.setLineWidth(oldThick)
end

function drawStats()
    --grey the background out
    love.graphics.setColor(0,0,0,0.3)
    love.graphics.rectangle('fill',0,0,screenw,screenh)
    --draw the base rectangle and its border
    local cellFactor = 3
    if system=="Android" then cellFactor=2 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    love.graphics.setLineWidth(7)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",screenw/2-width/2,screenh/2-height/2,width,height,5)
    love.graphics.setColor(love.math.colorFromBytes(24, 135, 54))
    love.graphics.rectangle("fill",screenw/2-width/2,screenh/2-height/2,width,height,5)

    --victory label
    local x = screenw/2-width/2
    local y = screenh/2-height/2+15
    local ySpacing = 12
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Estatísticas",cardfont,x,y,width,"center")
    y=y+cardfontsize+ySpacing
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("fill",x+10,y,width-20,5,5)
    y=y+ySpacing
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Menor tempo",cardfont,x+10,y,width,"left")
    local text = save.lowTime
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.printf("Maior tempo",cardfont,x+10,y,width,"left")
    local text = save.highTime
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.printf("Tempo total",cardfont,x+10,y,width,"left")
    local text = save.totalTime
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("fill",x+10,y,width-20,5,5)
    love.graphics.setColor(1,1,1)
    y=y+ySpacing
    love.graphics.printf("Partidas jogadas",cardfont,x+10,y,width,"left")
    local text = save.totalGames
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.printf("Partidas ganhas",cardfont,x+10,y,width,"left")
    local text = save.totalWins
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.printf("Partidas perdidas",cardfont,x+10,y,width,"left")
    local text = save.totalLoss
    love.graphics.printf(text,cardfont,x,y,width-10,"right")
    y=y+cardfontsize+ySpacing
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("fill",x+10,y,width-20,5,5)
    love.graphics.setColor(1,1,1)
    y=y+ySpacing
    love.graphics.printf("Maior pontuação",cardfont,x+10,y,width,"left")
    local text = save.highScore
    love.graphics.printf(text,cardfont,x,y,width-10,"right")

    --botão de jogar denovo
    local nw = cardfont:getWidth("Voltar")+30
    local nh = cardfont:getHeight()+10
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    love.graphics.setLineWidth(5)
    love.graphics.setColor(love.math.colorFromBytes(237, 234, 28))
    love.graphics.rectangle("line",x,y,nw,nh,5)
    love.graphics.setColor(0, 0.239, 0.063)
    love.graphics.rectangle("fill",x,y,nw,nh,5)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("Voltar",cardfont,x,y+5,nw,"center")
    love.graphics.setLineWidth(oldThick)
end
--Same as drawCard but it also takes a cardStyle input
function storeDrawCard(number,suit,x,y,cardStyle)
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
        y=y-5
    end
    love.graphics.draw(suits,naipes[suit],x+(cardw/2)-(95*insideSuitSize/2),y+(cardh/2)-(119*(insideSuitSize-0.1)/2),0,insideSuitSize,insideSuitSize-androidSmall)
    love.graphics.setColor(1,1,1)
end

--Same as drawBack but it also takes an image as a back image
function storeDrawBack(x,y,img)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line",x,y,cardw,cardh,round)
    love.graphics.setColor(1,1,1)
    GLOBALBACKX, GLOBALBACKY = x,y
    love.graphics.stencil(stencilRounded)
    love.graphics.setStencilTest("greater",0)
    local scaleX,scaleY = img:getDimensions()
    scaleX=cardw/scaleX
    scaleY=cardh/scaleY
    love.graphics.draw(img,x,y,0,scaleX,scaleY)
    love.graphics.setStencilTest()
    love.graphics.setColor(1,1,1)
end