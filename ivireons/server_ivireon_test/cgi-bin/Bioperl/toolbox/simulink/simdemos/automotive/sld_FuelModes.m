classdef sld_FuelModes < Simulink.IntEnumType
% Fuel modes for sldemo_fuelsys

% $Revision: 1.1.6.2 $
% $Date: 2010/05/20 03:16:18 $
%
% Copyright 1994-2010 The MathWorks, Inc.

    enumeration
        LOW(1)
        RICH(2)
        DISABLED(3)
    end
end
