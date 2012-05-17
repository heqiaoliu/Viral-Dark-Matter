function Dtf = tf(D)
% Conversion to TF

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:57 $

% Conversion starts
[ny,nu] = size(D.k);
num = cell(ny,nu);
den = cell(ny,nu);
for ct=1:ny*nu
   if isnan(D.k(ct))
      num{ct} = NaN;
      den{ct} = 1;
   elseif D.k(ct)==0
      num{ct} = 0;
      den{ct} = 1;
   else
      % Zeros are roots of numerator
      nct = D.k(ct) * poly(D.z{ct});
      % Poles are the roots of denominator
      dct = poly(D.p{ct});
      % Check for overflow
      if ~all(isfinite(nct)) || ~all(isfinite(dct))
          ctrlMsgUtils.error('Control:transformation:tf1')
      end
      % Make num/den of equal length
      lgap = length(dct)-length(nct);
      num{ct} = [zeros(1,lgap) nct];
      den{ct} = [zeros(1,-lgap) dct];
   end
end

% Create result
Dtf = ltipack.tfdata(num,den,D.Ts);
Dtf.Delay = D.Delay;
