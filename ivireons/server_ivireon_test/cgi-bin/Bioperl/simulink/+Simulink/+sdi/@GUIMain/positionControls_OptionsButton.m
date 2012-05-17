function positionControls_OptionsButton(this)

%   Copyright 2010 The MathWorks, Inc.
    tt = this.GetTabType();
    switch tt
        case Simulink.sdi.GUITabType.InspectSignals
            vis = get(this.inspectSplitter.rightDownPane, 'vis');
            set(this.OptionsMenuButton1Container, 'vis', vis);
            set(this.OptionsMenuButton2Container, 'vis', 'off');
            if(strcmpi(vis, 'on'))
                set(this.OptionsMenuButton1Container, 'parent',...
                    this.inspectSplitter.rightDownPane); 
                set(this.OptionsMenuButton1Container, 'vis', vis);
                helperPositionButton(this.OptionsMenuButton1Container,...
                                     this.AxesInspectSignals);                                 
            end
            
        case Simulink.sdi.GUITabType.CompareSignals
            vis1 = get(this.compareSigHorSplitter.rightDownPane, 'vis');
            set(this.OptionsMenuButton1Container, 'vis', vis1);
            vis2 = get(this.compareSigHorSplitter.leftUpPane, 'vis');
            set(this.OptionsMenuButton2Container, 'vis', vis2);
            
            if(strcmpi(vis1, 'on'))
                set(this.OptionsMenuButton1Container, 'parent',...
                    this.compareSigHorSplitter.rightDownPane); 
                set(this.OptionsMenuButton1Container, 'vis', vis1);
                helperPositionButton(this.OptionsMenuButton1Container,...
                                     this.AxesCompareSignalsData);
            end
            
            if(strcmpi(vis2, 'on'))
                set(this.OptionsMenuButton2Container, 'parent',...
                    this.compareSigHorSplitter.leftUpPane);  
                set(this.OptionsMenuButton2Container, 'vis', vis2);
                helperPositionButton(this.OptionsMenuButton2Container,...
                                     this.AxesCompareSignalsDiff);                          
            end
            
        case Simulink.sdi.GUITabType.CompareRuns
            vis1 = get(this.compareRunsHorSplitter.rightDownPane, 'vis');
            set(this.OptionsMenuButton1Container, 'vis', vis1);
            vis2 = get(this.compareRunsHorSplitter.leftUpPane, 'vis');
            set(this.OptionsMenuButton2Container, 'vis', vis2);
            
            if(strcmpi(vis1, 'on'))
                set(this.OptionsMenuButton1Container, 'parent',...
                    this.compareRunsHorSplitter.rightDownPane);
                set(this.OptionsMenuButton1Container, 'vis', vis1);
                helperPositionButton(this.OptionsMenuButton1Container,...
                                     this.AxesCompareRunsData);
            end
            
            if(strcmpi(vis2, 'on'))
                set(this.OptionsMenuButton2Container, 'parent',...
                    this.compareRunsHorSplitter.leftUpPane); 
                set(this.OptionsMenuButton2Container, 'vis', vis2);
                helperPositionButton(this.OptionsMenuButton2Container,...
                                     this.AxesCompareRunsDiff);  
            end
    end
        
end
    
function helperPositionButton(button, ax)
    GC = Simulink.sdi.GeoConst;
    p1 = getpixelposition(ax);
    legend(ax, 'boxoff');
    setpixelposition(button, [p1(1)+p1(3)-GC.mOptionWidth
                              p1(2)+p1(4)
                              GC.mOptionWidth
                              GC.mOptionHeight]);
end