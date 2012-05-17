function [g,factor,power] = dcgain(D)
% Computes DC gain and DC equivalent

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:27 $
no = nargout;
[ny,nu] = size(D.k);
g = zeros(ny,nu);
factor = zeros(ny,nu);
power = zeros(ny,nu);
RealFlag = isreal(D);
Ts = D.Ts;

if Ts==0,
   s = 0;  % Evaluate at s=0 for continuous-time models
else
   s = 1;  % Evaluate at z=1 for discrete-time models
end

% Loop over I/O pairs with nonzero gain (g=0 and dceq=0 when k=0)
idxnz = find(D.k~=0);
for ct=1:length(idxnz)
   i = idxnz(ct);
   zi = D.z{i};
   pi = D.p{i};   
   f = D.k(i);  % factor f in f * s^m equivalent
   
   if Ts~=0 && no>1
      % Find multiplicity of z=1 for more robust equivalent estimation
      % RE: Look only for hard zero in CT (anything else is adhoc and 
      % can give meaningless answer for VLF systems)
      TolOne = sqrt(eps); % Detection of roots at z=1
      indz = find(abs(zi-1)<0.01);
      indp = find(abs(pi-1)<0.01);
      z1m = mroots(zi(indz),'roots');
      p1m = mroots(pi(indp),'roots');
      % Replace multiple roots by average value if there are roots at z=1
      if any(abs(z1m-1)<TolOne)
         zi(indz,1) = z1m;   
      end
      if any(abs(p1m-1)<TolOne)
         pi(indp,1) = p1m;
      end
      % Locate roots at z=1
      indz = find(abs(zi-1)<TolOne);
      indp = find(abs(pi-1)<TolOne);
   else
      indz = find(zi==s);
      indp = find(pi==s);
   end
   zi(indz,:) = [];
   pi(indp,:) = [];
   
   % G(i) ~ f * s^m as s->0
   m = length(indz) - length(indp);
   if f~=0
      f = pow2(log2(f) + sum(log2(s-zi)) - sum(log2(s-pi)));
      if RealFlag
         f = real(f);
      end
   end
   if m<0,
      g(i) = Inf;
   elseif m>0,
      g(i) = 0;
   else
      g(i) = f;
   end
   factor(i) = f;
   power(i) = m;
end
