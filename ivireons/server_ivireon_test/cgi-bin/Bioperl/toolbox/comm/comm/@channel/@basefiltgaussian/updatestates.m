function updatestates( ...
            h, ...
            lastOutputs, ...
            state, ...
            WGNState, ...
            numSampOutput, ...
            enableProbe, ...
            forceDisableProbe)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:03 $

hData = h.PrivateData;
hData.LastOutputs = lastOutputs;
hData.State = state;
hData.WGNState = WGNState;
hData.NumSampOutput = numSampOutput;
hData.EnableProbe = boolean(round(enableProbe));
h.PrivateData = hData;

if hData.EnableProbe & ~isempty(hData.ProbeFcn) & ~forceDisableProbe
    hData.ProbeFcn(h);
end


