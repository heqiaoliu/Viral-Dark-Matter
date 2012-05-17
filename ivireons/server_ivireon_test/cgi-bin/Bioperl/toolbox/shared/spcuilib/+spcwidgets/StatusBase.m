classdef (CaseInsensitiveProperties = true,...
            TruncatedProperties = true, ...
            Sealed = true) StatusBase < spcwidgets.AbstractWidget
    %StatusBase   Define the StatusBase class.
   
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:46:25 $

    properties
        Parent;
        Visible = 'on';
        hContainer;
        hAllOptions;
        hstatusText;
        hOptionText;
        Listeners;
    end
    
    properties (SetObservable,  AbortSet)
        GrabBar = 'on';
        OptionWidths = [];
    end
    
    methods

        function this = StatusBase(varargin)
            %STATUSBASE Construct StatusBase object.
            %   STATUSBASE adds itself to a parent uiflowcontainer.  The parent
            %   generally has a 'bottomup' flowdirection, and StatusBase is
            %   generally added as the first child of the parent container so
            %   it is located at the bottom of the container.  If no parent is
            %   specified, an appropriate uiflowcontainer is instantiated.
            %
            %   StatusBar creates a region for displaying status information
            %   about the GUI application.  The left side of the status bar
            %   displays general status text in a "flat" region (no indents).
            %   The right side can have zero or more options regions, displaying
            %   additional information for the application in indented text areas.
            %   Automatic resizing of status bar is provided when figure is resized.
            %
            %   Not intended to be used directly; use StatusBar and Status.
            %   If a StatusBase object is instantiated, the graphical rendering
            %   will be destroyed by subsequent calls to StatusBar or Status.
            %
            % StatusBase('param',value, ...)
            %    specifies multiple parameter/value pairs to use in object construction
            %
            % StatusBase(hfig,'param',value, ...)
            %    specifies parent figure for status bar; may also be specified
            %    using 'Parent' property
            %
            % Parameters:
            %   GrabBar
            %     Turn on or off the resize grab bar
            %   OptionWidths
            %     Vector of pixel widths for each option region
            %     The number of options regions is the number of values
            %     in the vector.
            %   Parent
            %     Scalar handle to parent figure
            %   Visible
            %     On/off property changes visibility of status bar,
            %     effectively removing it from figure when set to 'off'.
            
            %   ResizePriority
            %     Specifies whether the status region ('Status') or options region
            %     ('Options') is to remain visible as the width of the status bar
            %     shrinks due to resizing. 'LastOption' keeps the status region
            %     visible until the last options region is about to vanish; then,
            %     the last options region is given priority.
            mlock;
            
            if mod(nargin,2)==1
                varargin=['Parent', varargin];
            end
            
            if ~isempty(varargin)
                set(this,varargin{:});
            end
%             installSetFunctions(this);
            localInit(this);
        end
        
%         % ----------------------------------------------------
%         function installSetFunctions(hStatusBar)
%             % We do this here, and not in the schema, since the functions
%             % needed for callbacks exist here as local functions.  So registering
%             % those here is simply a convenience.
%             
%             p = findprop(hStatusBar,'Visible');
%             p.SetFunction = @sf_Visible;
%         end
         % -----------------------------------------------
        function set.Visible(obj,val)
            %set.Visible Set-function handling changes to Visible property.
            set(obj.hContainer,'visible',val);
            obj.Visible = val;
        end
        
        % -----------------------------------------------
        function localDelete(hStatusBar)
            %localDelete localDelete StatusBar.
            delete(hStatusBar.listeners); % just to be sure
            hStatusBar.listeners = [];
            
            % Removes the bar and all children
            set(hStatusBar.hContainer,'DeleteFcn',[]); % remove fcn (prevents recursion)
            delete(hStatusBar.hContainer);
            hStatusBar.hContainer = [];
            
            % Just reset the other properties:
            %   they've been deleted or are no longer useful
            hStatusBar.hAllOptions = [];
            hStatusBar.hstatusText = [];
            hStatusBar.hOptionText = [];
        end
        % -----------------------------------------------
        function y = numOptions(obj)
            %numOptions Return number of option regions.            
            y = numel(obj.OptionWidths);
        end
        
        % -----------------------------------------------
        function cache = optionCache(h)
            %optionCache Cache state of option regions in status bar.
            
            % cache is a cell-matrix of option properties,
            %   with one property per column, and one option per row
            %
            % Option property names are specified in private helper method
            [p ap] = optionCacheProps(h);
            
            
            % We would have grabbed all prop values at once, but dynamic properties
            % don't participate in vector-get/set ... meaning, vector of properties.
            % (They DO participate in vector-of-handle accesses, however).
            Nprops  = numel(p);
            Naprops = numel(ap);
            cache = cell(1,Nprops+Naprops);
            if ~any(ishghandle(h.hOptionText))
                Naprops = 0;
            end
            Nopts = numel(h.hOptionText);
            if Nopts==1
                % Guarantee a cell-vector containing cells,
                % so restore has a simple pattern
                for i = 1:Nprops
                    cache{i} = {get(h.hOptionText,p{i})};
                end
                for i = 1:Naprops
                    cache{i+Nprops} = {getappdata(h.hOptionText, ap{i})};
                end
            else
                for i = 1:Nprops
                    cache{i} = get(h.hOptionText,p{i});
                end
                for i = 1:Naprops
                    propCache = cell(1,Nopts);
                    for j = 1:Nopts
                        propCache{j} = getappdata(h.hOptionText(j), ap{i});
                    end
                    cache{i+Nprops} = propCache;
                end
            end
        end
        
        % --------------------------------------
        function [y y2] = optionCacheProps(h)
            %optionCacheProps List of option region text-widget properties
            %  to be cached for later restoration.
            
            % Cached values:
            %
            % Standard props
            % --------------
            %  optionCallback: .hOptionText(idx), prop='buttondownfcn'
            %    optionEnable: .hOptionText(idx), prop='enable'
            %    optionHilite: .hOptionText(idx), prop='background'
            %      optionText: .hOptionText(idx), prop='string'
            %   optionTooltip: .hOptionText(idx), prop='tooltip'
            %
            % AppData props
            % -------------
            %  'OptionOrigString' (string)
            %    'optionTruncate' (bool)
            
            y  = {'string','tooltip','enable','background','buttondownfcn', 'visible'};
            y2 = {'OptionOrigString','optionTruncate'};
        end
        
        % -----------------------------------------------
        function y = statusCacheProps(h)
            %statusCacheProps List of status region text-widget properties
            %  to be cached for later restoration.
            
            % Cached values:
            %
            % Standard props
            % --------------
            %  statusCallback: .hstatusText, prop='buttondownfcn'
            %    statusEnable: .hstatusText, prop='enable'
            %      statusText: .hstatusText, prop='string'
            %   statusTooltip: .hstatusText, prop='tooltip'
            
            y = {'buttondownfcn','enable','string','tooltip','visible'};
        end

        % -----------------------------------------------
        function y = optionCallback(obj,idx,fcn)
            %optionCallback Set callback on options regions.
            
            error(nargchk(2,3,nargin, 'struct'));
            checkOptionIndex(obj,idx);
            
            if nargin>2
                set(obj.hOptionText(idx), 'buttondownfcn',fcn);
                
                % The following p/v pair allows callbacks to operate more reliably,
                % but suppresses tooltips completely:
                %  'enable','inactive', ...
            end
            if nargout>0
                y = get(obj.hOptionText(idx),'buttondownfcn');
            end
        end
        % -----------------------------------------------
        function optionDelete(h,delIdx)
            %OptionlocalDelete localDelete the referenced option regions.
                       
            % Allow "zero" regions to be removed
            %  (could be a programmatic thing)
            if isempty(delIdx)
                return
            end
            N = checkOptionIndex(h,delIdx);
            % Build "keep" index list from "delete" index list
            keepIdx = 1:N;
            keepIdx(delIdx) = [];
            
            if all(ishandle(h.hOptionText))
                optionKeep(h,keepIdx);
            end
        end
        % -----------------------------------------------
        function y = optionEnable(obj,idx,ena)
            %optionEnable Set enable state for option regions.
            %   optionEnable(H,IDX,ENA) sets the enable state for status bar
            %   option region specified by index IDX.  ENA='on' enables the
            %   option text, 'off' disables the text.
            %
            %   optionEnable(H,ENA) sets the enable state for all option regions.
            %
            %   ENA=optionEnable(H,IDX) gets the enable state for option region IDX.            
            error(nargchk(2,3,nargin,'struct'));
            
            % All on or all off specified:
            if nargin==2
                if nargout>0
                    y = get(obj.hOptionText(idx),'enable');
                else
                    % In this case, the 2nd arg (idx) is
                    % really the enable state (on/off)
                    ena=idx;
                    set(obj.hOptionText,'enable',ena);
                end
            else
                checkOptionIndex(obj,idx);
                set(obj.hOptionText(idx),'enable',ena);
            end
        end
        % -----------------------------------------------
        function optionHilite(obj,idx,state)
            %optionHilite Set highlighting for options regions.
            %   optionHilite(H,IDX,STATE) sets highlighting for the options
            %   region specified by index IDX.  STATE may be 'on' of 'off'.
            %   Highlight color is white.
            error(nargchk(3,3,nargin,'struct'));
            checkOptionIndex(obj,idx);
            
            if strcmpi(state,'on')
                % bg = [.8 .4 .4]; % pale red
                bg = [1 1 1];      % white
            else
                bg = obj.Background;  % restore (no highlight)
            end
            set(obj.hOptionText(idx),'background',bg);
        end
        % -----------------------------------------------
        function optionKeep(h,idx)
            %optionKeep Keep only the referenced option regions.
            checkOptionIndex(h,idx);
            
            % Store all old options
            cache = h.optionCache;
            
            % Keep only specified option region widths
            h.OptionWidths = h.OptionWidths(idx);
            
            % Restore only specified options
            h.optionRestore(cache,idx);
        end
        % -----------------------------------------------
        function optionRestore(h,optionCache,idx)
            %optionRestore Restore state of status and options regions from cache.
            %   optionRestore(H,CACHE,IDX) restores the option region text, tooltip,
            %   callback, and background color, in the order specified by IDX.
            %   If IDX is not specified, options are restored in order from the
            %   cache.  The number of options restored cannot exceed the number
            %   of defined options regions.  However, not all option regions need
            %   to be restored.
            
           if isempty(optionCache)
                return
            end
            localCheckoptionCache(h,optionCache);
            
            % Restore the options
            %   cache is organized with one cell-entry per property
            %   each cell entry has N items, one for each of the N option regions
            %  - take them from cache entries as cache{i}(idx)
            %    so IDX addresses the OLD items
            %  - put them in options{i}(1:N)
            %    so only N current options are addressed, in order
            NCachedOpts = numel(optionCache{1}); % # cached option regions
            if nargin<3
                % If not present, set the lesser of:
                %   - the number of cached options, and
                %   - the number of current options
                NCurrOpts = numel(h.hOptionText);
                N = min(NCachedOpts,NCurrOpts);
                idx = 1:N;
            end
            
            % Must pass extra option to checkOptionIndex, so it
            % checks against the cache --- not the object properties:
            checkOptionIndex(h,idx,NCachedOpts);
            
            % Set all the cached properties
            % set(h.hOptionText(1:numel(idx)), ...
            % 	optionCacheProps(h), optionCache(idx,:));
            
            [props aprops] = optionCacheProps(h);
            N = numel(idx);  % number of option regions to pull out of cache
            for i=1:numel(props)         % loop over each prop in set of cached props
                prop_i = props{i};       % i'th prop in set of cached props
                opts_i = optionCache{i}; % values for i'th prop for each text handle
                opts_i = opts_i(idx);    % pull out ones we want, in right order
                for j=1:N
                    set( h.hOptionText(j), prop_i, opts_i{j} );
                    optionTruncate(h,j); % reapply truncation
                end
            end
            for i = 1:numel(aprops)
                prop_i = aprops{i};
                opts_i = optionCache{i+numel(props)}; % values for i'th prop for each text handle
                opts_i = opts_i(idx);    % pull out ones we want, in right order
                for j=1:N
                    setappdata( h.hOptionText(j), prop_i, opts_i{j} );
                    optionTruncate(h,j); % reapply truncation
                end
            end
        end
        % -----------------------------------------------
        function y = optionText(h,idx,str)
            %optionText Get or set text for option regions.
            %   optionText(H,IDX,MSG) sets the text for status bar option region
            %     specified by index IDX.  IDX=1 is the first option region.
            %   optionText(H,IDX) returns the text for status bar option region
            %     specified by index IDX.
            error(nargchk(2,3,nargin,'struct'));
            checkOptionIndex(h,idx);
            
            % Get text widget
            % It has two dynamic properties on it that we care about here,
            %  - optionTruncate
            %  - OptionOrigString
            hTxt = h.hOptionText(idx);
            
            if nargin<3
                % Get current (non-truncated) string
                % Retrieve this from the original store, not the widget,
                % since it could have been truncated
                y = getappdata(hTxt,'OptionOrigString');
                
            else
                % Set new string
                
                % Store original text in case of truncation changes
                setappdata(hTxt,'OptionOrigString',str);
                
                if strcmpi(getappdata(hTxt,'optionTruncate'),'on')
                    % Takes longer time to process string, but looks nice.
                    % If strings overrun (adaptively truncates and uses '...')
                    renderTextWithEllipsis(h,idx,str);
                else
                    % Directly render text
                    % Faster, but could run past extent and get "clipped"
                    set(hTxt,'string',str);
                end
            end
        end
        % -----------------------------------------------
        function optionTextFast(h,idx,str)
            %optionTextFast Quickly set text for option regions.
            %   optionTextFast(H,IDX,MSG) quickly sets the text for status bar option
            %     region specified by index IDX.  IDX=1 is the first option region.
            %     Error checking and text truncation are NOT supported.
            
            % Set new string
            set(h.hOptionText(idx),'string',str);
        end
        % -----------------------------------------------
        function y = optionTextHandle(h,idx)
            %optionTextHandle Return option text handle for fast text updates.
            %   H = optionTextHandle(H,IDX) returns a text handle for fast updates
            %     to the option region text.            
            y = h.hOptionText(idx);
        end
        % -----------------------------------------------
        function y = optionTooltip(obj,idx,str)
            %optionTooltip Get or set tooltip for options regions.
            %   optionTooltip(H,IDX,TXT) sets the tooltip text for status bar option
            %   region specified by index IDX. IDX=1 is the first option region.
            %   optionTooltip(H,IDX) gets the tooltip text for status bar option.            
            error(nargchk(2,3,nargin, 'struct'));
            checkOptionIndex(obj,idx);
            y = [];
            if nargin<3
                y = get(obj.hOptionText(idx),'tooltip');
            else
                set(obj.hOptionText(idx),'tooltip',str);
            end
        end
        % -----------------------------------------------
        function y = optionTruncate(h,idx,trunc)
            %optionTruncate Set truncation control for option region.
            %   optionTruncate(H,IDX,TRUNC) sets text truncation option for status
            %   bar option region IDX.  'on' specifies the text should be
            %   automatically truncated to fit the width of the option region.
            %
            %   optionTruncate(H,IDX) invokes current truncation setting on
            %   a new option region text string.
            %
            %   TRUNC=optionTruncate(H,IDX) returns the current truncation state.
            
            error(nargchk(2,3,nargin, 'struct'));
            checkOptionIndex(h,idx);
            
            % Get text widget
            hTxt = h.hOptionText(idx);
            
            % Set new truncation option, if specified
            if nargin>2
                % Set new value for truncation
                %  - widget has a dynamic property on it: optionTruncate
                setappdata(hTxt,'optionTruncate',trunc);
            end
            
            % Only return current value if requested
            if nargout>0
                y = getappdata(hTxt,'optionTruncate');
            end
            
            % Only invoke truncation if no LHS is specified
            if nargout==0
                % Re-set string in this option region, so
                % the string truncation setting will take effect
                optionText(h, idx, getappdata(hTxt,'OptionOrigString'));
            end
        end
        % -----------------------------------------------
        function y = optionVisible(obj,idx,vis)
            %optionVisible Set visible state for option regions.
            %   optionVisible(H,IDX,VIS) sets the visible state for status bar
            %   option region specified by index IDX.  VIS='on' enables the
            %   option text, 'off' disables the text.
            %
            %   optionVisible(H,VIS) sets the visible state for all option regions.
            %
            %   VIS=optionVisible(H,IDX) gets the visible state for option region IDX.
            error(nargchk(2,3,nargin, 'struct'));
            
            % All on or all off specified:
            if nargin==2
                if nargout>0
                    y = get(obj.hAllOptions(idx),'visible');
                else
                    % In this case, the 2nd arg (idx) is
                    % really the visible state (on/off)
                    vis=idx;
                    set(obj.hAllOptions,'visible',vis);
                end
            else
                checkOptionIndex(obj,idx);
                set(obj.hAllOptions(idx),'visible',vis);
            end
        end
        % -----------------------------------------------
        function cache = statusCache(h)
            % Get all relevant properties related to status region
            % in order to save/restore its context.
            
            % Status property names are specified in private helper method
            % cache is a cell-vector
            cache = get(h.hstatusText,statusCacheProps(h));
        end
        % -----------------------------------------------
        function y = statusCallback(obj,fcn)
            %statusCallback Set callback on options regions.
            %   statusCallback(H,FCN) sets the callback function for status
            %   bar, which executes by right-clicking on the status region.
            %
            %   FCN=optionCallback(H) gets the current callback function.
            
            error(nargchk(1,2,nargin, 'struct'));
            if nargin>1
                set(obj.hstatusText, 'buttondownfcn',fcn);
                
                % The following p/v pair allows callbacks to operate more reliably,
                % but suppresses tooltips completely:
                %  'enable','inactive', ...
            end
            if nargout>0
                y = get(obj.hstatusText,'buttondownfcn');
            end
        end
        % -----------------------------------------------
        function y = statusEnable(obj,ena)
            %statusEnable Set enable state for status region.
            %   statusEnable(H,ENA) sets the enable state for status text.
            %   ENA='on' enables the status text, 'off' disables the text.
            %   Option region enable states are unaffected by this setting.
            %
            %   ENA=statusEnable(H) gets the enable state for status bar.
            
            error(nargchk(1,2,nargin, 'struct'));
            if nargin>1
                set(obj.hstatusText,'enable',ena);
            end
            if nargout>0
                y = get(obj.hstatusText,'enable');
            end
        end
        % -----------------------------------------------
        function statusRestore(h,cache)
            % Restore cached properties related to status region.            
            set(h.hstatusText,statusCacheProps(h),cache);
        end
        % -----------------------------------------------
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
        % -----------------------------------------------
        function statusTextFast(h,idx,str) %#ok
            %statusTextFast Quickly set text for status region.
            %   statusTextFast(H,MSG) quickly sets the text for status bar.
            %   No detection of text overlap with option region is performed;
            %   an explicit redraw or resize must be performed to have that
            %   checking occur.
            
            % Set new string
            set(h.hstatusText,'string',str);
        end
        % -----------------------------------------------
        function y = statusTextHandle(h,idx) %#ok
            %statusTextHandle Return status text handle for fast text updates.
            %   H=statusTextHandle(H,IDX) returns a text handle for fast updates
            %     to the status region text.
            
            y = h.hstatusText;
        end
        % -----------------------------------------------
        function y = statusTooltip(obj,str)
            %statusTooltip Set tooltip for status regions.
            %   Sets the tooltip for status region.
            if nargin>1
                set(obj.hstatusText,'tooltip',str);
            end
            if nargout>0
                y = get(obj.hstatusText,'tooltip');
            end
        end
    end
    
    methods (Access = 'protected')
        function N = checkOptionIndex(h,idx,N)
            %checkOptionIndex
            
            % Allow N to be manually specified, for the case
            % of checking against the Option cache (versus
            % checking against the number of Options in the object).
            if nargin<3
                N = h.numOptions;
            end
            
            if any(idx<1) || any(idx>N)
                error('spcwidgets:StatusBar:InvalidOptionIndex', ...
                    'Option index must be in the range [1,%d]',N);
            end
        end
                
        % --------------------------------------
        function localInit(hStatusBar)
            % Create (or recreate) status bar
            
            createStatusBar(hStatusBar);
            installPropertyListeners(hStatusBar);
        end
%         % ----------------------------------------------------
%         function installSetFunctions(hStatusBar)
%             % We do this here, and not in the schema, since the functions
%             % needed for callbacks exist here as local functions.  So registering
%             % those here is simply a convenience.
%             
%             p = findprop(hStatusBar,'Visible');
%             p.SetFunction = @set.Visible;
%         end
        % ----------------------------------------------------
        function createStatusBar(hStatusBar)
            %CreateStatusBar Add status bar to figure.
            
            persistent pf
            if isempty(pf)
                if isunix
                    pf = 1;
                else
                    pf = get(0, 'ScreenPixelsPerInch')/96;
                end
            end
            
            % Establish flow container for statusbar
            %
            % hStatusBar.parent may be
            %    an empty handle,
            %    a figure, or
            %    the child of a uiflowcontainer.
            %
            % These are the only valid parent handles.
            %
            % Use existing or create new flow/grid container parent
            hParent = hStatusBar.parent;
            if ishghandle(hParent,'figure')
                % parent the statusbar to a uicontainer within
                % a uiflowcontainer.  The uicontainer is used to
                % "fix" the position of the status bar within the
                % flow to remain at the bottom, even if the statusbar
                % is removed and re-rendered to this parent.
                %
                % If hParent was the flow container itself, each
                % time we unrender/re-render will cause the statusbar
                % to move up ABOVE any other children in the flow.
                %
                hFlow = findall(hParent, 'Tag', 'MainFlowContainer');
                if isempty(hFlow)
                    hFlow = uiflowcontainer('v0', ...
                        'parent',        hParent, ...
                        'flowdirection', 'bottomup', ...
                        'margin',        2, ...
                        'Tag',           'MainFlowContainer');
                end
                hParent = findall(hFlow, 'Tag', 'StatusBarContainer');
                if isempty(hParent)
                    hParent = uicontainer('parent',hFlow, 'Tag', 'StatusBarContainer');
                end
                
            end
            
            % Assumes we're called first in a bottomup flow parent,
            % so we can get the bottom position.
            
            % Define an "overall" container, so visibility can
            % be easily controlled (i.e., statusbar can be turned off)
            %
            % Be sure to take into account initial visibility when
            % creating this container
            %
            optHeight = 18*pf;
            allHeight = optHeight + (1 + 2)*pf; % 1 for line width, 2 for gutters
            allStatus = uiflowcontainer('v0', 'parent',hParent, ...
                'visible', hStatusBar.visible, ...
                'flowdirection','bottomup');
            hStatusBar.hContainer = allStatus;
            
            % Set a fixed height of the statusbar region in the flow container
            % This will fail if hParent is not a child of a uiflowcontainer
            % or a uigridcontainer.  Typically, hParent is a uicontainer child
            % of a uiflowcontainer set with .flowdir = 'bottomup'
            %
            set(hParent,'HeightLimits',[allHeight allHeight]);
            
            % Setup main status region
            %  - region of solid background and fixed height
            
            % Main backdrop area of status bar of constant height
            statusbar = uicontainer('parent',allStatus);
            set(statusbar,'HeightLimits',[optHeight optHeight]);
            
            % white line at top of status bar of unity height
            topline = uipanel('parent',allStatus, ...
                'bordertype','none', ...
                'background','w');
            set(topline,'HeightLimits',[1 1]);
            
            disabledBehavior = uiservices.getPlotEditBehavior('disabled');
            
            % Flow for content in main backdrop
            hStatusFlow = uiflowcontainer('v0', 'parent',statusbar,...
                'flowdirection','lefttoright',...
                'backgroundcolor','none', ...
                'margin',1);
            
            hgaddbehavior(hStatusFlow, disabledBehavior);
            
            % Status region text
            hStatusBar.hstatusText = uicontrol('parent',hStatusFlow,...
                'style','text',...
                'string','',...
                'horiz','left');
            
            hgaddbehavior(hStatusBar.hstatusText, disabledBehavior);
            
            % Option regions
            hStatusBar.hOptionText = [];  % clear out old settings (handle)
            nOpts = hStatusBar.numOptions;
            for idx=1:nOpts
                w = hStatusBar.OptionWidths(idx)*pf;
                hOptPanel = uicontainer( ...
                    'parent',hStatusFlow, ...
                    'hittest','off');
                % , ...
                % 		'shadow', [1 1 1]*.4
                % 		'highlight','w',...
                % 		'bordertype','beveledin', ...
                set(hOptPanel,'WidthLimits',[w w]);
                
                % Use a uicontrol for the frame to work around the bleed through issue.
                hFrame = uicontrol('parent', hOptPanel, ...
                    'style', 'frame', ...
                    'foregroundcolor', [.7 .7 .7], ...
                    'position', [1 0 w-1 optHeight-2]);
                hOptTxt = uicontrol('parent',hOptPanel, ...
                    'style','text', ...
                    'string','', ...
                    'units','pix', ...
                    'pos',[2 1 w-3 optHeight-4], ...
                    'horiz','left');
                hgaddbehavior(hFrame,  disabledBehavior);
                hgaddbehavior(hOptTxt, disabledBehavior);
                
                hStatusBar.hAllOptions(idx) = hOptPanel; % for option vis
                hStatusBar.hOptionText(idx) = hOptTxt;
                
                % Assign dynamic properties to text widget
                %
                % optionTruncate: used to track truncation setting.
                setappdata(hOptTxt,'optionTruncate','off');
                %
                % OptionOrigString: used to hold original (untruncated) string
                setappdata(hOptTxt,'OptionOrigString','');
            end
            
            % Create grab bar in lower right corner
            str=' ';
            if strcmp(computer,'PCWIN') || strcmp(computer, 'PCWIN64');
                str='o';
            end
            
            if strcmpi(hStatusBar.GrabBar,'on')
                g=12;  % pixel width
                hGrab = uicontainer('parent',hStatusFlow);
                set(hGrab,'WidthLimits',[g g]);
                h = uicontrol( ...
                    'parent',hGrab, ...
                    'style','text', ...
                    'units','pix', ...
                    'horiz','left', ...
                    'fontname','Marlett', ...
                    'fontweight','bold', ...
                    'fontsize',12, ...
                    'enable','on',...
                    'string',str, ...
                    'pos',[0 -5 20 19], ...
                    'foregr',[1 1 1]*.5);
                
                % If Marlett was available, vert extent is 19
                ex = get(h,'extent');
                if ex(4)>20
                    set(h,'vis','off'); % font not available
                end
            end
        end
        % ----------------------------------------------------
        function installPropertyListeners(this)
            % Initialize Listeners
            %
            % NOTE: The order of listeners in .listeners vector is important!
            
            % Reset vector in case old objects are present
            delete(this.Listeners);
            this.Listeners = [];
            
            this.Listeners = event.proplistener(this, ...
                [this.findprop('OptionWidths'), this.findprop('GrabBar')], ...
                'PostSet', @(h,e)redraw(this));
            
%             hStatusBar.Listeners(2) = event.proplistener(hStatusBar, hStatusBar.findprop('GrabBar'), ...
%                 'PostSet', @(h,e)redraw(hStatusBar));                        
        end
       
        % -----------------------------------------------
        function redraw(hStatusBar)
            % redraw entire status bar.
            
            % Stash all the state
            optCache = optionCache(hStatusBar);
            statCache = statusCache(hStatusBar);
            
            % Specifically cache the UserData on hContainer,
            % which is where we stash a copy of the StatusBar
            % object (when that object is instantiated)
            % in order to associate the high-level object (StatusBar)
            % with the low-level base rendering (StatusBase).
            %
            % In order to allow Status() to automatically create a parent
            % StatusBar if one is not explicitly passed in, we need to
            % "find" a StatusBar ... which is really a StatusBase object.
            % So the userdata holds the handle to the StatusBase object,
            % *if* a high-level StatusBase was created.
            udCache = get(hStatusBar.hContainer,'userdata');
            
            % Blow away then rebuild status bar
            %  - causes (unnecessary) Resize event to occur
            localDelete(hStatusBar);
            
            % Recreate status bar
            localInit(hStatusBar);
            
            % If we were just blowing away the option regions,
            % and leaving status region as is, we would do this:
            % 	local_RemoveAreas(h);
            % 	createAreas(h);
            
            % Restore userdata
            set(hStatusBar.hContainer,'userdata',udCache);
            
            % Restore all the state
            drawnow expose;
            statusRestore(hStatusBar,statCache);
            optionRestore(hStatusBar,optCache);
        end
        
        % -----------------------------------------------
        function localCheckoptionCache(h,cache)
            %Check that option cache is valid.
            
            % cache must be a cell-matrix of option properties,
            % with one property per column, and one option per row
            %
            % Option property names are specified in helper method
            [p ap] = optionCacheProps(h);
            if ~iscell(cache) || ...
                    ( numel(cache) ~= numel([p ap]))
                error('spcwidgets:StatusBar:InvalidoptionCache', ...
                    'Invalid option cache.');
            end
        end
        
        % -------------------------------------------
        function renderTextWithEllipsis(hStatusBar,idx,str)            
            % Get position of text widget
            hOptText = hStatusBar.hOptionText(idx);
            pos_dx = get(hOptText,'pos');
            pos_dx = pos_dx(3); % x-extent
            
            % Set the text into place, and get its rendered extent
            set(hOptText,'string',str);
            ext = get(hOptText,'extent');
            if ext(3) > pos_dx  % was text too wide?
                truncateUsingEllipsis(hOptText,pos_dx,str);
            end
        end
        
        % ---------------------------------------------
        function truncateUsingEllipsis(hOptionText,pos_dx,str)
            %truncateUsingEllipsis
            %  Need to search for maximum length of string
            %  that is just less than (or equal to) width
            %  of text extent
            %
            %  This is an iteration due to proportional fonts.
            %  We could do bisection, for fewer re-render attempts,
            %  but a simpler approach is to remove one char at each
            %  iteration (after initial substitution of last 3 chars
            %  with '...')
            
            set(hOptionText,'vis','off');  % make text invisible during iterations
            
            % Replace last 3 chars with ellipsis
            %   (this might sufficiently shorten the string itself!)
            str(end-2:end) = '...';
            
            % See if x-extent of string fits the position
            %  - If not, remove one char and try again
            %  - If we get down to <=3 chars (just the ellipsis)
            %    return an empty string
            while numel(str) > 3
                set(hOptionText,'string',str);
                ext = get(hOptionText,'extent');  % get new text extent
                if ext(3) <= pos_dx % compare x-extent
                    break           % text extent is fine now
                end
                str(end-3)='';	    % remove one char before ellipsis
            end
            if numel(str) <= 3      % just the ellipsis?
                str='';             % remove entire string
            end
            % Show truncated string
            set(hOptionText,'string',str,'vis','on');
        end
    end

end





% [EOF]
