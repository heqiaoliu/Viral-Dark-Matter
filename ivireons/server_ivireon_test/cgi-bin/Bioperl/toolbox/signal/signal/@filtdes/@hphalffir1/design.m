function Hd = design(h,d)
%DESIGN  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:12:44 $


% Set up design params
N = get(d,'order');

win = generatewindow(d);

b = firhalfband(N,win,'high');

% Construct object
Hd = dfilt.dffir(b);



