function updatestates( ...
            h, ...
            fgLastOutputs, ...
            fgState, ...
            fgWGNState, ...
            fgNumSampOutput, ...
            ppFilterInputState, ...
            ppFilterPhase, ...
            ppLastFilterOutputs, ...
            ppLinearInterpIndex, ...
            enableProbe, ...
            z1, ...  
            z1num, ...
            forceDisableProbe)
          
%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/05/14 15:01:05 $
            
s = h.FiltGaussian;
f = h.InterpFilter;

sData = s.PrivateData;
sData.LastOutputs = fgLastOutputs;
sData.State = fgState;
sData.WGNState = fgWGNState;
sData.NumSampOutput = fgNumSampOutput;
s.PrivateData = sData;

fData = f.PrivateData;
fData.FilterInputState = ppFilterInputState;
fData.FilterPhase = ppFilterPhase;
fData.LastFilterOutputs = ppLastFilterOutputs;
fData.LinearInterpIndex = ppLinearInterpIndex;
f.PrivateData = fData;

hData = h.PrivateData;
hData.EnableProbe = boolean(round(enableProbe));
h.PrivateData = hData;

storeoutput(s, z1(1:z1num, :).');

if hData.EnableProbe & ~isempty(hData.ProbeFcn) & ~forceDisableProbe
    hData.ProbeFcn(h);
end
