function args = postprocessargs(this,hspecs,N,Wn,TYPE,BETA)
%POSTPROCESSARGS Test that the spec is met.
%   kaiserord sometimes under estimate the order e.g. when the transition
%   band is near f = 0 or f = fs/2. POSTPROCESSARGS uses measurements to
%   adjust the filter order until the spec is met.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/04 23:24:18 $

args = {N, Wn, TYPE, kaiser(N+1, BETA)};
cache = args;
hfilter  = dfilt.dffir(fir1(args{:}));
if ~iskaisereqripminspecmet(this,hfilter,hspecs)
    done = false;
    count = 1;
    while ~done && count<10,
        N = N+1;
        if rem(N,2),
            N = updateoddorder(this,N);
        end
        args = {N, Wn, TYPE, kaiser(N+1, BETA)};
        hfilter.Numerator = fir1(args{:});
        count = count +1;        
        if iskaisereqripminspecmet(this,hfilter,hspecs), done = true; end
    end
else
    done = true;
end
if ~done,
    args = cache; % Return original design if spec is not met
end

% [EOF]