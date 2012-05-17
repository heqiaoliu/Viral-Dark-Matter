function yname = getCurrentOutput(this)
% return name of current output

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:51 $

ind = this.Current.OutputComboValue;

if ~this.isGUI
    if ind==1
        % we have multiple plots
        yname = this.Current.MultiOutputAxesTag;
    else
        yname = this.OutputNames{ind-1};
    end
else
    yname = this.OutputNames{ind};
end
