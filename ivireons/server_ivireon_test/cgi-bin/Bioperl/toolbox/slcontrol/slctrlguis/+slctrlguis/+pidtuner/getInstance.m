function h = getInstance(GCBH)
% PID helper function

% This function returns the handle of Tuner associated with block GCBH

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/03/26 17:53:53 $

h = [];
hPIDTuner = findall(0,'Tag','PIDTunerBLK','HandleVisibility','off');
if ~isempty(hPIDTuner)
    for ct=1:length(hPIDTuner)
        hObj = get(hPIDTuner(ct),'UserData');
        if hObj.DataSrc.GCBH == GCBH
            h = hObj;
            break
        end
    end
end