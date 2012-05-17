function N = setN(h,N)
%SETN   Sets the N value of the object.

% @fec\@bcbase

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/05 01:58:22 $

if h.Kset == false
    return;
end
h.Nset = false;
%set K to a default value
N_vec = [7 15 31 63 127 255];
K_vec = [4 11 26 57 120 247];

idx = find(N == N_vec);
if( isempty(idx))
    h.Nset = true;
    error([getErrorId(h) ':Nerr'],...
        'N must equal 2^m-1 for some integer m between 3 and 8.')
end

h.K = K_vec(idx);

h.t = bchnumerr(N,h.K);
h.genpoly = bchgenpoly(N,h.K);
h.m = log2(N+1);
h.T2 = 2*h.t;       % number of parity sym
h.PuncturePattern = ones(1,N-h.K);
h.Nset = true;
h.Type = algType(h,N,h.K,h.ShortenedLength,h.PuncturePattern);

% Since the value of N has changed, the GF tables need to be updated
updateTables(h,log2(N+1))

