function setSelectedVar(h,varname)
% SETSELECTEDVARINFO  Selects the variable named varname

% Author(s): 
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:42 $

for k=1:length(h.variables)
    if strcmp(varname,getfield(h.variables(k),'name'))
        awtinvoke(h.javahandle,'setSelectedIndex',k-1);
    end
end
