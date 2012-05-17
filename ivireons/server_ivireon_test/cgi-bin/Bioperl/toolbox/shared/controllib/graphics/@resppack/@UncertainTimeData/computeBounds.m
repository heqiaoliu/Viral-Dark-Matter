function computeBounds(this)
%getBounds  Data update method for bounds

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:36:19 $



RespData = this.Data;

if localHasCommonTimeVector(this);   
    % assume common time vector
    this.Bounds.UpperAmplitudeBound = max([RespData(1,:).Amplitude],[],2);
    this.Bounds.LowerAmplitudeBound = min([RespData(1,:).Amplitude],[],2);
    this.Bounds.Time = RespData(1).Time;
else
    [UpperBound, LowerBound , Time] = localInterpolateBounds(this);
    this.Bounds.UpperAmplitudeBound = UpperBound;
    this.Bounds.LowerAmplitudeBound = LowerBound;
    this.Bounds.Time = Time;
end

function b = localHasCommonTimeVector(this)

RespData = this.Data;
b = true;
for ct = 1:length(RespData)-1
    if ~isequal(RespData(ct).Time,RespData(ct+1).Time)
        b = false;
        break
    end
end

function [UpperBound, LowerBound , Time] = localInterpolateBounds(this)

RespData = this.Data;
Time = [];
for ct = 1:length(RespData)
    Time = [Time; RespData(ct).Time(:)];
end

Time = unique(Time);

for ct = 1:length(RespData)
    RespData(1,ct).Amplitude = ...
        utInterp1(RespData(1,ct).Time,RespData(1,ct).Amplitude,Time);
end    

UpperBound = max([RespData(1,:).Amplitude],[],2);
LowerBound = min([RespData(1,:).Amplitude],[],2);
