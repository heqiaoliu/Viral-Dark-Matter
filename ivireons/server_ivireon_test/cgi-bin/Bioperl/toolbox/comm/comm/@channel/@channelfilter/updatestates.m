function updatestates( ...
            h, ...
            state, ...
            enableProbe, ...
            pathGains, ...
            forceDisableProbe)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:28 $

updatetapgains(h, pathGains.');

hData = h.PrivateData;
hData.EnableProbe = boolean(round(enableProbe));
hData.State = state;
h.PrivateData = hData;

if hData.EnableProbe & ~isempty(hData.ProbeFcn) & ~forceDisableProbe
    hData.ProbeFcn(h);
end

