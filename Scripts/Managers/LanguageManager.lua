sm.scrapcomputers.languageManager = sm.scrapcomputers.languageManager or {
    currentLanguage = "",
    languageReloadPaths = {}
}

sm.scrapcomputers.languageManager.languages = {}
sm.scrapcomputers.languageManager.currentLanguage = sm.scrapcomputers.languageManager.currentLanguage or ""
sm.scrapcomputers.languageManager.lastLanguageUpdate = sm.game.getCurrentTick()

local function findPath(localid, name)
    local filePath = "$CONTENT_" .. localid .. "/Gui/Language/" .. name .. "/scrapcomputers"
    local extentionsToCheck = {".json", ".jsonc", ".txt"}

    for _, extension in pairs(extentionsToCheck) do
        local fullPath = filePath .. extension
        if sm.json.fileExists(fullPath) then
            return fullPath
        end
    end
    
    return nil
end

-- Gets all loaded languages and returns them
function sm.scrapcomputers.languageManager.getLanguages()
    return sm.scrapcomputers.languageManager.languages
end

-- Gets the total loaded languages and returns the amount
---@return integer totalLanguages The total amount of loaded languages
function sm.scrapcomputers.languageManager.getTotalLanguages()
    return #sm.scrapcomputers.languageManager.languages
end

-- Reloads all languages
function sm.scrapcomputers.languageManager.reloadLanguages()
    sm.scrapcomputers.languageManager.languages = {}

    local config = sm.scrapcomputers.config.getConfig("scrapcomputers.global.selectedLanguage")
    config.options = {"Automatic"}
    
    for _, language in pairs(sm.scrapcomputers.languageManager.languageReloadPaths) do
        local path = findPath(language[1], language[2])
        if not path then
            sm.scrapcomputers.logger.warn("LanguageManager.lua", "Cannot find a language!")
            goto continue
        end

        local success, data = pcall(sm.json.open, path)
        if not success then
            sm.scrapcomputers.logger.error("LanguageManager.lua", data)
            goto continue
        end

        sm.scrapcomputers.languageManager.languages[language[2]] = data
        
        table.insert(config.options, language[2])
        ::continue::
    end
end

-- Adds a language to the language manager
---@param localid string The local id of your mod/addon
---@param name string The name of the language
---@return boolean success If it succeeded adding the language
function sm.scrapcomputers.languageManager.addLanguage(localid, name)
    sm.scrapcomputers.errorHandler.assertArgument(localid, 1, {"string"})
    sm.scrapcomputers.errorHandler.assertArgument(name, 2, {"string"})
    
    local path = findPath(localid, name)
    sm.scrapcomputers.errorHandler.assert(path ~= nil, nil, "Local id \"%s\" with Language Name \"%s\" was NOT found!", localid, name)

    table.insert(sm.scrapcomputers.languageManager.languageReloadPaths, {localid, name})

    local success, data = pcall(sm.json.open, path)
    if not success then
        sm.scrapcomputers.logger.error("LanguageManager.lua", data)
        return false
    end

    sm.scrapcomputers.languageManager.languages[name] = data
    return true
end

-- Automatically detects a language. If there is no translation for it, it defaults to English.
function sm.scrapcomputers.languageManager.autoDetectLanguage()
    local selectedLanguage = sm.gui.getCurrentLanguage()
    sm.scrapcomputers.languageManager.currentLanguage = sm.scrapcomputers.languageManager.languages[selectedLanguage] and selectedLanguage or "English"
end

-- Sets the selected language to whatever you specify. Will error if it can't find one.
---@param language string The language to select
function sm.scrapcomputers.languageManager.setSelectedLanguage(language)
    sm.scrapcomputers.errorHandler.assertArgument(language, 1, {"string"})
    sm.scrapcomputers.errorHandler.assert(sm.scrapcomputers.languageManager.languages[language], nil, "Language Not Found!")

    sm.scrapcomputers.languageManager.currentLanguage = language
    sm.scrapcomputers.languageManager.lastLanguageUpdate = sm.game.getCurrentTick()
end

-- Gets the current selected language.
---@return string language The selected language
function sm.scrapcomputers.languageManager.getSelectedLanguage()
    local config = sm.scrapcomputers.config.getConfig("scrapcomputers.global.selectedLanguage")
    local data = config.options[config.selectedOption]

    if data == nil then
        return "English"
    end

    if config.selectedOption == 1 then
        sm.scrapcomputers.languageManager.autoDetectLanguage()
        return sm.scrapcomputers.languageManager.currentLanguage
    end

    if sm.scrapcomputers.languageManager.currentLanguage ~= data then
        sm.scrapcomputers.languageManager.currentLanguage = data
    end

    return sm.scrapcomputers.languageManager.currentLanguage
end

--- Translates the given text to the currently selected language, with optional string formatting.
--- This function looks up the text in the selected language's data and formats it with any provided arguments.
---
--- @param text string The key or text to translate.
--- @param ... any Optional arguments to format the translated text using string formatting.
--- @return string translatedText The translated and formatted text if available, otherwise returns the input text.
function sm.scrapcomputers.languageManager.translatable(text, ...)
    sm.scrapcomputers.errorHandler.assertArgument(text, 1, {"string"})

    local data = sm.scrapcomputers.languageManager.languages[sm.scrapcomputers.languageManager.getSelectedLanguage()]
    if not data then
        return text
    end

    local value = data[text]
    if not value then
        return text
    end
    
    if select("#", ...) > 0 then
        return string.format(value, ...)
    end

    return value
end

sm.scrapcomputers.languageManager.addLanguage("632be32f-6ebd-414e-a061-d45906ae4dc6", "English")

sm.scrapcomputers.languageManager.autoDetectLanguage()
