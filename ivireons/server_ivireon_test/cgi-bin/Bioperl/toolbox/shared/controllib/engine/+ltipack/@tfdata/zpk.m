function Dzpk = zpk(D)
% Conversion to ZPK

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision $  $Date: 2009/11/09 16:33:17 $
% Conversion starts
[ny,nu] = size(D.num);
z = cell(ny,nu);
p = cell(ny,nu);
k = zeros(ny,nu);
for ct=1:ny*nu
   % Zeros are roots of numerator
   [knum,z{ct}] = getkr(D.num{ct});
   if knum==0
      % Ignore dynamics when gain is zero
      p{ct} = zeros(0,1);
      k(ct) = 0;
   else
      % Poles are the roots of denominator:
      [kden,p{ct}] = getkr(D.den{ct});
      k(ct) = knum/kden;
   end
end

Dzpk = ltipack.zpkdata(z,p,k,D.Ts);
Dzpk.Delay = D.Delay;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [k,r] = getkr(p)
%GETKR   Computes K and the roots R such that
%                    P = K * poly(R)
if all(isfinite(p))
   r = roots(p);
   k = p(length(p)-length(r));
else
   r = zeros(0,1);
   k = NaN;
end

% RE: don't use MROOTS here otherwise roots(sys.den) and zpk(sys).p 
%     may be different. Usage of MROOTS is restricted to TF-ZPK to 
%     SS conversions
