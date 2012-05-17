function Hd = design(h,d)
%Design  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 00:25:22 $


% Set up design params
N = get(d,'order');
Fc1 = get(d,'Fc1');
Fc2 = get(d,'Fc2');
Fc = [Fc1, Fc2];

win = generatewindow(d);

scaleflag = determinescaleflag(d);

b = fir1(N,Fc,'stop',win,scaleflag);

% Construct object
Hd = dfilt.dffir(b);


