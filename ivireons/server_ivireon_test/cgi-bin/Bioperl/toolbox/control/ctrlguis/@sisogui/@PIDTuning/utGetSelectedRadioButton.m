function index = utGetSelectedRadioButton(this,Group) %#ok<*INUSL>
%

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/08 21:28:12 $
index = 0;
e = awtinvoke(Group,'getElements()'); 
for ct = 1:awtinvoke(Group,'getButtonCount()')
    if awtinvoke(e.nextElement,'getModel()') == awtinvoke(Group,'getSelection()')
        index = ct;
        break
    end
end

