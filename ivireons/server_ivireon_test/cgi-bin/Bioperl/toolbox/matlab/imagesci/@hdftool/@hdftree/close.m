function close(this)
%CLOSE A destruction method for the hdfTree class.
%
%   Function arguments
%   ------------------
%   THIS: the hdfTree object instance.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/22 23:50:25 $

    % Close any HDF panels.
    staticPanels = {'staticGridPanel' 'staticRasterPanel' 'staticSdsPanel' ...
        'staticSwathPanel' 'staticVdataPanel' 'staticPointPanel'};
    for i=1:length(staticPanels)
        if ishghandle(this.(staticPanels{i}))
            delete(this.(staticPanels{i}));
        end
    end
    delete(this);
end
