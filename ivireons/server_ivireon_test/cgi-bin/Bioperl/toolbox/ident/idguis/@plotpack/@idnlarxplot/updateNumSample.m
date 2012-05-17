function updateNumSample(this,N)
% update number of samples used to grid regressor space
% do so only for current plot and for GUI only

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:07 $

if ~this.isGUI
    return
end

this.NumSample = N;
this.generateRegPlot(false); %isNew=false (only update)
