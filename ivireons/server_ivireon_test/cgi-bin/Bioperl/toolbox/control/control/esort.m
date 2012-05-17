function [p,is] = esort(p)
%ESORT  Sort complex continuous eigenvalues in descending order.
%
%   S = ESORT(P)  sorts the complex eigenvalues in the vector P in
%   descending order by real part.  The unstable eigenvalues (in
%   the continuous-time sense) will appear first.
%
%   [S,NDX] = ESORT(P) also returns the vector NDX containing the 
%   indexes used in the sort.
%
%   See also: DSORT, SORT.

%   Clay M. Thompson  7-12-90, AFP 6-1-94, PG 4-9-96, 6-11-97
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2007/12/14 14:22:47 $
error(nargchk(1,1,nargin));
p = p(:);

% Sort by decreasing real parts
[rp,is] = sort(-real(p));
p = p(is);

% Find clusters with same real part and sort them by imaginary parts
ic = [0 ; find(diff(rp)) ; length(p)];
for ct=1:length(ic)-1
   ix = ic(ct)+1:ic(ct+1);
   if length(ix)>1
      [p(ix),is(ix)] = localSortByImagPart(p(ix),is(ix));
   end
end
   
%---- local functions ------------

function [p,ind] = localSortByImagPart(p,ind)
% Sorts p by increasing absolute imaginary parts
[imabs,is] = sort(abs(imag(p)));
p = p(is);  ind = ind(is);
% Find clusters with same |imag| and sort into complex conjugate pairs
ic = [0 ; find(diff(imabs)) ; length(p)];
for ct=1:length(ic)-1
   ix = ic(ct)+1:ic(ct+1);
   [p(ix),ind(ix)] = localSortByConjPair(p(ix),ind(ix));
end

function [p,ind] = localSortByConjPair(p,ind)
% Sorts a set of roots valued in {a+jb,a-jb}
imp = imag(p);
if length(p)>2
   ip = find(imp>0);
   in = find(imp<0);
   m = min(length(ip),length(in));
   if m>0
      % resort to first list all conjugate pairs (a+jb,a-jb), b>0
      perm = zeros(size(p));
      perm(1:2:2*m) = ip(1:m);
      perm(2:2:2*m) = in(1:m);
      perm(2*m+1:end) = [ip(m+1:end) ; in(m+1:end)];
      ind = ind(perm);
      p = p(perm);
   end
else
   % Fast version for complex conjugate pairs or single complex root
   [junk,is] = sort(-imp);
   p = p(is);   ind = ind(is);
end
