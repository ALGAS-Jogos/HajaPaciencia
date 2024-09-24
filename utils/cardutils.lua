--Adds a card at the bottom of a list
function addCardToList(listnumber,number,suit,visible)
    local index=0
    if cardlists[listnumber] then
        index = #cardlists[listnumber]
    else
        cardlists[listnumber] = {}
    end
    cardlists[listnumber][index+1] = {number=number,suit=suit,visible=visible}
end

--Adds cards to a list (used in generation)
function addCardToListGen(listnumber,number,suit,visible)
    if cardlists[listnumber] then
    else
        cardlists[listnumber] = {}
    end
    local obj={{number=number,suit=suit,visible=visible}}
    for k,v in ipairs(cardlists[listnumber]) do
        obj[#obj+1] = v
    end
    cardlists[listnumber]=obj
end

--Does all the funky stuff and shuffles the deck and sets a new board
function addCards()
    --if unusedAddCards()==false then return true end
    local cards = allCards()
    local limit = 28
    local hardSetting = settings.hardSetting.possible[settings.hardSetting.value]
    for i=1,#cards do
        local toWhere = random(1,100)
        local card = cards[i]
        if toWhere<=hardSetting and i==#cards-limit then toWhere=100 end
        if limit==0 then toWhere=1 end
        if toWhere>hardSetting and limit>0 then
            local trying = true
            local column = random(1,7)
            while trying do
                column = random(1,7)
                if cardlists[column] then
                    if #cardlists[column]<column then trying=false end
                else
                    trying=false
                end
            end
            local isVisible=false
            addCardToListGen(column,card.number,card.suit,isVisible)
            limit=limit-1
        else
            cardstacks[#cardstacks+1] = card
        end
    end

    --shuffle the stacks
    local obj = cardstacks
    cardstacks={}
    for i=1,#obj do
        local cardID = random(1,#obj)
        cardstacks[#cardstacks+1] = obj[cardID]
        table.remove(obj,cardID)
    end

    for i=1,7 do
        cardlists[i][#cardlists[i]].visible=true
    end
end

--Unused function that just puts a insta-winnable board
function unusedAddCards()
    local cards = allCards()
    for i=1,4 do
        for j=1,13 do
            local naipe = (i+j)%4
            local number = j
            if naipe==0 then naipe=4 end
            print(ordem[number], cnaipes[naipe])
            if j<9 then
                if cardlists[i%4+1] then
                    addCardToList(i%4+1,ordem[number],cnaipes[naipe],true)
                else
                    cardlists[i%4+1] = {}
                    addCardToList(i%4+1,ordem[number],cnaipes[naipe],true)
                end
            else
                cardstacks[#cardstacks+1] = {number=ordem[number],suit=cnaipes[naipe]}
            end
            if i==4 and j==13 then
                return false
            end
        end
    end
end

--Check for any null piles and auto deletes them (fixes some random bug)
function checkNullPiles()
    for i=1,4 do
        if cardpile[i] then
            if #cardpile[i] == 0 then
                table.remove(cardpile,i)
            else
                local localSuit = ""
                for k,v in ipairs(cardpile[i]) do
                    if k==1 then localSuit=v.suit end
                    if v.suit~=localSuit then
                        table.insert(cardstacks,v)
                        table.remove(cardpile[i],k)
                    end
                end
            end
        end
    end
    collectgarbage()
end

--Checks if the lastlist was a pile
function checkIfPileLast(lastlist)
    if string.match(lastlist,"pile") or lastlist=="litter" then return true else return false end
end

--checks if cardonhand can move to any pile
function checkPiles(ch)
    if #ch>1 then return false end
    local coh = ch[1]
    if coh.number=="A" then
        cardpile[#cardpile+1] = {}
        return #cardpile
    end
    for k,v in ipairs(cardpile) do
        local card = v[#v]
        if checkIfPost(card.number,coh.number) and coh.suit==card.suit then
            return k
        end
    end
    return false
end

--checks if cardonhand can move to a list
function checkLists(ch)
    local coh = ch[1]
    local last = ch.lastlist or "pass"
    for k,v in ipairs(cardlists) do
        if #v>0 then
            local card = v[#v]
            if checkIfPost(coh.number,card.number) and checkOpposite(card.suit,coh.suit) and (last=="pass" or last~=k) then
                return k
            end
        elseif coh.number=="K" then
            return k
        end
    end
    return false
end

--Makes the last card of the last list of the cardonhand visible
function makeVisible()
    local vis = true
    if cardonhand.lastlist~="litter" and not string.match(cardonhand.lastlist,"pile") then
        if #cardlists[cardonhand.lastlist]>0 then
            vis = cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible
            cardlists[cardonhand.lastlist][#cardlists[cardonhand.lastlist]].visible = true
        end
    end
    allVisible = checkAllVisible()
    return vis
end

--Saves the last move made on a table and resets the forwardMoves table
function putLastMove(oldLocation,newLocation,size,index,behindHidden)
    local move = oldLocation.."|"..newLocation.."|"..size.."|"..index.."|"..tostring(behindHidden)
    lastMoves[#lastMoves+1] = move
    lastMovesIndex = #lastMoves+1
    forwardMoves = {}
    save.moves=save.moves+1
end

--Gets the undo and does the funky bits
function getUndo()
    if lastMovesIndex>1 then
        local undoObj = lastMoves[lastMovesIndex-1]
        local move = ""
        if undoObj=="stack" then
            stackMove("backward")
            move = "stack"
            lastMovesIndex = lastMovesIndex - 1
        elseif undoObj=="restack" then
            cardlitter=invertTable(cardstacks)
            cardstacks={}
            move = "restack"
            lastMovesIndex = lastMovesIndex - 1
        else
            lastMovesIndex = lastMovesIndex - 1
            local splitted = split(undoObj,"|")
            local from = splitted[2]
            local to = splitted[1]
            local size = tonumber(splitted[3])
            local index = tonumber(splitted[4])
            local behindHidden = splitted[5]
            index = execMove(from,to,size,index,"undo",behindHidden)
            move = from.."|"..to.."|"..size.."|"..index.."|"..tostring(behindHidden)
        end
        forwardMoves[#forwardMoves+1] = move
        table.remove(lastMoves,lastMovesIndex)
        deductPoints(10)
        save.moves=save.moves+1
    end
end

--Gets the redo and does the funky bits
function getRedo()
    if #forwardMoves>0 then
        local redoObj = forwardMoves[#forwardMoves]
        local move = ""
        if redoObj=="stack" then
            stackMove("forward")
            move = "stack"
        elseif redoObj=="restack" then
            cardstacks=invertTable(cardlitter)
            cardlitter={}
            move = "restack"
        else
            local splitted = split(redoObj,"|")
            local from = splitted[2]
            local to = splitted[1]
            local size = tonumber(splitted[3])
            local index = tonumber(splitted[4])
            local behindHidden = splitted[5]
            index = execMove(from,to,size,index,"redo",behindHidden)
            move = from.."|"..to.."|"..size.."|"..index.."|"..tostring(behindHidden)
        end
        lastMoves[#lastMoves+1] = move
        lastMovesIndex = #lastMoves+1
        table.remove(forwardMoves,#forwardMoves)
        save.moves=save.moves+1
    else
        playSound("error")
    end
end

--Executes a move, used with Undo/Redo
function execMove(from,to,size,index,operation,behindHidden)
    --get card
    local card = {}
    if string.match(from,"pile") then
        local pile = tonumber(string.sub(from,5)) or 1
        local actualPile = cardpile[pile]
        card = {actualPile[#actualPile]}
        table.remove(actualPile,#actualPile)
        if #actualPile==0 then cardpile[pile] = nil end
    elseif from=="litter" then
        card = {cardlitter[#cardlitter]}
        table.remove(cardlitter,#cardlitter)
    else
        from = tonumber(from)        
        for i=index,#cardlists[from] do
            card[#card+1] = cardlists[from][i]
        end
        for i=index,#cardlists[from] do
            table.remove(cardlists[from],index)
        end
        if cardlists[from][#cardlists[from]] then cardlists[from][#cardlists[from]].visible=true end 
    end

    --put card
    if string.match(to,"pile") then
        local pile = tonumber(string.sub(to,5)) or 1
        local actualPile = cardpile[pile]
        if actualPile==nil then cardpile[pile] = {}; actualPile=cardpile[pile] end
        actualPile[#actualPile+1] = card[1]
        return #actualPile
    elseif to=="litter" then
        cardlitter[#cardlitter+1] = card[1]
        return #cardlitter
    else
        to = tonumber(to)
        for i=1,#card do
            cardlists[to][#cardlists[to]+1] = card[i]
        end
        --print(behindHidden)
        if cardlists[to][#cardlists[to]-size] and operation=="undo" and behindHidden=="false" then cardlists[to][#cardlists[to]-size].visible = false end
        return #cardlists[to]-size+1
    end
end

--Moves cards from or to the stack
function stackMove(where)
    if where=="backward" then
        cardstacks[#cardstacks+1] = cardlitter[#cardlitter]
        table.remove(cardlitter,#cardlitter)
    else
        cardlitter[#cardlitter+1] = cardstacks[#cardstacks]
        table.remove(cardstacks,#cardstacks)
    end
end

--Make move when Winning is triggered
function allVisibleMakeMove()
    for k,v in ipairs(cardlists) do
        if #v>0 then
            local card=v[#v]
            local pile = checkPiles({card})
            if pile~=false then
                cardpile[pile][#cardpile[pile]+1] = card
                addPoints(15)
                playSound("move")
                save.moves=save.moves+1
                local x = pile * (cardw+androidInterSpacing) - androidSpacing
                local y = cardh-cardh+cardfontsize+5 + androidOverhead
                local cardx = k * (cardw+androidInterSpacing) - androidSpacing
                local cardy = #v * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
                local m = math.atan2(y-(cardy),x-(cardx))
                local width=35*math.cos(m)
                local height=35*math.sin(m)
                local temp = {cards={card},cardx=cardx,cardy=cardy,x=x,y=y,width=width,height=height}
                cardAnimate["pile"..pile] = temp
                table.remove(v,#v)
                break
            end
        end
    end
    for i=1, #cardstacks+#cardlitter do
        if #cardlitter>0 then
            local card = cardlitter[#cardlitter]
            local pile = checkPiles({card})
            local list = checkLists({card})
            if pile~=false then
                cardpile[pile][#cardpile[pile]+1] = card
                addPoints(15)
                playSound("move")
                save.moves=save.moves+1
                local tempx = (5+#cardlitter%3+1) * (cardw+androidInterSpacing) - androidSpacing
                local x = pile * (cardw+androidInterSpacing) - androidSpacing
                local y = cardh-cardh+cardfontsize+5 + androidOverhead
                local cardx = tempx - (#cardlitter%3+1)*cardw*0.75 - (100-androidSpacing)
                local cardy = cardh-cardh+cardfontsize+5 + androidOverhead
                if system=="Android" then cardx=cardx+screenw/10 end
                local m = math.atan2(y-(cardy),x-(cardx+cardw/2))
                local width=35*math.cos(m)
                local height=35*math.sin(m)
                local temp = {cards={card},cardx=cardx+cardw/2,cardy=cardy,x=x,y=y,width=width,height=height}
                cardAnimate["pile"..pile] = temp
                table.remove(cardlitter,#cardlitter)
                break
            elseif list~=false then
                local index = #cardlists[list]
                local newIndex = index+1
                for i,v in ipairs({card}) do
                    v.visible=true
                    cardlists[list][index+i] = v
                end
                addPoints(2)
                playSound("move")
                clickSendCD=0
                local tempx = (5+#cardlitter%3+1) * (cardw+androidInterSpacing) - androidSpacing
                local cardx = tempx - (#cardlitter%3+1)*cardw*0.75 - (100-androidSpacing)
                local cardy = cardh-cardh+cardfontsize+5 + androidOverhead
                local x = tonumber(list) * (cardw+androidInterSpacing) - androidSpacing
                local y = tonumber(newIndex) * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
                if system=="Android" then cardx=cardx+screenw/10 end
                local m = math.atan2(y-(cardy),x-(cardx+cardw/2))
                local width=35*math.cos(m)
                local height=35*math.sin(m)
                local temp = {cards={card},cardx=cardx+cardw/2,cardy=cardy,x=x,y=y,width=width,height=height}
                cardAnimate["list"..list..":"..newIndex] = temp
                table.remove(cardlitter,#cardlitter)
            else
                if #cardstacks>0 then
                    local card = cardstacks[#cardstacks]
                    cardlitter[#cardlitter+1] = card
                    table.remove(cardstacks,#cardstacks)
                    playSound("move")
                    save.moves=save.moves+1
                    break
                else
                    cardstacks = invertTable(cardlitter)
                    cardlitter = {}
                    save.moves=save.moves+1
                    deductPoints(100)
                end
            end
        elseif #cardstacks>0 then
            local card = cardstacks[#cardstacks]
            cardlitter[#cardlitter+1] = card
            table.remove(cardstacks,#cardstacks)
            playSound("move")
            save.moves=save.moves+1
            break
        else
            cardstacks = invertTable(cardlitter)
            cardlitter = {}
            deductPoints(100)
            save.moves=save.moves+1
        end
    end
end

--Checks all the piles for Kings in their last positions
function checkVictory()
    local comply = 0
    for k,v in ipairs(cardpile) do
        if v[#v]==nil then return false end
        if v[#v].number == "K" then comply=comply+1 end
    end
    if comply==4 then
        calculateVictory()
        statsUpdate()
        save.totalWins=save.totalWins+1
        wonGame=true
        winning=false
        allVisible=false
        playSound("victory")
        inVictory=true
    end
end

--checks if all cards in lists are visible
function checkAllVisible()
    for k,v in ipairs(cardlists) do
        for i,c in ipairs(v) do
            if c.visible==false then return false end
        end
    end
   return true
end

--Returns the cardonhand to where it used to be, 
-- used when the cardonhand lands on a bad spot
function returnCard()
    local mx, my = love.mouse.getPosition()
    local speed = settings.animationSpeed.value
    if clickSendCD<0.5 then
        local pile = checkPiles(cardonhand)
        local list = checkLists(cardonhand)
        if pile~=false and cardonhand.lastlist~="pile"..pile then
            cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
            local behindHidden = makeVisible()
            putLastMove(cardonhand.lastlist,"pile"..pile,#cardonhand,0,behindHidden)
            checkVictory()
            if not string.match(cardonhand.lastlist,"pile") then addPoints(15) end
            playSound("move")
            clickSendCD=0
            local x = pile * (cardw+androidInterSpacing) - androidSpacing
            local y = cardh-cardh+cardfontsize+5 + androidOverhead
            local m = math.atan2(y-(my-cardonhand.cardy),x-(mx-cardonhand.cardx))
            local width=speed*math.cos(m)
            local height=speed*math.sin(m)
            local temp = {cards=cardonhand,cardx=mx-cardonhand.cardx,cardy=my-cardonhand.cardy,x=x,y=y,width=width,height=height}
            cardAnimate["pile"..pile] = temp    
            return nil
        elseif list~=false and cardonhand.lastlist~=list then
            local index = #cardlists[list]
            local newIndex = index+1
            for i,v in ipairs(cardonhand) do
                v.visible=true
                cardlists[list][index+i] = v
            end
            local behindHidden = makeVisible()
            putLastMove(cardonhand.lastlist,list,#cardonhand,newIndex,behindHidden)
            if checkIfPileLast(cardonhand.lastlist) then addPoints(2) end
            playSound("move")
            clickSendCD=0
            local x = tonumber(list) * (cardw+androidInterSpacing) - androidSpacing
            local y = tonumber(newIndex) * (cardh-cardh+cardfontsize+5) + (cardh + 40) + androidOverhead
            local m = math.atan2(y-(my-cardonhand.cardy),x-(mx-cardonhand.cardx))
            local width=speed*math.cos(m)
            local height=speed*math.sin(m)
            local temp = {cards=cardonhand,cardx=mx-cardonhand.cardx,cardy=my-cardonhand.cardy,x=x,y=y,width=width,height=height}
            cardAnimate["list"..list..":"..newIndex] = temp
            if string.match(cardonhand.lastlist,"pile") then
                local pile = tonumber(string.sub(cardonhand.lastlist,5)) or 1
                local actualPile = cardpile[pile]
                if actualPile then
                    if not (#actualPile>0) then table.remove(cardpile,pile) end
                end
            end
            return nil
        end
    end
    if cardonhand.lastlist=="litter" then
        cardlitter[#cardlitter+1]=cardonhand[1]
    elseif string.match(cardonhand.lastlist,"pile") then
        local pile = tonumber(string.sub(cardonhand.lastlist,5)) or 1
        local actualPile = cardpile[pile]
        if actualPile then
            actualPile[#actualPile+1] = cardonhand[1]
        else
            cardpile[pile] = {}
            cardpile[pile][#cardpile[pile]+1] = cardonhand[1]
        end
    else
        local index = #cardlists[cardonhand.lastlist]
        for i,v in ipairs(cardonhand) do
            cardlists[cardonhand.lastlist][index+i] = v
        end
    end
    playSound("error")
    clickSendCD=0
    return nil
end

--Wipes the board
function resetCards()
    cardlists = {}
    cardlitter = {}
    cardonhand = nil
    cardpile = {}
    cardstacks = {}

    forwardMoves={}
    lastMoves={}
    lastMovesIndex=1
end