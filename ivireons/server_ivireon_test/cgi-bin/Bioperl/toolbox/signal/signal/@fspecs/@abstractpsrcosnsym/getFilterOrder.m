function filterOrder = getFilterOrder(this)
%GETFILTERORDER Get the filterOrder.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:04 $

% Convert filter or der in symbols to filter order in samples and return
filterOrder = this.NumberOfSymbols * this.SamplesPerSymbol;

% [EOF]
