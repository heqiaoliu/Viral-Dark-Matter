function out = rmi_exists()
% this function is used to enable Requirements Management specific items
% in context menu code and slsf.m
% 

% Copyright 2005-2010 The MathWorks, Inc.

    persistent rmiExists;
    if isempty(rmiExists)
        rmiExists = exist([matlabroot '/toolbox/slvnv/reqmgt/+rmisl'], 'dir') == 7 ;
    end
    out = rmiExists;
end
