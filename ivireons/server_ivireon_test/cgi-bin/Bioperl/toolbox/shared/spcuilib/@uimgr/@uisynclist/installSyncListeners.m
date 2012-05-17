function installSyncListeners(hSyncList, hSrcItem)
%installSyncListeners Install synchronization listeners on item widget.
%   This must be done each time after an item has been rendered
%   because widget handles will change (newly created).

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/01/05 17:59:14 $

% Keep in mind, it's just the source uiitem that is guaranteed to have
% a widget at this time, since this is called during uiitem::renderPost
% and the source is the caller.
%
% That means we do not rely on the dstWidget being rendered (yet),
% and do not get nor embed any direct reference to it here.

if ~isempty(hSyncList)
    srcWidget = hSrcItem.hWidget;
    if isempty(srcWidget)
        error('uimgr:assert', ...
            ['Assert: srcWidget should not be empty here, since' ...
               'we''re being called from uigroup::renderPost.']);
    end
    
    % Define source property for event
    srcPropName = hSrcItem.StateName; % name of state property
    
    % Two things to do for each item in the sync list
    %  1 - perform initial sync
    %  2 - create listener to monitor state
    %
    for i=1:numel(hSyncList.Fcn)  % loop over all entries
        % Get sync function
        syncDefault = hSyncList.Default(i);  % default or custom mapping?
        syncArgs    = hSyncList.ArgsRaw{i};  % sync fcn args list
        syncFcn     = hSyncList.FcnRaw{i};   % sync fcn handle
        
        % These args may have been translated during plug-in install
        % Generally, the uiitem handles are re-mapped from the
        % plug-in tree to the target tree
        
        syncFcn  = @(hh,ev)syncFcn(syncArgs{:},ev);
        
        % Sync operates on a "destination item", to sync its state
        % to the source item/widget state
        %
        % Note that a default sync function is defined in uisynclist::sync
        % but the user can also use their own mapping function
        
        % Perform an initial sync of src/dst states
        % via a manual call to syncFcn.
        %
        % This only achieves initial sync if dst has a widget rendered
        % at this time ... and that is NOT guaranteed.  (srcWidget is
        % guaranteed, however).  So syncFcn must check dstWidget.
        %
        % Two types of callback functions:
        %   default: @(h,ev)SimpleWidgetSync(dstChild,ev);
        %  user map: @(h,ev)mapFcn(dst,i,src,srcPerm(i),ev);
        %
        % We "minimally" setup the event structure, ev, and
        % we pass h=[], since it is not mapped
        if ~syncDefault || ~isprop(srcWidget, srcPropName)
            % Non-default function (user-defined mapping fcn) is being used
            % Or, source property isn't mapped to standard value
            ev.NewValue = [];
			ev.Source.Name = '';
        else
            ev.NewValue = get(srcWidget,srcPropName);
			ev.Source.Name = srcPropName;
        end
        feval(syncFcn,[],ev);  % dummy "h" in all cases
        
        % Create listener on srcWidget to achieve one-sided sync
        % (src prop is monitored -> dst prop is affected)
        addlistener(srcWidget, srcPropName, 'PostSet', syncFcn);
        
		% Create Enable and Visible listeners
		addlistener(srcWidget, 'Enable', 'PostSet',syncFcn);
		addlistener(srcWidget, 'Visible', 'PostSet',syncFcn);
		
    end
end

% [EOF]
