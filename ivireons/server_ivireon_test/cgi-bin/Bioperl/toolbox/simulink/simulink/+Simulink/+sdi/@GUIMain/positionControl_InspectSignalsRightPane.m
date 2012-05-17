function positionControl_InspectSignalsRightPane(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.
    GC = Simulink.sdi.GeoConst;
    vis = get(this.inspectSplitter.rightDownPane, 'vis');
    
    p = getpixelposition(this.inspectSplitter.rightDownPane, true);      
    if(strcmpi(vis, 'on') && (p(3)-GC.mHorAxesDiffFromParent > 0) &&...
       (p(4)-GC.mVertAxesDiffFromParent > 0))    
        
        setpixelposition(this.AxesInspectSignals, [p(1)+GC.mBottomAxesMargin
                                                   p(2)+GC.mVerticalAxesMargin
                                                   p(3)-GC.mHorAxesDiffFromParent
                                                   p(4)-GC.mVertAxesDiffFromParent],...
                         true);
        tt = this.GetTabType; 

        if (tt == Simulink.sdi.GUITabType.InspectSignals)        
            p1 = getpixelposition(this.AxesInspectSignals);
            setpixelposition(this.OptionsMenuButton1Container,...
                                                      [p1(1)+p1(3)-GC.mOptionWidth
                                                       p1(2)+p1(4)
                                                       GC.mOptionWidth
                                                       GC.mOptionHeight]);
        end
    end

end
