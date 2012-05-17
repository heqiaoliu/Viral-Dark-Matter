function NewValue = convertValue(this,Value,OldFormat,NewFormat,units)
% convertVALUE converts value based on Format
%
% Format = 1; Value = [Real; Imag]; 
% Format = 2; Value = [Zeta, Wn];

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2006/01/26 01:45:58 $


if isequal(OldFormat, NewFormat)
   NewValue = Value;
else
   %Set Useful information
   Wmin    = 0;
   ZetaMax = 1;
   Ts      = this.Parent.Ts;
   if nargin < 5
      units.FrequencyUnits = 'rad/s';
   end

   if OldFormat == 1;
      %Real/Imag to Zeta/Wn
      if all(isfinite(Value))
         %Have finite values to convert
         [Wn, Zeta] = damp(Value(1)+i*Value(2), Ts);
      else
         %Non-finite values, return hard limits.
         if any(Value < 0)
            %Assume lower limit
            Zeta = -1;
            Wn   = 0;
         else
            %Assume upper limit
            Zeta = 1;
            Wn   = inf;
         end
      end
      %Return converted value
      NewValue = [Zeta;unitconv(Wn,'rad/s',units.FrequencyUnits)];
   else
      %Zeta/Wn to Real/Imag
      if all(isfinite(Value)) && abs(Value(1)) <= ZetaMax && Value(2) > Wmin
         %Have finite and valid values to convert
         Zeta = Value(1);
         if abs(Zeta)>1
            Zeta = sign(Zeta);
         end
         Wn = unitconv(Value(2), units.FrequencyUnits, 'rad/s');
         Loc = -Zeta*Wn + Wn*sqrt(Zeta^2-1);
         if Ts ~= 0
            Loc = exp(Loc*Ts);
         end
         NewValue = [real(Loc);imag(Loc)];
      else
         %Non-finite values, return hard limits.
         if any(Value < 0)
            %Assume lower limit
            NewValue = [-inf;-inf];
         else
            %Assume upper limit
            NewValue = [inf;inf];
         end
      end
   end
end