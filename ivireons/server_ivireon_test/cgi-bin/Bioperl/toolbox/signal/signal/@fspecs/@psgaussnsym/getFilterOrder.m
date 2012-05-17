function filterOrder = getFilterOrder(this)
%GETFILTERORDER Get the filterOrder.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:59 $

% Return the filter order
filterOrder = this.NumberOfSymbols * this.SamplesPerSymbol;

% [EOF]
