#pragma rtGlobals=1		// Use modern global access method.

//all of this code for simply Resizing images by specifing the new pixel dimensions
function Resize()
	
		string inputwave						// for input wave
	
	string list=wavelist("*",";","MINCOLS:2")			// only find image stacks

	prompt inputwave, "Wave Select", popup list	// prompt for input wave
	doprompt "Resize", inputwave
			if(V_flag==1)
			abort
		endif
	
	wave input=$inputwave	
		
	variable x=dimsize(input,0)				// current size of the x dimension
	variable y=dimsize(input,1)				// current size of the y dimension
	
	variable xnew = x							// variables for the new pixels, set to display the old ones in the prompt
	variable ynew = y
	
	prompt xnew, "new x pixels"			
	prompt ynew, "new y pixels"
	doprompt "new dimensions", xnew, ynew
			if(V_flag==1)
			abort
		endif
		
	string newname=inputwave+"_SZ"			// output wave name
	
	variable nx= (xnew-1)/(x-1)					// calc for rescaling
	variable ny=(ynew-1)/(y-1)
		
		
	imageinterpolate/F={nx,ny}/DEST=$newname bilinear input   // image interpolation
	

	end
	

Menu "Analysis"
			"Resize....", Resize()
End