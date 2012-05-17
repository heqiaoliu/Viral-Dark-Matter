function [gpeak,fpeak] = norminf(D,varargin)
% Compute the peak gain of the frequency response

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:45 $
nf = size(D.Response,3);
if nf>0
   smax = zeros(nf,1);
   for ct=1:nf
      smax(ct) = norm(D.Response(:,:,ct));
   end
   [gpeak,imax] = max(smax);
   fpeak = unitconv(D.Frequency(imax),D.FreqUnits,'rad/s');
else
   gpeak = NaN;  fpeak = NaN;
end
