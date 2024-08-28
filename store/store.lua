--Loads the store items
function loadStoreItems()
    local obj={
        {
            color={1,1,1},
            textcolor={0,0,0},
            suitcolor={0,0,0},
            casered={0.6,0,0},
            backimgName=nil,
            fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",
            bought=true,
            price=0,
            name="Default"
        },

        {name="Rustic",bought=false,price=500,fontName="fonts/Caprasimo.ttf",font="fonts/Caprasimo.ttf",color={1, 0.996, 0.863},textcolor={0.01,0.01,0.01},suitcolor={0.01,0.01,0.01},casered={0.612, 0, 0}},
        {name="Deep Purple",bought=false,price=500,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",color={0.208, 0, 0.302},textcolor={0.9,0.9,0.9},suitcolor={0.9,0.9,0.9},casered={1, 0, 0.722}},
        {name="Winter",bought=false,price=500,fontName="fonts/Griffy.ttf",font="fonts/Griffy.ttf",color={0.995,0.995,1},textcolor={0.01,0.01,0.01},suitcolor={0.01,0.01,0.01},casered={0.1,0.1,0.8}},
        {name="Silvery",bought=false,price=500,fontName="fonts/BlackOpsOne.ttf",font="fonts/BlackOpsOne.ttf",color={0.05,0.05,0.05},textcolor={0.859, 0.859, 0.859},suitcolor={0.859, 0.859, 0.859},casered={1,0.25,0.25}},
        {name="Neon Blue",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.05,0.05,0.05},textcolor={0.13,0.91,1.00},suitcolor={0.13,0.91,1.00},casered={0.64,0.17,1.00}},
        {name="Neon Red",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.05,0.05,0.05},textcolor={0.01,1.00,0.24},suitcolor={0.01,1.00,0.24},casered={1.00,0.03,0.22}},
        {name="Glass",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={1,1,1,0.85},textcolor={0,0,0},suitcolor={0,0,0},casered={0.9,0.1,0.1}},
        {name="Tinted Glass",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.05,0.05,0.05,0.85},textcolor={0.13,0.91,1.00},suitcolor={0.13,0.91,1.00},casered={0.64,0.17,1.00}},
        {name="Near Ocean",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={1, 0.984, 0.957},textcolor={0, 0.62, 0.333},suitcolor={0, 0.62, 0.333},casered={0.529, 0.337, 0.137}}
        
    }
    return obj
end

--Loads the store card backs
function loadStoreCB()
    local obj = {
        {name="Default",price=0,bought=true,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="cards/back1.png",color={1,1,1},textcolor={0,0,0}},
        {name="Black Wings",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back2.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Wings",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back3.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Knitting",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back4.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Flowers",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back5.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Deep Blue",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back6.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Cross",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back7.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Black Hole",price=500,bought=false,fontName="fonts/BlackOpsOne.ttf",font="fonts/BlackOpsOne.ttf",imgName="cards/back8.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Cross",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back9.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Cross",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back10.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Cross",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back11.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
    }
    return obj
end

--Loads the store background images
function loadStoreBacks()
    local obj = {
        {name="Default",price=0,bought=true,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back1.jpg",color={1,1,1},textcolor={0,0,0}},
        {name="Forest",price=250,bought=false,fontName="fonts/Outfit.ttf",font="fonts/Outfit.ttf",imgName="backgrounds/back2.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Woodboard",price=300,bought=false,fontName="fonts/AlfaSlabOne.ttf",font="fonts/AlfaSlabOne.ttf",imgName="backgrounds/back3.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Waterfall",price=250,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back4.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Foggy Mountains",price=450,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back5.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Starry night",price=350,bought=false,fontName="fonts/Tektur.ttf",font="fonts/Tektur.ttf",imgName="backgrounds/back6.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Sunrise",price=450,bought=false,fontName="fonts/Outfit.ttf",font="fonts/Outfit.ttf",imgName="backgrounds/back7.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Black Hole Sun",price=500,bought=false,fontName="fonts/BlackOpsOne.ttf",font="fonts/BlackOpsOne.ttf",imgName="backgrounds/back8.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Forest Sky",price=450,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back9.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Christmas Dog",price=650,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back10.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}}
    }
    return obj
end
