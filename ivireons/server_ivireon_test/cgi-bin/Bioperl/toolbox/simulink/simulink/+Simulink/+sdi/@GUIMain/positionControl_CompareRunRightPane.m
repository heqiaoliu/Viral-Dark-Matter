function positionControl_CompareRunRightPane(this, ~, ~)

%   Copyright 2010 The MathWorks, Inc.
    GC = Simulink.sdi.GeoConst;
    tt = this.GetTabType;
    
    vis1 = get(this.compareRunsHorSplitter.rightDownPane, 'vis');
    if strcmpi(vis1, 'on')
        p = getpixelposition(this.compareRunsHorSplitter.rightDownPane, true);  
        if ((p(3)-GC.mHorAxesDiffFromParent) > 0 && (p(4)-GC.mVertAxesDiffFromParent) > 0)
            setpixelposition(this.AxesCompareRunsData, [p(1)+GC.mBottomAxesMargin
                                                        p(2)+GC.mVerticalAxesMargin
                                                        p(3)-GC.mHorAxesDiffFromParent
                                                        p(4)-GC.mVertAxesDiffFromParent],...
                             true);
        end
    end
    
    vis2 = get(this.compareRunsHorSplitter.leftUpPane, 'vis');
    
    if strcmpi(vis2, 'on')
        p = getpixelposition(this.compareRunsHorSplitter.leftUpPane, true);
        if ((p(3)-GC.mHorAxesDiffFromParent) > 0 && (p(4)-GC.mVertAxesDiffFromParent) > 0)
            setpixelposition(this.AxesCompareRunsDiff, [p(1)+GC.mBottomAxesMargin
                                                        p(2)+GC.mVerticalAxesMargin
                                                       p(3)-GC.mHorAxesDiffFromParent
                                                       p(4)-GC.mVertAxesDiffFromParent],...
                             true);
        end
    end
                                           
    if (tt == Simulink.sdi.GUITabType.CompareRuns)
         p1 = getpixelposition(this.AxesCompareRunsData);
         p2 = getpixelposition(this.AxesCompareRunsDiff);
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

