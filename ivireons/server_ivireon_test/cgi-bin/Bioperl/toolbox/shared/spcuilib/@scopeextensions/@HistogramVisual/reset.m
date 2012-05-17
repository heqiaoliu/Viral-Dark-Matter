function reset(this)
%RESET    Reset the visual.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:41:38 $

resetData(this.DataObject);
if this.NTXFeaturedOn
    % Defer the work to the NTX object
    this.NTExplorerObj.reset();
else
    update(this.HistogramInfo);
end

% [EOF]
