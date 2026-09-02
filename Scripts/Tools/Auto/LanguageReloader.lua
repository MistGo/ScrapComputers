dofile("$CONTENT_632be32f-6ebd-414e-a061-d45906ae4dc6/Scripts/Config.lua")

---@class LanguageReloaderClass : ToolClass
LanguageReloaderClass = class()

function LanguageReloaderClass:client_onCreate()
end

function LanguageReloaderClass:client_onFixedUpdate()
    if sm.game.getCurrentTick() % 40 ~= 0 then return end

    local config = sm.scrapcomputers.config.getConfig("scrapcomputers.global.automaticLanguageReloading")
    if config.selectedOption ~= 2 then return end

    sm.scrapcomputers.languageManager.reloadLanguages()
end

function LanguageReloaderClass:client_onRefresh()
    self:client_onCreate()
end