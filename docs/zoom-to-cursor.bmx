



SuperStrict

Import maxgui.drivers
Import BRL.PNGLoader
Import BRL.BMPLoader

Function Rand!( lo!, hi! )
	Return lo + Rnd(lo + hi) + 1
EndFunction


Type obj
	Global List:TList
	
	Field X:Float
	Field Y:Float
	Field Size:Float
	Field HalfSize:Float
	Field R:Int
	Field G:Int
	Field B:Int
	

	
	Method New() 
		X = Rand(0 , GW) 
		Y = Rand(0 , GH) 
		Size = Rnd(0 , 1) 

		Size = size^3
		HalfSize = Size / 2.0
		R = Rand(0,255)
		G = Rand(0,255)	
		B = Rand(0 , 255) 
		
		If Not List Then List = New TList
		
		List.AddLast(Self)
		
	End Method
	
	Method Draw(ZoomOriginX:Float,ZoomOriginY:Float,_VIEWSCALE:Float) 
		SetColor(r,g,b)
		Local drawx:Float = ( (X - ZoomOriginX  ) * _viewscale)
			Local drawy:Float = ((Y- ZoomOriginY ) * _viewscale)
		DrawRect(drawX-HalfSize,drawY-HalfSize,size+1,size+1)
	End Method
	
End Type







Global GW:Int = ClientWidth(Desktop())
Global GH:Int = ClientHeight(Desktop())
Global GHW:Float = GW/2.0
Global GHH:Float = GH/2.0


Global Dragging:Byte = 0
Global MSX:Int
Global MSY:Int
Global MPosX:Int
Global MPosY:Int
Global DoubleClickTime:Int
Global DoubleClickDelay:Int = 300

Global Viewscale:Float = 1.0
Global WorldViewOriginX:Float = GHW
Global WorldViewOriginY:Float = GHH

Global ZoomTargetX:Float = GHW
Global ZoomTargetY:Float = GHH
Global ZoomTargetScale:Float = 1
Global ZoomFactor:Float = 1.25
Global ZoomMAX:Float = 30.0
Global ZoomMin:Float = 0.50


'Global RootDir:String = CurrentDir()

	
	
AddHook EmitEventHook, EventHook
	

SetGraphicsDriver(GLMax2DDriver() ) 


?Debug
	Global GraphicsContext:TGraphics = CreateGraphics(GW , GH , 0 , 60 , Graphics_BACKBUFFER) 
?Not Debug
	Global GraphicsContext:TGraphics = CreateGraphics(GW , GH , 32 , 60 , Graphics_BACKBUFFER)
?

SetGraphics(GraphicsContext) 


HideMouse()


For Local i:Int = 0 To 3000
	Local temp:obj = New obj
Next



Local ms:Int,time:Int,dt:Float

While Not KeyHit(KEY_ESCAPE)
	'ms = MilliSecs() 
	'dt = ms - time
	'time = ms
	
	'Print 1000.0/dt
	
	
	
	Cls
	
	SetScale(1 , 1)
	SetOrigin(GHW,GHH)
	
	

	
	SetColor(255 , 255 , 0) 
	SetLineWidth(5)
		Local tempx:Float = (-WorldViewOriginX * viewscale) 
		Local tempy:Float = (-WorldViewOriginY * viewscale )
		Local tempx2:Float = tempx+(GW*viewscale)
		Local tempy2:Float = tempy+(GH*viewscale)
		
		DrawLine(tempx , tempy , tempx2 , tempy) 
		DrawLine(tempx2, tempy , tempx2 , tempy2) 
		DrawLine(Tempx2 , tempy2 , tempx , tempy2) 
		DrawLine(tempx , tempy2 , tempx , tempy) 
	SetLineWidth(1)
	SetColor(255 , 255 , 255) 
	
	
		SetViewScale() 
	
	
	For Local t:obj = EachIn Obj.List
		t.draw(WorldViewOriginX, WorldViewOriginY, viewscale) 
		
	Next
		
				
	SetScale(1 , 1) 
	SetOrigin(0 , 0)
	
	
	SetBlend(LightBlend) 
	SetAlpha(0.4) 
	SetColor(255 , 155 , 0)
	SetLineWidth(2)	

		DrawLine(MPosX- 15 , MPosY, MPosX+ 15 , MPosY) 
		DrawLine(MPosX, MPosY- 15 , MPosX, MPosY+ 15 ) 
	
			
	SetLineWidth(1)
	SetBlend(SolidBlend) 
	
	
	
	SetColor(255 , 255 , 255) 
	DrawText("SCALE:  " + viewscale , 50 , 50) 
	
	Flip 0

Wend





Function SetViewScale()
	
		
		WorldViewOriginX = ZoomTargetX
		WorldViewOriginY = ZoomTargetY
		ViewScale = ZoomTargetScale
		
		SetScale(Viewscale , Viewscale)
	
End Function






Function ZoomIn(MouseScreenX:Int , MouseScreenY:Int) 
	
	If Not (ZoomTargetScale  >= ZoomMax) 	
	
		Local mx:Float = (MouseScreenX - GHW) /ZoomTargetScale
		Local my:Float = (MouseScreenY - GHH) /ZoomTargetScale
		Local z:Float = 1.0 - (1.0/ZoomFactor)
		
		ZoomTargetX = (mx)*(z) + WorldViewOriginX
		ZoomTargetY = (my)*(z) + WorldViewOriginY
					
		If ZoomTargetX > GW
			ZoomTargetX = GW
		Else If ZoomTargetX < 0
			ZoomTargetX = 0
		EndIf
				
		If ZoomTargetY > GH
			ZoomTargetY = GH
		Else If ZoomTargetY < 0
			ZoomTargetY = 0
		EndIf
			
					
		ZoomTargetScale:* ZoomFactor
		
		If ZoomTargetScale  > ZoomMax Then ZoomTargetScale  = ZoomMax
	
	EndIf
	
	
End Function




Function ZoomOut(MouseScreenX:Int , MouseScreenY:Int)

	If Not (ZoomTargetScale  =< ZoomMin) 
	
		Local mx:Float = (MouseScreenX - GHW) / ZoomTargetScale
		Local my:Float = (MouseScreenY - GHH) / ZoomTargetScale	
		Local z:Float = 1.0 - ZoomFactor
		
		ZoomTargetX  = mx*(z)+ WorldViewOriginX
		ZoomTargetY = my*(z)+ WorldViewOriginY
	
		ZoomTargetScale:/ ZoomFactor
		
		If ZoomTargetScale < ZoomMin Then ZoomTargetScale = ZoomMin
		
	EndIf
End Function





Function DoubleClick(button:Int , MouseScreenX:Int , MouseScreenY:Int)
	ZoomTargetX = WorldViewOriginX + (MouseScreenX - GHW) / ZoomTargetScale 	
	ZoomTargetY = WorldViewOriginY + (MouseScreenY - GHH) / ZoomTargetScale
	ZoomTargetScale = ZoomMax
End Function



Function Drag(MouseScreenX:Int , MouseScreenY:Int) 
	Local dx:Float = (MouseScreenX - MSX) / viewscale
	Local dy:Float = (MouseScreenY - MSY) / viewscale
	
	WorldViewOriginX:- dx
	WorldViewOriginY:- dy
	ZoomTargetX:- dx
	ZoomTargetY:- dy
	
	MSX = MouseScreenX
	MSY = MouseScreenY
	
	If WorldViewOriginX < 0
		WorldViewOriginX = 0
		ZoomTargetX = 0
	Else If WorldViewOriginX > GW
		WorldViewOriginX = GW
		ZoomTargetX = GW
	EndIf
	
	If WorldViewOriginY < 0
		WorldViewOriginY = 0
		ZoomTargetY = 0
	Else If WorldViewOriginY > GH
		WorldViewOriginY = GH
		ZoomTargetY = GH
	EndIf	
			
	
End Function




Function EventHook:Object(ID:Int , Data:Object , Context:Object) 
	Local Event:TEvent = TEvent(data)
	If Event = Null Then Return event
	
	Select event.id
		Case EVENT_MOUSEWHEEL
				
			If Event.Data > 0
				ZoomIn(event.x,Event.Y)
			Else
				ZoomOut(event.x,Event.Y)
			EndIf
		
							
		Case EVENT_APPTERMINATE
			End
			
			
		Case EVENT_KEYDOWN
			Select Event.Data
				Case KEY_ESCAPE End
					
									
			End Select
				
	
			
	
		Case EVENT_MOUSEDOWN
				
				Local ms:Int = MilliSecs()
					If ms - DoubleClickTime =< DoubleClickDelay
						DoubleClick(event.Data , event.X , event.Y) 
						Return Null
					Else DoubleClickTime = ms
				EndIf

			Select Event.data
			
				Case 1
					Dragging = 1
					MSX = Event.X
					MSY = Event.Y
					
			
				Case 3
					Dragging = 1
					MSX = Event.X
					MSY = Event.Y
					
					
			
			End Select
			
			
		Case EVENT_MOUSEUP
			Select Event.data
				Case 1,3
					Dragging = 0
			
			End Select
			
			
		Case EVENT_MOUSEMOVE
			
			MPosx = Event.x
			MPosY = Event.y
			
			If Dragging
				Drag(event.x,event.y)
				
			EndIf			

			
End Select


End Function





