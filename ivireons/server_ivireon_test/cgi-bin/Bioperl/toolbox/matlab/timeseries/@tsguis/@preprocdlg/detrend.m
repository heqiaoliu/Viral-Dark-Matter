function detrend(h,ts,colinds,T)
%detrend
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:58:49 $

%% Recorder initialization
recorder = tsguis.recorder;

%% Detrending
ts.detrend(h.Detrendtype,colinds);
if strcmp(recorder.Recording,'on')
    T.addbuffer(xlate('%% Detrending time series'));
    T.addbuffer([ts.Name, '= detrend(', ts.Name, ',''' h.Detrendtype ...
           ''',[' num2str(colinds), ']);'],ts);
end        
