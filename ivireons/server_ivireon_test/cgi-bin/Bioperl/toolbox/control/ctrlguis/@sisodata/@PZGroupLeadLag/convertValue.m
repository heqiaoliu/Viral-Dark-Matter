function NewValue = convertValue(this,Value,OldFormat,NewFormat,units)
% SETVALUE sets the value for the pzgroup based on Format
%
% Format = 1,  Value =  [zero;pole]
% Format = 2,  Value =  [PhaseMax;Wmax]

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/01/26 01:45:59 $


if isequal(OldFormat, NewFormat)
   NewValue = Value;
else
   %Set useful information
   Pmax = asin(1-eps); % Range imposed on valid phase inputs Phase < pi/2
   Wmin = 0;
   Ts   = this.Parent.Ts;
   if nargin < 5
      units.FrequencyUnits = 'rad/s';
      units.PhaseUnits = 'rad';
   end

   if OldFormat == 1;
      %Pole/Zero to Phase/Wn
      if all(isfinite(Value))
         %Have finite values to convert
         if (Ts == 0)
            % continuous case
            ZeroLocation = Value(1);
            PoleLocation = Value(2);
         else
            % discrete case
            ZeroLocation = log(Value(1))/Ts;
            PoleLocation = log(Value(2))/Ts;
         end

         % Calculate the maximum phase addition from lead/lag and freq
         % at which it occurs
         alpha    = ZeroLocation/PoleLocation;
         PhaseMax = unitconv(asin((1-alpha)/(1+alpha)),'rad',units.PhaseUnits);
         Wmax     = unitconv(-ZeroLocation/sqrt(alpha),'rad/s',units.FrequencyUnits);
      else
         %Non-finite values, return hard limits.
         if any(Value < 0)
            %Assume lower limit
            PhaseMax = unitconv(-Pmax,'rad',units.PhaseUnits);
            Wmax     = 0;
         else
            %Assume upper limit
            PhaseMax = unitconv(Pmax,'rad',units.PhaseUnits);
            Wmax     = inf;
         end
      end
      %Return converted value
      NewValue = [PhaseMax;Wmax];
   else
      %Phase/Wn to Pole/Zero
      Phasem = unitconv(Value(1),units.PhaseUnits,'rad');
      Wm     = unitconv(Value(2),units.FrequencyUnits,'rad/s');
   
      if all(isfinite(Value)) && abs(Value(1)) < Pmax && Value(2) >= Wmin
         %Have finite and valid values to convert
         
         % Zero = alpha * Pole
         alpha = (1-sin(Phasem))/(1+sin(Phasem));
         ZeroLoc = -Wm*sqrt(alpha);
         PoleLoc = ZeroLoc/alpha;
         if (Ts ~= 0)
            %Discrete system
            ZeroLoc = exp(ZeroLoc*Ts);
            PoleLoc = exp(PoleLoc*Ts);
         end
         
      else
         %Non-finite values, return hard limits.
         if any(Value < 0)
            %Assume lower limit
            ZeroLoc = -inf;
            PoleLoc = -inf;
         else
            %Assume upper limit
            ZeroLoc = inf;
            PoleLoc = inf;
         end
      end
      %Return converted value
      NewValue = [ZeroLoc; PoleLoc];
   end
end