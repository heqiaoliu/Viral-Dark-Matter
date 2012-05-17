function [x, y, z] = cordic_kernel_private(x, y, z, inpLUT, niters)
% CORDIC_KERNEL_PRIVATE Perform CORDIC iterations.

% Copyright 2009-2010 The MathWorks, Inc.
%#eml

if ~isempty(eml.target)
    eml_prefer_const(inpLUT, niters);
end

xtmp = x;
ytmp = y;

for idx = 1:niters
    if z < 0
        z(:) = z + inpLUT(idx);
        x(:) = x + ytmp;
        y(:) = y - xtmp;
    else
        z(:) = z - inpLUT(idx);
        x(:) = x - ytmp;
        y(:) = y + xtmp;
    end
    
    xtmp = bitsra(x, idx);
    ytmp = bitsra(y, idx);
end

% [EOF]
