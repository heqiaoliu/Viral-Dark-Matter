classdef (Hidden = true) XRangeSelector < handle
    % @XRangeSelector class definition
    % Author(s): John Glass 17-Mar-2009
    % Revised:
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:12:41 $
    properties(SetAccess='public',GetAccess = 'public', SetObservable = true)
        XRange = [0 1];
    end
    properties(SetAccess='private',GetAccess = 'private', SetObservable = true)
        Group;
        Parent;
        Visible = 'off';
        YRange = [-2 2];
        LowerLimitLine;
        LowerLimitKnob;
        UpperLimitLine;
        UpperLimitKnob;
        SelectedPatch;
        UDDListeners;
    end
    events
        UpdateSelection
    end
    methods
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = XRangeSelector(Parent,XRange)
            if nargin == 0
                return
            end
            obj.Parent = handle(Parent);
            obj.XRange = XRange;
            obj.YRange = get(Parent,'YLim');
            % Create the widgets
            LocalCreateHGObjects(obj)
        end        
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function setVisible(obj,value)
            set(obj.Group,'Visible',value)
            draw(obj);
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function p = getPatch(obj)
            p = obj.SelectedPatch;
        end
        function p = getLowerLimitKnob(obj)
            p = obj.LowerLimitKnob;
        end
        function p = getUpperLimitKnob(obj)
            p = obj.UpperLimitKnob;
        end
        function p = getLowerLimitLine(obj)
            p = obj.LowerLimitLine;
        end
        function p = getUpperLimitLine(obj)
            p = obj.UpperLimitLine;
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.XRange(obj,value)
            obj.XRange = value;
            draw(obj);
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function draw(obj)
            if strcmp(get(obj.Group,'Visible'),'on')
                set(obj.LowerLimitLine,'XData',[obj.XRange(1) obj.XRange(1)],'YData',[obj.YRange(1) obj.YRange(2)])
                set(obj.UpperLimitLine,'XData',[obj.XRange(2) obj.XRange(2)],'YData',[obj.YRange(1) obj.YRange(2)])
                set(obj.LowerLimitKnob,'XData',obj.XRange(1),'YData',mean(obj.YRange))
                set(obj.UpperLimitKnob,'XData',obj.XRange(2),'YData',mean(obj.YRange))
                pX = [obj.XRange(1) obj.XRange(1) obj.XRange(2) obj.XRange(2)];
                pY = [obj.YRange(1) obj.YRange(2) obj.YRange(2) obj.YRange(1)];
                set(obj.SelectedPatch, 'XData',pX,'YData',pY);                
            end
        end  
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addUDDListeners(obj,UDDListeners)
            obj.UDDListeners = [obj.UDDListeners;UDDListeners(:)];
        end
    end
end


%% 
function LocalCreateHGObjects(obj)
obj.Group = hggroup('Parent',obj.Parent,'Visible',obj.Visible);
ylim = get(obj.Parent,'Ylim');
ymarker = mean(ylim);
patchColor = [0.98    0.9    0.8];
obj.LowerLimitLine = line([obj.XRange(1) obj.XRange(1)],[obj.YRange(1) obj.YRange(2)],[0.5 0.5],...
                            'Parent',obj.Group,...
                            'LineWidth',1,...
                            'Color',[0 0 0],...
                            'XlimInclude','off','YlimInclude','off',...
                            'ButtonDownFcn',{@LocalButtonDownFcn,obj,'LowerLimitLine','init'});
obj.LowerLimitKnob = line(obj.XRange(1),ymarker,1,...
                            'Parent',obj.Group,...
                            'LineWidth',1,...
                            'Marker','<',...
                            'MarkerEdgeColor',[0 0 0],...
                            'MarkerFaceColor',[0 0 0],...
                            'Color',[0 0 0],...
                            'XlimInclude','off','YlimInclude','off',...
                            'ButtonDownFcn',{@LocalButtonDownFcn,obj,'LowerLimitLine','init'});                     
obj.UpperLimitLine = line([obj.XRange(2) obj.XRange(2)],[obj.YRange(1) obj.YRange(2)],[0.5 0.5],...
                            'Parent',obj.Group,...
                            'LineWidth',1,...
                            'Color',[0 0 0],...
                            'XlimInclude','off','YlimInclude','off',...
                            'ButtonDownFcn',{@LocalButtonDownFcn,obj,'UpperLimitLine','init'});
obj.UpperLimitKnob = line(obj.XRange(2),ymarker,1,...
                            'Parent',obj.Group,...
                            'LineWidth',1,...
                            'Marker','>',...
                            'MarkerEdgeColor',[0 0 0],...
                            'MarkerFaceColor',[0 0 0],...
                            'Color',[0 0 0],...
                            'XlimInclude','off','YlimInclude','off',...
                            'ButtonDownFcn',{@LocalButtonDownFcn,obj,'UpperLimitLine','init'});
pX = [obj.XRange(1) obj.XRange(1) obj.XRange(2) obj.XRange(2)];
pY = [obj.YRange(1) obj.YRange(2) obj.YRange(2) obj.YRange(1)];
pZ = -1*ones(size(pX));

obj.SelectedPatch = patch(pX,pY,pZ,'Parent',obj.Group,...
                            'FaceColor',patchColor,...
                            'EdgeColor',patchColor,...
                            'FaceAlpha',0.5,...
                            'XlimInclude','off','YlimInclude','off',...
                            'ButtonDownFcn',{@LocalButtonDownFcn,obj,'SelectedPatch','init'});
 
                        
                        
% Create listeners
obj.addUDDListeners(handle.listener(obj.Parent,obj.Parent.findprop('YLim'),'PropertyPostSet',{@LocalYLimitsChanged, obj}))
end

%% 
function LocalYLimitsChanged(es,ed,obj)
obj.YRange = get(obj.Parent,'YLim');
obj.draw;
end

%% 
function LocalButtonDownFcn(es,ed,obj,source,action)
persistent WBMU fig selectedPoint xLim;

switch action
    case 'init'
        fig = gcbf;
        xLim = get(obj.Parent,'xLim');
        WBMU = get(fig,{'WindowButtonMotionFcn';'WindowButtonUpFcn'});
        set(fig,'WindowButtonMotionFcn',{@LocalButtonDownFcn obj source 'move'},...
               'WindowButtonUpFcn',{@LocalButtonDownFcn obj source 'finish'})
        % Get the selected point
        point = get(obj.Parent,'CurrentPoint');
        selectedPoint = point(1);
    case 'move'
        point = get(obj.Parent,'CurrentPoint');
        deltaX = point(1)-selectedPoint;
        oldRange = obj.XRange;
        XScale = get(obj.Parent,'XScale');
        switch source
            case 'LowerLimitLine'
                newRange = oldRange;
                newRange(1) = oldRange(1) + deltaX;
                if newRange(1) >= newRange(2)
                    newRange = oldRange;
                end
            case 'UpperLimitLine'
                newRange = oldRange;
                newRange(2) = oldRange(2) + deltaX;
                if newRange(2) <= newRange(1)
                    newRange = oldRange;
                end
            case 'SelectedPatch'     
                if strcmp(XScale,'log')
                    newRange = 10.^(log10(point(1))-log10(selectedPoint)+log10(oldRange));
                else
                    newRange = obj.XRange + deltaX;
                end
        end
        if (newRange(1) >= xLim(1)) && (newRange(2) <= xLim(2)) || strcmp(source,'SelectedPatch')
            obj.XRange = newRange;
        end
        selectedPoint = point(1);
    case 'finish'
        set(fig,{'WindowButtonMotionFcn';'WindowButtonUpFcn'},WBMU);
end
end

