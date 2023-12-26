function loadSettings()
    local obj = {
        hardSetting = {value=50,name="Dificuldade"},
        backColor = {value="Sem cor",name="Cor do fundo"},
        animationSpeed = {value=35,name="Vel. Animação"}
    }
    return obj
end

function loadPossibleBackColors()
    local obj = {
        ["Sem cor"] = {1,1,1},
        ["Vermelho"] = {1,0.6,0.6},
        ["Verde"] = {0.6,1,0.6},
        ["Azul"] = {0.6,0.6,1},
        keys = {"Sem cor","Vermelho","Verde","Azul"}
    }
    return obj
end