classdef (CaseInsensitiveProperties = true,...
            TruncatedProperties = true, ...
            Sealed = true) StatusBar < spcwidgets.AbstractWidget
    %StatusBar   Define the StatusBar class.
    %
    %    StatusBar methods:
    %        method1 - Example method
    %
    %    StatusBar properties:
    %        Prop1 - Example property

    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:46:24 $

    properties % (SetAccess = private)   
       OptionWidths;
       Children;               
    end
    
    properties (Dependent)
        Tooltip;
        GrabBar;
        Callback;
        Enable;
        Visible;
        Text;
    end
    
    properties
       Tag;
       Type;
    
%     properties (GetAccess = private, SetAccess = private)       
       hWidget;
       TextHandle;
    end

    methods

        function this = StatusBar(varargin)
            %STATUSBAR Constructor for StatusBar object.
            %   STATUSBAR creates a StatusBar object.  Only one StatusBar can
            %   be created for each figure; subsequent creation attempts return
            %   the existing StatusBar object.
            %
            %   StatusBar(parent) creates a status region for figure PARENT.
            %
            %   StatusBar(p1,v1,...) passes parameter and value pairs p1,v1, ...,
            %   to the status bar constructor.
            mlock;
            
            args = varargin;
            if mod(nargin,2)==1
                args = ['Parent',args];  % add missing param name
            end
            [parent,args] = getParent(args);  % extract 'parent' value
            
            % Check if a statusbar already exists in parent figure
            % If so, return that handle
            %
            % We don't know how to do that, so we just create a new one
            % each time.
%             this = [];  % xxx getExistingStatusBar(parent)
%             if isempty(this)
                % create StatusBar
                this.hWidget = spcwidgets.StatusBase(parent);
%             end
            if ~isempty(args)
                set(this,args{:}); % set remaining param/value pairs
            end
        end
         % ----------------------------------------
        function addChildren(h,child)
            h.Children = [child, h.Children];
%             h.Children = [h.Children,child];
        end
        
        % ----------------------------------------
        function set.Text(h,str)
            statusText(h.hWidget,str);
        end
        
        % ----------------------------------------
        function str = get.Text(h)
            str = statusText(h.hWidget);
        end
        
        % ----------------------------------------
        function set.Tooltip(h,str)
            statusTooltip(h.hWidget,str);
        end
        
        % ----------------------------------------
        function str = get.Tooltip(h)
            str = statusTooltip(h.hWidget);
        end
        
        % ----------------------------------------
        function set.GrabBar(h,state)
            h.hWidget.GrabBar = state;
        end
        % ----------------------------------------
        function state = get.GrabBar(h) 
            state = h.hWidget.GrabBar;
        end
        % ----------------------------------------
        function set.Callback(h,str)
            statusCallback(h.hWidget,str);
        end
        % ----------------------------------------
        function str = get.Callback(h)
            str = statusCallback(h.hWidget);
        end
        % ----------------------------------------
        function set.Enable(h,ena)
            statusEnable(h.hWidget,ena);
        end
        % ----------------------------------------
        function ena = get.Enable(h)
            ena = statusEnable(h.hWidget);
        end
        % ----------------------------------------
        function set.Visible(h,state)
            h.hWidget.Visible = state;
        end
        % ----------------------------------------
        function state = get.Visible(h)
            state = h.hWidget.Visible;
        end
        
        % ----------------------------------------
%         function s = set.OptionWidths(h,s) %#ok
%             error('spcwidgets:StatusBar:ReadOnly', ...
%                 'OptionWidths is read-only.');
%         end
        % ----------------------------------------
        function s = get.OptionWidths(h)
            s = h.hWidget.OptionWidths;
        end
        % ----------------------------------------
%         function s = set.Children(h,s)  %#ok
%             error('spcwidgets:StatusBar:ReadOnly', ...
%                 'Children is read-only.');
%         end
%         % ----------------------------------------
%         function s = get.Children(h)
%             % StatusBar has zero or more Status children connected to it
%             %
%             % Construct list in backwards-creation order,
%             % to match order of other HG children vectors
%             s = [];
%             if ~isempty(h)
%                 hc = h.down('last');
%                 while ~isempty(hc)
%                     s=[s hc]; %#ok
%                     hc=hc.left;
%                 end
%             end
%         end
        % ----------------------------------------
        function set.Type(obj,val) 
            if isempty(obj.Type)
                obj.Type = val;
            else                
                error('spcuilib:spcwidgets:StatusBar:schema',...
                    'Property is read-only.');
            end
        end
        % ----------------------------------------
        function delete(h)
            %DELETE Destroy status bar.
            
            delete(h.hWidget);
            h.hWidget = [];
        end
        % ----------------------------------------
        function y = isHandle(h)
            %ISHANDLE True if StatusBar is managing a valid widget.
            
            y = ~isempty(h.hWidget) && isHandle(h.hWidget);
        end
        % ----------------------------------------
        function textFast(h,str)
            %TEXTFAST Quickly set option region text.            
            set(h.TextHandle,'string',str);
        end
        % ----------------------------------------
        function textFastInit(h,str) %#ok
            % Initialize textfast method.
            
            % For efficiency of textfast() method
            %
            % Must do this manually here, and not in constructor, in case re-rendering occurs
            % (such as a change in the # of option regions)
            %
            % No desire to put in a listener...            
            h.TextHandle = statusTextHandle(h.hWidget);
        end      
        
        % ----------------------------------------
        function y = statusText(obj,str)            
            if isempty(obj.hstatusText)
                if nargout>0
                    y = '';
                end
            else
                if nargin>1
                    set(obj.hstatusText,'string',str);
                end
                if nargout>0
                    y = get(obj.hstatusText,'string');
                end
            end
        end
    end
end

%     methods (Access = 'protected')

% ---------------------------------------------
function [parent,args] = getParent(args)
% Remove and return value of 'parent' property, if specified

% See if parent was specified
idx = find(strcmpi('parent',args));
if isempty(idx)
    % No parent figure specified
    parent = gcf;  % create default figure
else
    % Parent figure specified
    parent = args{idx*2};       % copy value
    args(idx*2-1 : idx*2) = [];	% remove param/value pair
end
end
        
%     end

% end

% [EOF]
