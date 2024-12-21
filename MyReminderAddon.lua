--[[ 
Add this to your .toc file:
## SavedVariables: MyReminderDB

Ulgrax the Devourer	2902
The Bloodbound Horror	2917
Sikran, Captain of the Sureki	2898
Rasha'nan	2918
Nexus-Princess Ky'veza	2920
Broodtwister Ovi'nax	2919
The Silken Court	2921
Queen Ansurek	2922

reset on wipe
tank buster timings
]]

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("ENCOUNTER_START")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MyReminderAddon" then
            if not MyReminderDB then
                MyReminderDB = {
                    encounterReminders = {}
                }
            end
        end
    elseif event == "ENCOUNTER_START" then
        local encounterID, encounterName, difficultyID, groupSize = ...
        -- Check if we have a reminder stored for this encounter
        if MyReminderDB 
           and MyReminderDB.encounterReminders 
           and MyReminderDB.encounterReminders[encounterID] then

            -- Trigger each reminder for this encounter
            for _, reminder in ipairs(MyReminderDB.encounterReminders[encounterID]) do
            local delay = reminder.delay
            local message = reminder.message
            C_Timer.After(delay, function()
                -- Reminder action
                -- PlaySound(416, "Master")
                -- /run C_TTSSettings.SetSpeechVolume(200)
                -- /run C_VoiceChat.SpeakText(1, "boss boss bawse baaasss", Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
                C_VoiceChat.SpeakText(1, message, Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
                print("Encounter Reminder (" .. encounterID .. "): " .. message)
            end)
            end
        end
    end
end)

SLASH_REMINDME1 = "/remindme"
SlashCmdList["REMINDME"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word)
    end

    local function printUsage()
        print("Usage:")
        print("/remindme <seconds> <message>")
        print("/remindme <encounterID> <seconds> <message>")
        print("Additional commands:")
        print("/remindme list")
        print("/remindme remove all")
        print("/remindme remove <encounterID>")
        print("/remindme remove <encounterID> <index>")
    end

    if #args == 0 then
        printUsage()
        return
    end

        local cmd = args[1]:lower()

    -- Handle list command
        if cmd == "list" then
            if not MyReminderDB or not MyReminderDB.encounterReminders or next(MyReminderDB.encounterReminders) == nil then
                print("No saved encounter reminders.")
                return
            end

            print("Saved Encounter Reminders:")
        for eID, reminders in pairs(MyReminderDB.encounterReminders) do
            print("EncounterID:", eID)
            for i, data in ipairs(reminders) do
                print("  ["..i.."] Delay:", data.delay, "Message:", data.message)
            end
            end
            return
    end

    -- Handle remove command
    if cmd == "remove" then
            if #args < 2 then
                print("Usage: /remindme remove <encounterID>")
                print("       /remindme remove all")
            print("       /remindme remove <encounterID> <index>")
                return
            end

            local removeTarget = args[2]:lower()

            if removeTarget == "all" then
                -- Remove all reminders
                MyReminderDB.encounterReminders = {}
                print("All encounter reminders have been removed.")
            return
        end

                local removeID = tonumber(removeTarget)
        if not removeID then
            print("Invalid encounterID.")
            return
        end

        -- If there's a third argument, it might be the index
        if #args > 2 then
            local removeIndex = tonumber(args[3])
            if removeIndex then
                -- remove a specific reminder from the encounter
                if MyReminderDB.encounterReminders[removeID] and MyReminderDB.encounterReminders[removeID][removeIndex] then
                    table.remove(MyReminderDB.encounterReminders[removeID], removeIndex)
                    if #MyReminderDB.encounterReminders[removeID] == 0 then
                MyReminderDB.encounterReminders[removeID] = nil
                    end
                    print("Removed reminder index " .. removeIndex .. " from encounterID " .. removeID)
            else
                    print("No reminder found at that index for encounterID " .. removeID)
                end
            return
        end
    end

        -- remove all reminders for a specific encounter if no index is given
        if MyReminderDB.encounterReminders[removeID] then
            MyReminderDB.encounterReminders[removeID] = nil
            print("Removed all reminders for encounterID " .. removeID)
        else
            print("No reminders found for encounterID " .. removeID)
        end
        return
    end

    -- If we're here, the user is setting a reminder
    -- check arguments for setting reminders:
    if #args < 2 then
        printUsage()
        return
    end

    local firstNumber = tonumber(args[1])
    if not firstNumber then
        print("First argument must be a number (seconds or encounterID).")
        return
    end

    local encounterID, delay, message

    -- Determine format
    if #args > 2 then
        local secondNumber = tonumber(args[2])
        if secondNumber then
            -- Format: /remindme <encounterID> <seconds> <message>
            encounterID = firstNumber
            delay = secondNumber
            message = table.concat(args, " ", 3)
        else
            -- Format: /remindme <seconds> <message>
            encounterID = nil
            delay = firstNumber
            message = table.concat(args, " ", 2)
        end
    else
        -- Only two args, must be seconds and message
        encounterID = nil
        delay = firstNumber
        message = args[2]
    end

    if not delay or not tonumber(delay) then
        print("Invalid seconds.")
        return
    end

    if encounterID then
        -- Append the encounter reminder permanently
        MyReminderDB.encounterReminders[encounterID] = MyReminderDB.encounterReminders[encounterID] or {}
        table.insert(MyReminderDB.encounterReminders[encounterID], { delay = delay, message = message })
        print("Added permanent reminder for encounter " .. encounterID .. ": " .. delay .. " seconds after start: " .. message)
    else
        -- Immediate timer (not saved)
        C_Timer.After(delay, function()
            -- PlaySound(416, "Master")
            C_VoiceChat.SpeakText(1, message, Enum.VoiceTtsDestination.LocalPlayback, 1, 100)
            print("Reminder: " .. message)
        end)
        print("Reminder set for " .. delay .. " seconds: " .. message)
    end
end
