' Get Keys using Canvas
' Written by David W (dw817) 12-14-15
' GetDeskTopArea written by dan_upright

Import MaxGui.Drivers
Strict

Extern "Win32"
  Function SystemParametersInfoA:Int(action:Int, param:Int, param2:Byte Ptr, winini:Int)
EndExtern

Global a,b,c,d,e,f,g,h,i,j,kk,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
Global aa$,bb$,cc$,dd$,ee$,ff$,gg$,hh$,ii$,jj$,k$,ll$,mm$
Global nn$,oo$,pp$,qq$,rr$,ss$,tt$,uu$,vv$,ww$,xx$,yy$,zzz$
Global key:Byte[256],lastkey,keytimer,mx,my,mk
Global shiftkey,ctrlkey,altkey,arrowkey,numkey

Global deskrect[4]
GetDesktopArea(deskrect)

Global window:TGadget
Global mainview:tgadget

window=CreateWindow("",deskrect[0],deskrect[1],deskrect[2],deskrect[3],,WINDOW_ACCEPTFILES)
mainview=createcanvas(deskrect[0]-2,deskrect[1]-1,deskrect[2]+4,deskrect[3]+3,window,1)

SetGraphics canvasgraphics(mainview)
activategadget mainview
Flip
SetBlend solidblend
SetScale 10,10

Repeat
  nano
  Cls
  If k$>""
    DrawText k$,50,50
  EndIf
Until k$="es"
zz

Function zz()
  End
EndFunction
    
Function nano()
Global ce,cd,cx,cy,i
  If lastkey>0
    keytimer:+1
    If keytimer<50 And keytimer<>25
      key[lastkey]=0
    Else
      key[lastkey]=1
    EndIf
  EndIf
  If PollEvent()
    ce=CurrentEvent.id
    cd=CurrentEvent.data
    cx=EventX()
    cy=EventY()
    If ce=event_windowclose Or ce=event_appterminate
      zz
    ElseIf ce=event_keydown
      key[cd]=1
      If cd<160 Or cd>165
        lastkey=cd
        keytimer=0
      EndIf
    ElseIf ce=event_keyup
      lastkey=0
      key[cd]=0
    ElseIf ce=event_mousemove
      mx=EventX()
      my=EventY()
    ElseIf ce=event_mousedown
      mk=cd
    ElseIf ce=event_mouseup
      mk=0
    ElseIf ce=event_appsuspend Or ce=event_mouseleave
      mk=0
      For i=0 To 255
        key[i]=0
      Next
      ce=0
      Repeat
        If PollEvent()
          ce=CurrentEvent.id
        EndIf
        Flip
        Flip
      Until ce=event_mouseenter Or ce=event_appresume
      k$=""
      lastkey=0
      keytimer=0
      activategadget mainview
      Return
    EndIf
  EndIf
  shiftkey=0; ctrlkey=0; altkey=0; arrowkey=0; numkey=0
  If key[160]+key[161]
    shiftkey=1
  EndIf
  If key[162]+key[163]
    ctrlkey=1
  EndIf
  If key[164]+key[165]
    altkey=1
  EndIf
  k$=""
  For i=48 To 57
    If key[i]=1And k$="" Then k$=k$+Chr$(i);numkey=1
  Next
  For i=65 To 90
    If key[i]=1And k$="" Then k$=k$+Chr$(32+i)
  Next
  If key[8] Then k$=k$+"bs"
  If key[9] Then k$=k$+"ta"
  If key[13] Then k$=k$+"cr"
  If key[27] Then k$=k$+"es"
  If key[32] Then k$=k$+" "
  If key[33] Then k$=k$+"pu"
  If key[34] Then k$=k$+"pd"
  If key[35] Then k$=k$+"en"
  If key[36] Then k$=k$+"ho"
  If key[37] Then k$=k$+"lf";arrowkey=1
  If key[38] Then k$=k$+"up";arrowkey=1
  If key[39] Then k$=k$+"rt";arrowkey=1
  If key[40] Then k$=k$+"dn";arrowkey=1
  If key[45] Then k$=k$+"in"
  If key[46] Then k$=k$+"de"
  If key[107] Then k$=k$+"n+"
  If key[109] Then k$=k$+"n-"
  If key[186] Then k$=k$+";"
  If key[187] Then k$=k$+"="
  If key[188] Then k$=k$+","
  If key[189] Then k$=k$+"-"
  If key[190] Then k$=k$+"."
  If key[191] Then k$=k$+"/"
  If key[192] Then k$=k$+"`"
  If key[219] Then k$=k$+"["
  If key[220] Then k$=k$+"\"
  If key[221] Then k$=k$+"]"
  If key[222] Then k$=k$+"'"
  If shiftkey And k$>""Then k$="#"+k$
  If ctrlkey And k$>""Then k$="^"+k$
  If altkey And k$>""Then k$="@"+k$
  If k$="^q"Or k$="es"Then zz
  Flip
  Flip
EndFunction

Function getdesktoparea(lprect:Int Ptr)
  systemparametersinfoa(spi_getworkarea,0,lprect,0)
End Function
