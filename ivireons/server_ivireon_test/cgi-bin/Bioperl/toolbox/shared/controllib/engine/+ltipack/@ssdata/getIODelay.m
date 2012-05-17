function [iod,nzio] = getIODelay(D,varargin)
%GETIODELAY  Extracts I/O delay data.
%
%   IOD = getIODelay(D) returns the I/O delay matrix.
%   For state-space models, getIODelay tests if internal 
%   delays are equivalent to I/O delays and returns the
%   equivalent I/O delay or NaN for each I/O pair.
%   It also returns a second output NZIO indicating which 
%   I/O transfer functions are not identically zero 
%   (I/O delays are always set to zero for identically zero 
%   I/O transfers).
% 
%   IOD = getIODelay(D,'total') returns the total I/O delay 
%   including the input and output delays.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:07 $
if hasInternalDelay(D)
   % Sizes
   InternalDelays = D.Delay.Internal;
   nfd = length(InternalDelays);
   [rs,cs] = size(D.d);
   nu = cs-nfd;
   ny = rs-nfd;
   
   % Determine hard zeros in H(s)
   % Complexity = o(rs+cs)n^3 worst case, typically closer to o(rs+cs)n^2
   xkeep = iosmreal(D.a,D.b,D.c,D.e);
   nzH = (D.d~=0 | reshape(any(xkeep,1),[rs cs]));
   h11 = nzH(1:ny,1:nu);
   h12 = nzH(1:ny,nu+1:cs);
   h21 = nzH(ny+1:rs,1:nu);
   h22 = nzH(ny+1:rs,nu+1:cs);
   
   % Permute internal delays to make H22 strictly upper triangular when
   % possible (g389527). MASK below assumes SUT structure. 
   [junk,p] = isNilpotent(h22);
   h22(p,p) = h22;  h21(p,:) = h21;  h12(:,p) = h12;  InternalDelays(p) = InternalDelays;
   
   % Determine minimal set of internal delays for each I/O pair
   dkeep = iosmreal(h22,h21,h12,[]);
   
   % Check that every I/O transfer is multilinear wrt its set of nonzero minimal delays
   %    H(s) = H11 + H12 inv(inv(theta)-H22) H21
   % LFT matrices for H(i,j) are:
   %    H11(i,j)    H12(i,dij)
   %    H21(dij,j)  H22(dij,dij)
   % where dij = dkeep(:,i,j).
   iod = zeros(ny,nu);
   nzio = false(ny,nu);
   for j=1:nu
      for i=1:ny
         % Hij(s,tau) = lft([h11(i,j) h12(i,dij);h21(dij,j) h22(dij,dij)],tau(dij))
         dij = find(dkeep(:,i,j) & InternalDelays>0);  % exclude zero delays
         nfdij = length(dij); 
         % Build mask for checking desired H22 structure
         mask = (h22(dij,dij)~=0 & diag(ones(1,nfdij-1),1)==0);
         % RE: h11(i,j) must be zero if NFDIJ>0 (g179848)
         if nfdij>0 && (h11(i,j) || any(mask(:)) || ...
               any(h12(i,dij(2:nfdij))) || any(h21(dij(1:nfdij-1),j)))
            % Internal delays cannot be reduced to I/O delays
            iod(i,j) = NaN;
         else
            iod(i,j) = sum(InternalDelays(dij));
         end
         nzio(i,j) = h11(i,j) || nfdij>0;
      end
   end
else
   % No or all zero internal delay
   [ny,nu] = iosize(D);
   iod = zeros(ny,nu);
   nzio = true(ny,nu);  % immaterial
end

if nargin>1
   iod = iod + D.Delay.Input(:,ones(1,ny)).' + D.Delay.Output(:,ones(1,nu));
end
