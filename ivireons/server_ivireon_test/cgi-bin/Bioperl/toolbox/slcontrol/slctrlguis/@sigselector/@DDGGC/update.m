function update(this,~,eventdata)
%

% UPDATE - Updates the DDG dialog for selected signal viewer for changes in
% tool component.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/21 22:05:04 $

dlg = LocalGetDialog(this);
% Set filter text if dialog is available
if ~isempty(dlg)
    tc = eventdata.Source;
    setWidgetValue(dlg,'selsigview_filterEdit',tc.getFilterText);
    % Refresh the dialog as the tree might need to be updated.
    dlg.refresh;
    % Select the first item if the AutoSelect is on
    opts = tc.getOptions;
    if opts.AutoSelect
        curitem = tc.getItems;
        if ~isempty(curitem)
            % Replace slash with double slashes
            sel = regexprep(curitem{1}.Name,{'/'},{'//'});
            setWidgetValue(dlg,'selsigview_signalsTree',sel);
        end
    end
    % Since DDG reflects the selection at the previous location, in order to
    % keep the data and view consistent, run select signals routine once
    % again.    
    selectSignal(this,dlg);
end

function dlg = LocalGetDialog(this)
dlg = [];
if ~isempty(this.Parent) && ishandle(this.Parent)
    dlg = DAStudio.ToolRoot.getOpenDialogs(this.Parent);
end




