function checkoptimizable(this, hTar)
%   OUT = CHECKOPTIMIZABLE(ARGS) Check if optimizations can be carried on

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 19:35:16 $

if any(this.ScaleValues==0) && strcmpi(hTar.OptimizeZeros,'on'),
   warning(generatemsgid('NullScaleValues'), ...
        'Disabled zero-gains optimization because at least one scale value is equal to zero.');
    hTar.OptimizeZeros = 'off';
end


% [EOF]
