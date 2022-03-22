#pragma rtGlobals=3		// Use modern global access method and strict wave access.





function scrub(w)  // scrub now overwites the mask, so that it is compatible with roibuddy.

	wave w
	wave keep
	
	if (waveexists(keep)==0)
		Abort "You first need to generate a wave called keep that has 1 for each ROI to keep and 0 for deletion"
	endif
	
	imagestats w
	variable l=abs(V_min),lk=dimsize(keep,0),i,j, count, s
	
	if(l!=lk)
		Abort "keep wave doesn't match ROI image"
	endif
	
	duplicate/o w, temp

	
	count = 0
	for(i=0;i<lk;i+=1)
	
		if(keep[i]==0)
			
			j=(i+1)*-1		// convert to roi
			j+=count			// running count of how many we deleted
			matrixop/FREE temp1=replace(temp,j,1)	// delete this roi
			temp=temp1	
			s=i-count			//the value of the next ROI corrected for any we deleted
			shift1(temp,s)
			
			count+=1
		endif
	
	endfor
	
	note temp, "this ROI has been cleaned based on a keep wave"
	string name = nameofwave(w)//+"S"
	duplicate/o temp, $name
	killwaves temp
end



Function shift1(w,s)		// WARNING! this function necessarily overwrites the original wave

	wave w		//ROI wave
	variable s	// where to start shifting from 

	imagestats w
	
	duplicate/o/FREE w, nROI
	
	Variable l=abs(V_min), i, j, nj
	
	for(i=s;i<l;i+=1)				//now shift all ROI up by one from s
		
		j=(i+1)*-1
		nj=j+1
		
		matrixop/FREE temp=replace(w,j,nj)
		
		w=temp		
	endfor
	
//	return w
end



function join(wroi,corthr,dthr)

	wave wroi
	variable dthr, corthr		// distance and correlation theshold to join
	wave concerns
	
	variable i,l=dimsize(concerns,0)
	
	duplicate/o/FREE wroi, mask
	

	for(i=(l-1);i>-1;i-=1)

		if(concerns[i][3]< dthr)
			matrixop/FREE temp=replace(mask,-(concerns[i][0]+1),-(concerns[i][1]+1))
			shift1(temp,concerns[i][0])
			mask=temp

		endif
	endfor
	
	string name=nameofwave(wroi)
	duplicate/o mask, $name
	
	
end
	
	
function join2(wroi,a,b)
		
		wave wroi
		variable a,b
		
		duplicate/o/FREE wroi, mask
	
		if(a<b)		
			matrixop/FREE temp=replace(mask,-(b+1),-(a+1))
			shift1(temp,b)
		elseif(a>b)
			matrixop/FREE temp=replace(mask,-(a+1),-(b+1))
			shift1(temp,a)
		endif
		
		mask=temp
		string name=nameofwave(wroi)
		duplicate/o mask, $name
		
		string nn=nameofwave(wroi)
		string newn=nn[0,strlen(nn)-5]
		wave w=$newn
		extractrois(w,$name)

		
end
	
	
	///////////////////////////////

	
	
	
	
	
	/////////////////////////////////
	
//	duplicate/FREE/o wroi, mask
//	
//	for(i=(0);i>l;i+=1)
//	
//		if(concerns[0][3]<dthr)
//		
//			
//		
//			matrixop/FREE temp=replace(mask,concerns[0][0],concerns[0][1])
//			
//			shift1(temp,(concerns[i][1]+1))
//			
//			mask=temp
//			
//			
//			duplicate/o mask, $name
//			wave avemov
//			extractrois(avemov,$name)
//			
//		endif
//	
//	
//	endfor
//
//	
//	Setscale/P x,0,dimdelta(wroi,0), temp
//	Setscale/P y,0,dimdelta(wroi,1), temp
//	duplicate/o mask, $name
//	wave avemov
//	extractrois(avemov,$name)
end


