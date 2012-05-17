function refreshInterpPanel(h)

% Copyright 2005 The MathWorks, Inc.

%% Table data callback which disables cross-time series interpolation if
%% more than one time series is selected
tsData = cell(h.Handles.tsTable.getModel.getData);
if size(tsData,1)>1 && sum(double([tsData{:,1}]))>1  
    set(h.Handles.RADIOthists,'Value',1)
    set(h.Handles.RADIOotherts,'Enable','off')
    set(h.Handles.COMBotherts,'Enable','off')
    h.InterptsPath = '';
elseif ~isempty(tsData)
    set(h.Handles.RADIOotherts,'Enable','on')
    set(h.Handles.COMBotherts,'Enable','on')
    set(h.Handles.COMBotherts,'String',tsData(:,3),'Value',1)
    if get(h.Handles.RADIOotherts,'Value')==1
        h.InterptsPath = tsData{1,3};
    else
        h.InterptsPath = '';
    end
else % No time series in the view
    set(h.Handles.RADIOotherts,'Enable','off')
    set(h.Handles.COMBotherts,'Enable','off')
    set(h.Handles.COMBotherts,'String',{''})
    h.InterptsPath = '';
end