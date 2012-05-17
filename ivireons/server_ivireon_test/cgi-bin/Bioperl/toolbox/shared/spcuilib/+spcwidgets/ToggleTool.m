classdef (CaseInsensitiveProperties = true, ...
            TruncatedProperties = true, ...
            Sealed = true) ToggleTool < spcwidgets.AbstractWidget
    %ToggleTool   Define the ToggleTool class.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2009/08/14 04:06:31 $
    
    properties        
        Parent;
        ClickedCallback;        
        Callback;
        OffCallback;
        OnCallback;                        
                            
    end
    
    properties (Dependent)
        BusyAction;
        Interruptible;
    end
    
    properties (SetObservable, AbortSet)
        Tag;
        Visible = 'on';        
        Enable = 'on';
        Separator = 'off';             
        State = 'off';
    end
    
    properties (SetObservable, Dependent, AbortSet)
        Tooltips = {};      
        Icons = {};
    end
    
    properties (SetAccess = private)
        Type = 'spcwidgets.ToggleTool';
    end
    
    properties (GetAccess = private, SetAccess = private)       
        hbutton;
        Listeners;
        privTooltips = {};      
        privIcons = {};
    end
    
    methods
        
        function this = ToggleTool(varargin)
            %ToggleTool   Construct the ToggleTool class.
                 
            mlock;
            
            % Instantiate push button widget:
            %
            if mod(nargin,2)==1
                this.parent=varargin{1};
                varargin=varargin(2:end);
            end
            
            if isempty(this.parent)
                this.hbutton = builtin('uitoggletool');
            else
                this.hbutton = builtin('uitoggletool',this.parent);
            end
            set(this.hbutton,'oncallback',     @(p,e) execCallBack(this,'oncallback'));
            set(this.hbutton,'offcallback',    @(p,e) execCallBack(this,'offcallback'));
            set(this.hbutton,'clickedcallback',@(p,e) execCallBack(this,'clickedcallback'));
            
            installPropertyListeners(this);
            
            set(this,varargin{:});
            
        end
        
        % -----------------------------------------------------
        function set.Interruptible(obj, val)            
            set(obj.hbutton, 'Interruptible', val);
        end     
        % -----------------------------------------------------
        function val = get.Interruptible(obj)            
            val = get(obj.hbutton, 'Interruptible');
        end
        
        % -----------------------------------------------------
        function set.BusyAction(obj, val)            
            set(obj.hbutton, 'BusyAction', val);
        end
        % -----------------------------------------------------
        function val = get.BusyAction(obj)            
            val = get(obj.hbutton, 'BusyAction');
        end
        
        % -----------------------------------------------------
        function val = get.Tooltips(obj)
            val = obj.privTooltips;
        end
        
        % -----------------------------------------------------
        function set.Tooltips(obj,val)
            % Set-function for Tooltips property
            %  - must be a string or cell-array of strings
            %  - an empty string is allowed
            
            % if a single string is passed, wrap in a cell
            if ischar(val)
                val={val};
            end
            % Validate setting
            msg = {'spcwidgets:MustBeStringVector', ...
                'Tooltips must be either a string or a cell-array of strings'};
            if ~iscell(val)
                error(msg{:});
            end
            numTips = numel(val);
            for i=1:numTips
                if ~ischar(val{i})
                    error(msg{:});
                end
            end
            
            % Cross-check with # of icons
            %  - scalar expansion demands 1 or N icons, where N=# tooltips
            %  - empty/zero entries is treated like 1 entry
            numIcons = numel(obj.Icons);
            if (numTips~=numIcons) && (numTips>1) && (numIcons>1)
                error('spcwidgets:NumTooltipsAndIcons', ...
                    ['Number of Tooltips (%d) and number of Icons (%d) are not compatible.\n', ...
                    'There must be the same number of Tooltips as Icons, or one of these\n' ...
                    'must be a single instance for scalar-expansion.'], ...
                    numTips,numIcons);
            end
            obj.privTooltips = val;
        end
        
        % -----------------------------------------------------
        function val = get.Icons(obj)
            val = obj.privIcons;
        end
        % -----------------------------------------------------
        function set.Icons(obj,val)
            % Set-function for Icons property
            %
            % Must be an array or cell-array of arrays
            %
            % Each icon must be either a 2-D matrix or a 3-D arrays with 3rd dim set to
            % 3, but we leave this reporting to when the icon is actually selected, so
            % the checking is not replicated here.
            
            % if a single array is passed, wrap in a cell
            if isnumeric(val)
                val={val};
            end
            % Validate setting
            msg = {'spcwidgets:InvalidIcons', ...
                'Icons must be either an array or a cell-array of arrays'};
            if ~iscell(val)
                error(msg{:});
            end
            numIcons = numel(val);
            for i=1:numIcons
                if ~isnumeric(val{i})
                    error(msg{:});
                end
            end
            
            % Cross-check with # of icons
            %  - scalar expansion demands 1 or N icons, where N=# tooltips
            %  - empty/zero entries is treated like 1 entry
            numTips = numel(obj.Tooltips);
            if (numTips~=numIcons) && (numTips>1) && (numIcons>1)
                error('spcwidgets:NumTooltipsAndIcons', ...
                    ['Number of Icons (%d) and number of Tooltips (%d) are not compatible.\n', ...
                    'There must be the same number of Icons as Tooltips, or one of these\n' ...
                    'must be a single instance for scalar-expansion.'], ...
                    numIcons, numTips);
            end
            obj.privIcons = val;
        end        
        
        % ----------------------------------
        function delete(h)
            %DELETE
            
            delete(h.listeners);
            h.listeners=[];
            
            if ishandle(h.hbutton)
                delete(h.hbutton);
            end
            h.hbutton=[];
            
            h.Icons={};
            h.Tooltips={};
        end
        
        % ----------------------------------
        function appdata = getappdata(this, varargin)
            appdata = getappdata(this.hbutton, varargin{:});
        end
        
        % ----------------------------------
        function b = isappdata(this, varargin)
            b = isappdata(this.hbutton, varargin{:});
        end
        
        % ----------------------------------
        function rmappdata(this, varargin)
            rmappdata(this.hbutton, varargin{:});
        end
        
        % ----------------------------------
        function setappdata(this, varargin)
            setappdata(this.hbutton, varargin{:});
        end
    end
    
    methods (Access = 'protected')
        % -------------------------------------------------------------------------
        function installPropertyListeners(this)
            % Initialize listeners
            this.Listeners = event.proplistener(this, ...
                [this.findprop('Icons'), this.findprop('Tooltips')], ...
                'PostSet', @(h,e)localAutoUpdate(this));                        
            
            this.Listeners(2) = event.proplistener(this, ...
                this.findprop('State'), ...
                'PostSet', @(h,e)localReactToState(this));
            
            this.Listeners(3) = event.proplistener(this, ...
                [this.findprop('Enable'), this.findprop('Separator'), ...
                 this.findprop('Visible'), this.findprop('Tag')], ...
                'PostSet', @(h,e)localReact(this, h));            
        end
        % -------------------------------------------------------------------------
        function localReact(this, hProp)
            propName = hProp.Name;                        
            set(this.hButton, propName, this.(propName));            
        end
        % -------------------------------------------------------------------------
        function localReactToState(this)
            % Change high-level object state
            set(this.hbutton,'State', this.State);
            % be sure to take into account initial state for icon
            localAutoUpdate(this);
        end
        % -------------------------------------------------------------------------
        function execCallBack(this,prop)
            % Execute callback and side-effect (local update)
            %  as dispatched from underlying uitoggletool button
            %
            % 'prop' describes one of the callback properties in the
            % widget object (either 'oncallback', 'offcallback', or
            % 'clickedcallback')
            %
            localAutoUpdate(this);
            cbFcn=this.(prop);
            if ~isempty(cbFcn)
                if ischar(cbFcn)
                    % Callback string - simple eval:
                    eval(cbFcn);
                else
                    % Pass two standard args (just like HG):
                    %  handle to parent object, and
                    %  event structure (which is empty here)
                    feval(cbFcn,this,[]);
                end
            end
        end
        % -------------------------------------------------------------------------
        function localAutoUpdate(this)
            % Change selection based on State
            
            % Disable listener before changing state setting
            this.listeners(2).Enabled=false;
            this.State = get(this.hbutton,'State');
            this.listeners(2).Enabled=true;
            
            switch this.State
                case 'on'
                    select = 1;
                otherwise
                    % May only be one selection
                    select = max([1 numel(this.Icons) numel(this.Tooltips)]);
            end
            
            % Change button tooltip, implement scalar-expansion
            i=min(select, numel(this.Tooltips));
            if i>0 % if i==0, leave HG default
                set(this.hbutton,'TooltipString',this.Tooltips{i});
            end
            
            % Change button icon, implement scalar-expansion
            % Could be zero as well
            i=min(select, numel(this.Icons));
            if i>0 % if i==0, leave HG default
                set(this.hbutton,'CData',this.Icons{i});
            end
        end
    end
    
end

% [EOF]
