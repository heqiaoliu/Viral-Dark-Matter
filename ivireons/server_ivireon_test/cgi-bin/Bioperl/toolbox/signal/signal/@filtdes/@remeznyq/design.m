function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2008/05/31 23:26:53 $

% Get filter order
N = get(d,'order');

% Get band
L = get(d,'band');

% Get rolloff/bandwidth
tm = get(d,'TransitionMode');
R = get(d,tm);    

% If bandwidth, convert to rolloff, frequencies have been prenormalized
tm_opts = set(d,'TransitionMode');
if strcmpi(tm,tm_opts{1}),
    R = R*L/2;
    % Error for bandwidth if rolloff not valid
    if R < 0 | R > 1,
        error(generatemsgid('InvalidRange'),'The bandwidth specified is too large.');
    end
end

D = 0;

% Get design type
dt = get(d,'DesignType');

b = firnyquist(N,L,R,D,dt);

% Construct object
Hd = dfilt.dffir(b);



