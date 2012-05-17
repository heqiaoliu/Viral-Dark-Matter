classdef (CaseInsensitiveProperties = true,...
            TruncatedProperties = true, ...
            Sealed = true) Status < spcwidgets.AbstractWidget
% classdef (Sealed = true) Status < spcwidgets.AbstractWidget
        
    %Status   Define the Status class.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2010/01/25 22:46:23 $

    properties
        Tag;
        hParent;
    end
     properties (Dependent)
       Callback;
       Enable;
       Text;
       Tooltip;
       Truncate;
       Visible;
       Width;                     
    end
    
    properties (GetAccess = private, SetAccess = private)       
       TextHandle = [];
       PrivateIndex;       
    end
    
    properties (SetAccess = private)     
        Index;        
    end

    methods

        function this = Status(varargin)
            %Status Constructor for Status object.
                        
            mlock;
            
            args = varargin;
            if mod(nargin,2)==1
                args = ['Parent', args]; % add missing param name
            end
            [parent,args] = getParent(args); % handle to StatusBar
            
            this.hParent = parent;
            
            [width,args] = getWidth(args); % pixel width of new option region
            parent.addChildren(this);
%             connect(this,parent,'up'); % Status is child of StatusBar
            
            % Add option region to list, specifying width
            hWidget = parent.hWidget;
            hWidget.OptionWidths = [hWidget.OptionWidths width];
            
            this.PrivateIndex = numOptions(hWidget);  % record option region index
            if ~isempty(args)
                set(this,args{:}); % set remaining param/value pairs            
            end
        end
        
        % ----------------------------------------
        function set.Width(h,val)
                % We're setting a PROPERTY on hWidget
                h.hParent.hWidget.optionWidths(h.PrivateIndex) = val;
        end
        
        % ----------------------------------------
        function val = get.Width(h)
                % We're setting a PROPERTY on hWidget
                val = h.hParent.hWidget.optionWidths(h.PrivateIndex);
        end
        
        % ----------------------------------------
        function val = get.Index(h,val) %#ok
            val = h.PrivateIndex; % get copy of private property
        end
        
        % ----------------------------------------
        function set.Text(h,str)
                optionText(h.hParent.hWidget, h.PrivateIndex, str);
        end
        
        % ----------------------------------------
        function str = get.Text(h)
                str = optionText(h.hParent.hWidget,h.PrivateIndex);
        end
        % ----------------------------------------
        function set.Tooltip(h,str)
                optionTooltip(h.hParent.hWidget, h.PrivateIndex, str);
        end
        % ----------------------------------------
        function str = get.Tooltip(h)
                str = optionTooltip(h.hParent.hWidget, h.PrivateIndex);
        end
        % ----------------------------------------
        function set.Callback(h,str)
                optionCallback(h.hParent.hWidget, h.PrivateIndex, str);
        end
        % ----------------------------------------
        function str = get.Callback(h)
                str = optionCallback(h.hParent.hWidget, h.PrivateIndex);
        end
        % ----------------------------------------
        function set.Enable(h,ena)
                optionEnable(h.hParent.hWidget, h.PrivateIndex, ena);
        end
        % ----------------------------------------
        function ena = get.Enable(h)
                ena = optionEnable(h.hParent.hWidget, h.PrivateIndex);
        end
        
        % ----------------------------------------
        function set.Visible(h,vis)
                optionVisible(h.hParent.hWidget, h.PrivateIndex, vis);
        end
        % ----------------------------------------
        function vis = get.Visible(h)
                vis = optionVisible(h.hParent.hWidget, h.PrivateIndex);
        end
        % ----------------------------------------
        function set.Truncate(h,trunc)
                optionTruncate(h.hParent.hWidget, h.PrivateIndex, trunc);
        end
        % ----------------------------------------
        function trunc = get.Truncate(h)
                trunc = optionTruncate(h.hParent.hWidget, h.PrivateIndex);
        end
        % ----------------------------------------
        function delete(h) 
%             %DELETE Destroy option region.
            
            % First we must adjust the recorded Index property of
            % all other children with Index >= thisIndex
            if isvalid(h.hParent) && ~isempty(h.hParent.hWidge)
                decrementIndices(h);
                optionDelete(h.hParent.hWidget, h.PrivateIndex);
                % disconnect(h); % Remove connection to StatusBar
                h.hParent.Children(end+1-h.PrivateIndex) = []; % = [h.hParent.Children(1:h.PrivateIndex-1) h.hParent.Children(h.PrivateIndex+1:end)];
            end
            
            % Reset private properties
            h.PrivateIndex = -1; % reset index
            h.TextHandle = [];  % reset to prevent accidents
        end
        
        % ----------------------------------------
        function textFast(h,str)
            %TEXTFAST Quickly set option region text.            
            set(h.TextHandle,'string',str);
        end
        % ----------------------------------------
        function textFastInit(h,str) %#ok
            %Initialize textfast method.
            
            % For efficiency of textfast() method
            %
            % Must do this manually here, and not in constructor, in case re-rendering occurs
            % (such as a change in the # of option regions)
            %
            % No desire to put in a listener...
            
            if ~isempty(h.hParent)
                h.TextHandle = optionTextHandle(h.hParent.hWidget,h.privateIndex);
            else
                % Parent no longer exists
                h.TextHandle = [];
            end            
        end                      
    end

    methods (Access = 'protected')
        % --------------------------------------
        function decrementIndices(hChild)
            %decrementIndices Decrement all child indices for children
            %  "past" the child referenced by h.privateIndex.
            %  Ex: if there are 6 children, and thisIndex=3,
            %      we decrement the index of child 4, 5, and 6.            
            
            idx = hChild.Index;
            for i=1:length(hChild.hParent.Children)-idx
                hChild = hChild.hParent.Children(i);
                hChild.privateIndex = hChild.privateIndex - 1;
            end
        end
    end
end

% -----------------------------------------------
function [width,args] = getWidth(args)
% Get pixel width of new option region
% Extract param names from list of param/value pairs

if isempty(args)
    paramNames = {};
else
    paramNames = args(1:2:end-1);
end
% Search param/value list for 'width' property
idx = find(strcmpi('width',paramNames));
if isempty(idx)
    % No width specified
    width = 40; % default
else
    % Copy corresponding width value
    width = args{idx*2};
    % Remove param/value pair
    args(idx*2-1 : idx*2) = [];
end
end

% -----------------------------------------------------------
function [parent,args] = getParent(args)

% Extract param names from list of param/value pairs
if isempty(args)
    paramNames = {};
else
    paramNames = args(1:2:end-1);
end
% Search param/value list for 'parent' property
idx = find(strcmpi('parent',paramNames));
if isempty(idx)
    % No parent specified
    
    % We'd like to use an existing one, or create a new one
    % But we don't know how to "find an existing one" currently
    % Just creating one each time will lead to problems, as
    % there should really only be ONE statusbar per figure.
    % So until we figure out how to detect one, and get its
    % handle, we error-out:
    error('spcwidgets:Status:NoParent', ...
        'Parent StatusBar handle must be specified.');
else
    % Copy corresponding parent value
    parent = args{idx*2};
    % Remove param/value pair
    args(idx*2-1 : idx*2) = [];
end
if ~isa(parent,'spcwidgets.StatusBar')
    error(generatemsgid('InvalidParent'),...
        'Invalid parent specified.');
end
end

% [EOF]
