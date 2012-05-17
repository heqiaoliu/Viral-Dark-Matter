function SnapShotTimes = evalSnapshotVector(snapshottimes_Str)
% EVALSNAPSHOTVECTOR 
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:35:54 $

if ~isempty(snapshottimes_Str)
    SnapShotTimes = str2num(snapshottimes_Str); %#ok<ST2NM>
    if isempty(SnapShotTimes)
        try
            SnapShotTimes = evalin('base',snapshottimes_Str);
        catch Ex %#ok<NASGU>
            ctrlMsgUtils.error('Slcontrol:linearizationtask:InvalidSnapshotTimes')
        end
    end
else
    ctrlMsgUtils.error('Slcontrol:linearizationtask:InvalidSnapshotTimes')
end