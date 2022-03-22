#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function stacks(w)

	wave w
	
	variable i,l=dimsize(w,2),j=0
	duplicate/o/FREE w, tempout
	redimension/n=(-1,-1,l/3) tempout
	
	for(i=0;i<l;i+=3)
	
		duplicate/o/R=[][][i+1]/FREE w, temp
		tempout[][][j]=temp[p][q][0]	
		j+=1
	endfor
	
	string name=nameofwave(w)+"AA"
	duplicate/o tempout, $name

end