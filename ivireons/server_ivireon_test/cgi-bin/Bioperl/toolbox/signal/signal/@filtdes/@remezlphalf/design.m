function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:13:02 $


% Set up design params
N = get(d,'order');

% Get passband frequency, it has been prenormalized
Fpass = get(d,'Fpass');

b = firhalfband(N,Fpass);

% Construct object
Hd = dfilt.dffir(b);



