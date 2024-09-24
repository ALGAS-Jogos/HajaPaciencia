
cardlists = {}
cardstacks = {}
cardpile = {}
cardlitter = {}
cardonhand = nil

round = 7
androidSpacing = 100
androidInterSpacing = 10
androidOverhead = 0
androidSmall = 0.1

mouseReleasedPos = nil

coinImg = love.graphics.newImage("img/coin.png")
settingsImg = love.graphics.newImage("img/settings.png")

buttons = {
    {img=love.graphics.newImage("img/undo.png")},
    {img=love.graphics.newImage("img/stats.png")},
    {img=love.graphics.newImage("img/new.png")},
    {img=love.graphics.newImage("img/market.png")},
    {img=love.graphics.newImage("img/redo.png")}
}

lastMoves = {}
lastMovesIndex = 1
forwardMoves = {}

system = love.system.getOS()

oldThick = love.graphics.getLineWidth()

inStore = false
inStorePrompt = nil
inStats = false
inVictory = false
inSettings = false

wonGame = false
allVisible = false
winning = false
winningCD = 0

pileCheckCD = 0

victoryCoins = 0

storeItems = {}
storeCB = {}
storeBacks = {}

storeButtons = {"Cartas","Versos","Fundos"}
storeState = 1
storePage = 1
storePages = 1
storeMax = 6
storeRows = 2

save = {
    coins=500,
    highScore=0,
    highTime="0:00",
    lowTime="0:00",
    totalTime="0:00",
    totalGames=0,
    totalWins=0,
    totalLoss=0,
    points=0,
    currentTime="0:00",
    moves=0,
    backImg="backgrounds/back1.jpg",
    backCard="cards/back1.png",
    version="1.3"
}

settings, settingsLen = loadSettings()
settingsEraseAll = false
settingsAllowed = 2
settingsPage = 1
settingsPages = math.floor(#settings/settingsAllowed)

currentSecs = 0
currentMins = 0
currentCD = 0
timePunish = 0

clickSendCD = 0

love.graphics.setBackgroundColor(0.2,0.05,0.2)

love.math.setRandomSeed(os.time())
random = love.math.random

sounds = {
    move = love.audio.newSource("sfx/newmove.mp3","static"),
    new = love.audio.newSource("sfx/new.mp3","static"),
    victory = love.audio.newSource("sfx/victory.mp3","static"),
    menu = love.audio.newSource("sfx/menu.mp3","static"),
    error = love.audio.newSource("sfx/error.mp3","static")
}

uistyle = {
    btncolor = {0, 0.239, 0.063},
    btnactive = {0.130,0.369,0.193},
    btnshading = {0,0.139,0.003},
    white = {1,1,1,1},
    backcolor = {0.035, 0.388, 0},
    backshading = {0.012, 0.11, 0},
    textcolor = {1,1,1},
    grayback = {0,0,0,0.6},
    exitcolor = {1, 0.239, 0.055},
    exitactive = {1, 0.49, 0.365},
    exitshading = {0.569, 0.11, 0}
}

