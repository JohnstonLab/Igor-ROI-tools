#pragma rtGlobals=3		// Use modern global access method and strict wave access.
function align(w)

	wave w
	string notes=note(w)
	string rotat = notes[(strsearch(notes,"state.acq.scanRotation=",0)+23),(strsearch(notes,"state.acq.scanShiftFast=",0)-2) ]
	string ymult = notes[(strsearch(notes,"state.acq.scanAngleMultiplierSlow=",0)+34),(strsearch(notes,"state.acq.scanRotation=",0)-2) ]
	
	variable rot=str2num(rotat)
	variable ratio=str2num(ymult)
	variable xx=dimsize(w,0), yy=dimsize(w,1),ny=xx*ratio
	
	variable dif=-70.6-rot
	print dif
	imagetransform averageimage w
	
	wave M_AveImage, M_StdvImage
	
	variable nx= (xx-1)/(xx-1)					// calc for rescaling
	variable newy=(ny-1)/(yy-1)
		
	imageinterpolate/F={nx,newy}/DEST=scaled bilinear M_AveImage
	
//	Setscale/P x,0,dimdelta(w,0), M_AveImage
//	Setscale/P y,0,dimdelta(w,0), M_AveImage
	
	imagerotate/A=(dif)/E=0/o scaled

	killwaves M_AveImage, M_StdvImage

end

