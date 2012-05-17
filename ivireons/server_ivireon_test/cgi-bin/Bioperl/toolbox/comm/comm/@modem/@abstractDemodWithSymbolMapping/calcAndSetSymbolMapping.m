function calcAndSetSymbolMapping(h, M)
%CALCANDSETSYMBOLMAPPING Calculate and set symbol  mapping (SymbolMapping
% property) for object H.

%   @modem/@abstractDemodWithSymbolMapping

%   Copyright 2006 - 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:46:29 $

switch lower(h.SymbolOrder)
    case 'binary'
        setPrivProp(h, 'PrivSymMapping', (0:M-1));
    case 'gray'
        mapping = calcGraySymbolMapping(h, M);
        setPrivProp(h, 'PrivSymMapping', mapping);
    case 'user-defined'
        % set PrivSymMapping same as 'binary' mapping. At this point, user has
        % not specified SymbolMapping
        setPrivProp(h, 'PrivSymMapping', (0:M-1));
end

%-------------------------------------------------------------------------------
% [EOF]
    