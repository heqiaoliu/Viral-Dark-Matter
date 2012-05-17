function advancePlus(this)
    
    % Function called when advanced options button is clicked on compare
    % runs tab.
    %
    % Copyright 2010 The MathWorks, Inc.
        
    str = get(this.compareRunAdvancePlus, 'String');
    p = getpixelposition(this.compareRunsVertSplitter.leftUpPane);
    GC = Simulink.sdi.GeoConst;
    
    % Cache GUI utilities class
    UG = Simulink.sdi.GUIUtil;
    [~, DialogH] = UG.LimitDialogExtents(this.HDialog,        ...
                                         GC.MDefaultDialogHE, ...
                                         GC.MDefaultDialogVE);
    if strcmp(str, '+')
        set(this.compareRunAdvancePlus, 'String', '-');
        set(this.advanceOptionsPanel, 'vis', 'on');
        xyGap = GC.MWindowMarginHE;
        margin = GC.MAxesNumGapVE;
        diffDialog = GC.diffDialogPlus;
        set(this.compareRunsTT.container, 'pos', [xyGap xyGap p(3)-margin (DialogH-diffDialog)]);
        set(this.alignByContainer, 'vis', 'on');
        set(this.firstThenByContainer, 'vis', 'on');
        set(this.secondThenByContainer, 'vis', 'on');
    elseif strcmp(str, '-')
        set(this.compareRunAdvancePlus, 'String', '+');
        set(this.advanceOptionsPanel, 'vis', 'off');
        diffDialog = GC.diffDialogMinus;
        xyGap = GC.MWindowMarginHE;
        margin = GC.MAxesNumGapVE;
        set(this.compareRunsTT.container, 'pos', [xyGap xyGap p(3)-margin (DialogH-diffDialog)]);
        set(this.alignByContainer, 'vis', 'off');
        set(this.firstThenByContainer, 'vis', 'off');
        set(this.secondThenByContainer, 'vis', 'off');
    end 
end