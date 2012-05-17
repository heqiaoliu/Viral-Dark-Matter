function dataddg_bus_edit_callback(h, busEditTag)

% Copyright 2006 The MathWorks, Inc.

thisDlg = DAStudio.ToolRoot.getOpenDialogs(h);

if isempty(thisDlg)
    busStr = h.Props.Type.BusObject;
else
    busStr = thisDlg.getWidgetValue(busEditTag);
end
                    
buseditor('Create', busStr);
