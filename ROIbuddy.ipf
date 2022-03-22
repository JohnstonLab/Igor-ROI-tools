#pragma rtGlobals=3		// Use modern global access method and strict wave access.


////////////////////////////////////////////Testing//////////////////////////////////////////////////////////////////////
Function ROIbuddy1(w,w1,w2,w3,w4)

	wave w,w1,w2,w3,w4
	string/G root:packages:aroitools:wn=nameofwave(w)
	svar wn=root:packages:aroitools:wn
	print wn
	variable nstart= strsearch(wn,"QA",0)-1

	string roin=wn[0,nstart]+"ROI"
	wave roi=$roin

	string aven=wn[0,nstart]+"AVE"
	wave avg=$aven
	
	variable/G root:packages:aroitools:ROI2display=0
	nvar ROI2display=root:packages:aroitools:ROI2display
	
	Variable/G root:packages:aroitools:CompareROI=0
	nvar CompareROI=root:packages:aroitools:CompareROI
	
	Display/K=1 /W=(79,45,688,549)/L=DF/B=Time w[*][ROI2display]
	appendtograph/L=DF/B=Time w1[*][ROI2display]
	appendtograph/L=DF/B=Time w2[*][ROI2display]
	appendtograph/L=DF/B=Time w3[*][ROI2display]
	appendtograph/L=DF/B=Time w4[*][ROI2display]
	
	ModifyGraph rgb=(52171,0,5911)
	AppendImage/T avg
	AppendImage/T roi
	SetAxis/A/R left
	ModifyImage $roin ctab= {*,0,Grays,0}
	ModifyImage $roin maxRGB=nan
	ModifyImage $roin explicit=1,eval={-1,52171,0,5911}//,eval={0,-1,-1,-1},eval={255,-1,-1,-1}
	ModifyGraph mirror(left)=0,mirror(top)=0
	ModifyGraph standoff(top)=0
	ModifyGraph lblPos(left)=53,lblPos(Time)=47
	ModifyGraph freePos(DF)=0
	ModifyGraph freePos(Time)=0
	ModifyGraph axisEnab(left)={0.55,1}
	ModifyGraph axisEnab(DF)={0,0.45}
	Label top "µm"
	Label Time "Time (s)"
	Label df "ÆF/F"
	ModifyGraph lblPos(DF)=65
	ControlBar 30
	SetVariable ShowROI1,pos={292,3},size={130,23},proc=ShowROI1,title="ShowROI"
	
	SetVariable ShowROI1 limits={0,dimsize(w,1)-1,1}
	SetVariable ShowROI1,fSize=15,value=ROI2display
	
	CheckBox Compare,pos={270,7},size={16,15},proc=CompareCB,title=""
	CheckBox Compare,value= 0,side= 1
	SetVariable Compar,pos={96,3},size={172,23},proc=CompareROIsetvar,title="Compare ROI#"
	SetVariable Compar,fSize=15,value= CompareROI
	
	Button copyROI,pos={424,3},size={82,22},proc=CopyROIbut,title="Copy ROI"
	Button copyROI,fSize=15
	Button JoinButton,pos={8,3},size={82,22},proc=JoinROIbudBut,title="Join"
	Button JoinButton,fSize=15
	Button KillROI,pos={523,3},size={82,22},proc=KillBut,title="Kill ROI"
	Button KillROI,fSize=15
	Button Add2kill,pos={615.00,3.00},size={87.00,22.00},proc=add2killButton,title="+ 2 kill list"
	Button Add2kill,fSize=15
	Button KillKilllist,pos={712.00,3.00},size={88.00,22.00},proc=KillKillButton,title="Kill KillList"
	Button KillKilllist,fSize=15

end


Function ShowROI1(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	SVAR wn=root:packages:aroitools:wn
	wave w=$wn
	wave Hip_IO_7V_Reg_QA, Hip_IO_5V_Reg_QA,Hip_IO_3V_Reg_QA,Hip_IO_1V_QA
	variable nstart= strsearch(wn,"QA",0)-1

	string roin=wn[0,nstart]+"ROI"
	wave roi=$roin

	
	switch( sva.eventCode )
		case 1: // mouse up
		
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable/G root:packages:aroitools:ROI2display=dval
			nvar ROI2display=root:packages:aroitools:ROI2display
		
			AppendToGraph/L=DF/B=Time w[][ROI2display]
			RemoveFromGraph $wn
			ModifyGraph rgb($wn)=(52171,0,5911)
			AppendToGraph/L=DF/B=Time Hip_IO_7V_Reg_QA[][ROI2display]
			RemoveFromGraph Hip_IO_7V_Reg_QA
			AppendToGraph/L=DF/B=Time Hip_IO_5V_Reg_QA[][ROI2display]
			RemoveFromGraph Hip_IO_5V_Reg_QA
			AppendToGraph/L=DF/B=Time Hip_IO_3V_Reg_QA[][ROI2display]
			RemoveFromGraph Hip_IO_3V_Reg_QA
			AppendToGraph/L=DF/B=Time Hip_IO_1V_QA[][ROI2display]
			RemoveFromGraph Hip_IO_1V_QA
		
		
			AppendImage/T $roin
			RemoveImage  $roin
			ModifyImage $roin ctab= {*,0,Grays,0}
			ModifyImage $roin maxRGB=nan
			ModifyImage $roin explicit=1,eval={-(roi2display+1),52171,0,5911}
			
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function ROIbuddy(w)

	wave w
	string/G root:packages:aroitools:wn=nameofwave(w)
	svar wn=root:packages:aroitools:wn
	print wn
	variable nstart= strsearch(wn,"QA",0)-1

	string roin=wn[0,nstart]+"ROI"
	wave roi=$roin

	string aven=wn[0,nstart]+"AVE"
	wave avg=$aven
	
	variable/G root:packages:aroitools:ROI2display=0
	nvar ROI2display=root:packages:aroitools:ROI2display
	
	Variable/G root:packages:aroitools:CompareROI=0
	nvar CompareROI=root:packages:aroitools:CompareROI
	
	Display/K=1 /W=(79,45,688,549)/L=DF/B=Time w[*][ROI2display]
	ModifyGraph rgb=(52171,0,5911)
	AppendImage/T avg
	AppendImage/T roi
	SetAxis/A/R left
	ModifyImage $roin ctab= {*,0,Grays,0}
	ModifyImage $roin maxRGB=nan
	ModifyImage $roin explicit=1,eval={-1,52171,0,5911}//,eval={0,-1,-1,-1},eval={255,-1,-1,-1}
	ModifyGraph mirror(left)=0,mirror(top)=0
	ModifyGraph standoff(top)=0
	ModifyGraph lblPos(left)=53,lblPos(Time)=47
	ModifyGraph freePos(DF)=0
	ModifyGraph freePos(Time)=0
	ModifyGraph axisEnab(left)={0.55,1}
	ModifyGraph axisEnab(DF)={0,0.45}
	Label top "µm"
	Label Time "Time (s)"
	Label df "ÆF/F"
	ModifyGraph lblPos(DF)=65
	ControlBar 30
	SetVariable ShowROI,pos={292,3},size={130,23},proc=ShowROI,title="ShowROI"
	
	SetVariable ShowROI limits={0,dimsize(w,1)-1,1}
	SetVariable ShowROI,fSize=15,value=ROI2display
	
	CheckBox Compare,pos={270,7},size={16,15},proc=CompareCB,title=""
	CheckBox Compare,value= 0,side= 1
	SetVariable Compar,pos={96,3},size={172,23},proc=CompareROIsetvar,title="Compare ROI#"
	SetVariable Compar,fSize=15,value= CompareROI
	
	Button copyROI,pos={424,3},size={82,22},proc=CopyROIbut,title="Copy ROI"
	Button copyROI,fSize=15
	Button JoinButton,pos={8,3},size={82,22},proc=JoinROIbudBut,title="Join"
	Button JoinButton,fSize=15
	Button KillROI,pos={523,3},size={82,22},proc=KillBut,title="Kill ROI"
	Button KillROI,fSize=15
	Button Add2kill,pos={615.00,3.00},size={87.00,22.00},proc=add2killButton,title="+ 2 kill list"
	Button Add2kill,fSize=15
	Button KillKilllist,pos={712.00,3.00},size={88.00,22.00},proc=KillKillButton,title="Kill KillList"
	Button KillKilllist,fSize=15

end

//./////////////////////////////////// 

function pop1(w,i)

	wave w
	variable i
	string name=nameofwave(w)+"_"+num2str(i)
	duplicate/o/R=[][i] w, $name
	
	redimension/N=(-1) $name
	setscale/P x,0,dimdelta(w,0), $name
	note/K $name
	note $name, "This ROI is from "+nameofwave(w)
	


end



//./////////////////////////////////// 


Function ShowROI(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	SVAR wn=root:packages:aroitools:wn
	wave w=$wn
	variable nstart= strsearch(wn,"QA",0)-1

	string roin=wn[0,nstart]+"ROI"
	wave roi=$roin

	
	switch( sva.eventCode )
		case 1: // mouse up
		
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			Variable/G root:packages:aroitools:ROI2display=dval
			nvar ROI2display=root:packages:aroitools:ROI2display
		
			AppendToGraph/L=DF/B=Time w[][ROI2display]
			RemoveFromGraph $wn
			ModifyGraph rgb($wn)=(52171,0,5911)
		
			AppendImage/T $roin
			RemoveImage  $roin
			ModifyImage $roin ctab= {*,0,Grays,0}
			ModifyImage $roin maxRGB=nan
			ModifyImage $roin explicit=1,eval={-(roi2display+1),52171,0,5911}
			
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

////////////////////////////

Function CompareCB(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	
	SVAR wn=root:packages:aroitools:wn
	wave w=$wn
	variable nstart= strsearch(wn,"QA",0)-1

	string roin=wn[0,nstart]+"ROI"
	wave roi=$roin

	nvar CompareROI=root:packages:aroitools:CompareROI
	nvar showroi=root:packages:aroitools:ROI2display
	
	switch( cba.eventCode )
		case 2: // mouse up
			Variable/G root:packages:aroitools:checkBoxCompare = cba.checked
			nvar checkBoxCompare=root:packages:aroitools:checkBoxCompare
			
			if(checkBoxCompare==1)
				
				duplicate/o roi, compareROImask
				duplicate/o w, compareData
				
				AppendToGraph/L=DF/B=Time compareData[][CompareROI]
				ModifyGraph rgb(compareData)=(9252,26214,42919)
				
				AppendImage/T compareROImask
				ModifyImage compareROImask ctab= {*,0,Grays,0}
				ModifyImage compareROImask maxRGB=nan
				ModifyImage compareROImask explicit=1,eval={-(CompareROI+1),9252,26214,42919}
				
				dowindow correlation_of_ROIs
				if(V_flag==1)
					dowindow/K correlation_of_ROIs
				endif
				display/K=1/N=correlation_of_ROIs compareData[][CompareROI] vs compareData[][showROI]
				ModifyGraph mode=3
				
				duplicate/FREE/R=[][CompareROI]compareData, aa
				duplicate/FREE/R=[][showROI]compareData, bb
				
				//StatsRankCorrelationTest aa,bb
			//	print statscorrelation(aa,bb)
				TextBox/C/N=text0/X=0.00/Y=0.00/F=0/A=LT "R\\S2\\M="+num2str(statscorrelation(aa,bb)^2)
			
			elseif(checkBoxCompare==0)
				
				wave compareData,compareROImask
				RemoveFromGraph compareData
				Removeimage compareROImask
				killwaves/Z compareData,compareROImask
				dowindow/K correlation_of_ROIs
				
			endif
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
////////////////////////////

Function CompareROIsetvar(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	
	SVAR wn=root:packages:aroitools:wn
	wave w=$wn
	string roin=wn[0,strlen(wn)-3]+"ROI"
	wave roi=$roin
	
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			variable/G root:packages:aroitools:CompareROI=dval
			
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


////////////////////////////////////////////

Function CopyROIbut(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			SVAR wavnam=root:packages:aroitools:wn
			wave w=$wavnam
			NVAR i=  root:packages:aroitools:ROI2display
			pop1(w,i)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

////////////////////////////////////////////


Function JoinROIbudBut(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			nvar CompareROI=root:packages:aroitools:CompareROI
			nvar showroi=root:packages:aroitools:ROI2display
			svar wn=root:packages:aroitools:wn
			wave w=$wn
			variable nstart= strsearch(wn,"QA",0)-1

			string roin=wn[0,nstart]+"ROI"
			wave wroi=$roin
			
			
			duplicate/o/FREE wroi, mask
	
			if(showroi<CompareROI)		
				matrixop/FREE temp=replace(mask,-(CompareROI+1),-(showroi+1))
				shift1(temp,CompareROI)
			elseif(showroi>CompareROI)
				matrixop/FREE temp=replace(mask,-(showroi+1),-(CompareROI+1))
				shift1(temp,showroi)
			endif
			
			mask=temp
			string name=nameofwave(wroi)
			duplicate/o mask, $name
			
			string nn=nameofwave(wroi)
			string newn=nn[0,strlen(nn)-5]
			wave w=$newn
			extractrois(w,$name)
			// click code here
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

////////////////////////////


Function KillBut(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
		
			nvar showroi=root:packages:aroitools:ROI2display
			svar wn=root:packages:aroitools:wn
			wave w=$wn
			variable nstart= strsearch(wn,"QA",0)-1
			string moviename=wn[0,nstart-1]
			wave movie=$moviename
			string roin=wn[0,nstart]+"ROI"
			wave wroi=$roin
			variable roival=-(showroi+1)
			matrixop/FREE temp=replace(wroi,roival,1)
			wroi=temp
			
			shift1(wroi,(showroi+1))
		//	doupdate
			
			extractrois(movie,wroi)
			doupdate
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function add2killButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
		
			// click code here
			nvar showroi=root:packages:aroitools:ROI2display
			wave killlist
			if(waveExists(killList)==0)
				make/N=1 killList = showroi
				edit/K=1 killlist
			elseif(waveExists(killList)==1)
				findvalue/V=(showroi) killlist
				if(V_value==-1)
					insertpoints/V=(showroi) dimsize(killlist,0), 1, killlist
				elseif(V_value!=-1)
					abort "Already added to kill list"
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function KillKillButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			wave killlist
			
			if(waveExists(killList)==0)
				Abort "No kill wave"
			endif
			
			variable i,len=dimsize(killlist,0)
			
			sort/R killlist, killlist
			
			
			svar wn=root:packages:aroitools:wn
			wave w=$wn
			variable nstart= strsearch(wn,"QA",0)-1
			string moviename=wn[0,nstart-1]
			wave movie=$moviename
			string roin=wn[0,nstart]+"ROI"
			wave wroi=$roin
			
			
			for(i=0;i<len;i+=1)
				variable roival=-(killlist[i]+1)
				matrixop/FREE temp=replace(wroi,roival,1)
				wroi=temp
				
				shift1(wroi,(killlist[i]+1))
			endfor
			
			
		//	doupdate
			
			extractrois(movie,wroi)
			doupdate
			
			killwaves/Z killlist
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
