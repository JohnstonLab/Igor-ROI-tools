#pragma rtGlobals=1		// Use modern global access method.

//#include "Sarfia"
#include "Resize"
#include "KalmanFilter"
#include "Corr_ROI"
#include "DeltaF"
#include "Pat5"
#include "DeltaF"
#include "Realign Mask"
#include "Timing"
#include "LineProfiler"
#include "QuickROI"
#include "Segmentation"
#include "getinfo"
#include "Scrub"
#include "AveRepsInMovie"
#include "LoadScanImage"
#include "RegisterStack"
#include "Regfolder"
#include "imshow"
#include "ROIbuddy"
#include "EqualizeScaling"

//NewDataFolder/O root:Packages
//NewDataFolder/O root:Packages:AROItools
//Variable/G root:Packages:AROItools:FOVatZoom1=610

Window AdvancedROI() : Panel
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:AROItools
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(993,45,1274,519) as "Advanced ROI tools"
	ModifyPanel cbRGB=(19452,22124,22440)
	SetDrawLayer UserBack
	SetDrawEnv linethick= 0,fillfgc= (10283,48779,31735)
	DrawRRect 21,218,258,453
	SetDrawEnv linethick= 0,fillfgc= (60450,21530,15568)
	DrawRRect 32,274,246,325
	SetDrawEnv linethick= 0,fillfgc= (10283,48779,31735)
	DrawRRect 21,34,258,71
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65535,65535,65535)
	DrawText 30,26,"Input"
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65535,65535,65535)
	DrawText 30,101,"Process"
	SetDrawEnv linethick= 0,fillfgc= (10283,48779,31735)
	DrawRRect 21,105,258,179
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65535,65535,65535)
	DrawText 31,212,"Explore"
	SetDrawEnv fsize= 15,textrgb= (65535,65535,65535)
	DrawText 39,273,"Segmentation"
	SetDrawEnv linethick= 0,fillfgc= (60450,21530,15568)
	DrawRRect 33,351,248,379
	SetDrawEnv fsize= 15,textrgb= (65535,65535,65535)
	DrawText 39,351,"Modify Mask"
	Button Threshold,pos={175.00,277.00},size={65.00,20.00},proc=ButtonProc_34,title="Thresh"
	Button Threshold,font="Lucida Grande",fStyle=0,fColor=(16191,18504,18761)
	Button Kalman,pos={28.00,147.00},size={65.00,20.00},proc=ButtonProc_35,title="Kalman"
	Button Kalman,fColor=(16191,18504,18761)
	Button Resize,pos={177.00,115.00},size={65.00,20.00},proc=ButtonProc_36,title="Resize"
	Button Resize,fColor=(16191,18504,18761)
	Button Noise,pos={37.00,277.00},size={65.00,20.00},proc=ButtonProc_37,title="Corr Map"
	Button Noise,labelBack=(16191,18504,18761),fColor=(11822,12079,12593)
	Button Corr_ROI,pos={37.00,301.00},size={65.00,20.00},proc=ButtonProc_38,title="Segment"
	Button Corr_ROI,fColor=(16191,18504,18761)
	Button DelatF,pos={99.00,390.00},size={80.00,20.00},proc=ButtonProc_40,title="ÆF/F"
	Button DelatF,fColor=(16191,18504,18761)
	Button Check_mask,pos={108.00,355.00},size={65.00,20.00},proc=ButtonProc_41,title="Check"
	Button Check_mask,fColor=(16191,18504,18761)
	Button Realign,pos={180.00,354.00},size={65.00,20.00},proc=ButtonProc_42,title="Realign"
	Button Realign,fColor=(16191,18504,18761)
	Button GetROIs,pos={106.00,301.00},size={65.00,20.00},proc=ButtonProc_1,title="GetROIS"
	Button GetROIs,fColor=(16191,18504,18761)
	Button Scale,pos={182.00,42.00},size={65.00,20.00},proc=ButtonProc,title="Scale SI"
	Button Scale,fColor=(16191,18504,18761)
	Button Scrub,pos={37.00,355.00},size={65.00,20.00},proc=ButtonProc_3,title="Scrub"
	Button Scrub,fColor=(16191,18504,18761)
	Button AveM,pos={122.00,147.00},size={100.00,20.00},proc=ButtonProc_2,title="Ave reps in vid"
	Button AveM,fColor=(16191,18504,18761)
	Button Load,pos={29.00,42.00},size={65.00,20.00},proc=ButtonProc_4,title="Load"
	Button Load,fColor=(16191,18504,18761)
	Button Reg,pos={104.00,115.00},size={65.00,20.00},proc=ButtonProc_5,title="Register"
	Button Reg,fColor=(16191,18504,18761)
	Button Show,pos={50.00,229.00},size={178.00,20.00},proc=ButtonProc_6,title="Show"
	Button Show,fColor=(16191,18504,18761)
	SetVariable FOV,pos={104.00,43.00},size={68.00,18.00},proc=SetVarProc_1,title="FOV"
	SetVariable FOV,help={"Field of view in µm @ zoom 1"},fSize=12,fStyle=1
	SetVariable FOV,fColor=(65535,65535,65535)
	SetVariable FOV,limits={0,inf,0},value= root:Packages:AROItools:FOVatzoom1
	Button ROIbud,pos={50.00,421.00},size={178.00,20.00},proc=ROIbuddybutton,title="ROI Buddy"
	Button ROIbud,fColor=(16191,18504,18761)
	Button Regfold,pos={27.00,115.00},size={65.00,20.00},proc=RegFolder,title="Reg Fold"
	Button Regfold,help={"Register all Ch1 data in a folder"}
	Button Regfold,fColor=(16191,18504,18761)
	Button JoinButton,pos={106.00,277.00},size={65.00,20.00},proc=JoinButton,title="Join"
	Button JoinButton,labelBack=(16191,18504,18761),fColor=(11822,12079,12593)
	Button Line,pos={175.00,301.00},size={65.00,20.00},proc=ButtonLineProfile,title="Line"
	Button Line,fColor=(16191,18504,18761)
EndMacro

Menu "Macros"
	
	"Advanced ROI panel", advancedroi() 

end




Function ButtonProc_34(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ThreshROI()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_35(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Kalman()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_36(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Resize()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End




Function ButtonProc_40(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			popdf()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_41(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			CheckMask()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_42(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Realign()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProc_37(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			segCorr()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_38(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			segment()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			
			getinfo()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_1(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			
			string mov, roi
			string list=wavelist("*",";","DIMS:3")
			string listM=wavelist("*ROI*",";","DIMS:2")
			prompt mov, "Movie select", popup, list
			prompt roi, "ROI mask select", popup, listm			
			doprompt "pick your movie and ROI mask ", mov, roi
				if(V_flag==1)
					Abort
				endif	

			wave w=$mov
			wave m=$roi
			
			extractrois(w,m)
			string qa=mov+"_qa"
			roiCor($qa)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonProc_3(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			string list=wavelist("*ROI*",";","DIMS:2")
			string roi
			prompt roi, "ROI mask select", popup, list
			doprompt "pick your ROI mask, make sure you have a keep wave! ",  roi
				if(V_flag==1)
					Abort
				endif	
			wave w=$roi
			scrub(w)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ButtonProc_2(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
		
			string mov
			variable n=3
			string list=wavelist("*",";","DIMS:3")
			prompt mov, "Movie select", popup, list
			prompt n, "Number of repitions"
			doprompt "pick your movie and number of repititions ", mov, n
				if(V_flag==1)
					Abort
				endif	
			
			wave w=$mov
			 aveREPs(w, n)	
			
			// click code here
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProc_4(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			
			string LSIname = LoadScanImage(), Ch1Name,Ch2Name,Ch3Name
			Variable nChannels, ii
			if (stringmatch(LSIname, "-1"))
				break
			else 
				ApplyHeaderInfo($LSIname)
				nChannels=nChannelsFromHeader($LSIname)
				if(nChannels > 1)
				
					SplitChannels($LSIname,nChannels)
					Ch1Name=LSIName+"_Ch1"
					Ch2Name=LSIName+"_Ch2"
					Ch3Name=LSIName+"_Ch3"	
					getinfo1($Ch1name)
				
				endif				
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End





Function ButtonProc_5(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			
			string list=wavelist("*",";","DIMS:3")
			string name
			prompt name, "wave to register", popup,list
			doprompt "pick your movie ", name
				if(V_flag==1)
					Abort
				endif	
			wave picwave=$name
			
			RegisterStack(picwave)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ButtonProc_6(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			imshow()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function SetVarProc_1(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			
			variable/G root:packages:aroitools:FOVatzoom1=dval
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

getinfo1

Function ButtonProc_7(ba) : ButtonControl	// ave button
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			
			string list=wavelist("*",";","DIMS:3")
			string name
			prompt name, "wave to average", popup,list
			doprompt "pick your movie ", name
				if(V_flag==1)
					Abort
				endif	
			wave picwave=$name
			string outname=name+"AVE"
			
			imagetransform averageimage picwave
			wave M_AveImage, M_StdvImage
			
			duplicate/o M_AveImage, $outname
			
			killwaves/z M_AveImage, M_StdvImage
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function ROIbuddybutton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			
			string list=wavelist("*QA*",";","DIMS:2")
			string name
			prompt name, "Data wave", popup,list
			doprompt "Pick data to examine ", name
				if(V_flag==1)
					Abort
				endif	
			
			wave w=$name
			
			roibuddy(w)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function RegFolder(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			 loadfoldRaw()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function JoinButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			string list=wavelist("*ROI*",";","DIMS:2")
			string name
			variable dist=0, cor=1
			prompt name, "ROI Mask", popup,list
			prompt dist, "1st ROI"
			prompt cor, "2nd ROI"
			doprompt "Join ROIs", name, dist,cor
				if(V_flag==1)
					Abort
				endif	
			
			wave w=$name
			
			join2(w,cor,dist)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ButtonLineProfile(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			string list=wavelist("*",";","DIMS:3")
			string name
			variable ch, width
			prompt name, "wave to average", popup,list
			prompt ch, "ÆF=0 diff=1"
			prompt width, "width of profile (pixels)"
			doprompt "Line Profiler", name,ch,width
				if(V_flag==1)
					Abort
				endif	
			
			lineprofile(name,ch,width)
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
