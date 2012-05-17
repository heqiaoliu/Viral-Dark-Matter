function renderPost(h)
%renderPost Rendering tasks performed after rendering children.
%  Overload for uigroup class.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/11/16 22:34:34 $

if areAnyChildren(h)
  % This is a non-empty uigroup
  % NOTE:
  %  See comments in uiitem::render_widget() regarding
  %  initialization order of selection constraints and item sync.
  
  % Install SelectionConstraint listeners (if requested)
  %  - execute install function
  %  - pass uigroup handle as argument
  if ~isempty(h.SelConInstall)
    % Remember: we are invoking a function handle here,
    % which was stored in a property.  This is NOT a method call.
    % Thus, there is no "automatic object handle" arg being passed.
    % We must pass the object handle explicitly (it's needed!)
    %
    % an alternate implementation that makes it more evident:
    %  feval(h.SelConInstall, h)
    h.SelConInstall(h);
  end
  
  %the following code takes into account that when first rendering
  %you can have a predefined empty group that once the source is
  %determined, and an item is to be added to the group we'll need
  %to turn that group back on
  if strcmpi(h.Visible, 'off') && strcmpi(h.Enable, 'on')...
      && (strcmpi(h.Type, 'uimenugroup') || strcmpi(h.Type, 'uibuttongroup'))
    h.Visible = 'on';
    enforceItemSeparators(h.up, true, true);
  end
else
  %this turns off any empty groups after the group has been rendered and
  %determined that it has no children
  h.Visible = 'off';
  %the following isempty check is to make sure that the item is parented
  %to a uimgr item that can have enforceItemSeparators called on it.  For
  %example you can instantiat a uimgr.uimenugroup and call render on it
  %directly and it will create a figure for you and use the figure as its
  %parent.  This figure cannot have enforceItemSeparators called on it.
  if ~isempty(h.up)
    enforceItemSeparators(h.up, false, true);
  end
end

% [EOF]
