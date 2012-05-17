function Dt = ctranspose(D)
% Pertransposition of transfer functions.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:29 $
[ny,nu] = size(D.num);
if ny==0 || nu==0
   Dt = transpose(D); return
end
Dt = D;
Dt.Delay = transposeDelay(D);

% Variable change s->-s or z->1/z
num = D.num;
den = D.den;
if D.Ts==0,
   % Continuous-time case: replace s by -s
   for ct=1:ny*nu
      num{ct}(2:2:end) = -num{ct}(2:2:end);
      den{ct}(2:2:end) = -den{ct}(2:2:end);
      num{ct} = conj(num{ct});
      den{ct} = conj(den{ct});
   end
else
   % Discrete-time case: replace z by z^-1
   for ct=1:ny*nu
      num{ct} = conj(fliplr(num{ct}));
      den{ct} = conj(fliplr(den{ct}));
   end
end
Dt.num = num';
Dt.den = den';