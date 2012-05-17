function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:12:57 $


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


% Set the magUnits temporarily to 'linear' to get deviations
magUnits = get(d,'magUnits');
set(d,'magUnits','linear');
Dpass = get(d,'Dpass');
set(d,'magUnits',magUnits);

b = firnyquist('minorder',L,R,Dpass);

% Construct object
Hd = dfilt.dffir(b);



