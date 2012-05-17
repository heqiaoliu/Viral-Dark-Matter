function order = setSymbolOrder(h, order)
%SETSYMBOLORDER Set SymbolOrder property for object H.

%   @modem/@oqpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/08 15:53:14 $

% Call base function
baseSetSymbolOrder(h, order);

% Reset
reset(h);

%-------------------------------------------------------------------------------
% [EOF]