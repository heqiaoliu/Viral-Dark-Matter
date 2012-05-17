function interp(h,ts,colind,T)
%interp
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2005/11/27 22:42:54 $


%% Recorder initialization
recorder = tsguis.recorder;

%% Interpolate missing data
otherTsPath = h.InterptsPath;
if isempty(otherTsPath) % Auto interp
    ts.resample(ts.Time);    
else % Interp from another time series
    warning('off','interpolation:interpolation:noextrap')
    otherTsList = h.ViewNode.getRoot.getts(otherTsPath);
    otherTs = otherTsList{1}.copy;
    otherTs.resample(ts.Time);
    I = isnan(ts.Data);
    if any(I(:))
        ts.Data(I(:)) = otherTs.Data(I(:));
    else
        return;
    end
    warning('on','interpolation:interpolation:noextrap')
end

%% Record action
if strcmp(recorder.Recording,'on')
   T.addbuffer(xlate('%% Interpolating missing data'));
   if isempty(otherTsPath)
       T.addbuffer([ts.name, ' = resample(', ts.Name, ',' ts.Name, '.Time);'],ts);
   else
       T.addbuffer(sprintf('%s = resample(%s,%s.Time)',otherTsList{1}.Name,otherTsList{1}.Name,ts.Name),ts,otherTsList{1});
       T.addbuffer(['I = isnan(' ts.Name '.Data);']);
       T.addbuffer(sprintf('%s.Data(I(:)) = %s.Data(I(:));',ts.Name,otherTsList{1}.Name));
   end
end
