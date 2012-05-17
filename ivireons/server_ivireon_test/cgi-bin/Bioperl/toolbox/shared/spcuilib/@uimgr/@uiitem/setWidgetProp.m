function setWidgetProp(theItem,propName,val)
%setWidgetProp "Protected" version of widget property change.
%  Sets property of widget according to same-named property of item,
%  or according to optional argument VAL.  If widget is not rendered,
%  or is not valid, set is aborted without error.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/04/27 19:55:11 $

hWidget = theItem.hWidget;

if ~isempty(hWidget) && uimgr.isHandle(hWidget);
    if isprop(hWidget, propName)
        if ~isempty(get(hWidget, propName))
            if nargin < 3
                val = theItem.(propName);
            end
            set(hWidget,propName,val);
        end
    end
end

% [EOF]
