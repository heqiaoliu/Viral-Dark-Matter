function selectionConstraintRestore(theChild)
%selectionConstraintRestore Manages selection constraints for uibuttons.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:24 $

% Called for "SelectOne" constraint, when the only widget that is
% "on" is clicked to "off" ... it must be restored to the "on" state
% immediately.
%
% We'd like to turn back on the widget right now.
% However, the timing is not right for HG for buttons,
% and it will ignore the request.  Instead, we "delay" our
% attempt until the off-callback executes.
%
% We must intercept the callback flow for 'offcallback',
% caching any old callback and replacing it when we're done.
%
% What happens next is that, after our new offcallback is set up,
% HG executes it due to the impending change to the 'off' state,
% and we regain control flow.  From there, we can safely change
% the state of the button.  And, suppress the caller's off-callback.

% It is assumed that hWidget is valid here, since this is called
% because the widget was just clicked.  (A reasonably safe assumption,
% but not a guarantee.)  For efficiency, we do no additional checking.

theWidget = theChild.hWidget;
old_offCB = get(theWidget,'offcallback');
set(theWidget, 'offcallback', ...
    @(h1,e1)local_RestoreButtonState(theChild,old_offCB));

end % selectionConstraintRestore

% ------------------------------------------
function local_RestoreButtonState(theChild,old_offCB)
% Just for managing uibuttons ...

% Restore previous callbacks that we overrode,
% and return button to the 'on' state
%
% Be sure to suppress 'on' callback before we
% change state to 'on' ... we want this constraint
% to operate as silently as possible.  Ideally,
% we'd suppress the "clicked" callback as well,
% but we cannot do that.  It fires no matter what.
%
% The order of param-value pairs is CRITICAL in the following!
% We must NOT install the on-callback before changing the
% state to 'on' ... otherwise the user's on-callback will fire.
% We don't want that; we want this constraint to work silently,
% as if the button was never pressed.  The off-callback can
% be set "anywhere", however ... it's order doesn't matter.
% Also, splitting up the set() into two set operations (i.e.,
% one set for state=on, the other to restore old callbacks)
% isn't a good idea ... it will cause the click callback to fire.
% So this set-command is somewhat delicate:
%
% Finally, it turns out that we do not need to disable
% the listener from firing.  It won't fire -- presumably
% because we're already in the listener callback and it
% is automatically disabled upon entry.

%h.SelConListener(idx).enabled = 'off';

theWidget = theChild.hWidget;
old_onCB = get(theWidget,'oncallback');
set(theWidget, ...
    'oncallback','');
set(theWidget, ...
    theChild.StateName, 'on', ...
    'offcallback', old_offCB, ...
    'oncallback', old_onCB);

%h.SelConListener(idx).enabled = 'on';

end % local_RestoreButtonState

% [EOF]
