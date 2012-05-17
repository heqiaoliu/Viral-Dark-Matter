function D = minreal(D,tol)
% Pole/zero cancellations in ZPK models

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:45 $
% Cancel matching pairs
for ct=1:prod(size(D.k))
   [D.z{ct},D.p{ct}] = LocalReduce(...
      mroots(D.z{ct},'roots',tol),mroots(D.p{ct},'roots',tol),tol);
end
   
%------------------- Local Functions ---------------------------------

function [zr,pr] = LocalReduce(z,p,tol)
% Cancels matching poles and zeros

% Test for complex conjugate poles and zeros
RealFlag = isconjugate(z) & isconjugate(p);

% Init
zr = zeros(0,1);
pr = p;
if RealFlag
    % Separate complex conjugate pairs from simple zeros
    ccz = z(imag(z)>0,:);
    sz = z(imag(z)==0,:);
else
    % Treat all roots as simple in complex data case
    ccz = [];
    sz = z;
end

% Process complex conjugate pairs of zeros first, making sure 
% that each cancellation preserves the symmetry of PR wrt y-axis
ikeep = ones(size(ccz));
for m=1:length(ccz),
   % Find pole in PR closest to ZM = ccz(M)
   zm = ccz(m);
   [dmin,imin] = min(abs(pr-zm));

   if dmin<tol*(1+abs(zm)),
      % Cancel pair zm,pm and monitor complex/real simplifications
      ikeep(m) = 0;
      pm = pr(imin);

      if imag(pm), 
         % PM is complex: cancel (ZM,PM) and their conjugates
         icjg = find(pr==conj(pm));
         pr([imin , icjg(1)],:) = [];
      else
         % PM is real: add Z=(PM+2*REAL(ZM))/3 to sz
         sz = [sz ; (pm+2*real(zm))/3];
         pr(imin,:) = [];
      end
   end
end
ccz = ccz(logical(ikeep),:);

% Process simple zeros
ikeep = ones(size(sz));
for m=1:length(sz),
   % Find pole closest to ZM = sz(M)
   zm = sz(m);
   [dmin,imin] = min(abs(pr-zm));

   if dmin<tol*(1+abs(zm)),
      % Cancel pair zm,pm
      ikeep(m) = 0;
      pm = pr(imin);

      if RealFlag & imag(pm), 
         % PM is complex: replace its conjugate by P=(ZM+2*REAL(PM))/3
         icjg = find(pr==conj(pm));
         pr(icjg(1)) = (zm+2*real(pm))/3;
      end
      pr(imin,:) = [];
   end
end
sz = sz(logical(ikeep),:);


% Put ZR together
ncz = length(ccz);
zr(1:2:2*ncz,1) = ccz;
zr(2:2:2*ncz,1) = conj(ccz);
zr = [zr ; sz];

