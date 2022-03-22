#pragma rtGlobals=1		// Use modern global access method.
////////////////////QUICK ROI TOOL////////////////////////////////
////Use the marquee tool to mark an ROI, right click and select quickroi.
////This is then appended to the image with its coordinates printed to the history.
////The average of the pixel values within the ROI in each frame is calculated and
//// shown in the wave QROI. If you select a new ROI this everything is updated.
/// You can also use the "subtract background" button to subtract the average of the 
////ROI pixels from the whole image on a frame by frmae basis. Useful for analysing Ca imaging movies
/// When done hit the done button to kill all waves and variables


Function quickROI() :GraphMarquee
	
	string inputlist = imagenamelist("",";") 
	string input = stringfromlist(0,inputlist)
	
	string/G imageInQroiGraph=input
	//print input
	Wave inwave =$input
	
	String info =imageinfo("",input,0)
	variable z = Dimsize(inwave,2)				// number of frames
	
	//print info
	
	string xaxis = stringbykey("XAXIS",info)	//name of xaxis
	string yaxis = stringbykey("YAXIS",info)	//name of yaxis
	string AxisFlag = stringbykey("AXISFLAGS",info)	// to check if right and or top axis is in use
	string top="/T"
	string right="/R"
	String both="/R/T"
		
	Getmarquee/k $xaxis, $yaxis
	
	
	// make and assign values to the ROI coordinate waves
	Make/o/n=5 roix, roiy
	roix[0,1]=V_left
	roix[2,3]=V_right
	roix[4]=V_left
	roiy[0]=V_bottom
	roiy[1,2]=V_top
	roiy[3,4]=V_bottom
	
	//print V_left, V_right,V_top,V_bottom

	variable leftP, rightP, topP, bottomP 
	
	if(V_left>V_right)
		
		leftP=(V_right)
		rightP=(V_left)
		
	else
		leftP=(V_left)
		rightP=(V_right)
	endif
	
	if(V_top>v_bottom)
		
		topP=(v_top)
		bottomP=(v_bottom)	
		
	else
		topP=(V_bottom)
		bottomP=(V_top)	
	endif
	
	/// calculate average of the ROI in each frame
	duplicate/FREE roix, x
	duplicate/FREE roiy, y
	x=(x/dimdelta(inwave,0))-dimoffset(inwave,0)
	y/=dimdelta(inwave,1)-dimoffset(inwave,1)	
	imagestats/M=1/Gs={leftP,rightP,bottomP,topP}/BEAM inwave   //Gs={V_right,V_left,V_top,V_bottom}/BRXY={x,y}
	
	print nameofwave(inwave)
	
	print round(V_left),round(v_right),round(V_top),round(V_bottom)
	
	Make/FREE/N=(z) output
	wave W_ISBeamAvg
	output = W_ISBeamAvg
	
	variable dimD, dimS
	dimd=dimdelta(inwave,2)
	dims=leftx(inwave)
	setscale/P x, dims,dimd, output
	duplicate/o output, QROI
	
	/// open an new window if it doesn't exist, otherwise update it
	dowindow ROI
	if (V_flag==0)
		
					//////// check how image is plotted and append the ROI to it
					if ((stringmatch(AxisFlag, top ))==1)
					appendtograph/T roiy vs roix
					elseif((stringmatch(AxisFlag, right ))==1)
					appendtograph/R roiy vs roix
					elseif((stringmatch(AxisFlag, both ))==1)
					appendtograph/R/T roiy vs roix
					else
					appendtograph roiy vs roix
					endif
		Display/N=ROI/W=(35,44,443,298)/K=1  QROI as "Quick ROI"
		ControlBar 22
		Button Done,pos={349.00,0.00},size={50.00,20.00},proc=ButtonProc_9,title="Done"
		Button SubBckg,pos={220.00,0.00},size={44.00,20.00},proc=subtractBKG_AVE,title="- Ave"
		Button SubBckg1,pos={141.00,0.00},size={57.00,20.00},proc=subtractBKG_PXP,title="- P by P"
		Button SubBckg2,pos={66.00,0.00},size={57.00,20.00},proc=subtractBKG_Fit,title="- expFit"
		Button Hold, pos={280,0}, title="Hold",proc=HoldTrace
	elseif (v_flag==1)
	doupdate
	endif
	
	string/g imagewin = S_marqueeWin		// global string to pass to cleanup button
	
	wavestats/q qroi
	variable/G AverageOfQroi=V_avg
	
	Killwaves W_ISBeamAvg, W_ISBeamMax, W_ISBeamMin
		
End


//Button for clean up
Function ButtonProc_9(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	
		
	switch( ba.eventCode )
		case 2: // mouse up
			SVAR imagewin
			killwindow ROI
			print imagewin
			removefromgraph/W=$imagewin/Z roiy
			killwaves/Z roiy, roix,qroi, held_qroi
			Killstrings/Z imagewin
			killvariables/Z V_flag
			break
	endswitch

	return 0
End



Function subtractBKG_AVE(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			nvar bkg=AverageOfQroi
			svar image=imageInQroiGraph
			wave im =$image
			wave qroi
			im-=bkg
			qroi-=bkg
			print "background subtratcted of "+num2str(bkg)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function subtractBKG_PXP(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			nvar bkg=AverageOfQroi
			svar image=imageInQroiGraph
			wave im =$image
			wave qroi
			im-=qroi[r]
			qroi-=QROI
			print "background subtratcted PxP "
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function subtractBKG_Fit(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			nvar bkg=AverageOfQroi
			svar image=imageInQroiGraph
			wave im =$image
			wave qroi
			variable l=dimsize(qroi,0)
			if(waveexists(fit_QROI)==1)
				killwaves/Z fit_QROI
			endif
			
			CurveFit/L=(l) /X=1 exp_XOffset QROI /D 
			wave fit_QROI
			appendtograph/W=ROI fit_QROI
			ModifyGraph lsize(fit_QROI)=2,rgb(fit_QROI)=(0,0,0)
			doupdate
			variable xx
			prompt xx, ""
			doprompt "Fit ok?", xx
			if(V_flag==1)
				abort
			endif
		
			im-=fit_qroi[r]
			qroi-=fit_QROI
			print "background subtratcted with a exp fit "
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function HoldTrace(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			duplicate/o QROI, Held_QROI
				
			appendtograph/W=ROI Held_QROI
			ModifyGraph rgb(Held_QROI)=(43690,43690,43690)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
