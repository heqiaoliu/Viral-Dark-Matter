function setGainValue(this, Value, Format)
%setGainValue   Set gain value for model api param spec
%
%   Format = 1 is formatted gain
%   Format = 2 is invariant gain

%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2007/05/18 04:59:22 $

if nargin == 2
    Format = 1;
end

if isequal(Format, 1)
    this.setFormattedGain(Value);
else
    this.Gain = Value;
end
