function [h,InfResp] = fresp(D,w)
% Frequency response of ZPK model.

%	 Author(s): P.Gahinet 
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:33 $
[ny,nu] = size(D.k);
RealFlag = isreal(D);

% Form vector s of complex frequencies
s = ltipack.utGetComplexFrequencies(w,D.Ts);

% Compute frequency response
h = zeros(length(s),ny,nu); % More convenient for loop below
InfResp = false;
for ct=1:ny*nu
   % Zeros and Poles for D(i,j)
   z = D.z{ct};  p = D.p{ct};  k = D.k(ct);
   % Sort by ascending magnitude to minimize risk of overflow
   [junk,isz] = sort(abs(z)); %#ok<ASGLU>
   [junk,isp] = sort(abs(p)); %#ok<ASGLU>
   % Evaluate response at each frequency
   % RE: ZPKFRESP ensures no underflow or overflow in intermediate results
   [h(:,ct),isSingular] = zpkfresp(z(isz),p(isp),k,s,RealFlag);
   InfResp = InfResp || isSingular;
end

% Reorder dimensions
h = permute(h,[2 3 1]);

% Factor in delays
if hasdelay(D)
   h = getDelayResp(D,h,s);
end
