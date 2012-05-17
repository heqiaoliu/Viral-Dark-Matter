classdef AbstractControllerDesignPanel < handle
    % AbstractControllerDesignPanel defines interactive tuning panel
    %
 
    % Author(s): R. Chen
    % Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.10.3 $ $Date: 2010/03/26 17:21:20 $

    properties
        % handles of GUI components
        Handles
        % wc slider center frequency
        CenterWC
    end

    properties (SetObservable = true, AbortSet = true)
        % current frequency
        WC
        % GUI
        MouseIsDragging
    end
    
    properties (Access = protected)
        % wc slider range 
        MaxWC
        MinWC
    end
    
    methods

        % Constructor
        function this = AbstractControllerDesignPanel()
            this.MinWC = realmin;
            this.MaxWC = realmax;
            this.MouseIsDragging = false;
        end
        
        % set visibility
        function setVisible(this, Visible)
            this.Handles.Panel.setVisible(Visible);
        end
        
        % compute wc from knob location
        function newWC = getFromLocationToWC(this, newLocation)
        % 0 -- 0.1 x this.CenterWC, 100 -- 10 x this.CenterWC, 50 -- this.CenterWC
            centerWC = this.CenterWC;
            Min = max(0.1*centerWC,this.MinWC)/centerWC;
            Max = min(10*centerWC,this.MaxWC)/centerWC;
            if newLocation>50
                newWC = centerWC*Max^((newLocation-50)/50);
            else
                newWC = centerWC*Min^((50-newLocation)/50);
            end
        end

        % compute knob location from wc
        function newLocation = getFromWCToLocation(this, newWC)
        % 0 -- 0.1 x this.CenterWC, 100 -- 10 x this.CenterWC, 50 -- this.CenterWC
            centerWC = this.CenterWC;
            Min = max(0.1*centerWC,this.MinWC)/centerWC;
            Max = min(10*centerWC,this.MaxWC)/centerWC;
            if newWC>centerWC
                newLocation = round(log10(newWC/centerWC)/log10(Max)*50+50);
            else
                newLocation = round(50-log10(newWC/centerWC)/log10(Min)*50);
            end
        end

        % knob dragging started callback
        function SliderMousePressedCallback(this)
            this.MouseIsDragging = true;
        end

        % knob dragging stopped callback
        function SliderMouseReleasedCallback(this)
            this.MouseIsDragging = false;
        end

    end
    
    methods (Static = true)
        
        % set slider value without firing event
        function setSliderWithoutFiringEvent(Slider, newLocation)
            Model = Slider.getModel;
            tmp = Model.getChangeListeners;
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSlider$ModelListener')
                    Model.removeChangeListener(tmp(ct));
                end
            end
            Model.setValue(newLocation);
            for ct=1:length(tmp)
                if isa(tmp(ct),'javax.swing.JSlider$ModelListener')
                    Model.addChangeListener(tmp(ct));
                end
            end
        end
        
    end
    
end

