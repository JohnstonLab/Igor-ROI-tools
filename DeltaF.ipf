#pragma rtGlobals=1		// Use modern global access method.

///////////////////////////////////////////////////////////////////
//////////MultiDelta F over F fo 1D waves
////////////////////////////////////////////////////////////////////////
/// This function does not overwite the waves, it creates new waves with "_Deltaf" appened to the original name
// Display wyour traces in a graph, place cursors over an appropraite F0
//Make sure the graph is the top one, call function


Function MultiDeltaFs()
	
	string TNL, newname,name
	variable tracecount
	string tracewindow=winname(0,1,1) 				//name of window to perform Delta F on
	Variable count =0
	TNL= tracenamelist(tracewindow,";",1)
	tracecount= itemsinlist(TNL)  						// number of traces function will process
	
	Variable Apoint, Bpoint								// epoch where F is measured
	Apoint=xcsr(a)
	Bpoint=xcsr(b)
	
	display												// Create a graph for the new waves
		
	do
	
	name=stringfromlist(count,TNL)					// get the wave name
	newname=stringfromlist(count,TNL)+"_deltaF"		// create new name for the processed version
	Wave toacton =$name								
	duplicate/o toacton $newname								
	wave output=$newname
			
	Variable F
	
	wavestats/Q/R=(Apoint,Bpoint) output				// measure F for this wave
	F = V_Avg
	
	output=(output-F)/F								// perform Delta F on this wave
	output*=-1           // for inversion
	appendtograph output								// update output graph
	count+=1											// loop to next wave
	
	while (Count<tracecount)							// continue to loop untill all waves have been processed
//	KillVariables tracecount, count, Apoint, Bpoint
End

Menu "SARFIA"
	"1D MultiDeltaF", MultiDeltaFs()						// Menu and short cut to call function 
End	






function popdf()

	string wa
	variable s, e
	
	s=0
	e=10
	
	
	string list=wavelist("*QA*",";","DIMS:2")// now restricting to qa waves
	prompt wa, "Select Popwave", popup list
	prompt S, "Start point for F"
	prompt E, "End point for F"
	doprompt "POP DF", wa, s,e
			if(V_flag==1)
			abort
		endif
	
	wave w=$wa
	string notes=note(w)
	variable ky=dimsize(w,1)
	
	variable i
	
	Duplicate/FREE/o w, fwave
	
	for(i=0;i<ky;i+=1)
	
		duplicate/o/FREE/R=[][i] w,tt1
		redimension/N=(-1) tt1
		wavestats/Q/R=[s,e] tt1
		fwave[][i]=V_avg
	
	endfor

	string name= nameofwave(w)
	string outname=name+"_DF"
	
	duplicate/o/FREE w, temp
	
	matrixop/FREE temp1=temp-fwave
	matrixop/FREE temp2=temp1/fwave
	setscale/P x, 0, dimdelta(w,0), temp2
	note temp2,notes
	duplicate/o temp2, $outname

end