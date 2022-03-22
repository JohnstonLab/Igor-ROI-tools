#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function pat5(wav)

	wave wav
	
	string name=nameofwave(wav)+"P5"
	duplicate/o/FREE wav, outTEMP
	duplicate/o/FREE wav, w
	if(mod(dimsize(w,0),2)==1)
		print "point deleted for fourier"
		deletepoints/M=0 (dimsize(w,0)-1), 1, w 
	endif
	variable i,l=dimsize(w,1)
	for(i=0;i<l;i+=1)
		
		duplicate/o/R=[][i]/FREE w, temp
		redimension/N=(-1) temp
		
		wignertransform/Gaus=2 temp
		wave M_wigner
		
		duplicate/o/FREE/R=()(5) M_wigner, p5
		duplicate/o/FREE/R=()(1,4) M_wigner, noise
		imagestats noise									// gives the power at 5Hz as a multiple of that at 1-4Hz
		p5/=V_avg
		
		outTEMP[][i]=p5[p]
		
		killwaves/Z M_wigner
		
	endfor

	duplicate/o outtemp,$name

end