function b = has1output(h)
%HAS1OUTPUT True if block for H si providing only one results. Not
%multiple inputs, outputs or values

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:56 $

b = (numel(h.daobject.inputSignalNames) == 1);

% [EOF]
