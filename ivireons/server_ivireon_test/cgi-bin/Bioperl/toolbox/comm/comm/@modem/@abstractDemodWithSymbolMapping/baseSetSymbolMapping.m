function mapping = baseSetSymbolMapping(h, mapping)
%BASESETSYMBOLMAPPING Set SymbolMapping property for object H.

%   @modem/@abstractDemodWithSymbolMapping

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/08 15:52:37 $

% Get M
M = h.M;

% Mapping is not allowed to be changed if SymbolOrder is 'binary' or 'gray'
if ismember(lower(h.SymbolOrder), {'binary','gray'})
    error([getErrorId(h) ':WriteOnlySymbolMapping'], ...
          ['Changing SymbolMapping is not allowed when SymbolOrder is ' ...
           '''Binary'' or ''Gray''.\nPlease set SymbolOrder to ''User-defined''.']);
else 
    %h.SymbolOrder = 'User-defined'
    % mapping must be a unique vector of length M with integer elements in range
    % [0, M-1]. 
    if (length(mapping) ~= M) || (length(unique(mapping)) ~= M) ...
        || any(floor(mapping) ~= mapping) || any(~isreal(mapping)) ...
            || (min(mapping) < 0) || (max(mapping) > M-1)
        error([getErrorId(h) ':InvalidSymbolMapping'], ...
              ['SymbolMapping must be a unique vector of length M with integer' ...
              ' valued elements in range [0:M-1].']);
    end

    % set PrivSymMapping prop - always do this first (after error checking)
    setPrivProp(h, 'PrivSymMapping', mapping);
end

% Initialize soft demodulator
initSoftDemod(h, h.M, h.SymbolMapping);

%-------------------------------------------------------------------------------
% [EOF]