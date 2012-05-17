classdef (CaseInsensitiveProperties = true,...
            TruncatedProperties = true, ...
            Sealed = true) PushTool < spcwidgets.AbstractWidget
    %PushTool   Define the PushTool class.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2009/08/14 04:06:25 $

    properties
        AutoCycle = 'off';
        ClickedCallback;        
        Parent;                                 
    end
    
    properties (SetObservable,  AbortSet) 
        Separator = 'off';
        Enable = 'on';
        Tag;        
        Visible = 'on';
        Interruptible = 'on';
        BusyAction = 'queue';       
    end
    
    properties (SetObservable, AbortSet)
        Icons = {};
        Selection = 1;        
        Tooltips = {}
    end
    
    properties (SetAccess = private)
        Type = 'spcwidgets.PushTool';
    end
    
    properties (GetAccess = private, SetAccess = private)       
        hButton;
        Listeners;
    end

    methods
        function this = PushTool(varargin)
            % Constructor for PushTool object.
                        
            mlock;
            % Instantiate push button widget:
            %
            if mod(nargin,2)==1
                this.parent=varargin{1};
                varargin=varargin(2:end);
            end
            if isempty(this.Parent)
                this.hButton = builtin('uipushtool');
            else
                this.hButton = builtin('uipushtool',this.Parent);
            end
            set(this.hButton,'clickedcallback',@(p,e) execCallback(this));
            
            installPropertyListeners(this);
            
            set(this,varargin{:});
        end
    end

    methods
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
            numIcons = numel(obj.Icons); %#ok
            if (numTips~=numIcons) && (numTips>1) && (numIcons>1)
                error('spcwidgets:NumTooltipsAndIcons', ...
                    ['Number of Tooltips (%d) and number of Icons (%d) are not compatible.\n', ...
                    'There must be the same number of Tooltips as Icons, or one of these\n' ...
                    'must be a single instance for scalar-expansion.'], ...
                    numTips,numIcons);
            end        
            obj.Tooltips = val;
        end
        
        % -----------------------------------------------------
        function set.Selection(obj,val)
            % Check Selection value
            
            % Count "zero items" as if there is one selection
            % That's because zero icons/tooltips is treated as one (default)
            %
            maxSel = max([1, numel(obj.Icons), numel(obj.Tooltips)]); %#ok
            if (val<1) || (val > maxSel)
                error('spcwidgets:InvalidSelection', ...
                    'Invalid Selection value - valid range is 1 to %d', maxSel);
            end
            obj.Selection = val;
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
            numTips = numel(obj.Tooltips); %#ok
            if (numTips~=numIcons) && (numTips>1) && (numIcons>1)
                error('spcwidgets:NumTooltipsAndIcons', ...
                    ['Number of Icons (%d) and number of Tooltips (%d) are not compatible.\n', ...
                    'There must be the same number of Icons as Tooltips, or one of these\n' ...
                    'must be a single instance for scalar-expansion.'], ...
                    numIcons, numTips);
            end
            obj.Icons = val;
        end        
        
        % -----------------------------------------------------
        function delete(h)            
            if ishandle(h.hButton)
                delete(h.Listeners);
            end
            h.Listeners=[];
            
            if ishandle(h.hButton)
                delete(h.hButton);
            end
            h.hButton=[];
            
            h.Icons={};
            h.Tooltips={};
        end
    end
    
    methods (Access = 'protected')
        % -------------------------------------------------------------------------
        function installPropertyListeners(this)
            % Initialize listeners            
            this.Listeners = event.proplistener(this, ...
                [this.findprop('Tooltips'), this.findprop('Icons')], ...
                'PostSet', @(h,e)localUpdateIcontooltip(this));
            
            this.Listeners(2) = event.proplistener(this, ...
                this.findprop('Selection'), ...
                'PostSet', @(h,e)localReactToSelection(this));
            
            this.Listeners(3) = event.proplistener(this, ...
                [this.findprop('Enable'), this.findprop('Separator'), ...
                 this.findprop('Visible'), this.findprop('Tag'), ...
                 this.findprop('BusyAction') this.findprop('Interruptible')], ...
                'PostSet', @(h,e)localReact(this, h));            
        end
        
        % -------------------------------------------------------------------------
        function localUpdateIcontooltip(this)
            % Called when Icons or Tooltips has changed
            % Try to keep current selection
            % If it is no longer viable, reset Selection to 1
            
            % It can be assumed that sel>0, since it's a current and legal value
            % but it may now exceed the max # of selections due to a change
            % in # of tooltips or icons
            %
            % Count "zero items" as if there is one selection
            % That's because zero icons/tooltips is treated as one (default)
            % icon/tooltip
            maxSel = max([1 numel(this.Icons) numel(this.Tooltips)]);
            if this.Selection > maxSel
                need_force = (this.Selection==1);
                this.Listeners(2).Enabled = false;
                this.Selection = 1; % changing selection may trigger update itself
                this.Listeners(2).Enabled = true;
                if need_force    % but if selection was already 1, we must push
                    localReactToSelection(this);   % the change manually
                end
            else
                % No need to change selection
                % Just update icon and/or tooltip as appropriate
                localReactToSelection(this);
            end
        end
        
        % -------------------------------------------------------------------------
        function localReactToSelection(this)
            % Change icon/tooltip based on selection
            
            % Change button tooltip, implement scalar-expansion
            i=min(this.Selection, numel(this.Tooltips));
            if i>0 % if i==0, leave HG default
                set(this.hButton,'TooltipString',this.Tooltips{i});
            end
            
            % Change button icon, implement scalar-expansion
            % Could be zero as well
            i=min(this.Selection, numel(this.Icons));
            if i>0 % if i==0, leave HG default
                set(this.hButton,'CData',this.Icons{i});
            end
        end
        
        % -------------------------------------------------------------------------
        function localReact(this, hProp)      
%             if ~isempty(findprop(hProp, 'Name'))
                propName = hProp.Name;
                % Change enable state
                set(this.hButton, propName, this.(propName));
%             end
%             propName = get(hProp, 'Name');
%             
%             % Change enable state
%             set(this.hButton, propName, get(this, propName));
        end
        
        % -------------------------------------------------------------------------
        function execCallback(this)
            % Execute callback and any side-effects (local update)
            %  as dispatched from underlying PushTool button
            
            % Cycle through selection, if option turned on
            if strcmpi(this.AutoCycle,'on')
                % Increment the current selection from 1 to N,
                % then cycle back to 1
                Nmax = max(numel(this.Tooltips),numel(this.Icons));
                this.Selection = rem(this.Selection,Nmax)+1;
            end
            
            % Execute callback
            cbFcn = this.clickedcallback;
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
    end

end

% [EOF]
