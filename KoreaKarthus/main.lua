--[[

     ____  __.                              _________            .__        __   
    |    |/ _|___________   ____ _____     /   _____/ ___________|__|______/  |_ 
    |      < /  _ \_  __ \_/ __ \\__  \    \_____  \_/ ___\_  __ \  \____ \   __\
    |    |  (  <_> )  | \/\  ___/ / __ \_  /        \  \___|  | \/  |  |_> >  |  
    |____|__ \____/|__|    \___  >____  / /_______  /\___  >__|  |__|   __/|__|  
            \/                 \/     \/          \/     \/         |__|         

    Korea Script - Korea Karthus
    Developed by Korea.

    Thank you for read this terrible code.
]]--

local KoreaKarthus = {}

-- Script Information Part

KoreaKarthus.scriptName = "Korea Karthus"
KoreaKarthus.scriptId = "KoreaKarthus"
KoreaKarthus.scriptDeveloper = "Korea"
KoreaKarthus.scriptVersion = 1.0
KoreaKarthus.scriptVersionDisplay = "1.0"
KoreaKarthus.scriptVersionDate = "2018.05.01"
KoreaKarthus.testedLolVersion = "8.8"


-- Script Var

KoreaKarthus.pState = false
KoreaKarthus.pStartTime = 0
KoreaKarthus.pEndTime = 0
KoreaKarthus.pLeftTime = 0

KoreaKarthus.eState = false
KoreaKarthus.eDelayStart = 0
KoreaKarthus.eDelayEnd = 0
KoreaKarthus.eOnDelay = false

KoreaKarthus.target = nil
KoreaKarthus.predQPosition = nil

KoreaKarthus.rSupporterText = {}



-- Small Function

function KoreaKarthus:printConsole(printContent)
    if not printContent or not type(printContent) == "string" then
        return false
    end

    console.set_color(63)
    print("["..self.scriptName.."] "..printContent)
    console.set_color(15)

    return true
end

-- Loading
local avada_lib = module.lib('avada_lib')
if not avada_lib then
    console.set_color(12)
    print("You need to have Avada Lib in your community_libs folder to run \'Star Alistar\'!")
    print("You can find it here:")
    console.set_color(11)
    print("https://gitlab.soontm.net/get_clear_zip.php?fn=Avada_Lib")
    console.set_color(15)
    return
elseif avada_lib.version < 1 then
    console.set_color(12)
    print("Your need to have Avada Lib updated to run \'Star Alistar\'!")
    print("You can find it here:")
    console.set_color(11)
    print("https://gitlab.soontm.net/get_clear_zip.php?fn=Avada_Lib")
    console.set_color(15)
    return
end

local orb = module.internal("orb")
local gpred = module.internal("pred")
local common = avada_lib.common
local ts = avada_lib.targetSelector
local enemies = common.GetEnemyHeroes()
local allies = common.GetAllyHeroes()

local function LoadScript()
    KoreaKarthus:CreateMenu()
    KoreaKarthus:printConsole("Version "..KoreaKarthus.scriptVersionDisplay.." was loaded!")
end

-- Menu
function print_r ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end


function KoreaKarthus:CreateMenu()
    self.menu = menu(self.scriptId.."Menu", self.scriptName)

    self.menu:header("headTitle", self.scriptName)

    -- Combo setting
    self.menu:menu("combo", "Combo Setting")
        self.menu.combo:header("headW", "W Spell Setting")
        self.menu.combo:boolean("w", "Use W", true)
        self.menu.combo:slider("wMana", "Use W if mane more than (%)", 20, 0, 100, 5)
        self.menu.combo:slider("wDistance", "Use W if enemy farther than", 650, 100, 1000, 50)
        self.menu.combo:header("headE", "E Spell Setting")
        self.menu.combo:boolean("e", "Use Auto E", true)
        self.menu.combo:slider("eMana", "Use E if mane more than (%)", 10, 0, 100, 5)
        self.menu.combo:header("headAA", "AA Control Setting")
        self.menu.combo:dropdown("controlAA", "Control AA Mode", 2, {"Do nothing", "Stop AA", "Stop Q"})
        self.menu.combo:header("headAA1", "Stop AA: Stop AA during Combo mode.")
        self.menu.combo:header("headAA2", "Stop Q: Do not cast Q when doing AA.")

    
    -- Harass Setting
    self.menu:menu("harass", "Harass Setting")
        self.menu.harass:header("headQ", "Q Spell Setting")
        self.menu.harass:boolean("q", "Use Q", true)
        self.menu.harass:header("headE", "E Spell Setting")
        self.menu.harass:boolean("e", "Use Auto E", true)
        self.menu.harass:slider("eMana", "Use E if mane more than (%)", 50, 0, 100, 5)
        self.menu.harass:header("headAA", "AA Control Setting")
        self.menu.harass:dropdown("controlAA", "Control AA Mode", 3, {"Do nothing", "Stop AA", "Stop Q"})
        self.menu.harass:header("headSH", "Smart Harass Setting")
        self.menu.harass:boolean("doOnClear", "Do Harass on Clear Mode", true)
        self.menu.harass:header("headAA1", "AA mode will be 'Stop Q' on Clear")

    -- Clear Setting (WIP)
    self.menu:menu("clear", "Clear Setting (Soon)")

    -- Lasthit Setting (WIP)
    self.menu:menu("lasthit", "Lasthit Setting (Soon)")

    -- Passive Combo Setting
    self.menu:menu("passive", "Passive Combo Setting")
        self.menu.passive:header("headR", "Auto R Setting")
        self.menu.passive:boolean("r", "Use Auto R on Passive", true)
        self.menu.passive:slider("rDamage", "R Damge Multiplier (%)", 120, 80, 150, 5)
        self.menu.passive:header("headR1", "Use R if enemy HP lower then")
        self.menu.passive:header("headR2", "(R Damge * Multiplier) when end.")

    -- Draw Setting
    self.menu:menu("drawing", "Drawing Setting")
        self.menu.drawing:header("drawSpell", "Draw Spell Range")
        self.menu.drawing:boolean("drawQ", "Draw Q Range", true)
        self.menu.drawing:color("drawQColor", "Draw Q Color", 240, 173, 78, 178)
        self.menu.drawing:boolean("drawW", "Draw W Range", false)
        self.menu.drawing:color("drawWColor", "Draw W Color", 240, 173, 78, 127)
        self.menu.drawing:boolean("drawE", "Draw E Range", true)
        self.menu.drawing:color("drawEColor", "Draw E Color", 240, 173, 78, 178)
        self.menu.drawing:header("drawPred", "Pred Drawing")
        self.menu.drawing:boolean("drawPredQ", "Draw Q Prediction Position", true)
        self.menu.drawing:color("drawPredQColor", "Draw Q Pred Pos Color", 255, 255, 255, 255)
        self.menu.drawing:header("drawExtra", "Extra Drawing")
        self.menu.drawing:boolean("drawP", "Draw Passive Time", true)
        self.menu.drawing:boolean("drawR", "Draw Killable Enemy with R", true)
        self.menu.drawing:slider("drawRHide", "Hide R text after (s)", 20, 0, 60, 1)
        self.menu.drawing:header("drawExtraInfo1", "If enemy is not visable during")
        self.menu.drawing:header("drawExtraInfo2", "x sec, hide killable text.")

    -- Msic Setting
    self.menu:menu("msic", "Msic Setting")
        self.menu.msic:header("headQ", "Auto Q Setting (Soon)")
        self.menu.msic:boolean("autoQ", "Use Auto Q", true)
        self.menu.msic:header("headQ2", "If you can hit one enemy only, use Q")
        self.menu.msic:header("headE", "E Setting")
        self.menu.msic:boolean("disableE", "Auto disable E if no enemy", true)
        self.menu.msic:slider("disableEDelay", "Disable E Delay (ms)", 500, 0, 1000, 50)
        self.menu.msic:slider("useERange", "E Hero Detect Range Adjust", 600, 450, 700, 10)
        self.menu.msic:header("headERange", "Larger range will cast E earlier.")
        self.menu.msic:header("headPred", "Pred Setting")
        self.menu.msic:slider("predQDelay", "Pred Q Delay (ms)", 750, 250, 1250, 10)
        self.menu.msic:header("headPred1", "Please adjust pred delay if you")
        self.menu.msic:header("headPred2", "can not hit enemy.")
        self.menu.msic:header("headDebug", "Debug Setting")
        self.menu.msic:boolean("debug", "Enable Debug Mode", false)
    
    -- Target Selector
    ts = ts(self.menu, 1200)
	ts:addToMenu()

    -- Script Information
    self.menu:header("headName", self.scriptName.." by. "..self.scriptDeveloper)
    self.menu:header("headVersion", "Version "..self.scriptVersionDisplay.." released "..self.scriptVersionDate)
    self.menu:header("headLolVersion", "Supported LOL version: "..self.testedLolVersion)

    -- Init Script

    cb.add(cb.tick, function() self:OnTick() end)
    cb.add(cb.draw, function() self:OnDraw() end)
    cb.add(cb.spell, function(spell) self:OnSpell(spell) end)
    cb.add(cb.updatebuff, function(buff) self:OnBuff(buff) end)

    self.wPred = {delay = 0.25, radius = 100, speed = math.huge, boundingRadiusMod = 0, range = 1000}
end

function KoreaKarthus:OnTick()
    -- Tick start
    ts.range = 1200
    self.target = ts.target

    -- Passive Combo First
    if self.pState then
        self:PassiveCombo()
    else
        -- Do other combo
        if orb.combat.is_active() then
            self:Combo()
        elseif orb.menu.hybrid:get() then
            self:Harass()
        elseif orb.menu.lane_clear:get() then
            if self.menu.harass.doOnClear then
                self:Harass()
            end
            self:Clear()
        elseif orb.menu.last_hit:get() then
            self:Lasthit()
        end

        -- Do Extra function
        if self.menu.drawing.drawPredQ:get() then
            if self.target then
                self.predQPosition = gpred.circular.get_prediction(self:GetQPred(), self.target)
            else
                self.predQPosition = nil
            end
        end

        if self.menu.msic.disableE:get() then
            self:AutoDisableE()
        end
    end

    if self.menu.drawing.drawR:get() then
        self:FindKillableR()
    end
end

function KoreaKarthus:Combo()
    -- Control AA
    if self.menu.combo.controlAA:get() == 2 and player.mana > 50 and player:spellSlot(0).level ~= 0 then
        orb.core.set_server_pause_attack()
    end

    -- W Logic first
    if self.menu.combo.w:get() and orb.core.can_action() and self.target then
        if player.pos:dist(self.target.pos) >= self.menu.combo.wDistance:get() then
            self:CastW(self.menu.combo.wMana:get())
        end
    end

    -- Q Logic
    if self.menu.combo.controlAA:get() ~= 3 or (self.menu.combo.controlAA:get() == 3 and orb.core.can_action()) then
        self:CastQ()
    end

    -- E Logic
    if self.menu.combo.e:get() then
        if self:IsEnemyHeroInE() and self:CheckMana(self.menu.combo.eMana:get()) then
            self:EnableE()
        else
            self:DisableE()
        end
    end
end

function KoreaKarthus:Harass()
    -- Control AA
    if self.menu.harass.controlAA:get() == 2 and not orb.menu.lane_clear:get() and player.mana > 50 and player:spellSlot(0).level ~= 0  then
        orb.core.set_server_pause_attack()
    end

    -- No W for Harass. If you need W, just use combo mode.

    -- Q Logic
    if self.menu.harass.controlAA:get() ~= 3 or (self.menu.harass.controlAA:get() == 3 and orb.core.can_action()) then
        self:CastQ()
    end

    -- E Logic
    if self.menu.harass.e:get() then
        if orb.menu.lane_clear:get() then
            if self:IsEnemyHeroInE() and self:CheckMana(self.menu.harass.eMana:get()) then
                self:EnableE()
            elseif not self:IsEnemyInE() then
                self:DisableE()
            end
        else
            if self:IsEnemyHeroInE() and self:CheckMana(self.menu.harass.eMana:get()) then
                self:EnableE()
            else
                self:DisableE()
            end
        end
    end
end

function KoreaKarthus:Clear()
    
end

function KoreaKarthus:Lasthit()
    
end

function KoreaKarthus:PassiveCombo()
    if self.pEndTime < game.time then
        self.pState = false
        return
    end
    
    ts.range = 825
    ts:OnTick()
    self.target = ts.target

    self.pLeftTime = self:Floor(self.pEndTime - game.time)

    -- R Logic
    if player:spellSlot(3).state == 0 and self.pLeftTime <= 4 and self.pLeftTime >= 3 and self.menu.passive.r:get() then
        for i = 1, #enemies do
            local enemy = enemies[i]
            if not enemy.isDead then
                local damage = avada_lib.damageLib.GetSpellDamage(3, enemy, 1, player)

                if common.GetShieldedHealth("AP", enemy) <= damage * (self.menu.passive.rDamage:get() * 0.01) then
                    player:castSpell("self", 3)
                    break
                end
            end
        end
    end

    -- W Logic
    self:CastW(0)

    -- Q Logic
    self:CastQ()
end

function KoreaKarthus:FindKillableR()
    for i = 1, #enemies do
        local enemy = enemies[i]
        if enemy.isVisible then
            local damage = avada_lib.damageLib.GetSpellDamage(3, enemy, 1, player)
            local enemyHP = common.GetShieldedHealth("AP", enemy)
            

            if enemyHP * 0.8 <= damage then

                local infoText = enemy.charName
                local infoDamage = self:Floor((damage / enemyHP) * 100 )
                local infoColor

                if enemyHP * 1.2 <= damage then
                    infoText = infoText.." is perfectly killable."
                    infoColor = graphics.argb(255, 255, 0, 0)
                elseif enemyHP <= damage then
                    infoText = infoText.." is killable."
                    infoColor = graphics.argb(255, 255, 255, 255)
                else
                    infoText = infoText.." will be killable soon."
                    infoColor = graphics.argb(255, 180, 180, 180)
                end

                infoText = infoText.." ("..math.floor(enemyHP).." / "..math.floor(damage)..", "..tostring(infoDamage).."%)"

                self.rSupporterText[i] = {true, infoText, infoColor, game.time}
            else
                self.rSupporterText[i] = {false}
            end
        end

        if enemy.isDead then
            self.rSupporterText[i] = {false}
        end
    end
end

function KoreaKarthus:OnDraw()
    -- Spell Drawing
    if player.isVisible then
        if self.menu.drawing.drawQ:get() then
            graphics.draw_circle(player.pos, 875, 1, self.menu.drawing.drawQColor:get(), 64)
        end
        if self.menu.drawing.drawW:get() then
            graphics.draw_circle(player.pos, 1000, 1, self.menu.drawing.drawWColor:get(), 64)
        end
        if self.menu.drawing.drawE:get() then
            graphics.draw_circle(player.pos, 550, 1, self.menu.drawing.drawEColor:get(), 64)
        end
    end

    -- Pred Drawing
    if self.menu.drawing.drawPredQ:get() then
        if self.predQPosition ~= nil and self.target and self.target.isVisible then
            graphics.draw_circle(vec3(self.predQPosition.endPos.x, game.mousePos.y, self.predQPosition.endPos.y), 200, 1, self.menu.drawing.drawPredQColor:get(), 32)
        end
    end

    -- Extra Drawing
    if self.menu.drawing.drawP:get() and player.isVisible then
        if game.time > self.pStartTime and game.time < self.pEndTime then
            local playerPos = graphics.world_to_screen(player.pos)
            graphics.draw_text_2D(tostring(self.pLeftTime), 20, playerPos.x, playerPos.y, 0xFFffffff)
        end
    end
    if self.menu.drawing.drawR:get() then
        local ii = 0

        for i, info in ipairs(self.rSupporterText) do
            if info[1] == true and (info[4] + self.menu.drawing.drawRHide:get()) > game.time then

                graphics.draw_text_2D(info[2], 20, 200, 100 + (ii * 30), info[3])
                ii = ii + 1
            end
        end
    end

    -- Debug
    if self.menu.msic.debug:get() then
        graphics.draw_text_2D("Now: "..tostring(game.time), 18, 200, 200, 0xFFffffff)
        graphics.draw_text_2D("Core.can_action: "..(orb.core.can_action() and "true" or "false").." Core.can_attack: "..(orb.core.can_attack() and "true" or "false"), 18, 200, 220, 0xFFffffff)
        graphics.draw_text_2D("Core.is_attack_paused: "..(orb.core.is_attack_paused() and "true" or "false"), 18, 200, 240, 0xFFffffff)
        graphics.draw_text_2D("E ON/OFF: "..(self.eState and "true" or "false"), 18, 200, 260, 0xFFffffff)
        graphics.draw_text_2D("Passive: "..(self.pState and "true" or "false").." "..tostring(self.pStartTime).." to "..tostring(self.pEndTime), 18, 200, 280, 0xFFffffff)
        graphics.draw_text_2D("Is Enemy in E: "..(self:IsEnemyHeroInE() and "true" or "false").." Is Minion in E: "..(self:IsEnemyInE() and "true" or "false"), 18, 200, 300, 0xFFffffff)
        graphics.draw_text_2D("E on delay: "..(self.eOnDelay and "true" or "false").." "..tostring(self.eDelayStart).." to "..tostring(self.eDelayEnd), 18, 200, 320, 0xFFffffff)
    end
end

function KoreaKarthus:OnSpell(spell)
    if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ALLY and spell.owner.networkID == player.networkID and spell.startPos:dist(player.pos) then
        if string.lower(spell.name) == "karthusdefile" then
            self.eState = false
        elseif string.lower(spell.name) == "karthusdefilesounddummy2" then
            self.eState = true
        end
    end
end

function KoreaKarthus:OnBuff(buff)
    if buff.owner.type == TYPE_HERO and buff.owner.team == TEAM_ALLY and buff.owner.networkID == player.networkID then
        if string.lower(buff.name) == "karthusdeathdefiedbuff" then
            self.pState = true
            self.pStartTime = game.time
            self.pEndTime = game.time + 7
            self.pLeftTime = 7
        end
    end
end

function KoreaKarthus:GetQPred()
    return {delay = self.menu.msic.predQDelay:get() * 0.001, radius = 200, speed = math.huge, boundingRadiusMod = 0, range = 825}
end

function KoreaKarthus:CastQ()
    if player:spellSlot(0).state == 0 and self.target then
        local predPos = gpred.circular.get_prediction(self:GetQPred(), self.target)
        if predPos and predPos.startPos:dist(predPos.endPos) <= 875 then
            player:castSpell("pos", 0, vec3(predPos.endPos.x, self.target.pos.y, predPos.endPos.y))
        end
	end
end

function KoreaKarthus:CastW(manaPersent)
    if not manaPersent then manaPersent = 0 end
    if player:spellSlot(1).state == 0 and self.target and orb.core.can_action() then
        local predPos = gpred.circular.get_prediction(self.wPred, self.target)
        if self:CheckMana(manaPersent) and predPos and predPos.startPos:dist(predPos.endPos) <= 1000 then
            player:castSpell("pos", 1, vec3(predPos.endPos.x, self.target.pos.y, predPos.endPos.y))
        end
	end
end

function KoreaKarthus:EnableE()
    if self.eOnDelay == true then
        self.eOnDelay = false
    end

    if player:spellSlot(3).state == 0 and self.eState == false then
        player:castSpell("self", 2)
	end
end

function KoreaKarthus:DisableE()
    if player:spellSlot(3).state == 0 and self.eState == true then

        if self.eOnDelay == false then
            self.eOnDelay = true
            self.eDelayStart = game.time
            self.eDelayEnd = game.time + (self.menu.msic.disableEDelay:get() * 0.001)
        else
            if self.eDelayEnd ~= 0 and self.eDelayEnd <= game.time then
                self.eOnDelay = false
                self.eState = false
                player:castSpell("self", 2)
            end
        end
	end
end

function KoreaKarthus:AutoDisableE()
    if not self:IsEnemyHeroInE() and not self:IsEnemyInE() then
        self:DisableE()
    end
end

function KoreaKarthus:IsEnemyInE()
    if #(common.GetMinionsInRange(550, TEAM_ENEMY)) > 0 or #(common.GetMinionsInRange(550, TEAM_NEUTRAL)) > 0 then
        return true
    else
        return false
    end
end

function KoreaKarthus:IsEnemyHeroInE()
    if #(common.GetEnemyHeroesInRange(self.menu.msic.useERange:get())) > 0 then
        return true
    else
        return false
    end
end

function KoreaKarthus:CheckMana(persent)
    return (player.mana / player.maxMana) >= (persent * 0.01)
end

function KoreaKarthus:Floor(number) 
    return math.floor((number) * 100) * 0.01
end

-- Checking Update

-- updated checked

LoadScript()
