include("autorun/sh_init.lua")

surface.CreateFont("Roboto", {
    font = "Roboto",
    size = 22,
    weight = 700,
})

local staffPanelOpenned = false

local function STAFF_PANEL.OpenMenu()
    staffPanelOpenned = true
    chatLogger(LocalPlayer(), "Openning Staff Panel!", Color(0,255,0))

    local screenWidth, screenHeight = ScrW(), ScrH()
    local hudWidth, hudHeight = screenWidth*.25, screenHeight*.25
    local animTime, animeDelay, animeEase = 1, 0, 0.1

    STAFF_PANEL.Menu = vgui.Create("DFrame")
    STAFF_PANEL.Menu:SetTitle("StaffPanel - Manager")
    STAFF_PANEL.Menu:MakePopup(true)
    STAFF_PANEL.Menu:SetSize(0, 0)
    STAFF_PANEL.Menu:Center()

    STAFF_PANEL.Menu.Paint = function(me, width, height)
        surface.SetDrawColor(52,52,52,255)
        surface.DrawRect(0, 0, width, height)

        surface.SetDrawColor(210,144,52,255)
        surface.DrawRect(0, 0, width, height/11)
    end

    local isAnimating = true;
    STAFF_PANEL.Menu:SizeTo(hudWidth, hudHeight, animTime, animDelay, animEase, function() 
        isAnimating = false 
    end)

    STAFF_PANEL.Menu.Think = function(this) 
        if isAnimating then
            this:Center()
        end
    end

    local toggleStaffModeButton = STAFF_PANEL.Menu:Add("DButton")
    toggleStaffModeButton:Dock(TOP)
    toggleStaffModeButton:SetText("")
    toggleStaffModeButton.isActive = false 
    toggleStaffModeButton.Paint = function(this, width, height)
        surface.SetDrawColor(210,144,52)

        if this:IsHovered() then
            surface.SetDrawColor(102,72,29)
        end
    
        surface.DrawRect(0,0,width, height)
        draw.SimpleText(not this.isActive and "Enter Staff Mode" or "Leave Staff Mode", "Roboto", width*0.5, height*0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    toggleStaffModeButton.DoClick = function(this)
        this.isActive = not this.isActive
        net.Start("SP_NET_SV_TurnStaffMode")
        net.WriteBool(this.isActive)
        net.SendToServer()
    end

    STAFF_PANEL.Menu.OnSizeChanged = function(this, width, height) 
        if isAnimating then
            this:Center()
        end
        toggleStaffModeButton:SetTall(height * 0.1)
    end
end

local function STAFF_PANEL.CloseMenu()
    staffPanelOpenned = false
    chatLogger(LocalPlayer(), "Closing Staff Panel!", Color(255,0,0))
end

local function chatLogger(ply, message, color)
    chat.AddText(ADDON_CONFIG.color, ply, ADDON_CONFIG.logger, color, " " .. message)
end

local function keyPressed(ply, key)
    if key == KEY_O then
        if not staffPanelOpenned then
	        STAFF_PANEL.OpenMenu()
        else
            STAFF_PANEL.CloseMenu()
        end
    end
end
hook.Add("KeyPress", "SP_HK_KEY_PRESSED", keyPressed)

net.Receive("SP_NET_CL_StaffModeOn", function(len, ply)
    local message = net.ReadString()
    local color = net.ReadColor()

    chatLogger(ply, message, color)
end)

net.Receive("SP_NET_CL_StaffModeOff", function(len, ply)
    local message = net.ReadString()
    local color = net.ReadColor()

    chatLogger(ply, message, color)
end)