function selectionConstraintRestore(theChild)
%selectionConstraintRestore Manages selection constraints for uimenus.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:31:29 $

% Called for "SelectOne" constraint, when the only widget that is
% "on" is clicked to "off" ... it must be restored to the "on" state
% immediately.
%
% We'd like to "turn back on" the widget right now
% However, the timing is not right for HG for menus,
% and it will ignore the request.  Instead, we "delay" our
% attempt until the callback executes.
%
% We must intercept the callback flow for 'callback',
% caching any old callback and replacing it when we're done.
%
% What happens next is that, after our new callback is set up,
% HG executes it due to the impending change to the 'off' state,
% and we regain control flow.  From there, we can safely change
% the state of the button.

% We can safely assume that hWidget exists (non-empty and ishandle)
theWidget = theChild.hWidget;
old_CB = get(theWidget,'callback');
set(theWidget, 'callback', ...
    @(h1,e1)local_RestoreMenuState(theChild,old_CB));

end % selectionConstraintRestore

% ------------------------------------------
function local_RestoreMenuState(theChild,old_CB)
% Just for managing uimenus ...

% Restore previous callbacks that we overrode,
% and return button to the 'on' state
% Be sure to suppress the callback before we
% change state to 'on'
%
% The order of param-value pairs is CRITICAL in the following!
% We must NOT install the callback before changing the
% state to 'on' ... otherwise the user's callback will fire.
% We don't want that; we want this constraint to work silently,
% as if the button was never pressed.
% So this set-command is somewhat delicate:
%
% Finally, it turns out that we do not need to disable
% the listener from firing.  It won't fire -- presumably
% because we're already in the listener callback and it
% is automatically disabled upon entry.

%h.SelConListener(idx).enabled = 'off';

theWidget = theChild.hWidget;
set(theWidget, ...
    'callback','');
set(theWidget, ...
    theChild.StateName, 'on', ...
    'callback', old_CB);

%h.SelConListener(idx).enabled = 'on';

end % local_RestoreMenuState

% [EOF]
