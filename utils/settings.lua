function loadSettings()
    local obj = {
        hardSetting = {value="Médio",name="Dificuldade",possible=loadPossibleDifficulties()},
        backColor = {value="Sem cor",name="Cor do fundo",possible=loadPossibleBackColors()},
        animationSpeed = {value=35,name="Vel. Animação",min=15,max=45,step=10},
        volume = {value=100,name="Volume",min=0,max=100,step=5}
    }
    return obj,4
end

function loadPossibleBackColors()
    local obj = {
        ["Sem cor"] = {1,1,1},
        ["Vermelho"] = {1,0.6,0.6},
        ["Verde"] = {0.6,1,0.6},
        ["Azul"] = {0.6,0.6,1},
        ["Escuro"] = {0.3,0.3,0.3},
        ["Roxo"] = {1,0.6,1},
        ["Amarelo"] = {1,1,0.6},
        ["Laranja"] = {1,0.6,0.3},
        keys = {"Sem cor","Vermelho","Verde","Azul","Roxo","Amarelo","Laranja","Escuro"}
    }
    return obj
end

function loadPossibleDifficulties()
    local obj = {
        ["Fácil"] = 30,
        ["Médio"] = 45,
        ["Difícil"] = 75,
        keys = {"Fácil","Médio","Difícil"}
    }
    return obj
end

function switchNext(tab)
    local found = false
    for i,v in ipairs(tab.possible.keys) do
        local k=v
        if found then
            local nextKey = k
            tab.value=nextKey
            break
        end
        if k == tab.value then
            found = true
        end
        if i==#tab.possible.keys then
            tab.value=tab.possible.keys[1]
            break
        end
    end
end

function switchPrior(tab)
    for i,v in ipairs(tab.possible.keys) do
        local k=v
        if k == tab.value then
            if i==1 then
                tab.value=tab.possible.keys[#tab.possible.keys]
                break
            end
            local nextKey = tab.possible.keys[i-1]
            tab.value=nextKey
            break
        end
    end
end

function stepSetting(tab,signal)
    if signal>0 then
        tab.value=math.min(tab.value+tab.step,tab.max)
    else
        tab.value=math.max(tab.value-tab.step,tab.min)
    end
end

function calculateSettingsToShow(height)
    local cellFactor = 2.8
    if system=="Android" then cellFactor=2.4 end
    local height = screenh-(screenh/cellFactor)
    local nh = cardfont:getHeight()+5
    height=height-nh-15-nh-15
    local ySpacing = cardfont:getHeight()-10
    local spacing = cardfontsize+ySpacing
    height=height-cardfontsize+ySpacing
    return math.floor(height/(spacing+ySpacing+cardfont:getHeight()+15))
end