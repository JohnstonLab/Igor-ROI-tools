#pragma rtGlobals=1		// Use modern global access method.
#include <All IP Procedures>
#include <Image Saver>

/////////////////////////////////////////////////////////////
///////////// Kalman filter for image stacks of time series data///////
/////////////////////////////////////////////////////////////
///////the prediction bias determins the amount of filtering//////////////
//////the noise estimate has little effect on the outcome/////////////
/////////////////////////////////////////////////////////////
////////Adapted from some imagej code////////////////////////

function kalman()

	//Initialize variables and input waves
	string inputwave
	Variable G = 0.8		//Filter gain
	Variable V = 0.06		// error estimate
	
	string list=wavelist("*",";","DIMS:3")
	prompt inputwave, "Wave Select", popup list
	prompt G, "Prediction Bias"
	prompt V, "Noise Estimate"
	doprompt "Kalman Filter", inputwave, G,V
			if(V_flag==1)
			abort
		endif
			
	wave input=$inputwave			// reference to wave being filtered
	redimension/s input			// convert to single floating point
	
	variable z = dimsize(input,2)	//counts the number of frames
	
	//Generate prediction seed
	Duplicate/FREE/o input, predicted
	redimension/N=(-1,-1,0) predicted
	multithread predicted=input[p][q][0]
	
	//Generate other variables
	duplicate/FREE/o predicted, one, observed
	one=1
	
	//Generate error seed
	Duplicate/Free/o predicted, Perror
	Perror=V
	Duplicate/FREE/o Perror, errorEst
	
	//Generate ouput wave
	Duplicate/FREE/o input, output
	
	variable i
	for(i=0;i<z;i+=1)		//Do filter
		multithread	observed=input[p][q][i]		//Get observed values
		
		matrixop/FREE/o Kalman=Perror/(Perror+errorEst)			//Calculate Kalman gain
		
		matrixop/FREE/o corrected= g*predicted+(1-g)*observed+kalman*(observed-predicted)		//calcuate corrected image
		
		matrixop/FREE/o correctedError = Perror*(one-kalman)					// calculate corrected noise estimate 
		
		matrixop/o Perror = correctedError										//Update predicted noise 
		Matrixop/o predicted = corrected											//Update prediction
		multithread output[][][i]=corrected[p][q]									//append corrected image to output stack	
		
	endfor
	
	redimension output
	String outputname=inputwave+"_Kal"	//Give filtered wave new name
	Duplicate/o output, $outputname
	
	newimage/k=1 $outputname 		//Display filtered wave with slider
	WMAppend3DImageSlider();

end

menu  "Analysis"
			"Kalman Filter", kalman()
End




function kalmanProg(w,G)

	//Initialize variables and input waves
	wave w
	Variable G 		//Filter gain
	Variable V = 0.06		// error estimate

			
	wave input=w		// reference to wave being filtered
	redimension/s input			// convert to single floating point
	
	variable z = dimsize(input,2)	//counts the number of frames
	
	//Generate prediction seed
	Duplicate/FREE/o input, predicted
	redimension/N=(-1,-1,0) predicted
	multithread predicted=input[p][q][0]
	
	//Generate other variables
	duplicate/FREE/o predicted, one, observed
	one=1
	
	//Generate error seed
	Duplicate/Free/o predicted, Perror
	Perror=V
	Duplicate/FREE/o Perror, errorEst
	
	//Generate ouput wave
	Duplicate/FREE/o input, output
	
	variable i
	for(i=0;i<z;i+=1)		//Do filter
		multithread	observed=input[p][q][i]		//Get observed values
		
		matrixop/FREE/o Kalman=Perror/(Perror+errorEst)			//Calculate Kalman gain
		
		matrixop/FREE/o corrected= g*predicted+(1-g)*observed+kalman*(observed-predicted)		//calcuate corrected image
		
		matrixop/FREE/o correctedError = Perror*(one-kalman)					// calculate corrected noise estimate 
		
		matrixop/o Perror = correctedError										//Update predicted noise 
		Matrixop/o predicted = corrected											//Update prediction
		multithread output[][][i]=corrected[p][q]									//append corrected image to output stack	
		
	endfor
	
	redimension output
	String outputname=nameofwave(w)+"_Kal"	//Give filtered wave new name
	Duplicate/o output, $outputname

end
