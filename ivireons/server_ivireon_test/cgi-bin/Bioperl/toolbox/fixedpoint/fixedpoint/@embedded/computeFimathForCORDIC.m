function localFimath = computeFimathForCORDIC(valueWithThetaNumType, ioWordLength, ioFracLength)
% computeFimathForCORDIC

% Copyright 2009-2010 The MathWorks, Inc.

% Set sum word length and fraction length attributes same as I/O data type;
% sum overrides fimath properties (use homogeneous add and subtract).
% Set rounding mode to 'floor' (a.k.a. none) and overflow mode to wrap.
localFimath                   = valueWithThetaNumType.fimath;
localFimath.ProductMode       = 'FullPrecision';
localFimath.SumMode           = 'SpecifyPrecision';
localFimath.SumWordLength     = ioWordLength;
localFimath.SumFractionLength = ioFracLength;
localFimath.CastBeforeSum     = true;
localFimath.RoundMode         = 'floor';
localFimath.OverflowMode      = 'wrap';

% [EOF]
