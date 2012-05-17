function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:13:00 $


% Set up design params
N = get(d,'order');

% Get passband frequency, it has been prenormalized
Fpass = get(d,'Fpass');

if Fpass <= 0.5,
    error(generatemsgid('InvalidRange'),'The passband edge must be greater then half the Nyquist frequency.');
end

b = firhalfband(N,1-Fpass,'high');

% Construct object
Hd = dfilt.dffir(b);



