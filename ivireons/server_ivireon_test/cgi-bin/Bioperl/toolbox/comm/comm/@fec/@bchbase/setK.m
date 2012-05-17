function K = setK(h,K)
%SETK   Sets the K value of the object.

% @fec\@bcbase

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:33 $

if h.Nset == false
    return;
end
h.Kset = false;

try
    h.t = bchnumerr(h.N,K);
catch
    h.Kset = true;
    error([getErrorId(h) ':Kerr'],...
        'The values for N and K do not produce a valid narrow-sense BCH code')
end

h.T2 = 2*h.t;       % number of parity sym
h.PuncturePattern = ones(1,h.N-K);
h.genpoly = bchgenpoly(h.N,K);
h.Kset = true;
h.Type = algType(h,h.N,K,h.ShortenedLength,h.PuncturePattern);
