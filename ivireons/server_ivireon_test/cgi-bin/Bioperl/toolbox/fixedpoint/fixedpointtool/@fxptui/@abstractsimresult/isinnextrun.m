function b = isinnextrun(h)
%ISINNEXTRUN True this result will be updated during the next run

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/17 21:49:49 $

b = true;
if(isempty(h.Run)); return; end
appdata = SimulinkFixedPoint.getApplicationData(h.getbdroot);
if(isempty(appdata)); return; end
b = fxptui.str2run(h.Run) == appdata.ResultsLocation;

% [EOF]
