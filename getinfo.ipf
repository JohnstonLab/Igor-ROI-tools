#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// extracts info from the header of tiff files generated in scan image
function GetInfo()

	string mov
	NVAR FOV =root:packages:aroitools:FOVatzoom1
	string list=wavelist("*",";","DIMS:3")
	prompt mov, "Movie select", popup, list
	
	doprompt "pick your movie to scale ", mov
		if(V_flag==1)
				Abort
		endif	
	
	
	
	wave inst=$mov
	
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
	
	string xpos = notes[(strsearch(notes,"state.motor.absXPosition=",0)+25),(strsearch(notes,"state.motor.absYPosition=",0)-2) ]
	string ypos = notes[(strsearch(notes,"state.motor.absYPosition=",0)+25),(strsearch(notes,"state.motor.absZPosition=",0)-2) ]
	string zpos = notes[(strsearch(notes,"state.motor.absZPosition=",0)+25),(strsearch(notes,"state.motor.absZZPosition=",0)-2) ]
	string rotat = notes[(strsearch(notes,"state.acq.scanRotation=",0)+22),(strsearch(notes,"state.acq.scanShiftFast=",0)-2) ]
	string zstep = notes[(strsearch(notes,"state.acq.zStepSize=",0)+19),(strsearch(notes,"state.acq.numAvgFramesSaveGUI=",0)-2) ]
	
	make/o/N=(1,3) xyzcoords={{str2num(xpos)}, {str2num(ypos)},{str2num(zpos)}}
	
	print xpos +" xposition"
	print ypos +" yposition"
	print zpos +" zposition"
	print zstep+ " z step"
	print "and rotated "+rotat+"¼"
	

end




function getxyz()


	string mov
	
	string list=wavelist("*",";","DIMS:3")
	prompt mov, "Movie select", popup, list
	doprompt "pick your movie", mov
		if(V_flag==1)
				Abort
		endif	

	
	wave inst=$mov
	
	string notes=note(inst)
	
	string xpos = notes[(strsearch(notes,"state.motor.absXPosition=",0)+25),(strsearch(notes,"state.motor.absYPosition=",0)-2) ]
	string ypos = notes[(strsearch(notes,"state.motor.absYPosition=",0)+25),(strsearch(notes,"state.motor.absZPosition=",0)-2) ]
	string zpos = notes[(strsearch(notes,"state.motor.absZPosition=",0)+25),(strsearch(notes,"state.motor.absZZPosition=",0)-2) ]
	string rotat = notes[(strsearch(notes,"state.acq.scanRotation=",0)+22),(strsearch(notes,"state.acq.scanShiftFast=",0)-2) ]
	string zstep = notes[(strsearch(notes,"state.acq.zStepSize=",0)+19),(strsearch(notes,"state.acq.numAvgFramesSaveGUI=",0)-2) ]
	
	make/o/N=3 xyzcoords={str2num(xpos),str2num(ypos),str2num(zpos)}
	print xpos,	ypos,	zpos
	print xpos +" xposition"
	print ypos +" yposition"
	print zpos +" zposition"
	print zstep+ " z step"
	print "and rotated "+rotat+"¼"
		
end