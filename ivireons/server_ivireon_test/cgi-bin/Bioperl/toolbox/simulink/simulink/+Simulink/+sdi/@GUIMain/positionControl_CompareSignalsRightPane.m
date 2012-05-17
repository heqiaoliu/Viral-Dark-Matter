function positionControl_CompareSignalsRightPane(this, ~, ~)
    
    %   Copyright 2010 The MathWorks, Inc.
    GC = Simulink.sdi.GeoConst;
    vis1 = get(this.compareSigHorSplitter.rightDownPane, 'vis');
    p = getpixelposition(this.compareSigHorSplitter.rightDownPane, true); 
    if (strcmpi(vis1, 'on') && (p(3)-GC.mHorAxesDiffFromParent > 0) &&...
        (p(4)-GC.mVertAxesDiffFromParent > 0))
        if ((p(3)-GC.mHorAxesDiffFromParent) > 0 && (p(4)-GC.mVertAxesDiffFromParent) > 0)
            setpixelposition(this.AxesCompareSignalsData, [p(1)+GC.mBottomAxesMargin
                                                           p(2)+GC.mVerticalAxesMargin
                                                           p(3)-GC.mHorAxesDiffFromParent
                                                           p(4)-GC.mVertAxesDiffFromParent],...
                             true);
        end
    end
          
    vis2 = get(this.compareSigHorSplitter.leftUpPane, 'vis');
    p = getpixelposition(this.compareSigHorSplitter.leftUpPane, true);
    
    if (strcmpi(vis2, 'on') && (p(3)-GC.mHorAxesDiffFromParent > 0) &&...
        (p(4)-GC.mVertAxesDiffFromParent > 0))
        if ((p(3)-GC.mHorAxesDiffFromParent) > 0 && (p(4)-GC.mVertAxesDiffFromParent) > 0)
            setpixelposition(this.AxesCompareSignalsDiff, [p(1)+GC.mBottomAxesMargin
                                                           p(2)+GC.mVerticalAxesMargin
                                                           p(3)-GC.mHorAxesDiffFromParent
                                                           p(4)-GC.mVertAxesDiffFromParent],...
                             true);
        end
    end
    tt = this.GetTabType;
    if (tt == Simulink.sdi.GUITabType.CompareSignals)
        p1 = getpixelposition(this.AxesCompareSignalsData);
        p2 = getpixelposition(this.AxesCompareSignalsDiff);
        if strcmpi(vis1, 'on')
            setpixelposition(this.OptionsMenuButton1Container,...
                                                      [p1(1)+p1(3)-GC.mOptionWidth
                                                       p1(2)+p1(4)
                                                       GC.mOptionWidth
                                                       GC.mOptionHeight]);
        end
        if strcmpi(vis2, 'on')
            setpixelposition(this.OptionsMenuButton2Container,...
                               [p2(1)+p2(3)-GC.mOptionWidth
                                p2(2)+p2(4)
                                GC.mOptionWidth
                                GC.mOptionHeight]);
        end
    end
    
end
