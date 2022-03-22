#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function aveREPs(w, n)

	wave w
	variable n
	
	variable l=dimsize(w,2), k=l/n, j,i
	
	if(mod(l,n)!=0)
		Abort "there aren't "+num2str(n)+"repeats in this movie"
	endif
	
	j=0
	for(i=0;i<l;i+=k)
		string tempname="S_"+num2str(j)
		Duplicate/o/R=[][][i,i+(k-1)] w, $tempname
		j+=1
	
	endfor
	
	string list=wavelist("S_*",";","")
	print list

	wave s_0
	//s0*=1/n
	for(i=1;i<n;i+=1)
	
		wave a=$stringfromlist(i,list)
		s_0+=a
		killwaves $stringfromlist(i,list)
	endfor
	s_0/=n
	duplicate/o S_0, aveMov
	killwaves s_0

end