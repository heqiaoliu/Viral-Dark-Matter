function ts = computeSampleTime(this,SampleTime)
% COMPUTESAMPLETIME  Computes a scalar sample time.
%
 
% Author(s): John W. Glass 12-Oct-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/10/15 23:31:17 $

if ischar(SampleTime)
    try
        ts = evalin('base',SampleTime); 
    catch
        ctrlMsgUtils.error('Slcontrol:linutil:InvalidSampleTimeExpression',SampleTime)
    end
else
    ts = SampleTime;
end