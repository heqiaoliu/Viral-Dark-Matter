function o = sl_saveas(mdlName, ver, breakLinks, saveasName)
    
% SL_SAVEAS object is used to register
% functions for Simulink Saveas to use 
% when saving to an older version of simulink.
%
%  Copyright 2008-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $
    
    o.modelName  = mdlName;
    o.ver        = ver; 
    o.breakLinks = breakLinks;
    o.saveasName = saveasName;
    o.data       = sl_saveas_data;
    o = class(o,'sl_saveas');
end
