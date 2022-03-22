#pragma rtGlobals=1		// Use modern global access method.
#include <WindowBrowser>
#include "MultiROIBeams"
#include "MultiRoi"
////////////////////////////////////////////////////
//ThersholdROI///////////
// Generate an ROI mask by manually thresholding an image with histogram and slider
/// Background (or what you want to exclude) should be yellow, and make sure keep overlay is selected
///////////////////////////////////////////////////

function ThreshROI()


string input, inlist
variable choice =0
inlist=wavelist("*",";","DIMS:3")
prompt input, "movie", popup inlist
prompt choice, "AV or SD"

doprompt "some choices", input, choice
	if(V_flag==1)
		abort
	endif

wave new=$input
String outname=input+"_ThROI"

if(choice==0)
	imagetransform/o averageimage new


	newimage/K=1/N=Threshold M_AveImage

	

	ModifyGraph/W=Threshold expand=3

	WMCreateImageThresholdGraph();
	pauseforuser WMImageThresholdGraph
	killwindow Threshold

		if((waveexists(M_AveImage_bin))==0)
			Abort "keep overlay"
		endif


	wave M_AveImage_bin
	M_AveImage_bin/=255



	wave M_AveImage_bin
	redimension/U/B M_AveImage_bin

	multiROI(M_AveImage_bin, outname) 

elseif(choice==1)
imagetransform/o averageimage new


	newimage/K=1/N=Threshold M_StdvImage

	

	ModifyGraph/W=Threshold expand=3

	WMCreateImageThresholdGraph();
	pauseforuser WMImageThresholdGraph
	killwindow Threshold

		if((waveexists(M_StdvImage_bin))==0)
			Abort "keep overlay"
		endif


	wave M_StdvImage_bin
	M_STDVImage_bin/=255



	wave M_StdvImage_bin
	redimension/U/B M_StdvImage_bin

	multiROI(M_StdvImage_bin, outname) 

endif

//duplicate/o M_AveImage_bin, $outname

killwaves/z M_AveImage_bin,M_AveImage, M_StdvImage, M_StdvImage_bin

END


/////////////////////////////////////////////
//// estimate peak noise correlation of the background 
/// for use with Corr ROI
///////////////////////////////////////////
function noiseCor()

Variable down=1
string input, inlist
inlist=wavelist("*",";","DIMS:3")
prompt input, "movie", popup inlist
prompt down, "downsample, match for cor_roi"
doprompt "some choices", input, down

	if(V_flag==1)
		abort
	endif

wave new=$input
variable z=dimsize(new,2)

imagetransform/o averageimage new

newimage/K=1/N=backgroundNoise M_AveImage
ModifyGraph/W=backgroundNoise expand=3

WMCreateImageROIPanel();
pauseforuser WMImageROIPanel
killwindow backgroundNoise

	if((waveexists(M_ROImask))==0)
		Abort "pick some background"
	endif
	
duplicate/FREE new, temp
redimension/N=(-1,-1) temp	

redimension/U/B M_ROImask

imagetransform/R=M_ROImask roito1d temp



wave W_ROI_to_1d
variable d=(dimsize(W_ROI_to_1d,0))

make/FREE/N=(d,z) cor
variable i,j,k


for(i=0;i<z;i+=1)
temp[][]=new[p][q][i]
imagetransform/R=M_ROIMASK roito1d temp
cor[][i]=W_ROI_to_1d[p]
endfor



// transpose vol so it can be viewed in pop browser 
MatrixTranspose cor 
Resample/DOWN=(Down) cor

matrixop/o bkg=sumrows(cor)
variable n
bkg/=d
wavestats/q bkg
n=V_avg

variable dz=dimsize(cor,0)
// perform pearson correlation on pixel by pixel
make/FREE/N=(d,d) correlation
make/FREE/N=(dz) t1,t2

for(j=0;j<d;j+=1)
t1=cor[p][j]
for(k=0;k<d;k+=1)
t2=cor[p][k]
correlation[j][k]=StatsCorrelation(t1,t2)
endfor
endfor

matrixop/o mm=replace(correlation,1,nan)
//make/FREE/N=(d) w1=1

//matrixop/o sub=diagonal(w1)
//matrixop/o mm=correlation-sub
wavestats/Q mm

print "highest correlation of noise is "+num2str(V_max)+", calculated from "+num2str(d)+" pixels, downsampled by "+num2str(down)
Print "average background value is "+num2str(n)
killwaves/z M_AveImage, M_StdvImage,W_ROI_to_1d, M_roimask,mm
End


//////////////////////////////////////////////////////
// Calculate roi/////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
function CorROI()

Variable corrThresh, down, stim
down=1
string input, inlist
inlist=wavelist("*",";","DIMS:3")
prompt input, "movie", popup inlist
prompt Corrthresh, "correlation threhold"
prompt stim, "stimulation start?"
prompt down, "downsample for z dimension = much faster"
doprompt "some choices", input, corrthresh, down, stim
	if(V_flag==1)
		abort
	endif

wave new=$input

print "correlation threhold of = "+num2str(corrthresh)
print "Downsampled by= "+num2str(down)

imagetransform/o averageimage new

newimage/K=1/N=Threshold M_AveImage
ModifyGraph/W=Threshold expand=3

WMCreateImageThresholdGraph();
pauseforuser WMImageThresholdGraph
killwindow Threshold

	if((waveexists(M_AveImage_bin))==0)
		Abort "keep overlay"
	endif


wave M_AveImage_bin
M_AveImage_bin/=255


wave M_AveImage_bin
duplicate/FREE M_AveImage, frame
frame=M_AveImage_bin
redimension/U/B frame


variable z=dimsize(new,2)
variable h=dimsize(new,1)
variable w=dimsize(new,0)

variable i, j,k

duplicate/FREE new, temp

//make index wave to match back pixel locations
redimension/N=(-1,-1) temp
duplicate/O temp, inde
inde[][]=p+1
make/FREE/N=(h) sca=p*w
inde[][]+=sca[q]

// get the number of pixels in thrsholded image
imagetransform/R=Frame roito1d temp
wave W_ROI_to_1d
variable y=dimsize(W_ROI_to_1d,0)
print num2str(y)+" pixels being processed"
make/FREE/N=(y,z) pixels, index
redimension/N=(-1) index

imagetransform/R=Frame roito1d inde
index[][i]=W_ROI_to_1d[p]

//extract individual pixels in col major order
for(i=0;i<z;i+=1)
temp[][]=new[p][q][i]
imagetransform/R=Frame roito1d temp
pixels[][i]=W_ROI_to_1d[p]
endfor

// transpose vol so it can be viewed in pop browser 
MatrixTranspose pixels 
DeletePoints 0,(stim-30), pixels
Resample/DOWN=(Down) pixels

variable pixelz=dimsize(pixels,0)
// perform pearson correlation on pixel by pixel
make/FREE/N=(y,y) correlation
make/FREE/N=(pixelz) t1,t2
tic()
for(j=0;j<y;j+=1)
t1=pixels[p][j]
for(k=0;k<y;k+=1)
t2=pixels[p][k]
correlation[j][k]=StatsCorrelation(t1,t2)
endfor
endfor

toc()

// selection of correlation threshold 
imagethreshold/T=(Corrthresh) correlation
wave M_imagethresh

M_imagethresh/=255

redimension/S M_imagethresh
duplicate/FREE M_imagethresh, pixs

matrixop/FREE count = sumrows(M_imagethresh)
redimension/S/N=(-1) count

pixs[][]*=index[q]

matrixop/FREE pixsy=replace(pixs, 0,nan)

variable ii

//roisize=2 /////temporary
make/o/N=0 bb

for(ii=0;ii<y;ii+=1)

 if((count[ii])>2)

 string name="R_"+num2str(ii)
 make/FREE/N=(y) ROI=pixsy[ii][p]
wavetransform zapnans roi
// duplicate/o roi, $name
 concatenate/NP {roi},bb
killwaves/Z roi 
 endif

endfor



variable many=dimsize(bb,0)
variable kk, pp

duplicate/FREE inde, out
out=1
redimension/s out

for(kk=0;kk<many;kk+=1)
pp=bb[kk]

matrixop/FREE mask=Replace(inde,pp,nan)
out*=mask
endfor

matrixop/FREE CORR_ROI=replacenans(out,0)



//imagethreshold/O/T=0 CORR_ROI

string outname=input+"_Co"+num2str(corrThresh)+"_ROI"

multiROI(CORR_ROI, outname) 

//duplicate/o corr_Roi, $outname

newimage/K=1 $outname

killwaves/z M_AveImage, M_StdvImage, M_aveimage_bin, inde, M_imagethresh, W_ROI_to_1d, bb,mm

End