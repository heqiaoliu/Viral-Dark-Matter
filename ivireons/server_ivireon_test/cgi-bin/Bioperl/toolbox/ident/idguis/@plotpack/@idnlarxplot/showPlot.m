function showPlot(this,retainRegNames)
% show plot for selected output combo choice
% retainRegNames: if true (default), try to retain the existing regressor
% names selected in the two combo boxes.

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/12/29 02:07:55 $

if nargin<2
    retainRegNames = true;
end

if ~isempty(this.MainPanels) 
    set(this.MainPanels,'vis','off');
    str = this.getTag; %get tag of "current" panel
    cp = findobj(this.MainPanels,'Tag',str,'type','uipanel');
    if ~isempty(cp)
        set(cp,'vis','on')
        
        % design: regressor selections for reg1 and reg2 will not
        % automatically change if output is changed; they will change only
        % if the previous selection(s) cannot be used (same reg not available
        % for new output).
        
        this.refreshControlPanel(retainRegNames);
        if retainRegNames
            this.generateRegPlot(false);
        end
        this.executeResizeFcn; %to refresh
        return;
    end
end

wb = [];
if this.isGUI
    wb = waitbar(0.5,'Opening Nonlinear ARX models plot window...');
end

% generate afresh
this.generateRegPlot(true,retainRegNames); %isNew=true

if this.isGUI && idIsValidHandle(wb) 
    waitbar(1,wb,'Done.')
end

this.executeResizeFcn;
if idIsValidHandle(wb), close(wb), end
