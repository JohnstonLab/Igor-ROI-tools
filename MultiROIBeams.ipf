#pragma rtGlobals=1		// Use modern global access method.

//////////////////////////////////////////////////////////////////
// MultiROIBeams(wv,ROImask) extracts all beams from the image stack wv  //
// that are defined by the MultiROIMask ROIMask. The function produces 2	//
// waves:  NameOfWave(wv)+"_ROIBeams", which is the populationwave		//
// containing all the beams, and NameOfWave(wv)+"_index" which contains	//
// The ROInumbers that the traces belong to.									//
//																			//
// SortPopByIndex(pop, index, [rev]) sorts the traces in pop according to 	//
// index; rev=1 <--> reverse sorting.										//
//																			//
// ROIBeams2Traces(ROIBeams, index, ResultName) makes proper traces	//
// out of ROiBeams, based on index. 											//
/////////////////////////////////////////////////////////////////

Function/wave MultiROIBeams(wv,ROImask)		
	Wave wv, ROIMask
	
	Variable xd, yd, zd, ii, arow, acol, nPixels, PxCount=0, MultiROI
	String OutputName1,  OutputName2
	
	xd = dimsize(wv,0)
	yd = DimSize(wv,1)
	zd = DimSize(wv,2)
	
	if(dimsize(ROIMask,0) != xd || dimsize(ROIMask,1) !=yd)
		Abort "Dimension mismatch"
	endif
	
	if(wavemin(ROIMask) < 0)
		MultiROI = 1
	else
		MultiROi = 0
	endif
	
	Duplicate/o/free ROIMask binROI
	
	//Transforming the MultiROI mask into an ("inverted") binary mask
	MultiThread binROI=SelectNumber(ROIMask[p][q]<=0,0,1)	//binary; 1=in ROI, 0=outside
	
	Duplicate/o/free binROI, binROIlin
	Redimension /n=(xd*yd) binROIlin
	
	nPixels=sum(binROIlin)
	
	Make /o/free/n=(zd,nPixels) wv2Dx
	Make /o/free/n=(nPixels) wv2Dx_index
	
	//Extracting beams
	for(ii=0;ii<xd*yd;ii+=1)
	
		arow = mod(ii,xd)
		acol = floor(ii/xd)	
		
		if(binROI[arow][acol]==1)
			Matrixop/o/free Beams = Beam(wv,arow,acol)
			MultiThread wv2dx[][PxCount] = Beams[p]
			wv2Dx_index[PxCount] = ROIMask[arow][acol]
			PxCount+=1
		endif
		
	endfor
	
	setscale/p x,DimOffSet(wv,2),DimDelta(wv,2),WaveUnits(wv,2) wv2dx
	
	SortPopByIndex(wv2Dx, wv2Dx_index, rev=1)
	
	MatrixOP /o/free ROIIndex = abs(wv2Dx_index) -1		//compensate for -1 based ROI numbering
	
	OutputName1=NameOfWave(wv)+"_ROIBeams"
	OutputName2=NameOfWave(wv)+"_index"
	
	Duplicate/o wv2dx $OutputName1
	
	if(MultiROI)
		Duplicate/o ROIIndex $OutputName2
	endif
	
	return $OutputName1
end

////////////////////////////////////////////////////////////////

Function SortPopByIndex(pop, index, [rev])
	wave pop, index
	variable rev
	
	variable nTraces = DimSize(pop,1), ii
	
	if(nTraces != dimsize(index,0))
		Abort "Dimension mismatch"
	endif
	
	if(paramisdefault(rev))
		rev=0
	endif
	
	duplicate /o/free index sort_index, sorted_index
	duplicate /o/free index sorted_index
	duplicate /o/free pop sorted_pop
	
	MatrixOP/o/free sorted_id=abs(index)-1
	
	if(rev>0)
		makeindex sorted_id, sort_index
	else
		makeindex/r sorted_id, sort_index
	endif
	
	
	
	For(ii=0;ii<nTraces;ii+=1)
	
		MultiThread sorted_pop[][ii]=pop[p][sort_index[ii]]
	
	EndFor

	IndexSort sort_index, index		//overwrites

	FastOP pop = sorted_pop		//overwrites
end


////////////////////////////////////////////////////////////////

Function ROIBeams2Traces(ROIBeams, index, ResultName)
	wave ROIBeams, index
	string ResultName
	
	Variable nROIs, ii, nTraces
	
	nROIs=wavemax(index)+1
	nTraces=DimSize(ROIBeams,1)
	
	Duplicate /o/free ROIBeams popwave
	redimension /n=(-1,nROIs) popwave
	Duplicate/o/free index TperR		// traces per ROI
	FastOP TperR=0
	FastOP popwave=0
	
	for(ii=0;ii<nTraces;ii+=1)
	
		popwave[][index[ii]]+=ROIBeams[p][ii]
		TperR[index[ii]]+=1
	
	endfor
	
	for(ii=0;ii<nROIs;ii+=1)
		
		popwave[][ii]/=TperR[ii]
	
	endfor
	
	Duplicate/o popwave $ResultName
	Duplicate/o tPerR idx2
End


///////////////////////////////////////////////////////

Function MultiROIBeams_prompt()
	string wvName, ROIname
	
	Prompt wvName, "Select image stack", popup, wavelist("*",";","DIMS:3")
	Prompt ROIName, "Select MultiROI mask", popup, wavelist("*",";","DIMS:2")
	
	Doprompt /help="MultiROI Beams" "MultiROI Beams", wvName, ROIName

	if(V_flag)	//Abort
		return -1
	endif
	
	Wave RB=MultiROIBeams($wvName,$ROIname)

	display /k=1
	appendimage RB
	
	label left "Pixel Nr."
	SetAxis/A/R left

end
