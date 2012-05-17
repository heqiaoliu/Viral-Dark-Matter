function K = setK(h,K)
%SETN   Sets the K value of the object.

% @fec\@rsbase

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:37 $

if h.Nset == false
    h.kSet = true;
    return;
end
h.kSet = false;
if ( h.N <= K)
    error([getErrorId(h),':NlargeK'], 'N must be larger than K');
end

if( floor((h.N-K)/2) < 1)
    error([getErrorId(h),':NminusK'],'(N-K)/2 must be greater than or equal to 1.');
end


h.t = floor((h.N-K)/2);
h.T2 = 2*h.t;       % number of parity sym
h.m = log2(h.N+1);
h.PuncturePattern = ones(1,h.N-K);
h.genpoly = rsgenpoly(h.N,K);
h.kSet = true;
h.Type = algType(h,h.N,K,h.ShortenedLength,h.PuncturePattern);