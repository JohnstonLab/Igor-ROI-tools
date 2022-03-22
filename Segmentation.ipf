#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//#include "Sarfia"
#include <All IP Procedures>
#include <Image Saver>
#include "Advanced ROI tools"
#include <WindowBrowser>




Function segCorr()
	
	string input, inlist
	inlist=wavelist("*",";","DIMS:3")
	prompt input, "movie", popup inlist
	
	doprompt "some choices", input
	if(V_flag==1)
		abort
	endif
	
	segmcorr(input)
end

function segmCorr(input)
	
	string input
	
	wave w=$input
	variable n=1
	variable lx=dimsize(w,0),ly=dimsize(w,1), ix,iy		// length and counters for x and y dims
	
	duplicate/o/R=[][][0] w,CorrMap
	redimension/S/n=(-1,-1) CorrMap							// image mask for correlations
	 CorrMap=0
	 
	 make/FREE/o/n=8 corr
	 
	for(iy=2;iy<ly-2;iy+=1)
		for(ix=2;ix<lx-2;ix+=1)
			
			matrixop/FREE/o pix=beam(w,ix,iy) 				//original
			matrixop/FREE/o pix1=beam(w,ix+n,iy+n) 		// above to the right
			matrixop/FREE/o pix2=beam(w,ix+n,iy) 			//  right
			matrixop/FREE/o pix3=beam(w,ix,iy+n) 			//above
			matrixop/FREE/o pix4=beam(w,ix-n,iy-n)		// below left
			matrixop/FREE/o pix5=beam(w,ix-n,iy) 			//left
			matrixop/FREE/o pix6=beam(w,ix,iy-n)			//below
			matrixop/FREE/o pix7=beam(w,ix+n,iy-n)			//below right
			matrixop/FREE/o pix8=beam(w,ix-n,iy+n)			//above left
			
			corr[0]=statscorrelation(pix,pix1)
			corr[1]=statscorrelation(pix,pix2)
			corr[2]=statscorrelation(pix,pix3)
			corr[3]=statscorrelation(pix,pix4)
			corr[4]=statscorrelation(pix,pix5)
			corr[5]=statscorrelation(pix,pix6)
			corr[6]=statscorrelation(pix,pix7)
			corr[7]=statscorrelation(pix,pix8)
			
			wavestats/q corr
			CorrMap[ix][iy]=V_avg
			
			
		endfor
	endfor


	imagestats corrmap
	Make/N=50/O CorrMap_Hist;DelayUpdate
	Histogram/B={V_min,((V_max-V_min)/50),50} CorrMap,CorrMap_Hist
	
	string newname=input+"Map"
	duplicate/o corrmap $newname
	
	display/N=XCORR/W=(35,45,598,326)/K=1 corrmap_hist
	Label bottom "Pearson's "
	ModifyGraph axisEnab(left)={0,0.35}, log(bottom)=1
	AppendImage/L=lImage/T  $newname
	ModifyGraph axisEnab(lImage)={0.4,1},freePos(lImage)=0
	ModifyImage  $newname ctab= {*,*,Grays,0}
	SetAxis/A/R lImage
	ControlBar 40
	Slider slider0,pos={7,2},size={411,43},proc=SliderProc_0,font="Helvetica"
	Slider slider0,limits={V_min,V_max,0},value= 0,vert= 0
	CheckBox check0,pos={428,2},size={58,15},proc=CheckProc_1,title="Lock Max"
	CheckBox check0,value= 1
	variable/G root:packages:aroitools:checked=1
	//ShowInfo
	
	
end

function segment()

	string input, inlist
	variable pmax=inf,minthr=0.2, thr=0.55,minsize=5
	inlist=wavelist("*",";","DIMS:3")
	
	nvar thresh=root:packages:aroitools:curval
	if(nvar_exists(thresh)==1)
		minthr=thresh
	endif
	
	prompt input, "movie", popup inlist
	prompt minthr, "Min correlation threshold"
	prompt thr, "threshold relative to local max"
	prompt minsize, "exclude ROIs smaller than this"
	prompt pmax, "Max ROI size in pixels"
	doprompt "some choices", input, minthr,thr,minsize,pmax
	if(V_flag==1)
		abort
	endif

	segmentation(input,minthr,thr,minsize,pmax)
	
end

function segmentation(input,minthr,thr,minsize,pmax)
	
	string input
	variable pmax,minthr,thr,minsize
	wave w=$input
	
	
	
	redimension/S w
	variable n=1


	
	variable lx=dimsize(w,0),ly=dimsize(w,1), ix,iy		// length and counters for x and y dims
	variable xdelta=dimdelta(w,0),ydelta=dimdelta(w,1)
	
	duplicate/FREE/o/R=[][][0] w,ROI
	redimension/S/n=(-1,-1) roi							// image mask for correlations
	 roi=0
	 
	 make/FREE/n=8 corr
	 string testname=input+"map"
	 if(waveexists($testname)==0)
		for(iy=2;iy<ly-2;iy+=1)
			for(ix=2;ix<lx-2;ix+=1)
				
				matrixop/FREE/o pix=beam(w,ix,iy) 				//original
				matrixop/FREE/o pix1=beam(w,ix+n,iy+n) 		// above to the right
				matrixop/FREE/o pix2=beam(w,ix+n,iy) 			//  right
				matrixop/FREE/o pix3=beam(w,ix,iy+n) 			//above
				matrixop/FREE/o pix4=beam(w,ix-n,iy-n)		// below left
				matrixop/FREE/o pix5=beam(w,ix-n,iy) 			//left
				matrixop/FREE/o pix6=beam(w,ix,iy-n)			//below
				matrixop/FREE/o pix7=beam(w,ix+n,iy-n)			//below right
				matrixop/FREE/o pix8=beam(w,ix-n,iy+n)			//above left
				
				corr[0]=statscorrelation(pix,pix1)
				corr[1]=statscorrelation(pix,pix2)
				corr[2]=statscorrelation(pix,pix3)
				corr[3]=statscorrelation(pix,pix4)
				corr[4]=statscorrelation(pix,pix5)
				corr[5]=statscorrelation(pix,pix6)
				corr[6]=statscorrelation(pix,pix7)
				corr[7]=statscorrelation(pix,pix8)
				
				wavestats/q corr
				roi[ix][iy]=V_avg
				
				
			endfor
		endfor
	
	else
		wave corMappp=$testname
		roi=cormappp
	
	endif
	
	imagestats roi
	Make/N=50/O roi_Hist;DelayUpdate
	Histogram/B={V_min,((V_max-V_min)/50),50} roi,roi_Hist
	wavestats/q roi_hist
	variable base=V_maxloc
	
	make/o/FREE/n=8 neighx, neighy
	
	neighx[0]=-1
	neighx[1]=0
	neighx[2]=1
	neighx[3]=-1
	neighx[4]=1
	neighx[5]=-1
	neighx[6]=0
	neighx[7]=1
	
	neighy[0]=1
	neighy[1]=1
	neighy[2]=1
	neighy[3]=0
	neighy[4]=0
	neighy[5]=-1
	neighy[6]=-1
	neighy[7]=-1
	
	
	variable pp=0,i
	variable seedx,seedy, nseedx,nseedy, ss, lopeak
	
	do												//loop for moving through seeds
		
		pp+=1										// value of roi same as the ith do loop
		make/o/n=(1,2) seed
		ss=0
		imagestats roi
		lopeak=V_max
		
		seed[0][0]=V_maxRowLoc			// first seed location
		seed[0][1]=V_maxColLoc				// first seed location
			
	
		
		matrixop/o pix=beam(w,seed[0][0],seed[0][1]) 				//original seed timeseries
		
		roi[seed[0][0]][seed[0][1]]=-PP								// set this pixel to the correspodning roi
		
		///////////////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////
		
		do 
			
			for(i=0;i<8;i+=1)								// loop through neighbours
								
				nseedx=seed[ss][0]+neighx[i]
				nseedy=seed[ss][1]+neighy[i]		
				
				if(roi[nseedx][nseedy]>0)						// is this pixel already in an roi?
					
					matrixop/o pix1=beam(w,nseedx,nseedy)	// get timeseries of this pixel
					
					if(statscorrelation(pix,pix1)>(((lopeak-base)*thr)+base))			// if it is above the corr threshold add it to the roi								
						
						roi[nseedx][nseedy]=-PP					// add to roi if it is correlated
						insertpoints/M=0 inf,1,seed
						seed[dimsize(seed,0)-1][0]=nseedx		// update the seed with this pixel
						seed[dimsize(seed,0)-1][1]=nseedy
						//pix+=pix1
						
					endif
				
				endif
				
				if(dimsize(seed,0)>=Pmax)
					break									// break for limiting roi size
				endif
			
			
			endfor
			ss+=1

			if(dimsize(seed,0)>=Pmax)
				break									// break for limiting roi size
			endif
			

			

			
		while(ss<dimsize(seed,0))  //stop if roi didn't grow with last loop 
		///////////////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////	
											
											///remove rois that are smaller than the deifned size		
		if(dimsize(seed,0)<=minsize)
				
				matrixop/o/FREE roitemp=replace(roi,-pp,0)
				
				Duplicate/o roitemp roi
				pp-=1								// reset the roi counter as we deleted this one

				
		endif

		
	
	while(lopeak>MinThr)		// stop searching for new seeds if the remaining seeds are below specified threshold
	

	 
	for(iy=0;iy<ly;iy+=1)
		for(ix=0;ix<lx;ix+=1)
		
			if(roi[ix][iy]>-0.5)
				roi[ix][iy]=1
			endif
	
		endfor
	endfor
	
	string name=input+"_ROI"
	setscale/P x, 0, xdelta ,roi
	setscale/P y, 0, ydelta,roi
	duplicate/o roi, $name
	
	Newimage/k=1 $name
	ModifyImage $name ctab= {*,0,Web216,0};DelayUpdate
	ModifyImage $name minRGB=0,maxRGB=(43690,43690,43690)
	
	imagestats roi
	
	make/FREE/n=(abs(V_min)) hist
	
	histogram/B={V_min,1,abs(V_min)} roi, hist
	
	print "  "
	print "This found "+num2str(-V_min)+" ROIs"
	Print "Using a correlation threshold of ="+num2str(minthr)
	print "Excluding ROIs smaller than "+num2str(minsize)+" pixels"
	print "and limiting ROIs to "+num2str(pmax)+" pixels" 
	print "note that pixels are "+num2str(xdelta)+" by "+num2str(ydelta)+" µm"
	print "with a threshold for local max of "+num2str(thr)
	wavestats/q hist
	print "the average ROI size is "+num2str(V_avg)+" pixels"
	print "the largest ROI is "+num2str(V_max)+" pixels" 
	print  "  "

	doupdate
	
	print "extracting data waves"
	
	extractrois(w,$name)
	
	print "now examine the correlation matrix to decide if rois should be joined"
	print "also have a look at the distance matrix"
	Print "the area of 1 pixel is "+num2str(xdelta*ydelta)
	print "so you need " +num2str(0.64/(xdelta*ydelta))+" pixels for a structure at the resolution roughly!"
	
	string dataname=nameofwave(w)+"_QA"
	wave data=$dataname
	
	note data, "Data was generated using a correlation threshold of "+num2str(minthr)+"\n a threshold for local max of "+num2str(thr)+"\n excluding ROIs smaller than "+num2str(minsize)+"pixels"+"\n and limiting ROIs to "+num2str(pmax)+" pixels"
	
	 //roiCor(data)
	 
	 wave roicorr, DistanceM
	 
	 newimage/k=1 roicorr
	 ModifyImage ROICorr ctab= {0.7,*,Geo32,0}
	ColorScale/C/N=text0/F=0/A=RC/E image=ROICorr,tickLen=2.00
	 newimage/k=1 DistanceM
	 ModifyImage DistanceM ctab= {0,*,Geo32,0}

	wave concerns, CorrMap,CorrMap_hist, W_WaveList, pix,pix1
	edit/K=1 concerns
	 
	killwaves seed, roi_hist, CorrMap, CorrMap_hist, W_WaveList, pix,pix1
	
end




/////

function extractrois(w,m)

	wave w, m		// w is your movie, m is your roiMask
	imagestats/q m		// get some deets about the number of rois
	string name=nameofwave(w)+"_QA"				//outnames
	string avname=nameofwave(w)+"_AVE"				//outnames
	variable i, l=abs(v_min), j, xx=dimsize(w,2), xd=dimdelta(w,2)		
	
	variable dx=dimdelta(w,0), dy=dimdelta(w,1)
	
	make/FREE/o/n=(xx,l) data			// make a wave to hold all your data
	note data, "This is the raw data for each ROI\n make sure you subtract background before proceeding"
	make/o/n=(l,3) xysize			
	note xysize, "1st colum = x centre in pixels\n 2nd colum = y centre in pixels\n 3rd column = area in µm"
	
	setscale/P x, 0, (xd), data
	
	for(i=0;i<l;i+=1)
		
		j=(i+1)*-1		// loop through the rois in the mask, the rois in the image start at -1 and decrease
				
		matrixop/o/FREE tmask=replace(m,j,1000)		//highlight the current roi
		
		 imagethreshold/T=10/o/I tmask				// make into a binary mask
		 ImageAnalyzeParticles/A=0/q stats tmask		// get the xy position and size of each roi and put it into teh wave "xysize"
		wave M_RawMoments, W_ImageObjArea, W_ImageObjArea,W_SpotX,W_SpotY,W_circularity,W_rectangularity,W_ImageObjPerimeter,W_xmin,W_ymin,W_xmax,W_ymax
		xysize[i][0]= M_RawMoments[0][0]/W_ImageObjArea[0]	/// gets the centre of mass x coordinate
		xysize[i][1]=M_RawMoments[0][1]/W_ImageObjArea[0]		/// gets the centre of mass y coordinate
		xysize[i][2]=W_ImageObjArea[0]*dx*dy
		
		 imagestats/BEAM/R=tmask w			// get the time series of this roi
		wave W_ISBeamAvg	
		multithread data[][i]=W_ISBeamAvg[p]		// put it into data
	
	endfor

	imagetransform averageimage w			// average the movie 
	wave M_AveImage, M_StdvImage
	SetScale/P x 0,dimdelta(w,0),"", M_AveImage
	SetScale/P y 0,dimdelta(w,1),"", M_AveImage
	duplicate/o M_AveImage, $avname
	duplicate/o data, $name
	
	roiCor($name)
	
	wave W_ISBeamAvg, W_ISBeammax, W_ISBeammin// for clean up
	killwaves W_ISBeamAvg, W_ISBeammax, W_ISBeammin, M_RawMoments, W_ImageObjArea, W_ImageObjArea,W_SpotX,W_SpotY,W_circularity,W_rectangularity,W_ImageObjPerimeter,W_xmin,W_ymin,W_xmax,W_ymax, M_AveImage, M_StdvImage
	
end






// for checking whether ROIs should be joined

function roiCor(w)
	
	wave w
	//string name=nameofwave(wn)+"_qa"
	//wave w=$name
	
	wave xysize
	variable i,j, l=dimsize(w,1),k=0
	make/o/n=(l,l) ROICorr, DistanceM
	RoiCorr=0
	DistanceM=0
	note roicorr, "This is the pearsons correlation between each pair of ROIs"
	note DistanceM, "This is the euclidean disatnce between the centre of mass of each ROI pair"
	
	make/o/n=(1,4) concerns=0
	for(i=0;i<l;i+=1)
	
		duplicate/R=[][i]/FREE/o w, test
		redimension/n=-1 test
		for(j=0;j<(i+1);j+=1)
			
			duplicate/R=[][j]/o/FREE w, trial
			redimension/n=-1 trial
			ROIcorr[i][j]=StatsCorrelation(test, trial)
			DistanceM[i][j]=SQRT(((xysize[i][0]-xysize[j][0])^2)+((xysize[i][1]-xysize[j][1])^2))
				
			if (ROIcorr[i][j]>0.6 && ROIcorr[i][j]!=1)
				concerns[k][0]=i
				concerns[k][1]=j
				concerns[k][2]=ROIcorr[i][j]
				concerns[k][3]=DistanceM[i][j]
				k+=1
				insertpoints/M=0 inf,1, concerns
			endif
		
			
		endfor


	endfor
	
	l=dimsize(concerns,0)
	deletepoints/M=0 (l-1),1, concerns
end


Function SliderProc_0(sa) : SliderControl
	STRUCT WMSliderAction &sa
				getwindow kwTopWin wavelist
				wave/T W_WaveList
				string name=W_WaveList[0][0]
				if(stringmatch(name,"*map")==0)
					 name=W_WaveList[1][0]
				endif	
				
	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable/G root:packages:aroitools:curval = sa.curval
				Nvar curval=root:packages:aroitools:curval
				NVAR checked =root:packages:aroitools:checked
				
				
				if(checked==0)
					ModifyImage $name ctab= {curval,(curval+0.02),Grays,0}
					Tag/C/N=text0/F=0/X=0.00/Y=10.00 CorrMap_Hist, curval,"\\OX"
				elseif(checked==1)
					ModifyImage $name ctab= {curval,*,Grays,0}
					Tag/C/N=text0/F=0/X=0.00/Y=10.00 CorrMap_Hist, curval,"\\OX"
				endif
			endif
			break
	endswitch

	return 0
End



Function CheckProc_1(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
				getwindow kwTopWin wavelist
				wave/T W_WaveList
				string name=W_WaveList[0][0]
				if(stringmatch(name,"*map")==0)
					 name=W_WaveList[1][0]
				endif	
				wave ingraph=$name
				
	switch( cba.eventCode )
		case 2: // mouse up
			Variable/G root:packages:aroitools:checked = cba.checked
			NVAR curval=root:packages:aroitools:curval
			NVAR checked=root:packages:aroitools:checked 
				if(checked==1)
					ModifyImage $name ctab= {curval,*,Grays,0}
				else
					ModifyImage $name ctab= {curval,(curval+0.02),Grays,0}
				endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End