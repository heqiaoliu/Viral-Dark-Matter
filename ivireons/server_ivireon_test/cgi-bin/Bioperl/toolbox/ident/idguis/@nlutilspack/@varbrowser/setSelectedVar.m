function setSelectedVar(h,varname)
% SETSELECTEDVARINFO  Selects the variable named varname

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:05:12 $

for k=1:length(h.variables)
    if strcmp(varname,getfield(h.variables(k),'name'))
        javaMethodEDT('setSelectedIndex',h.javahandle,k-1);
    end
end
