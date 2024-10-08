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

    --settings button
    local x = 15
    y = y - buttonHeight-20
    local nw,nh = settingsImg:getDimensions()
    nw,nh=nw*androidFactor,nh*androidFactor
    love.graphics.setColor(0,0,0,0.35)
    love.graphics.rectangle("fill",-100,y+5,nw+100+10+15,nh+10,nw/2)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(settingsImg,x,y+10,0,androidFactor)
    love.graphics.setColor(1,1,1,1)
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
    --draw the base rectangle and its border
    local cellFactor = 4
    if system=="Android" then cellFactor=3.5 end
    local androidTax = 0
    if system=="Android" then androidTax=10+30+10 end
    local width = screenw-(screenw/8)
    local height = screenh-(screenh/cellFactor)
    drawPanel(width,height)
    local ySpacing = cardfontsize+5
    local y = screenh/2-height/2 + height/25+ySpacing+androidTax
    if system=="Android" then drawHeader("Loja",screenw/2-width/2,screenh/2-height/2,width,"left",15) end
    if storeState==1 then
        storeDraw(storeItems,y,width,height)
    elseif storeState==2 then
        storeDraw(storeCB,y,width,height)
    elseif storeState==3 then
        storeDraw(storeBacks,y,width,height)
    end

    --Dock render
    local imgw, imgh = coinImg:getDimensions()
    local scale = (height/8-10)/imgh
    local dockw,dockh = cardfont:getWidth(tostring(save.coins))+(imgw*scale)+15,height/8
    local dockx,docky = screenw/2-width/2+15, screenh/2-height/2+height-dockh-15
    love.graphics.setColor(uistyle.btnshading)
    love.graphics.rectangle("fill",dockx+5,docky+5,dockw,dockh)
    love.graphics.setColor(uistyle.btncolor)
    love.graphics.rectangle("fill",dockx,docky,dockw,dockh)
    love.graphics.setColor(0.7,0.7,0.2,1)
    love.graphics.draw(coinImg, dockx+5, docky+5, 0, scale)
    love.graphics.setColor(uistyle.textcolor)
    love.graphics.print(tostring(save.coins),cardfont,dockx+(coinImg:getWidth()*scale)+5,docky+(math.abs(cardfontsize-dockh))/2)

    --Buttons
    local nw = cardfont:getWidth(storeButtons[1])+15
    local totalWidth = nw*3
    local spacing = (screenw-totalWidth)/4
    local y = screenh/2-height/2+5+androidTax
    local nh = cardfontsize+10
    for i=1,3 do
        local x = (i-1)*(nw+spacing)+spacing
        local color = {
            active=uistyle.btnactive,
            btn=uistyle.btncolor,
            shading=uistyle.btnshading,
            text=uistyle.textcolor
        }
        if i==storeState then
            color.btn=color.active
        end
        btn(storeButtons[i],cardfont,x,y,nw,nh,color,function ()
            local whatButton = i
            storeState=whatButton
            storePage=1
            if storeState==1 then
                storePages=math.ceil(#storeItems/(storeMax*storeRows))
            elseif storeState==2 then
                storePages=math.ceil(#storeCB/(storeMax*storeRows))
            elseif storeState==3 then
                storePages=math.ceil(#storeBacks/(storeMax*storeRows))
            end
            return true
        end)
    end

    --pages
    local nw = cardfont:getWidth(">")+15
    local nh = cardfontsize+10
    local x = screenw/2+width/2-nw-15
    local y = screenh/2-height/2+height-dockh
    drawButton(">",x,y,nw,nh,function ()
        storePage=math.min(storePage+1,storePages)
        return true
    end)
    nw = cardfont:getWidth(storePage.."/"..storePages)+15
    x = x-nw-5
    love.graphics.printf(storePage.."/"..storePages,cardfont,x,y+(math.abs(nh-cardfontsize)/2),nw,"center")
    nw = cardfont:getWidth("<")+15
    x = x-nw-5
    drawButton("<",x,y,nw,nh, function ()
        storePage=math.max(storePage-1,1)
        return true
    end)

    drawExitButton(width,height,function ()
        inStore=false
        return true
    end)

    love.graphics.setLineWidth(oldThick)
end

function drawStorePrompt()
   
    if inStorePrompt==nil then return nil end
    --draw the base rectangle and its border
    local cellFactor = 2.3
    if system=="Android" then cellFactor=1.60 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    drawPanel(width,height)
    
    if storeState==1 then
        local naipesDraw = {"spades","hearts","clubs","diamonds"}
        for k,v in ipairs(naipesDraw) do
            local spacing = ((width-cardw*4))/4
            local otherSpacing = ((screenw/2-width/2+(4)*(cardw+spacing))-width)/4
            --if k>1 then otherSpacing=0 end
            local x = screenw/2-width/2+(k-1)*(cardw+spacing) + otherSpacing
            local y = screenh/2-height/2 +10*2+30
            drawCardStyle("A",v,x,y,inStorePrompt)
        end
    else
        local x = screenw/2-cardw/2
        local y = screenh/2-height/2+30+10*2
        storeDrawBack(x,y,inStorePrompt.img)
    end

    local nw = cardfont:getWidth(text)+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15

    local newColor = {inStorePrompt.color[1],inStorePrompt.color[2],inStorePrompt.color[3]}
    local color = {
        active = {newColor[1]+0.130,newColor[2]+0.130,newColor[3]+0.130},
        btn = newColor,
        shading = {newColor[1]-0.130,newColor[2]-0.130,newColor[3]-0.130},
        text = inStorePrompt.textcolor
    }
    y=y-nh*1.5
    nw=inStorePrompt.font:getWidth(inStorePrompt.name)+30
    x = screenw/2-nw/2
    btn(inStorePrompt.name,inStorePrompt.font,x,y,nw,nh,color)

    local text = "Comprar"
    if save.coins<inStorePrompt.price then text="Sem dinheiro" end
    local nw = cardfont:getWidth(text)+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    drawButton(text,x,y,nw,nh, function ()
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
        return true
    end)

    drawExitButton(width,height,function ()
        inStorePrompt=nil
        return true
    end)
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
    drawButton(text,x,y,nw,nh,function ()
        winning=true
        allVisible=false
        winningCD=0
    end)
end

function drawVictory()

    local cellFactor = 2.60
    if system=="Android" then cellFactor=2 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    panelWrapper("Vitória",width,height)

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
    y=y+cardfontsize+ySpacing
    drawLine(x+10,y,width-20)
    y=y+ySpacing
    
    local sec=tostring(currentSecs)
    if tonumber(sec)<10 then sec="0"..sec end
    local text = currentMins..":"..sec
    if timeBonus>0 then text = "+"..timeBonus.." "..text end
    if timeBonus<0 then text = timeBonus.." "..text end
    statWrapper("Tempo",text,x,y,width)
    y=y+cardfontsize+ySpacing
    drawLine(x+10,y,width-20)
    y=y+ySpacing
    local text = save.moves
    if movBonus>0 then text = "+"..movBonus.." "..text end
    if movBonus<0 then text = movBonus.." "..text end
    statWrapper("Movimentos",text,x,y,width)
    y=y+cardfontsize+ySpacing
    drawLine(x+10,y,width-20)
    y=y+ySpacing
    statWrapper("Pontos",save.points,x,y,width)
    y=y+cardfontsize+ySpacing
    drawLine(x+10,y,width-20)
    y=y+ySpacing
    local text = "+"..victoryCoins
    statWrapper("Moedas",text,x,y,width)

    --botão de jogar denovo
    local nw = cardfont:getWidth("Jogar denovo")+30
    local nh = height/6
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    drawButton("Jogar denovo",x,y,nw,nh,function ()
        pressButton(3)
        inVictory=false
    end)
end

function drawStats()
    --draw the base rectangle and its border
    local cellFactor = 3
    if system=="Android" then cellFactor=2 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    panelWrapper("Estatísticas",width,height)

    --victory label
    local x = screenw/2-width/2
    local y = screenh/2-height/2+15
    local ySpacing = 12
    
    y=y+cardfontsize+ySpacing
    drawLine(x+10,y,width-20)
    y=y+ySpacing
    statWrapper("Menor tempo",save.lowTime,x,y,width)
    y=y+cardfontsize+ySpacing
    statWrapper("Maior tempo",save.highTime,x,y,width)
    y=y+cardfontsize+ySpacing
    statWrapper("Tempo total",save.totalTime,x,y,width)
    y=y+cardfontsize+ySpacing
    drawLine(x+10,y,width-20)
    y=y+ySpacing
    statWrapper("Partidas jogadas",save.totalGames,x,y,width)
    y=y+cardfontsize+ySpacing
    statWrapper("Partidas ganhas",save.totalWins,x,y,width)
    y=y+cardfontsize+ySpacing
    statWrapper("Partidas perdidas",save.totalLoss,x,y,width)
    y=y+cardfontsize+ySpacing
    drawLine(x+10,y,width-20)
    y=y+ySpacing
    statWrapper("Maior pontuação",save.highScore,x,y,width)

    local nw = cardfont:getWidth("Voltar")+30
    local nh = cardfont:getHeight()+10
    local x = screenw/2-nw/2
    local y = screenh/2+height/2-nh-15
    drawButton("Voltar",x,y,nw,nh,function ()
        inStats=false
        return true
    end)
end

--Same as drawBack but it also takes an image as a back image
function storeDrawBack(x,y,img,v,index)
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

    if mouseReleasedPos~=nil and inStorePrompt==nil then
        local mx,my = mouseReleasedPos.x,mouseReleasedPos.y
        if mx >= x and mx <= x+cardw and my >= y and my <= y+cardh then
            if v.bought then
                if storeState==2 then
                    cardBack=v.img
                    save.backCard=v.imgName
                elseif storeState==3 then
                    changeBack(v.img)
                    save.backImg=v.imgName
                end
            else
                v["index"] = index
                if inStorePrompt==nil then inStorePrompt=v end
            end
            mouseReleasedPos=nil
            playSound("menu")
        end
    end
end

function drawSettings()
    --draw the base rectangle and its border
    local cellFactor = 2.8
    if system=="Android" then cellFactor=2.6 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    
    panelWrapper("Configurações",width,height)

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
            y=y+ySpacing
            love.graphics.setColor(1,1,1)
            love.graphics.printf(v.name,cardfont,x,y,width,"center")
            y=y+ySpacing+10
            local nw = cardfont:getWidth("+")+30
            local nh = cardfont:getHeight()+5
            local nx = x+width-nw-15
            drawButton("+",nx,y+2.5,nw,nh,function ()
                local whatButton=v
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
                return true
            end)
            nx=x+10
            drawButton("-",nx,y+2.5,nw,nh, function ()
                local whatButton = v
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
                return true
            end)
            love.graphics.setColor(1,1,1)
            love.graphics.printf(v.value,cardfont,x,y,width,"center")
            y=y+cardfontsize+ySpacing+5
        end
    end

    local nw = cardfont:getWidth("Apagar dados")+30
    local nh = cardfont:getHeight()+5
    local nx = x+15
    y=screenh/2+height/2-nh-15-nh-15
    drawButton("Apagar dados",nx,y,nw,nh, function ()
        if settingsEraseAll==false then settingsEraseAll=true end
        return true
    end)

    local nw = cardfont:getWidth("Voltar")+30
    local nh = cardfont:getHeight()+5
    local nx = x+15
    y=screenh/2+height/2-nh-15
    drawButton("Voltar",nx,y,nw,nh, function ()
        inSettings=false
        return true
    end)
    --reset button

    local nw = cardfont:getWidth(">")+15
    local nh = cardfontsize+10
    local x = screenw/2+width/2-nw-15
    local y = screenh/2-height/2+height-nh-15
    drawButton(">",x,y,nw,nh,function ()
        settingsPage=math.min(settingsPage+1,settingsPages)
        return true
    end)
    nw = cardfont:getWidth(settingsPage.."/"..settingsPages)+15
    x = x-nw-5
    love.graphics.printf(settingsPage.."/"..settingsPages,cardfont,x,y+(math.abs(nh-cardfontsize)/2),nw,"center")
    nw = cardfont:getWidth("<")+15
    x = x-nw-5
    drawButton("<",x,y,nw,nh,function ()
        settingsPage=math.max(settingsPage-1,1)
        return true
    end)


    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(oldThick)
end

function drawSettingsEraseAll()
    local cellFactor = 2
    if system=="Android" then cellFactor=1.60 end
    local width = screenw-(screenw/4)
    local height = screenh-(screenh/cellFactor)
    drawPanel(width,height)

    local x = screenw/2-width/2
    local y = screenh/2-height/2+5
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Apagar dados",cardfont,x,y,width,"center")
    y=y+cardfont:getHeight()*1.4+5
    love.graphics.printf("Essa ação apagará todos os seus dados, seja itens na loja, ou estatísticas. Certeza que deseja continuar?",cardfont,x,y,width,"center")

    local text = "Não"
    local nw = cardfont:getWidth(text)+30
    local nh = height/6
    local x = screenw/2-width/2+nw/2+5
    local y = screenh/2+height/2-nh-15
    drawButton(text,x,y,nw,nh,function ()
        settingsEraseAll=false
        return true
    end)

    local text = "Sim"
    local nw = cardfont:getWidth(text)+30
    local x = screenw/2+width/2-nw-nw/2-5
    drawButton(text,x,y,nw,nh,function ()
        eraseSave()
        settingsEraseAll=false
        startGame()
        playSound("new")
        return true
    end)
end

function drawButton(text,x,y,w,h,fun)
    local fn = fun or function () end
    drawButtonFont(text,cardfont,x,y,w,h,fn)
end

function drawButtonFont(text,font,x,y,w,h,fun)
    local fn = fun or function () end
    local color = {
        shading = uistyle.btnshading,
        active = uistyle.btnactive,
        btn = uistyle.btncolor,
        text = uistyle.textcolor
    }
    btn(text,font,x,y,w,h,color,fn)
end

function btn(text,font,x,y,w,h,color,fun)
    local fn = fun or function () end
    love.graphics.setColor(color.shading)
    love.graphics.rectangle("fill",x+5,y+5,w,h)
    local mx,my = love.mouse.getPosition()
    if mx >= x and mx <= x+w and my >= y and my <= y+h then
        love.graphics.setColor(color.active)
    else
        love.graphics.setColor(color.btn)
    end

    if mouseReleasedPos~=nil then
        local mx,my = mouseReleasedPos.x,mouseReleasedPos.y
        if mx >= x and mx <= x+w and my >= y and my <= y+h then
            if fn() then
                mouseReleasedPos=nil
                playSound("menu")
            end
        end
    end
    love.graphics.rectangle("fill",x,y,w,h)
    love.graphics.setColor(color.text)
    love.graphics.printf(text,font,x,y+(h-font:getHeight())/2,w,"center")
end

function drawPanel(width,height)
    --gray background
    love.graphics.setColor(uistyle.grayback)
    love.graphics.rectangle('fill',0,0,screenw,screenh)

    love.graphics.setColor(uistyle.backshading)
    love.graphics.rectangle("fill",screenw/2-width/2+5,screenh/2-height/2+5,width,height)

    love.graphics.setColor(uistyle.backcolor)
    love.graphics.rectangle("fill",screenw/2-width/2,screenh/2-height/2,width,height)
end

function panelWrapper(text,width,height)
    drawPanel(width,height)
    love.graphics.setColor(uistyle.textcolor)
    local x = screenw/2-width/2+10
    local y = screenh/2-height/2+15
    love.graphics.printf(text,cardfont,x,y,width,"center")
    love.graphics.setColor(uistyle.btncolor)
    local y = screenh/2-height/2+cardfont:getHeight()*1.2+15
    love.graphics.rectangle("fill",x,y,width-20,5)
end

function statWrapper(left,right,x,y,width)
    love.graphics.setColor(uistyle.textcolor)
    love.graphics.printf(left,cardfont,x+10,y,width,"left")
    love.graphics.printf(right,cardfont,x,y,width-10,"right")
end

function drawLine(x,y,w)
    love.graphics.setColor(uistyle.btncolor)
    love.graphics.rectangle("fill",x,y,w,5)
end

function resetDrawValues()
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(oldThick)
end

function storeDraw(table,giveny,width,height)
    local y = giveny
    for k=1,#table do
        local itr = k
        local spacing = ((width-cardw*storeMax))/storeMax
        local otherSpacing = ((screenw/2-width/2+(storeMax)*(cardw+spacing))-width)/storeMax
        if k>storeMax*storeRows then break end
        if k>storeMax then itr=k%storeMax end
        if itr==0 then itr=storeMax end
        local x = screenw/2-width/2+(itr-1)*(cardw+spacing) + otherSpacing
        local v = table[k+(storeMax*storeRows*(storePage-1))]
        if v==nil then break end
        local index = k+((storeMax*storeRows)*(storePage-1))
        if v.img~=nil then storeDrawBack(x,y,v.img,v,index) else drawCardStyle("K","spades",x,y,v,index) end
        local color = {
            active=uistyle.btnactive,
            btn=uistyle.btncolor,
            shading=uistyle.btnshading,
            text=uistyle.textcolor
        }
        if v.bought==false then
            text=v.price
        else
            text=";D"
            color.btn=color.active
        end
        btn(text,cardfont,x,y+cardh+3,cardw,cardfont:getHeight()+5,color,function ()
            if inStorePrompt==nil then
                if v.bought then
                    if storeState==1 then
                        cardStyle=v
                    elseif storeState==2 then
                        cardBack=v.img
                        save.backCard=v.imgName
                    elseif storeState==3 then
                        changeBack(v.img)
                        save.backImg=v.imgName
                    end
                else
                    v["index"] = index
                    inStorePrompt=v 
                end
                return true
            end
            return false
        end)
        if k%(storeMax)==0 then
            y=y+(cardh+cardfont:getHeight()+10*2)--*math.floor(k/storeMax)
        end

    end
end

function drawExitButton(width,height,fun)
    local color = {
        active=uistyle.exitactive,
        btn=uistyle.exitcolor,
        shading=uistyle.exitshading,
        text=uistyle.white
    }
    local nw,nh=30,30
    local fun = fun or function () end
    btn("X",cardfont,screenw/2+width/2-nw-10,screenh/2-height/2+10,nw,nh,color,fun)
end

function drawHeader(text,x,y,width,align,spacing)
    --love.graphics.rectangle("fill",x+spacing-5,y+spacing+cardfont:getHeight()/2,cardfont:getWidth(text)+5*2,cardfont:getHeight()/2)
    drawText(text,x+2,y+2,width,align,spacing,uistyle.btnshading)
    drawText(text,x,y,width,align,spacing,uistyle.textcolor)
end

function drawText(text,x,y,width,align,spacing,color)
    color = color or uistyle.textcolor
    love.graphics.setColor(color)
    align = align or "center"
    love.graphics.printf(text,cardfont,x+spacing,y+spacing,width-spacing*2,align)
end