function cleanup(this)
%CLEANUP   

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/05/31 23:28:43 $

hFVT = getcomponent(this, 'fvtool');

% Delete FVTool and the figure object
delete(hFVT);

% This was for g279483, but we have decided that we want to leave the
% MDI open because the user may have setup the MDI and removing it might be
% annoying.
hFVTs = findall(0, 'tag', 'filtervisualizationtool');

if isempty(setdiff(hFVTs, this.double))
    com.mathworks.mlservices.MatlabDesktopServices.getDesktop.closeGroup('Filter Visualization Tool');
end

% [EOF]
