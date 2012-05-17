function computeBounds(this)
%getBounds  Data update method for bounds

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:20 $



RespData = this.Data;

if localHasCommonFrequencyVector(this);   
    % assume common frequency vector
    this.Bounds.UpperMagnitudeBound = max([RespData(1,:).Magnitude],[],2);
    this.Bounds.LowerMagnitudeBound = min([RespData(1,:).Magnitude],[],2);
    this.Bounds.UpperPhaseBound = max([RespData(1,:).Phase],[],2);
    this.Bounds.LowerPhaseBound = min([RespData(1,:).Phase],[],2);
    this.Bounds.Frequency = RespData(1).Frequency;
else
   [UpperMagBound, LowerMagBound , UpperPhaseBound, LowerPhaseBound, Frequency] = localInterpolateBounds(this);
    this.Bounds.UpperMagnitudeBound = UpperMagBound;
    this.Bounds.LowerMagnitudeBound = LowerMagBound;
    this.Bounds.UpperPhaseBound = UpperPhaseBound;
    this.Bounds.LowerPhaseBound = LowerPhaseBound;
    this.Bounds.Frequency = Frequency;
end

function b = localHasCommonFrequencyVector(this)

RespData = this.Data;
b = true;
for ct = 1:length(RespData)-1
    if ~isequal(RespData(ct).Frequency,RespData(ct+1).Frequency)
        b = false;
        break
    end
end

function [UpperMagBound, LowerMagBound , UpperPhaseBound, LowerPhaseBound, Frequency] = localInterpolateBounds(this)

RespData = this.Data;
Frequency = [];
for ct = 1:length(RespData)
    Frequency = [Frequency; RespData(ct).Frequency(:)];
end

Frequency = unique(Frequency);

for ct = 1:length(RespData)
    RespData(1,ct).Magnitude = ...
        utInterp1(RespData(1,ct).Frequency,RespData(1,ct).Magnitude,Frequency);
    RespData(1,ct).Phase = ...
        utInterp1(RespData(1,ct).Frequency,RespData(1,ct).Phase,Frequency);
end    

UpperMagBound = max([RespData(1,:).Magnitude],[],2);
LowerMagBound = min([RespData(1,:).Magnitude],[],2);

UpperPhaseBound = max([RespData(1,:).Phase],[],2);
LowerPhaseBound = min([RespData(1,:).Phase],[],2);
