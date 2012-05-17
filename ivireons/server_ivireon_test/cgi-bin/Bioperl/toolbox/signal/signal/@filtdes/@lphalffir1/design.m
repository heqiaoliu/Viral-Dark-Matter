function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:14:03 $


% Set up design params
N = get(d,'order');

win = generatewindow(d);

b = firhalfband(N,win);

% Construct object
Hd = dfilt.dffir(b);



