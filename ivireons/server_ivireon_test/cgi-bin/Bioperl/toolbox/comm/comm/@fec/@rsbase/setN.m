function N = setN(h,N)
%SETN   Sets the N value of the object.

% @fec\@rsbase

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/09/13 06:46:29 $

if h.Kset == false
    h.nSet = true;
    return;
end
h.nSet = false;
if ( N <= h.K)
    error([getErrorId(h),':NlargeK'], 'N must be larger than K');
end

if( floor((N-h.K)/2) < 1)
    error([getErrorId(h),':NminusK'],'(N-K)/2 must be greater than or equal to 1.');
end

h.t = floor((N-h.K)/2);
h.T2 = 2*h.t;       % number of parity sym

h.m = log2(N+1);  % Needs to be set before genpoly since it uses h.m to populate GF tables
h.genpoly = rsgenpoly(N,h.K);
h.PuncturePattern = ones(1,N-h.K);
h.nSet = true;
h.Type = algType(h,N,h.K,h.ShortenedLength,h.PuncturePattern);
