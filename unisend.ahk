;
; ╓──────────────────────────────────────────────────────╖
; ║ 💀 UniSym Send                                       ║
; ║ 💀 © 2020 Ian Pride - New Pride Software/Services    ║
; ║ 💀 Work with Unicode characters, symbols, and emojis ║
; ║ 💀 using the corresponding hexadecimal value. Paste  ║
; ║ 💀 it down in the active window or copy it to the    ║
; ║ 💀 clipboard.                                        ║
; ╙──────────────────────────────────────────────────────╜
; 
; ╓─────────╖
; ║ 💀 Init ║
; ╙─────────╜
;
#SingleInstance, Force
#KeyHistory, 0
SetBatchLines, -1
ListLines, Off
SendMode Input
SetWorkingDir, %A_ScriptDir%
SetWinDelay, 0
WM_MESSAGES(    {   0x201:"WM_LBUTTONDOWN"
                ,   0x100:"WM_KEYDOWN"
                ,   0x101:"WM_KEYUP"
                ,   0x102:"WM_CHAR"
                ,   0x135:"WM_CTLCOLOR"
                ,   0x202:"WM_NOTRANS"
                ,   0x2A1:"WM_NOTRANS"
                ,   0x2A2:"WM_NOTRANS"
                ,   0x2A3:"WM_NOTRANS"
                ,   0x232:"WM_NOTRANS"  }   )
;
; ╓─────────╖
; ║ 💀 Vars ║
; ╙─────────╜
; 
global colors   :=  {   black:"0x1D1D1D"
                    ,   text:"0x2D89EF"
                    ,   text_invert:"0xEF892D"
                    ,   red:"0xEE1111"
                    ,   red_invert:"0x1111EE"
                    ,   blue:"0x2D89EF"
                    ,   blue_invert:"0xEF892D"}
global EDIT1HWND, MAINGUI, ETEXT, DISPLAY1HWND, HEXHWND
global TITLE:="UniSym Send"
global MAINGUI:=New _Gui(,TITLE)
;
; ╓─────────╖
; ║ 💀 Menu ║
; ╙─────────╜
;
Menu,Tray,NoStandard
Menu,Tray,Tip,%TITLE%`nShow %TITLE% - Win+Shift+u
if (! A_IsCompiled)
{
    Menu,Tray,Icon,unisend.ico
}
Menu,Tray,Add,&Show %TITLE% - Win+Shift+u,Display
Menu,Tray,Icon,&Show %TITLE% - Win+Shift+u,% (A_IsCompiled?A_ScriptName:"unisend.ico"),% (A_IsCompiled?1:""),32
Menu,Tray,Add
Menu,Tray,Add,E&xit %TITLE%,GuiClose
Menu,Tray,Icon,E&xit %TITLE%,% (A_IsCompiled?A_ScriptName:"unisend_stop.ico"),% (A_IsCompiled?2:""),32
;
; ╓─────────────╖
; ║ 💀 Buid Gui ║
; ╙─────────────╜
;
MAINGUI.Options([   "+ToolWindow"
                ,   "-Caption"
                ,   "+AlwaysOnTop"   
                ,   "+Border"])
MAINGUI.id:=MAINGUI.getId()
MAINGUI.Margin(0,0)
MAINGUI.Color("0x34FF56","0xEFEFEF")
MAINGUI.Font("Segoe UI","s13 q2 c" colors.black)
MAINGUI.Add("Text"," Hexadecimal: ","-BackgroundTrans h33 +0x200 w140 +Center +Border HwndHEXHWND")
; MAINGUI.Add("Picture","unicode.ico","xp yp")
MAINGUI.Font("Segoe UI","s14 c" colors.red)
MAINGUI.Add("Edit",,"+0x8 HwndEDIT1HWND x+0 yp w139 +Center +Border")
WinSet,ExStyle,-0x00000200,ahk_id %EDIT1HWND%
MAINGUI.Font("Segoe UI","s51 c" colors.text)
MAINGUI.Add("Edit",,"x+0 yp h103 w103 HwndDISPLAY1HWND +Center +0x200 -0x200000")
MAINGUI.Font("Segoe UI","s12 c" colors.black)
MAINGUI.Add("Button","&Send","x0 y33 w140 +Border HwndBTTN1HWND Default")
MAINGUI.Add("Button","System &Tray","x+0 yp w139 +Border HwndBTTN2HWND")
MAINGUI.Add("Button","Copy &Hexadecimal","x0 y+0 w140 +Border HwndBTTN3HWND")
MAINGUI.Add("Button","Copy &Character","x+0 yp w139 +Border HwndBTTN4HWND")
MAINGUI.Show("AutoSize")
WinSet,TransColor,0x34FF56,% "ahk_id " MAINGUI.id
WinSet,Redraw,,% "ahk_id " MAINGUI.id
MAINGUI.getControls()
;
return
;
; ╓────────────╖
; ║ 💀 HotKeys ║
; ╙────────────╜
;
#+u::
    MAINGUI.Show()
return
;
; ╓──────────────╖
; ║ 💀 Functions ║
; ╙──────────────╜
;
WM_KEYDOWN()
{   
    GuiControlGet,ETEXT,,%EDIT1HWND%
}
WM_KEYUP(ARGS*)
{   
    GuiControlGet,ETEXT,,%EDIT1HWND%
}
WM_CHAR(ARGS*)
{
    if (ARGS[4]=EDIT1HWND)
    {
        if  (   GetKeyState("Ctrl","P")
            Or  GetKeyState("ALt","P")  )
        {
        return
        }
        GuiControlGet,ETEXT,,%EDIT1HWND%
        char:=Chr(ARGS[1])
        if (! (RegExMatch(char,"[0-9A-Fa-f]")) And (ARGS[1]!=8))
        {
            bs:=Func("Backspace")
            SetTimer,%bs%,-1
            return
        }
        dt:=Func("SetCharInDisplay")
        SetTimer,%dt%,-1
    }
    if (ARGS[4]=DISPLAY1HWND)
    {
        ct:=Func("SetDisplayInChar")
        SetTimer,%ct%,-1      
    }
}
Backspace(count:=1)
{
    SendInput,{%A_ThisFunc% %count%}
}
SetCharInDisplay()
{   
    GuiControlGet,_ETEXT,,%EDIT1HWND%
    GuiControl,,%DISPLAY1HWND%,% Chr("0x" _ETEXT)
}
SetDisplayInChar()
{
    GuiControlGet,_ETEXT,,%DISPLAY1HWND%
    _len:=((Ord(_ETEXT)>65535)?2:1)
    if (StrLen(_ETEXT)>_len)
    {
        _ETEXT:=SubStr(_ETEXT,1,_len)
        GuiControl,,%DISPLAY1HWND%,%_ETEXT%
    }
    SetFormat,Integer,Hex
    GuiControl,,%EDIT1HWND%,% SubStr(Ord(_ETEXT),3)
    SetFormat,Integer,Dec
}
WM_LBUTTONDOWN(ARGS*)
{   
    global
    local THISCTRL
    MouseGetPos,,,,THISCTRL
    if (THISCTRL="Static1")
    {   
        WinSet,Transparent,127,% "ahk_id " MAINGUI.id
        PostMessage,0xA1,2,,,% "ahk_id " MAINGUI.id
    }
}
WM_NOTRANS()
{
    global
    WinSet,Transparent,255,% "ahk_id " MAINGUI.id
    WinSet,Transparent,Off,% "ahk_id " MAINGUI.id
}
WM_MESSAGES(MSG_OBJ){
    if (IsObject(MSG_OBJ))
        for message, function in MSG_OBJ
            OnMessage(message,function)
}
WM_CTLCOLOR(wParam, lParam, hwnd)   
{   
    WinGetClass,class,ahk_id %lParam%
    if (class="Button")
    {
        return DllCall("Gdi32.dll\CreateSolidBrush", "UInt",colors.text_invert, "UPtr")
    }
}
;
; ╓────────────╖
; ║ 💀 Classes ║
; ╙────────────╜
;
#Include, _Gui.aclass
;
; ╓─────────╖
; ║ 💀 Subs ║
; ╙─────────╜
;
Display:
    MAINGUI.Show()
return
ButtonCopyHexadecimal:
    GuiControlGet,_txt,,%EDIT1HWND%
    Clipboard:=(_txt?_txt:Clipboard)
    _txt:=""
return
ButtonCopyCharacter:
    GuiControlGet,_txt,,%DISPLAY1HWND%
    Clipboard:=(_txt?_txt:Clipboard)
    _txt:=""
return
ButtonSend:
    GuiControlGet,_txt,,%EDIT1HWND%
    if (_txt)
    {
        MAINGUI.Hide()
        WinActivate,A
        sleep,250
        Send,% "{U+" _txt "}"
        MAINGUI.Show()
    }
    _txt:=""
return
GuiEscape:
ButtonSystemTray:
    MAINGUI.Hide()
return
GuiClose:
    ExitApp