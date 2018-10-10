local Type, Version = "MethodDungeonToolsPullButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

local width,height = 248,32
local maxPortraitCount = 7
local tinsert,SetPortraitToTexture,SetPortraitTextureFromCreatureDisplayID,GetItemQualityColor,MouseIsOver = table.insert,SetPortraitToTexture,SetPortraitTextureFromCreatureDisplayID,GetItemQualityColor,MouseIsOver

local function GetDropTarget()
    return 2
end

--Methods
local methods = {
    ["OnAcquire"] = function(self)
        self:SetWidth(width);
        self:SetHeight(height);
    end,
    ["Initialize"] = function(self)
        self.callbacks = {}

        function self.callbacks.OnClickNormal(_, mouseButton)
            if not MouseIsOver(MethodDungeonTools.main_frame.sidePanel.pullButtonsScrollFrame.frame) then return end
            if(IsControlKeyDown())then

            elseif(IsShiftKeyDown()) then

            else
                MethodDungeonTools:EnsureDBTables()
                if(mouseButton == "RightButton") then
                    MethodDungeonTools:SetMapSublevel(self.index)
                    MethodDungeonTools:SetSelectionToPull(self.index)
                    L_EasyMenu(self.menu,MethodDungeonTools.main_frame.sidePanel.optionsDropDown, "cursor", 0 , -15, "MENU")
                else
                    --normal click
                    MethodDungeonTools:SetMapSublevel(self.index)
                    MethodDungeonTools:SetSelectionToPull(self.index)
                end
            end
        end

        function self.callbacks.OnEnter()
            MethodDungeonTools.pullTooltip:SetPoint("TOPRIGHT",self.frame,"TOPLEFT",0,0)
            MethodDungeonTools.pullTooltip:SetPoint("BOTTOMRIGHT",self.frame,"TOPLEFT",-250,-(4+MethodDungeonTools.pullTooltip.myHeight))
            local tooltipBottom = MethodDungeonTools.pullTooltip:GetBottom()
            local mainFrameBottom = MethodDungeonTools.main_frame:GetBottom()
            if tooltipBottom<mainFrameBottom then
                MethodDungeonTools.pullTooltip:SetPoint("TOPRIGHT",self.frame,"BOTTOMLEFT",0,(4+MethodDungeonTools.pullTooltip.myHeight))
                MethodDungeonTools.pullTooltip:SetPoint("BOTTOMRIGHT",self.frame,"BOTTOMLEFT",-250,-4)
            end
            MethodDungeonTools:ActivatePullTooltip(self.index)
            self.frame:SetScript("OnUpdate", function()
                MethodDungeonTools:UpdatePullTooltip(MethodDungeonTools.pullTooltip)
            end)
            --progressbar
            if MethodDungeonTools.ProgressBarResetTimer then MethodDungeonTools.ProgressBarResetTimer:Cancel() end
            local currentForces = MethodDungeonTools:CountForces(self.index)
            local db = MethodDungeonTools:GetDB()
            local teeming = MethodDungeonTools:IsCurrentPresetTeeming()
            MethodDungeonTools:Progressbar_SetValue(MethodDungeonTools.main_frame.sidePanel.ProgressBar,currentForces,teeming and MethodDungeonTools.dungeonTotalCount[db.currentDungeonIdx].teeming or MethodDungeonTools.dungeonTotalCount[db.currentDungeonIdx].normal)
        end

        function self.callbacks.OnLeave()
            MethodDungeonTools.pullTooltip.Model:Hide()
            MethodDungeonTools.pullTooltip.topString:Hide()
            self.frame:SetScript("OnUpdate", nil)
            MethodDungeonTools:UpdatePullTooltip(MethodDungeonTools.pullTooltip)
            MethodDungeonTools.pullTooltip:Hide()
            MethodDungeonTools.ProgressBarResetTimer = C_Timer.NewTimer(0.35, function()
                MethodDungeonTools:UpdateProgressbar()
            end)
        end

        function self.callbacks.OnDragStart()
            print("Drag started")
            self:Drag()
        end

        function self.callbacks.OnDragStop()
            print("Drag stopped")
            self:Drop()
        end

        function self.callbacks.OnKeyDown(self, key)
            if (key == "ESCAPE") then
                --
            end
        end


        self.menu = {}
        if self.index ~= 1 then
            tinsert(self.menu, {
                text = "Move up",
                notCheckable = 1,
                func = function() MethodDungeonTools:MovePullUp(self.index) end
            })
        end
        if self.index<self.maxPulls then
            tinsert(self.menu, {
                text = "Move down",
                notCheckable = 1,
                func = function() MethodDungeonTools:MovePullDown(self.index) end
            })
        end
        if self.index ~= 1 or self.index < self.maxPulls then
            tinsert(self.menu, {
                text = " ",
                notClickable = 1,
                notCheckable = 1,
                func = nil
            })
        end
        tinsert(self.menu, {
            text = "Insert before",
            notCheckable = 1,
            func = function()
                MethodDungeonTools:PresetsAddPull(self.index)
                MethodDungeonTools:ReloadPullButtons()
                MethodDungeonTools:SetSelectionToPull(self.index)
            end
        })

        tinsert(self.menu, {
            text = "Insert after",
            notCheckable = 1,
            func = function()
                MethodDungeonTools:PresetsAddPull(self.index + 1)
                MethodDungeonTools:ReloadPullButtons()
                MethodDungeonTools:SetSelectionToPull(self.index + 1)
            end
        })
        tinsert(self.menu, {
            text = " ",
            notClickable = 1,
            notCheckable = 1,
            func = nil
        })
        if self.index ~= 1 then
            tinsert(self.menu, {
                text = "Merge up",
                notCheckable = 1,
                func = function()
                    local newIndex = MethodDungeonTools:PresetsMergePulls(self.index, self.index - 1)
                    MethodDungeonTools:ReloadPullButtons()
                    MethodDungeonTools:SetSelectionToPull(newIndex)
                end
            })
        end
        if self.index < self.maxPulls then
            tinsert(self.menu, {
                text = "Merge down",
                notCheckable = 1,
                func = function()
                    local newIndex = MethodDungeonTools:PresetsMergePulls(self.index, self.index + 1)
                    MethodDungeonTools:ReloadPullButtons()
                    MethodDungeonTools:SetSelectionToPull(newIndex)
                end
            })
        end
        if self.index ~= 1 or self.index < self.maxPulls then
            tinsert(self.menu, {
                text = " ",
                notClickable = 1,
                notCheckable = 1,
                func = nil
            })
        end
        tinsert(self.menu, {
            text = "Clear",
            notCheckable = 1,
            func = function() MethodDungeonTools:ClearPull(self.index) end
        })
        tinsert(self.menu, {
            text = "Clear Preset",
            notCheckable = 1,
            func = function() MethodDungeonTools:OpenClearPresetDialog() end
        })
        tinsert(self.menu, {
            text = " ",
            notClickable = 1,
            notCheckable = 1,
            func = nil
        })
        if self.maxPulls > 1 then
            tinsert(self.menu, {
                text = "Delete",
                notCheckable = 1,
                func = function() MethodDungeonTools:DeletePull(self.index) end
            })
            tinsert(self.menu, {
                text = " ",
                notClickable = 1,
                notCheckable = 1,
                func = nil
            })
        end

        tinsert(self.menu, {
            text = "Close",
            notCheckable = 1,
            func = MethodDungeonTools.main_frame.sidePanel.optionsDropDown:Hide()
        })


        --Set pullNumber
        self.pullNumber:SetText(self.index)
        self.pullNumber:Show()


        self.frame:SetScript("OnClick", self.callbacks.OnClickNormal);
        self.frame:SetScript("OnKeyDown", self.callbacks.OnKeyDown);
        self.frame:SetScript("OnEnter", self.callbacks.OnEnter);
        self.frame:SetScript("OnLeave", self.callbacks.OnLeave);
        self.frame:EnableKeyboard(false);
        self.frame:SetMovable(true);
        self.frame:RegisterForDrag("LeftButton");
        self.frame:SetScript("OnDragStart", self.callbacks.OnDragStart);
        self.frame:SetScript("OnDragStop", self.callbacks.OnDragStop);
        self:Enable();
        --self:SetRenameAction(self.callbacks.OnRenameAction);
    end,
    ["Drag"] = function(self)
        local uiscale, scale = UIParent:GetScale(), self.frame:GetEffectiveScale()
        local x, w = self.frame:GetLeft(), self.frame:GetWidth()
        local _, y = GetCursorPosition()

        MethodDungeonTools.pullTooltip:Hide()

        self.dragging = true
        self.frame:StartMoving()
        self.frame:ClearAllPoints()
        self.frame.temp = {
            parent = self.frame:GetParent(),
            strata = self.frame:GetFrameStrata()
        }
        self.frame:SetParent(UIParent)
        self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
        self.frame:SetPoint("Center", UIParent, "BOTTOMLEFT", (x+w/2)*scale/uiscale, y/uiscale)
        self.frame:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = (self.elapsed or 0) + elapsed
            if self.elapsed > 0.1 then
                --print("Show Drop Indicator")
                self.elapsed = 0
            end
        end)
    end,
    ["Drop"] = function(self)
        local insertID = GetDropTarget()
        self.frame:StopMovingOrSizing()
        self.frame:SetScript("OnUpdate", nil)

        if self.dragging then
            self.frame:SetParent(self.frame.temp.parent)
            self.frame:SetFrameStrata(self.frame.temp.strata)
            self.frame.temp = nil
        end

        self.dragging = false
        local index = self.index
        if index > insertID then
            index = index + 1
        end

        MethodDungeonTools:PresetsAddPull(insertID)
        local newIndex = MethodDungeonTools:PresetsMergePulls(index, insertID)
        MethodDungeonTools:ReloadPullButtons()
        MethodDungeonTools:SetSelectionToPull(newIndex)

        MethodDungeonTools.pullTooltip:Hide()
    end,
    ["SetTitle"] = function(self, title)
        self.titletext = title;
        self.title:SetText(title);
    end,
    ["Disable"] = function(self)
        self.background:Hide();
        self.frame:Disable();
    end,
    ["Enable"] = function(self)
        self.background:Show();
        self.frame:Enable();
    end,
    ["Pick"] = function(self)
        self.frame:LockHighlight();
    end,
    ["ClearPick"] = function(self)
        self.frame:UnlockHighlight();
    end,
    ["SetIndex"] = function(self, index)
        self.index = index
    end,
    ["SetMaxPulls"] = function(self, maxPulls)
        self.maxPulls = maxPulls
    end,
    ["SetNPCData"] = function(self,enemyTable)
        local idx = 0
        --hide all textures first
        for k,v in pairs(self.enemyPortraits) do
            v:Hide()
            v.overlay:Hide()
            v.fontString:Hide()
        end

        table.sort(enemyTable,function(a,b)
            return a.count>b.count
        end)

        for npcId,data in ipairs(enemyTable) do
            idx = idx + 1
            if not self.enemyPortraits[idx] then break end
            self.enemyPortraits[idx].enemyData = data
            if data.displayId then
                SetPortraitTextureFromCreatureDisplayID(self.enemyPortraits[idx],data.displayId)
            else
                SetPortraitToTexture(self.enemyPortraits[idx],"Interface\\Icons\\achievement_boss_hellfire_mannorothreanimated")
            end
            self.enemyPortraits[idx]:Show()
            self.enemyPortraits[idx].overlay:Show()
            local quality = 0
            if data.count>0 then quality = 1 end
            if data.count>2 then quality = 2 end
            if data.count>3 then quality = 3 end
            if data.count>6 then quality = 4 end
            if data.count>9 then quality = 5 end
            local r, g, b, hex = GetItemQualityColor(quality)
            if quality == 0 then r,g,b = 0,0,0 end
            self.enemyPortraits[idx].overlay:SetVertexColor(r,g,b)
            self.enemyPortraits[idx].fontString:SetText("x"..data.quantity)
            self.enemyPortraits[idx].fontString:Show()
        end
    end,
}

--Constructor
local function Constructor()
    local name = "MethodDungeonToolsPullButton"..AceGUI:GetNextWidgetNum(Type);
    local button = CreateFrame("BUTTON", name, UIParent, "OptionsListButtonTemplate");
    button:SetHeight(height);
    button:SetWidth(width);
    button.dgroup = nil;
    button.data = {};

    local background = button:CreateTexture(nil, "BACKGROUND");
    button.background = background;
    background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp");
    background:SetBlendMode("ADD");
    background:SetVertexColor(0.5, 0.5, 0.5, 0.25);
    background:SetPoint("TOP", button, "TOP");
    background:SetPoint("BOTTOM", button, "BOTTOM");
    background:SetPoint("LEFT", button, "LEFT");
    background:SetPoint("RIGHT", button, "RIGHT");

    local icon = button:CreateTexture(nil, "OVERLAY");
    button.icon = icon;
    icon:SetWidth(height);
    icon:SetHeight(height);
    icon:SetPoint("LEFT", button, "LEFT");


    local pullNumber = button:CreateFontString(nil,"OVERLAY", "GameFontNormal")
    pullNumber:SetHeight(14)
    pullNumber:SetJustifyH("CENTER");
    pullNumber:SetPoint("LEFT", button, "LEFT",5,0);

    local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    button.title = title;
    title:SetHeight(14);
    title:SetJustifyH("LEFT");
    title:SetPoint("TOP", button, "TOP", 0, -2);
    title:SetPoint("LEFT", icon, "RIGHT", 2, 0);
    title:SetPoint("RIGHT", button, "RIGHT");

    button.description = {};

    button:SetScript("OnEnter", function()

    end);
    button:SetScript("OnLeave", function()

    end);






    local renamebox = CreateFrame("EDITBOX", nil, button, "InputBoxTemplate");
    renamebox:SetHeight(height/2);
    renamebox:SetPoint("TOP", button, "TOP");
    renamebox:SetPoint("LEFT", icon, "RIGHT", 6, 0);
    renamebox:SetPoint("RIGHT", button, "RIGHT", -4, 0);
    renamebox:SetFont("Fonts\\FRIZQT__.TTF", 10);
    renamebox:Hide();

    renamebox.func = function() --[[By default, do nothing!]] end;
    renamebox:SetScript("OnEnterPressed", function()
        local oldid = button.title:GetText();
        local newid = renamebox:GetText();
        if(newid == "" or (newid ~= oldid --[[and WeakAuras.GetData(newid)]] )) then
            --if name exists
            renamebox:SetText(button.title:GetText());
        else
            renamebox.func();
            title:SetText(renamebox:GetText());
            title:Show();
            renamebox:Hide();
        end
    end);

    renamebox:SetScript("OnEscapePressed", function()
        title:Show();
        renamebox:Hide();
    end);

    --enemy portraits
    local enemyPortraits = {}

    for i=1,maxPortraitCount do
        enemyPortraits[i] = button:CreateTexture(nil, "BACKGROUND", nil, 2)
        enemyPortraits[i]:SetSize(height-2,height-2)
        if i == 1 then
            enemyPortraits[i]:SetPoint("LEFT",icon,"RIGHT",-5,0)
        else
            enemyPortraits[i]:SetPoint("LEFT",enemyPortraits[i-1],"RIGHT",-2,0)
        end
        enemyPortraits[i]:Hide()
        enemyPortraits[i].overlay = button:CreateTexture(nil, "BACKGROUND", nil, 1)
        enemyPortraits[i].overlay:SetTexture("Interface\\Addons\\MethodDungeonTools\\Textures\\Circle_White")
        enemyPortraits[i].overlay:SetPoint("CENTER",enemyPortraits[i],"CENTER")
        enemyPortraits[i].overlay:SetSize(height+2,height+2)
        enemyPortraits[i].overlay:Hide()

        enemyPortraits[i].fontString = button:CreateFontString(nil,"BACKGROUND",nil)
        enemyPortraits[i].fontString:SetFont("Fonts\\FRIZQT__.TTF", 10,"OUTLINE")
        enemyPortraits[i].fontString:SetTextColor(1, 1, 1, 1);
        enemyPortraits[i].fontString:SetWidth(25)
        enemyPortraits[i].fontString:SetHeight(10)
        enemyPortraits[i].fontString:SetPoint("BOTTOM", enemyPortraits[i], "BOTTOM", 0, 0);
        enemyPortraits[i].fontString:Hide();


    end



    local widget = {
        frame = button,
        title = title,
        icon = icon,
        pullNumber = pullNumber,
        renamebox = renamebox,
        background = background,
        enemyPortraits = enemyPortraits,
        type = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget);
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
