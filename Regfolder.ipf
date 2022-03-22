#pragma rtGlobals=3		// Use modern global access method and strict wave access.
/////////// for cycling through folders
//#include "Sarfia"
function regfold()

	getfilefolderinfo/D/Q
		if(V_flag==-1)
			abort
		endif
	newpath/O pathstr, S_path
	
	string path=S_path
	string filelist= indexedfile(pathstr,-1,".ibw")  // list of files 
	variable l=itemsinlist(filelist), i
	
	print path
	print filelist
	for(i=0;i<l;i+=1)
		string filen=stringfromlist(i,filelist)
		print "working on "+filen
		string file=filen[0,(strlen(filen)-5)]
		string fullpath=path+filen
		
		//AutoLoadScanImage11(path, filen)
		loadwave/o/W/A fullpath
		
		wave reg=$file
		RegisterStack(Reg)
		
		wave ref1, M_StdvImage
		string sav=file+"_reg"
		string savnam=sav+".ibw"
		wave tosave=$sav
		setscale/P z 0,0.1, tosave
		Save/C/P=pathstr tosave as savnam
		
		killwaves reg, ref1,M_StdvImage, tosave
	
	
	endfor
	

end


function loadfoldRaw()

	getfilefolderinfo/D/Q
		if(V_flag==-1)
			abort
		endif
	newpath/O pathstr, S_path
	
	string path=S_path
	string filelist= indexedfile(pathstr,-1,".tif")  // list of files 
	variable l=itemsinlist(filelist), i
	
	print path
	print filelist
	for(i=0;i<l;i+=1)
		string filen=stringfromlist(i,filelist)
		print "working on "+filen
		string file=filen[0,(strlen(filen)-5)]
		print file
		string ch1=file+"_ch1"
		//string fullpath=path+filen
		
		AutoLoadScanImage11(path, filen)
		//loadwave/o/W/A fullpath
		
		wave reg=$ch1
		
		GetInfo1(reg)
		RegisterStack(Reg)
		
		wave ref1, M_StdvImage
		string sav=ch1+"_reg"
		
		print sav
		
		 
		string savnam=sav+".ibw"
		wave tosave=$sav
		
		Save/C/P=pathstr tosave as savnam
//		
		killwaves reg, ref1,M_StdvImage, tosave
	doupdate
	
	endfor
	

end




Function /wave AutoLoadScanImage11(pathstr, filenamestr)			//Does not open a file dialogue, takes path and filename as input parameters
	String pathstr, filenamestr

	String ImgWaveName, FirstWave
	string header, s_info = "No header info available\r"
	Variable PointPos
	
	NewPath/o/q path, pathstr
	
	ImageLoad/T=tiff /Q /O /C=-1/p=path filenamestr
	
	if (v_flag == 0)
		Abort
	endif
	
		header = s_info
		PointPos = strsearch(S_Filename, ".tif", 0)
		ImgWaveName = S_FileName[0,PointPos-1]
		ImgWaveName = ReplaceString("-", ImgWaveName, "_")
		
		PointPos = strsearch(S_Wavenames, ";", 0)
		FirstWave =S_Wavenames[0,PointPos-1]
		
	if (waveexists($ImgWaveName))
		killwaves /z $ImgWaveName
	endif
	
	
	duplicate /o $FirstWave, $ImgWaveName
	Killwaves /z $FirstWave
	
	redimension /d $ImgWaveName		//convert to double precision floating point
	
	Note $ImgWaveName, header
	Note $ImgWaveName, "file.path="+s_path
	Note $ImgWaveName, "file.name="+s_filename
	
	Wave ReturnWv =  $ImgWaveName
	SplitChannels11(ReturnWv,1)
	
	string ch2name=ImgWaveName+"_ch2"
	wave kill=$ch2name
	killwaves/Z ReturnWv, kill
	
	//Return ReturnWv
End


Function SplitChannels11(PicWave,nChannels)
	wave PicWave
	variable nChannels
	
	variable nFrames = DimSize(PicWave,2), FramesPerChannel, Rest, ii
	String wvName
	FramesPerChannel=nFrames/nChannels
	Rest=FramesPerChannel-trunc(FramesPerChannel)
	
	if(Rest)
		Print "WARNING: inequal number of frames per channel."
		FramesPerChannel=trunc(FramesPerChannel)
	endif
	
	For(ii=0;ii<nChannels;ii+=1)
		wvName=NameOfWave(PicWave)+"_Ch"+Num2Str(ii+1)
		Duplicate /o PicWave $wvName
		wave w=$wvName
		Redimension/n=(-1,-1,FramesPerChannel) w
		MultiThread w=PicWave[p][q][r*nChannels+ii]	
	EndFor	
End








function GetInfo1(inst)

	wave inst
	NVAR FOV =root:packages:aroitools:FOVatzoom1
	
	
	
	string notes=note(inst)
	
	string zoom = notes[(strsearch(notes,"state.acq.zoomFactor=",0)+21),(strsearch(notes,"state.acq.scanAngleMultiplierFast=",0)-2) ]
	string frameHz = notes[(strsearch(notes,"state.acq.frameRate=",0)+20),(strsearch(notes,"state.acq.zoomFactor=",0)-2) ]
	string msPline = notes[(strsearch(notes,"state.acq.msPerLine=",0)+20),(strsearch(notes,"state.acq.fillFraction=",0)-2) ]
	string xmult =  notes[(strsearch(notes,"state.acq.scanAngleMultiplierFast=",0)+34),(strsearch(notes,"state.acq.scanAngleMultiplierSlow=",0)-2) ]
	string ymult = notes[(strsearch(notes,"state.acq.scanAngleMultiplierSlow=",0)+34),(strsearch(notes,"state.acq.scanRotation=",0)-2) ]
	
	variable xx=dimsize(inst,0)
	variable yy=dimsize(inst,1)
	
	print "zoom was " +zoom
	print "Frame rate was "+frameHz
	print "ms per line was "+mspline
	print "physical aspect ratio was "+xmult+" by "+ymult
	
	variable zoo=str2num(zoom)
	variable freq=str2num(frameHz)
	variable xmul=str2num(xmult)
	variable ymul=str2num(ymult)
	
	
	
	setscale/I x,0,((FOV/zoo)*xmul), inst
	setscale/I y,0,((FOV/zoo)*ymul), inst
	setscale/P z,0,(1/freq), inst


end