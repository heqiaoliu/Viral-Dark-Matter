function Hd = design(this,d)
%Design  Method to design the filter given the specs.

%   Author(s): R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2005/06/16 08:26:05 $


% Set up design params
N = get(d,'order');
Fc = get(d,'Fc');
win = generatewindow(d);

scaleflag = determinescaleflag(d);

inputs = {N, Fc, 'high', win, scaleflag};

if rem(N, 2) == 1
    inputs{end+1} = 'h';
end

b = fir1(inputs{:});

% Construct object
Hd = dfilt.dffir(b);
