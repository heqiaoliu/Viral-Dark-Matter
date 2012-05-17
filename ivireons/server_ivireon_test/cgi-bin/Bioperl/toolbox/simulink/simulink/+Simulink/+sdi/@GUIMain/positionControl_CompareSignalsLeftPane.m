function positionControl_CompareSignalsLeftPane(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.
    GC = Simulink.sdi.GeoConst;
        % Cache GUI utilities class
    UG = Simulink.sdi.GUIUtil;
    p = getpixelposition(this.compareSigVertSplitter.leftUpPane);
    [~, DialogH] = UG.LimitDialogExtents(this.HDialog,        ...
                                               GC.MDefaultDialogHE, ...
                                               GC.MDefaultDialogVE);
    vis = get(this.compareSigVertSplitter.leftUpPane, 'vis');
    
    if(p(3)-20 > 0 && strcmpi(vis, 'on'))
        set(this.compareSignalsTT.container, 'pos', ...
             [GC.IGWindowMarginVE GC.IGWindowMarginVE p(3)-20 (DialogH-45)]);
    end

end
