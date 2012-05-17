function positionControl_InspectSignalsLeftPane(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.
    GC = Simulink.sdi.GeoConst;
        % Cache GUI utilities class
    UG = Simulink.sdi.GUIUtil;    
    p = getpixelposition(this.inspectSplitter.leftUpPane);
    [~, DialogH] = UG.LimitDialogExtents(this.HDialog,        ...
                                         GC.MDefaultDialogHE, ...
                                         GC.MDefaultDialogVE);
    vis = get(this.inspectSplitter.leftUpPane, 'vis');
    if(strcmpi(vis, 'on') && (p(3) -20) > 0)
        set(this.InspectTT.container, 'pos', ...
        [GC.IGWindowMarginVE GC.IGWindowMarginVE p(3)-20 (DialogH-45)]);
    end

end
