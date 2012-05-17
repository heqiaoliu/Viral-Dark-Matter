function defaultButtonDownFcn(this,EventSrc)
% Default axis buttondown function

%  Author(s): P. Gahinet
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:19 $
switch get(get(EventSrc,'Parent'),'SelectionType')
   case 'normal'
      PropEdit = PropEditor(this,'current');  % handle of (unique) property editor
      if ~isempty(PropEdit) && PropEdit.isVisible
         % Left-click & property editor open: quick target change
         PropEdit.setTarget(this);
      end
      % Get the cursor mode object
      hTool = datacursormode(ancestor(EventSrc,'figure'));
      % Clear all data tips
      target = handle(EventSrc);
      if ishghandle(target,'axes')
          removeAllDataCursors(hTool,target);
      end
   case 'open'
      % Double-click: open editor
      PropEdit = PropEditor(this);
      PropEdit.setTarget(this);
end