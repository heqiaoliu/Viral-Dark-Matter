function order = baseSetSymbolOrder(h, order)
%BASESETSYMBOLORDER Set SymbolOrder property for object H.

%   @modem/@abstractDemodWithSymbolMapping

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/08 15:52:39 $

% set PrivOrder prop - always do this first
setPrivProp(h, 'PrivSymOrder', order);

% changing SymbolOrder requires updating Mapping
calcAndSetSymbolMapping(h, h.M);

% Update ProcessFunction
setProcessFunction(h, h.M);

% Initialize soft demodulator
initSoftDemod(h, h.M, h.SymbolMapping);

%-------------------------------------------------------------------------------
% [EOF]