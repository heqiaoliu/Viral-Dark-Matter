function NewValue = convertGainValue(this,Value,OldFormat,NewFormat)
% convertGainVALUE converts value based on Format used by model api
%
% Format = 1; Value = Formatted Gain; 
% Format = 2; Value = Invariant Gain;

%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2007/05/18 04:59:18 $


if isequal(OldFormat, NewFormat)
   NewValue = Value;
else
   if OldFormat == 1;
      %Formatted to Invariant
      NewValue = Value / this.formatfactor;
   else
      %Invariant to Formatted
      NewValue = Value * this.formatfactor;
   end
end