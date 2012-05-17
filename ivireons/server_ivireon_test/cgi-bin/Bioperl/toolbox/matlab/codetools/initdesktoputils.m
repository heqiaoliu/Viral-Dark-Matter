function initdesktoputils
%INITDESKTOPUTILS Initialize the MATLAB path and other services for the 
%   desktop and desktop tools. This function is only intended to
%   be called from matlabrc.m and will not have any effect if called after
%   MATLAB is initialized.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $

if usejava('swing')
    com.mathworks.jmi.MatlabPath.setInitialPath(path);
    com.mathworks.mlservices.MatlabDebugServices.initialize;
end
