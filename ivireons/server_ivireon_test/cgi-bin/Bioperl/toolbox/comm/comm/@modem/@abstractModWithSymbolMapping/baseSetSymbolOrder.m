function order = baseSetSymbolOrder(h, order)
%BASESETSYMBOLORDER Set SymbolOrder property for object H.

%   @modem/@abstractModWithSymbolMapping

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/08 15:52:44 $

% set PrivOrder prop - always do this first
setPrivProp(h, 'PrivSymOrder', order);

% changing Order requires updating Mapping
calcAndSetSymbolMapping(h, h.M);

%-------------------------------------------------------------------------------
% [EOF]