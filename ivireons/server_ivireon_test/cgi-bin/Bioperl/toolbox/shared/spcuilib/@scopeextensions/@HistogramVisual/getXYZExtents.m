function xyz = getXYZExtents(this)
%GETXYZEXTENTS Get the XYZExtents.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/31 18:41:32 $

% Plot navigation tools are not enabled for the new NTX visual. If the NTX
% feature is "Off", then return the extents for plot navigation to use in
% order to autoscale.
if ~(this.NTXFeaturedOn)
    data = this.HistData;
    xyz = [ ...
        min(this.MinBin, data.BinMin)-0.5 max(this.MaxBin, data.BinMax)+0.5; ...
        min(data.hist) max(data.hist); ...
        -1 1];
end

% [EOF]
