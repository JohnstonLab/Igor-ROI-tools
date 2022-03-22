#pragma TextEncoding = "MacRoman"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "Advanced ROI tools"



//Procedure for measuring ÆF/f along the length of a dendrite



function lineProfile(wn,ch,wid)
	
	string wn
	variable ch		// choice, 0 for df , 1 for diff image, 2 for raw
	variable wid		// width of profile

	variable bs=0, be=1000	// baseline start and end

	wave W_Ypoly0
	if (waveexists(W_Ypoly0)==1)
		killwaves/Z W_Ypoly0,W_Xpoly0
	endif
	
	if (ch==0)
		deltaim($wn,bs,be) 		// get dletaF image and average
		wave wdf=$wn+"df"
	elseif(ch==1)
		diffim($wn,bs,be) 		// get dletaF image and average
		wave wdf=$wn+"dif"
	
	elseif(ch==2)
		imagetransform averageimage $wn
		Wave M_AveImage, M_StdvImage 		// get raw image and average
		string name=wn+"Av"
		duplicate/o M_AveImage, $name		
		wave wdf=$wn
	endif	
		
	wave wav=$wn+"av"
	
	variable dz=dimdelta($wn,2)
	
	display/N=LineProfiler/K=1 
	appendimage wav
	imagestats wav

	ModifyImage $wn+"av" ctab= {0,(V_max),Grays,0} //add back V_max/4
	GraphWaveDraw/o
	
	PauseForUser LineProfiler
	wave W_Ypoly0, W_Xpoly0
	
	ImageLineProfile/P=-2 xwave=W_Xpoly0, yWave=W_Ypoly0, srcwave=wdf, width=wid
	wave M_ImageLineProfile

	// calculate length of drawn line	
	duplicate/FREE W_Xpoly0, x1,x0
	duplicate/FREE W_Ypoly0, y1,y0	
	variable lx=dimsize(x0,0)
	deletepoints/M=0 0,1, x1,y1
	deletepoints/M=0 lx-1,1, x0,y0
	x0-=x1
	y0-=y1
	x0=x0^2
	y0=y0^2
	x0=sqrt(x0+y0)
	variable l=sum(x0)
	
	
	
	// scale profile
	setscale/I x,0,l,M_ImageLineProfile
	setscale/P y,0,dz,M_ImageLineProfile
	matrixtranspose M_ImageLineProfile
	duplicate/o M_ImageLineProfile, profile
	
	// profile of events from time series
		
	// get profile of events
	duplicate/o/FREE profile, aa	
	duplicate/o/FREE/R=[0,45][] profile, base
	
	matrixop/o/FREE baseAv=sumcols(base)/((45-0)+1) // get average of baseline for each row
	base-=baseav[0][q]						// next 5 calculate SD
	base=base^2
	base/=dimsize(base,0)
	matrixop/o/FREE baseSD=sumcols(base)
	basesd=sqrt(basesd)
	
	aa-=baseav[0][q]				// convert aa to SNR
	aa/=baseSD[0][q]
	
	matrixop/o/FREE great=greater(aa,2)	// only use events that are >3 SNR
	MatrixFilter /N=3 median great	// despeckle, i.e. remove single pixel events as real events should last some time and be in more than 1 row
	duplicate/o/FREE profile bb
	bb*=great
	matrixtranspose bb
	matrixop/o eventProfile=sumrows(bb)
	setscale/I x,0,l,eventProfile


	// tidy up
	wave W_LineProfileX, W_LineProfiley
	killwaves/Z M_ImageLineProfile, W_LineProfileX, W_LineProfiley, M_VolumeTranspose, M_AveImage,M_StdvImage
	
	
	//graph stuff
	display/K=1
	appendimage/T wav
	appendtograph/T W_YPoly0 vs W_XPoly0
	ModifyGraph lsize=2,axisEnab(left)={0.65,1}
	appendimage/L=line profile
	ModifyGraph axisEnab(line)={0,0.6},freePos(line)=0, axisEnab(bottom)={0,0.9}
	AppendToGraph/B=HorizCrossing/L=line/VERT eventProfile
	ModifyGraph noLabel(HorizCrossing)=2,axThick(HorizCrossing)=0
	ModifyGraph axisEnab(HorizCrossing)={0.91,1},freePos(HorizCrossing)=0
	modifyGraph standoff=0
	
	Label left "µm"
	Label top "µm"
	Label line "µm"
	ModifyGraph lblPos(line)=46
	Label bottom "Time (s)"
	ModifyImage profile ctab= {0,*,YellowHot,0}
	Tag/C/N=text1/F=0/B=1/X=0.00/Y=2.00/L=1/TL={lineRGB=(65535,65535,0)} W_YPoly0, 0,"\\K(65535,65535,0)0"
	Tag/C/N=text2/F=0/B=1/X=0.00/Y=2.00/L=1/TL={lineRGB=(65535,65535,0)} W_YPoly0, (lx-1),"\\K(65535,65535,0)"+num2str(round(l))

	
	
end



function deltaIm(w,s,e)	// generates a ÆF/F image of w and the average

	wave w
	variable s,e
	
	duplicate/o/FREE /R=[][][s,e] w, temp
	imagetransform averageimage temp
	Wave M_AveImage, M_StdvImage
	
	variable dx=dimdelta(w,0),dy=dimdelta(w,1)
	
	setscale/P x, 0, dx, M_AveImage
	setscale/P y, 0, dy, M_AveImage
	
	duplicate/o/FREE w, temp1
	temp1-=M_AveImage[p][q]
	temp1/=M_AveImage[p][q]
	string nam=nameofwave(w)+"DF"
	duplicate/o temp1, $nam
	string name=nameofwave(w)+"Av"
	duplicate/o M_AveImage, $name
end

function diffIm(w,s,e)	// generates a difference image of w

	wave w
	variable s,e
	
	duplicate/o/FREE /R=[][][s,e] w, temp
	imagetransform averageimage temp
	Wave M_AveImage, M_StdvImage
	
	variable dx=dimdelta(w,0),dy=dimdelta(w,1)
	setscale/P x, 0, dx, M_AveImage
	setscale/P y, 0, dy, M_AveImage
	
	duplicate/o/FREE w, temp1
	temp1-=M_AveImage[p][q]
	
	string nam=nameofwave(w)+"dif"
	duplicate/o temp1, $nam
	string name=nameofwave(w)+"Av"
	duplicate/o M_AveImage, $name
end