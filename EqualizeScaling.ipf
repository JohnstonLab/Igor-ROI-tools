#pragma rtGlobals=1		// Use modern global access method.

// The function CopyScaling(source, destination) applies point-by-point scaling from source in all 4 dimensions (+data full scale)
// to destination and copies the wavenote. Source and destination don't need to have the same number of dimensions. If source has
// 3 dimsensions, but destination only 2, then those 2 will be appropriately scaled. Copying the dimlabels messed
// everything up, so it is not implemented.
//
// CopySize(source, destination), in contrast, applies the length of the respecive axes from source to destination,
// regardless of the number of points. This is useful, for instance, after resampling or pixelating an image.


Function CopyScaling(source, destination)
wave source, destination

variable dimnums, dimnumd
string snote, dnote
snote = note(source)
dnote = note(destination)

if (cmpstr(snote,dnote) != 0)	//are wave notes different?
	note destination, snote
endif


dimnums = wavedims(source)
dimnumd = wavedims(destination)


setscale d -inf, inf, waveunits(source,-1), destination

setscale /P x, DimOffset(source, 0),  DimDelta(source, 0),WaveUnits(source, 0), destination

if ((dimnums > 0) && (dimnumd > 0))
	setscale /P y, DimOffset(source, 1),  DimDelta(source, 1),WaveUnits(source, 1), destination
	
endif

if  ((dimnums > 1) && (dimnumd > 1))
	setscale /P z, DimOffset(source, 2),  DimDelta(source, 2),WaveUnits(source, 2), destination
endif

if  ((dimnums > 2) && (dimnumd > 2))
	setscale /P t, DimOffset(source, 3),  DimDelta(source, 3),WaveUnits(source, 3), destination
endif

End


///////////////////////////////////////////////////////////////

Function CopySize(source, destination)
wave source, destination

variable dimnums, dimnumd
string snote, dnote
snote = note(source)
dnote = note(destination)

if (cmpstr(snote,dnote) != 0)	//are wave notes different?
	note destination, snote
endif


dimnums = wavedims(source)
dimnumd = wavedims(destination)


setscale d -inf, inf, waveunits(source,-1), destination

setscale /i x, DimOffset(source, 0),  DimDelta(source, 0)*DimSize(source,0),WaveUnits(source, 0), destination


if ((dimnums > 0) && (dimnumd > 0))
	setscale /i y, DimOffset(source, 1),  DimDelta(source, 1)*DimSize(source,1),WaveUnits(source, 1), destination	
endif

if  ((dimnums > 1) && (dimnumd > 1))
	setscale /i z, DimOffset(source, 2),  DimDelta(source, 2)*DimSize(source,2),WaveUnits(source, 2), destination
endif

if  ((dimnums > 2) && (dimnumd > 2))
	setscale /i t, DimOffset(source, 3),  DimDelta(source, 3)*DimSize(source,3),WaveUnits(source, 3), destination
endif

End