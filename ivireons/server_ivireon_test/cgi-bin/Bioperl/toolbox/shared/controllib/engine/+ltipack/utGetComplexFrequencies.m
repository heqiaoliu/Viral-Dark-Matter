function s = utGetComplexFrequencies(w,Ts)
% Turns real or complex frequency vector W into
% vector of complex frequencies (s or z).

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:04 $
if isreal(w)
   if Ts==0
      % Don't use 1i*w because this maps w=Inf to NaN+1i*Inf
      s = complex(0,w);
   else
      s = exp(complex(0,w*abs(Ts)));  % z = exp(j*w*Ts)
   end
else
   % W contains complex frequencies (old syntax)
   s = w;
end
