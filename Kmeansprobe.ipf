#pragma rtGlobals=1		// Use modern global access method.



Function KMProbeROI()

string datalist=wavelist("*",";","DIMS:3")
string roilist=wavelist("*",";","DIMS:2")
string roiname, dataname
variable ROInum, n, smth, start, en
roinum=-1
smth=20
start=-inf
en=inf
prompt start, "frame start"
prompt en, "frame end"
prompt dataname, "Which data set?", popup datalist
prompt roinum, "which ROI? (include -)"
prompt roiname, "Which mask?", popup roilist
prompt n, "number of clusters?, 0 will generate FOM"
prompt smth, "smoothing window, only used in clustering, does not affect data"
doprompt "pick ROI Mask and roi to explore" dataname, roiname, roinum, smth, n, start, en

	if(V_flag==1)
		abort
	endif

wave rois=$roiname
wave data=$dataname
variable h=dimsize(rois,1) // y dim
variable w=dimsize(rois,0) // x dim
variable d=dimsize(data,2) // z dim
variable i,j, acol, arow, brow,bcol

multiroi(rois,"roi")
wave roi

if(roinum==0)
	roi*=-1
	imagethreshold/I/T=1 roi
	wave M_Imagethresh
else
	matrixop/o/FREE temp=replace(roi, roinum, 1000) 
	imagethreshold/I/T=999 temp
	wave M_Imagethresh
endif

// ++++++++++++++ index wave
duplicate/o roi, index
index=p
j=0
for(i=0;i<h;i+=1)
index[][i]+=j
j+=w
endfor




imagetransform/R=M_Imagethresh roiTo1D index
wave W_roi_to_1d

duplicate/o W_roi_to_1d, PixIndex

wavestats/q PixIndex
variable numpix=V_npnts

make/o/n=(d,numpix) pixels

for(i=0;i<numpix;i+=1)

FindValue/V=(PixIndex[i]) index

acol=floor(V_value/w)
arow=V_value-acol*w

Matrixop/o/free Beams = Beam(data,arow,acol)

multithread pixels[][i]=beams[p]

Endfor



duplicate/o/FREE pixels, transp 

//matrixtranspose transp
duplicate/o/R=[start,en][] transp, parse
Smooth smth, parse

variable dist, nclu

// for generating a figure or merit

if(n==0)
	Make/o/N=(25) FOM =nan
	
	display/K=1 FOM
	SetScale/P x 2,1,"", FOM
	ModifyGraph grid(bottom)=1,nticks(bottom)=10,minor(bottom)=1;
	doupdate
	
	For(i=0;i<(60);i+=1)
	 
	Kmeans/CAN/OUT=2/ncls=(i+2) parse //FPclustering/NOR/MAXC=(i+2) parse
	wavestats/q W_KMDispersion
	
	FOM[i]=V_max
	print num2str(i)
	doupdate
	Endfor
	
	differentiate FOM/D=temp1
	differentiate temp1/D=temp2
	Findlevel/ EDGE=2 temp2, 0
	n=ceil(V_levelx)
	


	// ++++++++++++++I'm here


	doprompt "Pick number of clusters, 1st inflection is suggested" n
	
		if(V_flag==1)
			abort
		endif

endif
	
Kmeans/CAN/OUT=2/ncls=(n) parse//FPclustering/NOR/MAXC=(n) transp

wave W_KMMembers

roibeams2traces(pixels, W_KMMembers, "AVG_Clust")

variable num=dimsize(pixels,1)



// put clusters back on the graph 
 duplicate/o roi, roiSplit
 
 roisplit=0
 
 for(i=0;i<numpix;i+=1)

FindValue/V=(PixIndex[i]) index

bcol=floor(V_value/w)
brow=V_value-bcol*w
 
roisplit[brow][bcol]=W_KMMembers[i]+1
 
 endfor
 
 
 // Display split rois
 newimage/K=1 roisplit
 ModifyImage roiSplit ctab= {*,*,Geo32,0}
 ModifyGraph axisEnab(top)={0,0.9}
 ColorScale/C/N=text1/A=RC/X=0.59/Y=0.78


// plot clustered traces
For(i=0;i<n;i+=1)

Display/K=1 as "Cluster"+num2str(i+1)

for(j=0;J<num;j+=1)
if (W_KMMembers[j]==i)
appendtograph pixels[][j]
endif
 endfor
 appendtograph AVG_Clust[][i]
 ModifyGraph rgb(AVG_Clust)=(0,0,0)
 ModifyGraph lsize(AVG_Clust)=3
 

 ENDfor

roisplit*=-1



 killwaves/z W_FPClusterIndex, M_Imagethresh, W_ROI_To_1D,  W_FPCenterIndex, temp1, temp2
 
END