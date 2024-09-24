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
            name="Padrão"
        },

        {name="Rústico",bought=false,price=500,fontName="fonts/Caprasimo.ttf",font="fonts/Caprasimo.ttf",color={1, 0.996, 0.863},textcolor={0.01,0.01,0.01},suitcolor={0.01,0.01,0.01},casered={0.612, 0, 0}},
        {name="Roxo Escuro",bought=false,price=500,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",color={0.208, 0, 0.302},textcolor={0.9,0.9,0.9},suitcolor={0.9,0.9,0.9},casered={1, 0, 0.722}},
        {name="Inverno",bought=false,price=500,fontName="fonts/Griffy.ttf",font="fonts/Griffy.ttf",color={0.995,0.995,1},textcolor={0.01,0.01,0.01},suitcolor={0.01,0.01,0.01},casered={0.1,0.1,0.8}},
        {name="Prateado",bought=false,price=500,fontName="fonts/BlackOpsOne.ttf",font="fonts/BlackOpsOne.ttf",color={0.05,0.05,0.05},textcolor={0.859, 0.859, 0.859},suitcolor={0.859, 0.859, 0.859},casered={1,0.25,0.25}},
        {name="Azul Neon",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.05,0.05,0.05},textcolor={0.13,0.91,1.00},suitcolor={0.13,0.91,1.00},casered={0.64,0.17,1.00}},
        {name="Vermelho Neon",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.05,0.05,0.05},textcolor={0.01,1.00,0.24},suitcolor={0.01,1.00,0.24},casered={1.00,0.03,0.22}},
        {name="Vidro",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={1,1,1,0.85},textcolor={0,0,0},suitcolor={0,0,0},casered={0.9,0.1,0.1}},
        {name="Vidro Escuro",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.05,0.05,0.05,0.85},textcolor={0.13,0.91,1.00},suitcolor={0.13,0.91,1.00},casered={0.64,0.17,1.00}},
        {name="Beira-mar",bought=false,price=500,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={1, 0.984, 0.957},textcolor={0, 0.62, 0.333},suitcolor={0, 0.62, 0.333},casered={0.529, 0.337, 0.137}},
        {name="Pastel",bought=false,price=650,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.981,0.91,0.875},textcolor={0.118,0.118,0.118},suitcolor={0.118,0.118,0.118},casered={0.82,0.02,0.208}},
        {name="Futurista",bought=false,price=450,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0.1,0.1,0.1},textcolor={0,0.546,0.616},suitcolor={0,0.546,0.616},casered={0.899,0.216,0.216}},
        {name="Papiro",bought=false,price=600,fontName="fonts/Tektur.ttf",font="fonts/Tektur.ttf",color={0.953,0.934,0.875},textcolor={0,0,0},suitcolor={0,0,0},casered={0.969,0.106,0.106}},
        {name="Esperança escura",bought=false,price=300,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0,0.095,0.232},textcolor={0.428,0.95,0.475},suitcolor={0.428,0.95,0.475},casered={0.95,0.859,0.428}},
        {name="Esperança espiritual",bought=false,price=350,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",color={0,0.095,0.232,0.85},textcolor={0.428,0.95,0.475},suitcolor={0.428,0.95,0.475},casered={0.95,0.859,0.428}},
        
    }
    return obj
end

--Loads the store card backs
function loadStoreCB()
    local obj = {
        {name="Padrão",price=0,bought=true,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="cards/back1.png",color={1,1,1},textcolor={0,0,0}},
        {name="Asas Negras",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back2.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Asas vermelhas",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back3.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Tear",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back4.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Flores de Carmim",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back5.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Azul Profundo",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back6.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Cruz Vermelha",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back7.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Buraco Negro",price=500,bought=false,fontName="fonts/BlackOpsOne.ttf",font="fonts/BlackOpsOne.ttf",imgName="cards/back8.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Cross",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back9.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Cross",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back10.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Red Cross",price=500,bought=false,fontName="fonts/RussoOne.ttf",font="fonts/RussoOne.ttf",imgName="cards/back11.png",color={0.05,0.05,0.05},textcolor={1,1,1}},
    }
    return obj
end

--Loads the store background images
function loadStoreBacks()
    local obj = {
        {name="Padrão",price=0,bought=true,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back1.jpg",color={1,1,1},textcolor={0,0,0}},
        {name="Floresta",price=250,bought=false,fontName="fonts/Outfit.ttf",font="fonts/Outfit.ttf",imgName="backgrounds/back2.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Madeira",price=300,bought=false,fontName="fonts/AlfaSlabOne.ttf",font="fonts/AlfaSlabOne.ttf",imgName="backgrounds/back3.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Cachoeira",price=250,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back4.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Montanha às névoas",price=450,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back5.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Noite estrelada",price=350,bought=false,fontName="fonts/Tektur.ttf",font="fonts/Tektur.ttf",imgName="backgrounds/back6.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Nascer do sol",price=450,bought=false,fontName="fonts/Outfit.ttf",font="fonts/Outfit.ttf",imgName="backgrounds/back7.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Buraco negro estelar",price=500,bought=false,fontName="fonts/BlackOpsOne.ttf",font="fonts/BlackOpsOne.ttf",imgName="backgrounds/back8.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Céu na floresta",price=450,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back9.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Cachorro do natal",price=650,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back10.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Montanhas na distância",price=450,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back11.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Flor alaranjada",price=300,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back12.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Planta a crescer",price=550,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back13.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}},
        {name="Nuvens a pensar",price=600,bought=false,fontName="fonts/Bricolage.ttf",font="fonts/Bricolage.ttf",imgName="backgrounds/back14.jpg",color={0.05,0.05,0.05},textcolor={1,1,1}}
    }
    return obj
end
