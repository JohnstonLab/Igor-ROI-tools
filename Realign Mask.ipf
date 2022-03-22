#pragma rtGlobals=1		// Use modern global access method.

function checkmask()

	string input
	string list = wavelist("*",";","DIMS:2")
	prompt input, "Average projection", popup list
	doprompt "Choose Average projection", input
	if(V_flag==1)
		Abort
	endif

	newimage/k=1/F $input
	
	string ROI
	string roilist = wavelist("*ROI*",";","DIMS:2")
	prompt ROI, "ROI Mask", popup roilist
	doprompt "Choose ROI mask", ROI
	if(V_flag==1)
		Abort
	endif
	
	appendimage $ROI
	
	ModifyImage $ROI ctab= {-1,0,Grays,0};DelayUpdate
	ModifyImage $ROI minRGB=(65535,65535,0),maxRGB=NaN


END	

////////////////////////////////


Function Realign()

	Variable xx, yy
	String Wname
	
	prompt Wname, "ROImask",popup,wavelist("*",";","DIMS: 2")
	prompt xx, "x offset"
	prompt yy, "y offset"
	doprompt "Move ROI Mask", Wname, xx, yy
	if(V_flag==1)
		abort
	endif
	
	wave toacton=$Wname
	
	duplicate/o toacton shiftedROI
	shiftedROI=1
	
	if(xx>0 && yy>0)	
		shiftedROI[xx,*][yy,*]=toacton[p-xx][q-yy]
	elseif (xx>0)
		shiftedROI[xx,*][]=toacton[p-xx][q-yy]
	elseif(yy>0)
		shiftedROI[][yy,*]=toacton[p-xx][q-yy]
	else
		shiftedROI[][]=toacton[p-xx][q-yy]
	endif
	
End