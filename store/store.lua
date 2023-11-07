--Loads the store items
function loadStoreItems()
    local obj={
        {
            color={1,1,1},
            textcolor={0,0,0},
            suitcolor={0,0,0},
            casered={0.6,0,0},
            backImg=nil,
            font="fonts/Bricolage.ttf",
            bought=true,
            price=0,
            name="Default"
        },

        {name="Neon Blue",bought=false,price=500,font="fonts/Bricolage.ttf",color={0.05,0.05,0.05},textcolor={0.13,0.91,1.00},suitcolor={0.13,0.91,1.00},casered={0.64,0.17,1.00}},
        {name="Neon Red",bought=false,price=500,font="fonts/Bricolage.ttf",color={0.05,0.05,0.05},textcolor={0.01,1.00,0.24},suitcolor={0.01,1.00,0.24},casered={1.00,0.03,0.22}},
        {name="Rustic",bought=false,price=500,font="fonts/Caprasimo.ttf",color={1, 0.945, 0.682},textcolor={0.01,0.01,0.01},suitcolor={0.01,0.01,0.01},casered={0.612, 0, 0}},
        {name="Deep Blue",bought=false,price=500,font="fonts/RussoOne.ttf",color={0.1,0,0.35},textcolor={0.9,0.9,0.9},suitcolor={0.9,0.9,0.9},casered={1,0.1,0.1}},
        {name="Winter",bought=false,price=500,font="fonts/Griffy.ttf",color={0.995,0.995,1},textcolor={0.01,0.01,0.01},suitcolor={0.01,0.01,0.01},casered={0.1,0.1,0.8}},
        {name="Glass",bought=false,price=500,font="fonts/Bricolage.ttf",color={1,1,1,0.85},textcolor={0,0,0},suitcolor={0,0,0},casered={0.9,0.1,0.1}}
        
    }
    return obj
end

--Loads the store card backs
function loadStoreCB()
    local obj = {
        {name="Default",price=0,bought=true,font="fonts/Bricolage.ttf",img=love.graphics.newImage("cards/back1.png"),color={1,1,1},textcolor={0,0,0}},
        {name="Death Wings",price=500,bought=false,font="fonts/RussoOne.ttf",img=love.graphics.newImage("cards/back2.png"),color={0.05,0.05,0.05},textcolor={1,1,1}}
    }
    return obj
end
