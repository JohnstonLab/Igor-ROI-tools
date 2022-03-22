#pragma rtGlobals=1		// Use modern global access method.
#pragma IgorVersion = 6.1
//#include "Sarfia"

Function RegisterStack(picwave, [target])

	wave picwave
	string target
	variable dims, type
	string info, name
	
	info = waveinfo(picwave,0)
	type = NumberByKey("NUMTYPE", info)
	//	NUMTYPE	A number denoting the numerical type of the wave:
	//		1:	Complex, added to one of the following:
	//		2:	32-bit (single precision) floating point
	//		4:	64-bit (double precision) floating point
	//		8:	8-bit signed integer
	//		16:	16-bit signed integer
	//		32:	32-bit signed integer
	//		64:	Unsigned, added to 8, 16 or 32 if wave is unsigned
	dims = wavedims(picwave)
	name = Nameofwave(picwave)
	
	if(paramisdefault(target))
		target = name+"_reg"
	endif
	
	
	if (dims != 3)
		DoAlert 0, "<"+name+"> ins not a stack. Aborting RegisterStack." 
		return -1
	endif
	
	duplicate /o picwave, regcalcwave
	
	redimension /s regcalcwave		//redimension to single precision float, as ImageRegistration allows only that
	
	duplicate /o/R=[][][0,50] regcalcwave, ref1		// modified by jamie 10/11/14 to take an averag of the 1st 50 frames
	imagetransform averageimage ref1		// modified by jamie 10/11/14 to take an averag of the 1st 50 frames
	wave M_aveimage									// modified by jamie 10/11/14 to take an averag of the 1st 50 frames
	wave ref=M_aveimage					// modified by jamie 10/11/14 to take an averag of the 1st 50 frames
	redimension/S /N=(-1,-1) ref
	
	
	imageregistration /q /stck /csnr=0 /refm=0 /tstm=0 testwave=regcalcwave, refwave=ref
	wave m_regout
	
	imagestats/q picwave
	MatrixOP/o/free w_NaNBusted = ReplaceNaNs(m_regout, V_min)	//replace NaN's with minimum value

	copyscaling(regcalcwave, w_NaNBusted)
	duplicate /o w_NaNBusted, $target
	
	killwaves /z  ref, regcalcwave, M_Regout, M_Regmaskout//, M_RegParams, W_RegParams  
end


////////////////////////////////////////////////

Function Reg2(picwave)
wave picwave

string result = nameofwave(picwave)

RegisterStack(picwave, target=result)

print "Completed registration of <"+result+">"

end

////////////////////////////////////////////////

Function QuickReg()

string topwave

GetWindow kwTopWIn, wavelist
wave /t w_wavelist

topwave = w_wavelist[0][0]

Reg2($topwave)

killwaves /z w_wavelist
end

