function regstruct = hdlblocks
% HDLBLOCKS

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/06/16 06:00:12 $

regstruct.package = { 'hdlstateflow' };
regstruct.name    = { 'Stateflow HDL Implementations' };
regstruct.version = { 'v1.0' };
regstruct.license = 1;
regstruct.controlfile = { 'hdldefault_sf_control' };
if license('test', 'Stateflow')
    regstruct.library = { 'sflib', 'eml_lib' };
else
    regstruct.library = { 'eml_lib' };
end
% [EOF]
