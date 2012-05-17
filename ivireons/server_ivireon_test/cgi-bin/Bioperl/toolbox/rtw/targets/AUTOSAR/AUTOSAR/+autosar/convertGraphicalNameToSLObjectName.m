function str = convertGraphicalNameToSLObjectName( str )
% CONVERTGRAPHICALNAMETOSLOBJECT convert Simulink graphical name to AUTOSAR SLObjectName

% Copyright 2010 The MathWorks, Inc.

if ~isempty( str )
    str = strrep(str, char(10), '_'); % rip off all RETURN keys
end
