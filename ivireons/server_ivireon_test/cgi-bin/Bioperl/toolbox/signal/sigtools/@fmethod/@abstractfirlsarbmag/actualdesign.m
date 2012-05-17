function varargout = actualdesign(this,hspecs,varargin)
%ACTUALDESIGN   Perform the actual design.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:16:38 $

[N,F,D,W,nfpts] = getdesiredresponse(this,hspecs);

% Determine if the filter is real
isreal = true;
if F(1)<0, isreal = false; end

if isreal,
% If only positive frequencies specified, assume hermitian symmetry
    F = [-F(end-1:-1:2) F];
    D = [conj(D(end-1:-1:2)) D];
    W = [W(end-1:-1:2) W];
    nfpts = length(F);   
end

W = diag(sqrt(W));
x = exp(-1i*pi*F);
C = ones(nfpts,N+1); 
for i=1:N,
    C(:,i) = x.^(i-1);
end
WC = W*C;
wd = W*D(:);

% Compute weighted least-square solution
w = warning('off'); %#ok<WNOFF>
b = WC\wd;
warning(w);

if isreal,
    b = real(b);
end
    
% Force symmetry if linear phase design
b = thisforcelinearphase(this,b);

varargout = {{b}};

