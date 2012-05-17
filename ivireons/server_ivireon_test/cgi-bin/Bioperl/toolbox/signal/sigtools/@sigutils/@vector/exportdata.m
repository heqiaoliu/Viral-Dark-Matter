function data2xp = exportdata(h)
%EXPORTDATA Extract data to export.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:32:04 $

data2xp = {};

[r, c] = size(h);
for rndx = 1:r
    for cndx = 1:c
        for n = 1:length(h(rndx, cndx)),
            newdata  = elementat(h(rndx, cndx),n);
            data2xp =  {data2xp{:},newdata};
        end
    end
end

% [EOF]
