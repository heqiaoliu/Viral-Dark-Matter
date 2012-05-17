function tableContextMenuCallback_Columns(this, s, e)

%   Copyright 2010 The MathWorks, Inc.

    tabType = this.GetTabType;
    
    switch tabType
        case Simulink.sdi.GUITabType.InspectSignals
            this.tableContextMenu_Inspect(s,e);
        case Simulink.sdi.GUITabType.CompareSignals
            this.tableContextMenu_CompareSignals(s,e);
    end
    
    