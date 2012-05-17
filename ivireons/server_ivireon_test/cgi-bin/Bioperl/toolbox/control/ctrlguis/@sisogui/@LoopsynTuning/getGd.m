function Gd = getGd(this)
%getGd Get desired target loopshape

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:34:16 $


if strcmp(this.TuningPreference{this.idxC},'TargetLoopShape')
    % Get desired loop shape
    try
        Gd = evalin('base',this.TargetLoopShapeData(this.idxC).TargetLoopShape);
    catch
        errordlg('Target loop shape must be a valid single-input single-output LTI object.')
    end
else
    % Create desired loop shape from bandwisth requirement
    try
        B = evalin('base',this.TargetBandwidthData(this.idxC).TargetBandwidth);
        Gd = zpk([],0,B);
    catch
        errordlg('Target bandwidth must be a positive value.')
    end
end
    
