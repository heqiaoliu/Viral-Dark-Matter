function h = bchcon(varargin)
%bchcon Helper function for BCH encoder/decoder object construction

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/29 08:21:40 $

h = varargin{1};

h.Nset = false;
h.Kset = false;
h.ParityPosition = 'end';

if(nargin == 1)
    N = 7;
    K = 4;
    h.t = bchnumerr(N,K);
    h.GenPoly = bchgenpoly(N,K);
elseif isa(varargin{2},'char')
    h.Nset = true;
    h.Kset = true;
    h = InitPropValuePairs(h,varargin{2:end});
    h.m = log2(h.N+1);
    return
elseif (isa(varargin{2},'fec.bchdec') || isa(varargin{2},'fec.bchenc') )
    bch = varargin{2};
    h.N = bch.N;
    h.K = bch.K;
    h.ParityPosition  = bch.ParityPosition;
    h.PuncturePattern = bch.PuncturePattern;
    h.ShortenedLength = bch.ShortenedLength;
    h.GenPoly = bch.GenPoly;
    h.m = log2(bch.N+1);
    h.t = bchnumerr(bch.N,bch.K);
    h.Nset = true;
    h.Kset = true;
    h.Type = algType(h,h.N,h.K,h.ShortenedLength,h.PuncturePattern);
    return
else
    if(nargin ~= 3) % At this point, there must be exactly 2 input arguments
        error([getErrorId(h),':InvalidNumInput'],'Incorrect number of input arguments');
    end
    N = varargin{2};
    K = varargin{3};
end

try
    h.GenPoly = bchgenpoly(N,K);
    h.t = bchnumerr(N,K);
catch %#ok<CTCH>
    error([getErrorId(h),':NKerr'],...
        'The values for N and K do not produce a valid narrow-sense BCH code')
end

h.N = N;
h.K = K;

h.Nset = true;
h.Kset = true;

h.ShortenedLength = 0;
h.PuncturePattern = ones(1,N-K);
h.m = log2(N+1);

h.Type = algType(h,N,K,h.ShortenedLength,h.PuncturePattern);
