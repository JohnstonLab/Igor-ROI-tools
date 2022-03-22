#pragma rtGlobals=3		// Use modern global access method and strict wave access.



function imshow()

	string list=wavelist("*",";","DIMS:3")
	string wn
	prompt wn, "Display this movie", popup, list
	
	doprompt "Select movie" wn
	
	 
	
	if(V_flag==1)
		Abort
	endif
	
	wave w=$wn
	string/G wavenameingraph=wn

	
	Display /W=(451,49,1139,294)/K=1 
	AppendImage w
	ModifyGraph mirror(left)=0,mirror(bottom)=2
	//ModifyGraph axisEnab(bottom)={0,0.85}
	SetAxis/A/R left
	WMAppend3DImageSlider()

	imagestats w
	
	variable/G low=V_min
	variable/G high=V_max
	
	ControlBar 55

	SetVariable Set_Zero,pos={59,29},size={104,15},proc=SetVarProc,title="Set Zero"
	SetVariable Set_Zero, Value=low
	Slider slider0,pos={198,30},size={314,16},proc=SliderProc
	Slider slider0,limits={V_min,V_max,-1},value= V_max,vert= 0,ticks= 0
	
end




Function SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			SVAR wn=wavenameingraph

			
			variable/G low=dval
			NVAR high=high
			ModifyImage $wn ctab= {low,high,Grays,0}
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End




Function SliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				
				
				SVAR wn=wavenameingraph
					
				variable/G high=curval
				NVAR low=low
				ModifyImage $wn ctab= {low,high,Grays,0}
				
				
				
			endif
			break
	endswitch

	return 0
End