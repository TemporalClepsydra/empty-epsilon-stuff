---@diagnostic disable: discard-returns
-- Name: Superweapon
-- Description: Save the galaxy from a Kraylor superweapon!
-- Type: Development
-- Author: Bored Developer
-- Setting[Difficulty]: set the difficulty level
-- Difficulty[easy|Default]: easy level
-- Difficulty[medium]: medium difficulty
-- Difficulty[hard]: hard difficulty
-- Setting[Orbits]: Configures orbit speeds of planets and stations. Further refinement available on GM screen
-- Orbits[Slow|Default]: Slow orbit speeds
-- Orbits[Medium]: Medium speeds
-- Orbits[Fast]: Fast speeds

freighter1 = nil

require("utils.lua")
require("tasks.lua")
-- comment syntax:
-- setup section: [-] setup subsection: [--] mission stage function: [~] Utility function section: [~-]
-- will update later: [~~]
-- setScenario("scenario_97_savegalaxy.lua")
-- 1: start, 2: post briefing/recover intelligence, 3: intelligence recovered, get materials, 4: materials gathered, destroy base
missionStage = "1.0"
orders = ""

kraylorTransports = {}


-- [~-] stage functions

function start_2_2()
    -- [~] start stage 2.2
    string.format("")
    orders = "dock to D077"
    
    freighter1 = CpuShip():setFaction("Independent"):setTemplate("Jump Carrier"):setTypeName("Mk1 Equipment Carrier"):setJumpDrive(false):setWarpDrive(true):setCallSign("D077"):setPosition(52455, -39804):orderRoaming():setRotationMaxSpeed(50)
    freighter1:orderIdle():setCommsFunction(function(comms_source, comms_target)
        if comms_source:isDocked(comms_target) then
            setCommsMessage("Welcome to our ship!")
            addCommsReply("We have someone who would like to go on your ship as an apprentice.",
            function (_comms_source, _comms_target)
                setCommsMessage("Alright, we have taken the person onto our ship. We have some business with the Kraylor, but your apprentice can come along.")
                freighter1:orderDock(supply3)
                missionStage = "2.21"
                orders = "wait for D077"
                addTask(function ()
                    missionStage = "2.23"
                    addTimeTask(start_2_24, getScenarioTime()+10)
                end, function (_time)
                    return freighter1:isDocked(supply3)
                end)
            end)

        else
            setCommsMessage("Dock if you need anything.")
        end
    end)
end

function start_2_24()
    -- [~]
    if not freighter1 then
        freighter1 = CpuShip():setFaction("Independent"):setTemplate("Jump Carrier"):setTypeName("Mk1 Equipment Carrier"):setJumpDrive(false):setWarpDrive(true):setCallSign("D077"):setPosition(52455, -39804):orderRoaming():setRotationMaxSpeed(50)
        freighter1:orderIdle():setCommsFunction(function(comms_source, comms_target)
            if comms_source:isDocked(comms_target) then
                setCommsMessage("Welcome to our ship!")
                addCommsReply("We have someone who would like to go on your ship as an apprentice.",
                function (_comms_source, _comms_target)
                    setCommsMessage("Alright, we have taken the person onto our ship. We have some business with the Kraylor, but your apprentice can come along.")
                    freighter1:orderDock(supply3)
                    missionStage = "2.21"
                    orders = "wait for D077"
                    addTask(function ()
                        missionStage = "2.23"
                        addTimeTask(start_2_24, getScenarioTime()+10)
                    end, function (_time)
                        return freighter1:isDocked(supply3)
                    end)
                end)
    
            else
                setCommsMessage("Dock if you need anything.")
            end
        end)
    end
    string.format("")
    freighter1:orderFlyTowards(61943, -19026)
    freighter1:setCommsFunction(function(comms_source, comms_target)
        if comms_source:isDocked(comms_target) then
            setCommsMessage("Welcome to our ship! The apprentice is not very interested, and wishes to go back to your ship.")
            addCommsReply("Pick up apprentice",
            function (_comms_source, _comms_target)
                setCommsMessage("person has been dropped off on your ship")
             --   freighter1:orderDock(supply3)
                missionStage = "2.25"
                addTask(function ()
                deltaBase:sendCommsMessage(
                    player,
                    string.format(
                        "Incoming encrypted transmission: Due to security reasons, you will need to go to the secret base area 52. It is about %d u away in direction %d. You will have to navigate a minefield, follow the marker buoys.",
                        math.floor(distance(player, area52)),
                        math.floor(angleHeading(player, area52))
                    )
                )
                end,
                function (_)
                    return not player:isDocked(freighter1)
                end

            )
                orders = "Dock to area 52"
            end)
            
        else
            setCommsMessage("Dock if you need anything.")
        end
    end)
end

function start_3()
    -- [~]
    string.format("")
    missionStage = "3.0"
    area52:sendCommsMessage(player, "We have processed the information from the spy. Things are not looking good. The Kraylor have made significant progress on their superweapon. However, we do have hope. The spy has discovered that the Kraylor have to procure some supplies in order to finish building the superweapon,and some Kraylor transports are going to the superweapon. By destroying these transports, you can delay the Kraylor enough that we can find a way to destroy the superweapon. You can exit the maze through the wormhole.")
    orders = "destroy the Kraylor transports"
    WormHole():setPosition(-8992, -107658):setTargetPosition(-3836, -75378)
    for _ = 1, 3, 1 do
        
        local transport = CpuShip():setFaction("Kraylor"):setTemplate("Equipment Freighter 1"):setPosition(supply3:getPosition()):orderDock(galactus)
        table.insert(kraylorTransports, transport)
    end
end

function start_3_1()
    -- [~]
    string.format("")
    if tonumber(missionStage) >= tonumber("3.1") then
        return
    end
    missionStage = "3.1"
    deltaBase:sendCommsMessage(player, "You have succesfully destroyed the transports and delayed the Kraylor. Dock to Delta Base to reload and recover, then dock to jc20.")
    jc20 = CpuShip():setFaction("Human Navy"):setTemplate("Jump Carrier"):setCallSign("JC20"):setPosition(30410, -58847)
    jc20:setCommsFunction(function (comms_source, comms_target)
        if missionStage == "3.1" and comms_source:isDocked(jc20) then
            setCommsMessage("Are you ready?")
            addCommsReply("Yep", function (comms_source_, comms_target_)
                setCommsMessage("hold on tight!")
                missionStage = "3.12"
                jc20:orderFlyTowardsBlind(-359626, 382391)
                addTask(function ()
                    missionStage = "3.13"
                    jc20:sendCommsMessage(player, "Dock to the mining colony, pick up supplies, and then dock to me for a ride home.")
                    colony1:setCommsFunction(function (comms_source, comms_target)
                        setCommsMessage("Wow, you came pretty far. What can I do for you?")
                        addCommsReply("I need some supplies to stop the Kraylor superweapon.", function (comms_source_, comms_target_)
                            setCommsMessage("Alright. Here it is.")
                            missionStage = 3.14
                        end)
                    end)
                    end,
                    function (_)
                    return distance(jc20, -359626, 382391) < 100
                end)
            end)
        elseif missionStage == "3.14" and comms_source:isDocked(jc20) then
            setCommsMessage("Are you ready?")
            addCommsReply("Yep", function (comms_source_, comms_target_)
                setCommsMessage("hold on tight!")
                missionStage = "3.1"
                jc20:orderFlyTowardsBlind(30410, -58847)
        end)
        end
    end)

end

-- [~-] comms functions

function deltaBaseInformation(comms_source, comms_target)
    setCommsMessage("What information do you need?")
    if missionStage == "1.0" then
        addCommsReply("what is the new intelligence?", function (_comms_source, _comms_target)
            setCommsMessage("Recent intelligence data has shown that the Kraylor are developing a new superweapon. However, we do not have very much information. You need to take a spy and dock to freighter D077 and drop it off, and pretend that the person is an apprentice who wants to visit. After the freighter has docked and undocked from the Kraylor base supply 3, Dock with it again and bring the spy back.")
            addCommsReply(_("<- Back"), deltaBaseInformation)
            missionStage = "2.2"
            start_2_2()
        end)
    elseif missionStage == "3.1" then
        addCommsReply("what is the new intelligence?", function (_comms_source, _comms_target)
            setCommsMessage("Recent intelligence data has shown that the Kraylor are developing a new superweapon. However, we do not have very much information. You need to take a spy and dock to freighter D077 and drop it off, and pretend that the person is an apprentice who wants to visit. After the freighter has docked and undocked from the Kraylor base supply 3, Dock with it again and bring the spy back.")
            addCommsReply(_("<- Back"), deltaBaseInformation)
            missionStage = "2.2"
            
        end)
    else
        addCommsReply("What are my current orders?", function (_comms_source, _comms_target)
            setCommsMessage(orders)
            addCommsReply(_("<- Back"), deltaBaseInformation)

        end)
    end

    
    addCommsReply(_("<- Back"), deltaBaseComms)
end

function deltaBaseComms(comms_source, comms_target)
    if comms_source:isDocked(comms_target) then
        setCommsMessage("What do you need?")
        addCommsReply("Mission information needed.", deltaBaseInformation)
        addCommsReply("Please restock missiles.", function (comms_source_, comms_target_)
            string.format("")
            for _, value in ipairs({"Homing", "Nuke", "Mine", "EMP", "HVLI"}) do
                comms_source_:setWeaponStorage(value, comms_source_:getWeaponStorageMax(value))
            end
            setCommsMessage("Missiles restocked.")
            addCommsReply(_("<- Back"), deltaBaseComms)
        end)
    else
        setCommsMessage("For security reasons please dock if you need information.")
    end
end


function area52CommsFunction(comms_source, comms_target) 
    if missionStage == "2.25" and comms_source:isDocked(comms_target) then
        setCommsMessage("Welcome to the top secret base. What do you need?")
        addCommsReply("We were sent here to drop off a spy.", function (comms_source_, comms_target_)
            setCommsMessage("Thank you. We will process the information and contact you shortly.")
            addCommsReply(_("<- Back"), area52CommsFunction)
            missionStage = "2.26"
            addTimeTask(start_3, getScenarioTime() + random(30, 60)) -- [~~]
        end)
    else
        setCommsMessage("Welcome to the top secret base. What do you need?")
            addCommsReply("What are my current orders?", function (comms_source_, comms_target_)
                setCommsMessage(orders)
                addCommsReply(_("<- Back"), area52CommsFunction)
            end)
    end
end

-- [~-] other utilities

stageFunctions = {}
stageFunctions["2.2"] = start_2_2
stageFunctions["2.24"] = start_2_24
stageFunctions["3.0"] = start_3
stageFunctions["3.1"] = start_3_1

function gmFunctionsMain()
    string.format("")
    clearGMFunctions()
    addGMFunction("Check Mission Status", function()
        local tmp = string.format([[stage: %s]], missionStage)
        addGMMessage(tmp)
            end)
    addGMFunction("skip to stage", function ()
        string.format("")
        clearGMFunctions()
        addGMFunction("<- Back", gmFunctionsMain)
        for key, value in pairs(stageFunctions) do
            addGMFunction(key, function ()
                string.format("")
                value()
                gmFunctionsMain()
            end)
        end
    end)
end

settings = {
    orbitspeed=100,
}
function setVariations()
    orbitSpeedSettings = {Slow=100, Medium=80, Fast=60}
    if getScenarioSetting("Orbits") then
        settings["orbitspeed"] = orbitSpeedSettings[getScenarioSetting("Orbits")]
    end
end

function init()
    -- human navy stuff [-]
    gmFunctionsMain()
    deltaBase = SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setCallSign("Delta Base"):setPosition(41922, -75926)
    deltaBase:setCommsFunction(deltaBaseComms)
    player = PlayerSpaceship():setTemplate("Atlantis"):setPosition(-323, 16082):setWarpDrive(true):setMaxEnergy(2000)
    -- making ship fast during the development period [~~]
    player:setImpulseMaxSpeed(250, 250):setRotationMaxSpeed(40):setAcceleration(50, 50):setAutoCoolant(true):commandSetAutoRepair(true):setRepairCrewCount(10)

    area52 = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("Area 52"):setPosition(-6603, -109989)
    area52:setCommsFunction(area52CommsFunction)

    -- natural stuff [-]
    star=Planet():setPosition(0, 0):setPlanetAtmosphereTexture("Atmosphere.png"):setPlanetAtmosphereColor(200, 0, 0):setCallSign("Rigel")
    planet1 = Planet():setPosition(0, 30000):setPlanetAtmosphereColor(200, 4, 4):setPlanetAtmosphereTexture("Atmosphere.png"):setPlanetSurfaceTexture("planet-3.png"):setPlanetCloudTexture("clouds-3.png"):setOrbit(
        star, settings["orbitspeed"]/10):setCallSign("Rigel A")

    -- Galactus nebula field [--]
    Nebula():setPosition(100488, -29667)
    Nebula():setPosition(152720, -26197)
    Nebula():setPosition(146511, -25466)
    Nebula():setPosition(162765, -14326)
    Nebula():setPosition(165687, -19439)
    Nebula():setPosition(166052, -26197)
    Nebula():setPosition(172444, 102)
    Nebula():setPosition(164409, -5742)
    Nebula():setPosition(176097, -14143)
    Nebula():setPosition(185594, -2455)
    Nebula():setPosition(150894, -19805)
    Nebula():setPosition(163496, -1359)
    Nebula():setPosition(147607, -19805)
    Nebula():setPosition(141763, -28571)
    Nebula():setPosition(137197, -24005)
    Nebula():setPosition(125509, -17248)
    Nebula():setPosition(157651, -3551)
    Nebula():setPosition(145780, -12865)
    Nebula():setPosition(135188, -24553)
    Nebula():setPosition(135736, -18526)
    Nebula():setPosition(129892, -3185)
    Nebula():setPosition(147789, -11221)
    Nebula():setPosition(126239, -32954)
    Nebula():setPosition(131718, -38615)
    Nebula():setPosition(121308, -11221)
    Nebula():setPosition(137562, -36607)
    Nebula():setPosition(136832, -40442)
    Nebula():setPosition(132814, -40259)
    Nebula():setPosition(134457, -28754)
    Nebula():setPosition(137014, -12500)
    Nebula():setPosition(161121, -36789)
    Nebula():setPosition(161852, -22179)
    Nebula():setPosition(148155, -26745)
    Nebula():setPosition(148703, -4646)
    Nebula():setPosition(171714, -2455)
    Nebula():setPosition(151625, -48660)
    Nebula():setPosition(146694, -40807)
    Nebula():setPosition(161852, -68567)
    Nebula():setPosition(184681, -71854)
    Nebula():setPosition(184133, -59435)
    Nebula():setPosition(177375, -22179)
    Nebula():setPosition(161121, -38433)
    Nebula():setPosition(176280, -32406)
    Nebula():setPosition(155825, 9781)
    Nebula():setPosition(184315, -11404)
    Nebula():setPosition(93548, -52861)
    Nebula():setPosition(71268, -64731)
    Nebula():setPosition(69441, -81168)
    Nebula():setPosition(142676, 10329)
    Nebula():setPosition(172262, 11608)
    Nebula():setPosition(182854, -46834)
    Nebula():setPosition(193081, -49391)
    Nebula():setPosition(206779, 19278)
    Nebula():setPosition(204039, -5194)
    Nebula():setPosition(202578, -11586)
    Nebula():setPosition(202213, -33867)
    Nebula():setPosition(195273, -13778)
    Nebula():setPosition(198926, -7751)
    Nebula():setPosition(232164, -13595)
    Nebula():setPosition(217736, -26562)
    Nebula():setPosition(210614, -68384)
    Nebula():setPosition(210979, -53956)
    Nebula():setPosition(227416, -40807)
    Nebula():setPosition(152903, -52495)
    Nebula():setPosition(178654, -39711)
    Nebula():setPosition(176280, -44642)


    -- area 52 maze [--]
    Nebula():setPosition(2504, -115035)
    Nebula():setPosition(-3261, -117159)
    Nebula():setPosition(-9581, -118170)
    Nebula():setPosition(-16863, -112760)
    Nebula():setPosition(-16458, -120496)
    Nebula():setPosition(-5991, -123277)
    Nebula():setPosition(3262, -108411)
    Nebula():setPosition(-3463, -109877)
    Nebula():setPosition(-9632, -111597)
    Nebula():setPosition(-14436, -104770)
    Nebula():setPosition(-7559, -102748)
    Nebula():setPosition(-479, -101281)
    Nebula():setPosition(7864, -101534)
    Nebula():setPosition(10999, -107956)
    Nebula():setPosition(10038, -114984)
    Nebula():setPosition(-22880, -106945)
    Nebula():setPosition(-22930, -116046)
    Nebula():setPosition(-20453, -98905)
    Nebula():setPosition(-11806, -94152)
    Nebula():setPosition(-13525, -98804)
    Nebula():setPosition(-3615, -93798)
    Nebula():setPosition(3768, -93848)
    Nebula():setPosition(12819, -93798)
    Nebula():setPosition(15904, -101231)
    Nebula():setPosition(19544, -108310)
    Nebula():setPosition(18786, -115136)
    Nebula():setPosition(-631, -123328)
    Nebula():setPosition(6195, -121052)
    Nebula():setPosition(14437, -121052)
    Nebula():setPosition(21264, -121457)
    Nebula():setPosition(18129, -127575)
    Nebula():setPosition(9583, -128081)
    Nebula():setPosition(3161, -129547)
    Nebula():setPosition(-3564, -129749)
    Nebula():setPosition(-11806, -126159)
    Nebula():setPosition(-19593, -127777)
    Nebula():setPosition(-23689, -122418)
    Nebula():setPosition(-9834, -134857)
    Nebula():setPosition(785, -134806)
    Nebula():setPosition(-28290, -111597)
    Nebula():setPosition(-30262, -118221)
    Nebula():setPosition(-29504, -125249)
    Mine():setPosition(8117, -123429)
    Mine():setPosition(8117, -122064)
    Mine():setPosition(8015, -120648)
    Mine():setPosition(7813, -119131)
    Mine():setPosition(7864, -118018)
    Mine():setPosition(7864, -117412)
    Mine():setPosition(7884, -119739)
    Mine():setPosition(8177, -121345)
    Mine():setPosition(8080, -122756)
    Mine():setPosition(7982, -116330)
    Mine():setPosition(7884, -115370)
    Mine():setPosition(8021, -114391)
    Mine():setPosition(7982, -113529)
    Mine():setPosition(7942, -112647)
    Mine():setPosition(7766, -111197)
    Mine():setPosition(7805, -111981)
    Mine():setPosition(7844, -110277)
    Mine():setPosition(7825, -109317)
    Mine():setPosition(7825, -108220)
    Mine():setPosition(7864, -107299)
    Mine():setPosition(7864, -106300)
    Mine():setPosition(8001, -105164)
    Mine():setPosition(3887, -104635)
    Mine():setPosition(2869, -104576)
    Mine():setPosition(1889, -104478)
    Mine():setPosition(655, -104360)
    Mine():setPosition(-266, -104537)
    Mine():setPosition(-1010, -104282)
    Mine():setPosition(-1853, -104263)
    Mine():setPosition(-2715, -104184)
    Mine():setPosition(-3616, -104165)
    Mine():setPosition(-4438, -104204)
    Mine():setPosition(-5398, -104282)
    Mine():setPosition(-6280, -104263)
    Mine():setPosition(-7162, -104204)
    Mine():setPosition(-8102, -104165)
    Mine():setPosition(-8846, -104223)
    Mine():setPosition(-9610, -104184)
    Mine():setPosition(-10335, -104125)
    Mine():setPosition(-11197, -104106)
    Mine():setPosition(-11941, -104223)
    Mine():setPosition(-12705, -104478)
    Mine():setPosition(-12686, -105164)
    Mine():setPosition(-12764, -105791)
    Mine():setPosition(-13039, -106555)
    Mine():setPosition(-13058, -107260)
    Mine():setPosition(-13058, -108063)
    Mine():setPosition(-12921, -108925)
    Mine():setPosition(-12980, -109787)
    Mine():setPosition(-12823, -110590)
    Mine():setPosition(-12803, -111530)
    Mine():setPosition(-12882, -112412)
    Mine():setPosition(-12882, -113235)
    Mine():setPosition(-12882, -113940)
    Mine():setPosition(-12862, -114704)
    Mine():setPosition(-12803, -115625)
    Mine():setPosition(-12745, -116448)
    Mine():setPosition(-12686, -117231)
    Mine():setPosition(-12705, -117858)
    Mine():setPosition(-12764, -118720)
    Mine():setPosition(-12882, -119582)
    Mine():setPosition(-12823, -120503)
    Mine():setPosition(-12745, -121580)
    Mine():setPosition(-12627, -122383)
    Mine():setPosition(-12549, -123186)
    Mine():setPosition(-11981, -123206)
    Mine():setPosition(-11256, -123167)
    Mine():setPosition(-10531, -123147)
    Mine():setPosition(-9885, -123186)
    Mine():setPosition(-9081, -123226)
    Mine():setPosition(-8200, -123128)
    Mine():setPosition(-7318, -123128)
    Mine():setPosition(-6417, -123206)
    Mine():setPosition(-5496, -123069)
    Mine():setPosition(-4576, -122932)
    Mine():setPosition(-3733, -122951)
    Mine():setPosition(-2734, -122951)
    Mine():setPosition(-1872, -123010)
    Mine():setPosition(-1147, -122932)
    Mine():setPosition(-481, -122873)
    Mine():setPosition(381, -122834)
    Mine():setPosition(1262, -122736)
    Mine():setPosition(2222, -122756)
    Mine():setPosition(3123, -122971)
    Mine():setPosition(3711, -123010)
    Mine():setPosition(4475, -123049)
    Mine():setPosition(5200, -123108)
    Mine():setPosition(5885, -123167)
    Mine():setPosition(6649, -123108)
    Mine():setPosition(7355, -123245)
    Mine():setPosition(3750, -105281)
    Mine():setPosition(3750, -106143)
    Mine():setPosition(3456, -106868)
    Mine():setPosition(3280, -107612)
    Mine():setPosition(3104, -108514)
    Mine():setPosition(3182, -109238)
    Mine():setPosition(3123, -110042)
    Mine():setPosition(2967, -110923)
    Mine():setPosition(2869, -111824)
    Mine():setPosition(2771, -112667)
    Mine():setPosition(2653, -113548)
    Mine():setPosition(2692, -114391)
    Mine():setPosition(2692, -115194)
    Mine():setPosition(2575, -116173)
    Mine():setPosition(2477, -117016)
    Mine():setPosition(2300, -117917)
    Mine():setPosition(1439, -117936)
    Mine():setPosition(655, -117878)
    Mine():setPosition(106, -117799)
    Mine():setPosition(-697, -117603)
    Mine():setPosition(-1598, -117740)
    Mine():setPosition(-2362, -117760)
    Mine():setPosition(-3283, -117760)
    Mine():setPosition(-4419, -117838)
    Mine():setPosition(-5457, -117740)
    Mine():setPosition(-6476, -117740)
    Mine():setPosition(-7397, -117740)
    Mine():setPosition(-8317, -117838)
    Mine():setPosition(-12549, -113294)
    Mine():setPosition(-11569, -113411)
    Mine():setPosition(-10668, -113391)
    Mine():setPosition(-9708, -113372)
    Mine():setPosition(-9042, -113391)
    Mine():setPosition(-8396, -113411)
    Mine():setPosition(-7690, -113411)
    Mine():setPosition(-6887, -113333)
    Mine():setPosition(-6084, -113411)
    Mine():setPosition(-5477, -113411)
    Mine():setPosition(-4811, -113215)
    Mine():setPosition(-4145, -113294)
    Mine():setPosition(-3302, -113137)
    Mine():setPosition(-2264, -113019)
    Mine():setPosition(-2225, -112079)
    Mine():setPosition(-2127, -111393)
    Mine():setPosition(-2029, -110492)
    Mine():setPosition(-2127, -109826)
    Mine():setPosition(-2166, -108984)
    Mine():setPosition(-2049, -108102)
    Mine():setPosition(-2852, -107926)
    Mine():setPosition(-3674, -107710)
    Artifact():setPosition(7565, -99035):setModel("artifact4")
    Artifact():setPosition(8669, -97989):setModel("artifact3")
    Artifact():setPosition(9696, -96924):setModel("artifact2")
    Artifact():setPosition(10837, -96049):setModel("artifact6")
    Artifact():setPosition(11769, -95041):setModel("artifact8")
    Artifact():setPosition(4541, -103220):setModel("artifact5")
    Artifact():setPosition(5112, -102421):setModel("artifact4")
    Artifact():setPosition(5930, -101337):setModel("artifact5")
    Artifact():setPosition(6690, -100177):setModel("artifact8")
    Artifact():setPosition(12245, -100957):setModel("artifact3")
    Artifact():setPosition(10628, -102003):setModel("artifact6")
    Artifact():setPosition(9220, -102973):setModel("artifact6")
    Artifact():setPosition(17513, -96677):setModel("artifact4")
    Artifact():setPosition(19225, -95174):setModel("artifact4")
    Artifact():setPosition(15060, -92321):setModel("artifact6")
    Artifact():setPosition(16486, -91446):setModel("artifact7")
    Artifact():setPosition(17837, -90837):setModel("artifact7")
    Artifact():setPosition(16334, -97723):setModel("artifact1")
    Artifact():setPosition(15459, -98427):setModel("artifact2")
    Artifact():setPosition(14546, -99245):setModel("artifact7")
    Artifact():setPosition(13576, -100005):setModel("artifact6")
    Artifact():setPosition(12834, -93900):setModel("artifact1")
    Artifact():setPosition(13995, -92911):setModel("artifact8")
    Artifact():setPosition(8326, -104152):setModel("artifact1")

    -- mining base [--]
    Balthas1=Planet():setPosition(-373111, 391249):setPlanetRadius(5000):setPlanetCloudRadius(5200.00):setCallSign("Balthas 1")
    colony1 = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Balthas 1 mining colony")
    setCirclePos(colony1, -373111, 391249, 0, 10000)
    colony1:setCommsFunction(function (comms_source, comms_target)
        setCommsMessage("how did you get here?")
    end)



    -- Kraylor stuff [-]
    galactus = SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setCallSign("Galactus 9"):setPosition(189591, -31968):setTypeName("Galactus")
    supply3 = SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setCallSign("Supply 3"):setPosition(82773, 14530)


    -- begin mission [-]
    deltaBase:sendCommsMessage(player, "ATTENTION ALL SHIPS STOP NEW GALACTIC THREAT DISCOVERED STOP DOCK TO DELTA BASE IN B7 AT ONCE STOP")

end

function update()
    time = getScenarioTime()
    stepTimeTasks(time)
    stepTasks(time)
    setCirclePos(colony1, -373111, 391249, math.sin(time/settings["orbitspeed"])*360, 10000)
    if missionStage == "3.0" then
        local count_of_docked = 0
        for _,ship in ipairs(kraylorTransports) do
          if ship:isValid() then
            if ship:isDocked(galactus) then
              count_of_docked = count_of_docked + 1
            end
          else
            start_3_1()
            --this is where you add code for the next stage
          end
        end
        if count_of_docked == 3 then
          globalMessage("The Kraylor completed the superweapon")
          victory("Kraylor")
        end
      end
end