classdef (CaseInsensitiveProperties = true,...
            TruncatedProperties = true, ...
            Sealed = true) ToggleMenu < spcwidgets.AbstractWidget
    %ToggleMenu   Define the UIMenuToggle class.
   
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:05 $

    properties (SetAccess = private)     
        Type = 'spcwidgets.ToggleMenu';
        hmenu;        
        Listeners;
    end
    
    properties        
        Parent;        
        Callback;        
    end
    
    properties (SetObservable, AbortSet)
        Accelerators;
        Labels;
        Enable = 'on';        
        Separator = 'off';
        Visible = 'off';
        Tag = '';
        Checked = 'off';
        Test = 1;
    end
    
    methods
        
        function this = ToggleMenu(varargin)
            %ToggleMenu   Construct the ToggleMenu class.
                        
            mlock;
            
            % Instantiate menu widget:
            %
            if mod(nargin,2)==1
                this.Parent=varargin{1};
                varargin=varargin(2:end);
            end
            
            % Because this.Visible is 'off' by default, pass this value directly to the
            % uimenu at creation.  Do not rely on listeners for that first set, because
            % they will not fire.
            pvPairs = {'Visible', this.Visible, 'Enable', this.Enable, 'Tag', this.Tag, ...
                'Separator', this.Separator};
            if isempty(this.Parent)
                this.hmenu = uimenu(pvPairs{:});
            else
                this.hmenu = uimenu(this.Parent, pvPairs{:});
            end
            set(this.hmenu,'Callback',@(p,e) execCallback(this));
            
            installPropertyListeners(this);
            
            set(this,varargin{:});            
            localAutoUpdate(this);
        end
        
        % -----------------------------------------------------
        function set.Checked(obj,val)
            obj.Checked = val;
        end
        
        % -----------------------------------------------------
        function set.Labels(obj,val)
            % Set-function for Labels property
            %  - must be a string or cell-array of strings
            %  - an empty string is allowed
            
            % if a single string is passed, wrap in a cell
            if ischar(val)
                val = {val};            
            end
            % Validate setting
            msg = {'spcwidgets:MustBeString','Labels must be either a string or a cell-array of strings'};
            if ~iscell(val)
                error(msg{:});
            end
            numLabels = numel(val);
            for i=1:numLabels
                if ~ischar(val{i})
                    error(msg{:});
                end
            end
            
            % Cross-check with # of Accelerators
            %  - scalar expansion demands 1 or N labels, where N=# accel
            %  - empty/zero entries is treated like 1 entry
            numAccel = numel(obj.Accelerators); %#ok
            if (numLabels~=numAccel) && (numLabels>1) && (numAccel>1)
                error('spcwidgets:NumLabelsAndAccel', ...
                    ['Number of Labels(%d) and number of Accelerators (%d) are not compatible.\n', ...
                    'There must be the same number of Labels as Accelerators, or one of these\n' ...
                    'must be a single instance for scalar-expansion.'], ...
                    numLabels,numAccel);
            end
            obj.Labels = val;
        end
        % -----------------------------------------------------
        function set.Accelerators(obj,val)
            % Set-function for Labels property
            %  - must be a string or cell-array of strings
            %  - an empty string is allowed
            
            % if a single string is passed, wrap in a cell
            if ischar(val)
                val ={val};            
            end
            % Validate setting
            msg = {'spcwidgets:MustBeStringVector', ...
                'Accelerators must be either a string or a cell-array of strings'};
            if ~iscell(val)
                error(msg{:});
            end
            numAccel = numel(val);
            for i=1:numAccel
                if ~ischar(val{i})
                    error(msg{:});
                end
            end
            
            % Cross-check with # of Labels
            %  - scalar expansion demands 1 or N accels, where N=# accel
            %  - empty/zero entries is treated like 1 entry
            numLabels = numel(obj.Labels); %#ok
            if (numLabels~=numAccel) && (numLabels>1) && (numAccel>1)
                error('spcwidgets:NumLabelsAndAccel', ...
                    ['Number of Labels(%d) and number of Accelerators (%d) are not compatible.\n', ...
                    'There must be the same number of Labels as Accelerators, or one of these\n' ...
                    'must be a single instance for scalar-expansion.'], ...
                    numLabels,numAccel);
            end
            obj.Accelerators = val;
        end
                
        % -----------------------------------------------------------------        
        function delete(h)
            delete(h.Listeners);
            h.Listeners=[];
            
            % Handle could have been "pulled out" from under us
            if uimgr.isHandle(h.hmenu)
                delete(h.hmenu);
            end
            h.hmenu=[];
        end
        
        function appdata = getappdata(this, varargin)
            %GETAPPDATA Get the appdata.
            %   OUT = GETAPPDATA(ARGS) get the appdata specified in varargin
            appdata = getappdata(this.hmenu, varargin{:});
        end

        function val = isappdata(this, key)
            %SETAPPDATA Set the appdata
            %   OUT = SETAPPDATA(ARGS) sets the appdata identified in varargin           
            val = isappdata(this.hmenu, key);            
        end
        
        function setappdata(this, varargin) 
            %  SETAPPDATA(H, NAME, VALUE) sets application-defined data for
            %  the object H
            setappdata(this.hmenu, varargin{:});
        end
        
        function rmappdata(this, varargin)
            %RMAPPDATA remove the appdata identified by varargin
            %   OUT = RMAPPDATA(ARGS) remove the appdata identified by varargin
            rmappdata(this.hmenu, varargin{:});
        end
    end
    
    methods (Access = 'protected')
        % -------------------------------------------------------------------------
        function installPropertyListeners(this)
            % Initialize listeners
            %            
            delete(this.Listeners);
            this.Listeners = [];
                        
            this.Listeners = event.proplistener(this, this.findprop('Accelerator'), ...
                'PostSet', @(p,e) localAutoUpdate(this));
            
%             this.Listeners(2) = addlistener(this, 'Checked', 'PostSet', ...
%                         @(p,e) localReactToChecked(this) );
            
            this.Listeners(2) = event.proplistener(this, this.findprop('Checked'), ...
                'PostSet', @(p,e) localReactToChecked(this));
            
            this.Listeners(3) = event.proplistener(this, this.findprop('Labels'), ...
                'PostSet',  @(p,e) localAutoUpdate(this));
            
            this.Listeners(4) = event.proplistener(this, [this.findprop('Enable'), ...
                this.findprop('Separator'), this.findprop('Visible'), ...
                this.findprop('Tag')], ...
                'PostSet',  @(p,e) localReact(this, p));                        
                
        end
        % -------------------------------------------------------------------------
        function execCallback(this)
            % Execute callback and side-effect (local update)
            %  as dispatched from underlying uimenu
            
            if strcmpi(this.Checked,'on')
                s='off';
            else
                s='on';
            end
            % Disable listener before changing checked setting
            % so we can guarantee sequential ordering
            % first auto-update, then callback
            this.Listeners(2).Enabled = false;
            this.Checked = s;
            this.Listeners(2).Enabled = true;
            
            % Note:
            % A listener of "Checked" state may have changed
            % the state on us, say, to implement a constraint
            % on whether the item can be turned off.
            %
            % So we must re-confirm that Checked has changed
            % If the current Checked state matches "s",
            % it has changed.  If is has not, skip:
            if strcmpi(this.Checked,s)
                % Change in state occurred
                
                % Update label, accelerator, etc
                localAutoUpdate(this,1);
                
                % Execute callback
                if ~isempty(this.Callback)
                    if ischar(this.Callback)
                        eval(this.Callback);
                    else
                        % Function handle:
                        %
                        % Pass two standard args (just like HG):
                        %  handle to Parent object, and
                        %  event structure (which is empty here)
                        feval(this.Callback,this,[]);
                    end
                end
            end
        end
    end
end

% -------------------------------------------------------------------------
function localReactToChecked(this)
% Change high-level object state
set(this.hmenu,'Checked', this.Checked);
% be sure to take into account initial state for label
localAutoUpdate(this);
end
% -------------------------------------------------------------------------
function localReact(this, hProp)
propName = hProp.Name;
%             propName = get(hProp, 'Name');

% Change enable state
%             set(this.hmenu, propName, get(this, propName));
set(this.hmenu, propName, this.(propName));
end
% -------------------------------------------------------------------------
function localAutoUpdate(this,dir)
% Change selection based on Checked

if nargin<2
    % dir:
    %  0: copy checked state from hmenu to this
    %  1: copy checked state from this to hmenu
    dir=0;
end

if dir
    set(this.hmenu,'Checked',this.Checked);
else
    % Disable listener before changing checked setting
    this.Listeners(2).Enabled = false;
    this.Checked = get(this.hmenu,'Checked');
    this.Listeners(2).Enabled = true;
end

switch this.Checked
    case 'on'
        select = 1;
    otherwise
        % May only be one selection
        select = max([1 numel(this.Labels) numel(this.Accelerators)]);
end

% Change menu accelerator, implement scalar-expansion
i=min(select, numel(this.Accelerators));
if i>0 % if i==0, leave HG default
    set(this.hmenu,'Accelerator',this.Accelerators{i});
end

% Change menu label, implement scalar-expansion
% Could be zero as well
i=min(select, numel(this.Labels));
if i>0 % if i==0, leave HG default
    set(this.hmenu,'Label',this.Labels{i});
end
end

% [EOF]
