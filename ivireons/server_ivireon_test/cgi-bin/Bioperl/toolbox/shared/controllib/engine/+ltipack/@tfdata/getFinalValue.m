function yf = getFinalValue(D,RespType,varargin)
% Computes steady-state value for a given response type, assuming the 
% model is stable

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:39 $
Ts = D.Ts;
if strncmpi(RespType,'impulse',1)
   % YF is DC gain of s * H(s) or (z-1) * H(z)
   for ct=1:numel(D.num)
      % Form s * hij(s)
      num = D.num{ct};
      den = D.den{ct};
      if Ts==0
         ld = length(den);
         if den(ld)==0
            % Pair integrator with s factor
            den = den(1:ld-1);
            % Equalize length of num and den
            if num(1)==0
               num = num(2:ld);
            else
               den = [0 den];
            end
         else
            num = [num 0];
            den = [0 den];
         end
      else
         if sum(den)==0
            % den(z=1) = 0
            den = deconv(den,[1 -1]);
            % Equalize length of num and den
            if num(1)==0
               num = num(2:end);
            else
               den = [0 den];
            end
         else
            num = conv(num,[1 -1]);
            den = [0 den];
         end
      end
      D.num{ct} = num;
      D.den{ct} = den;
   end
end

% Compute final value
yf = dcgain(D);
