function dp = findDialogPresenter(hfig)
% Return handle to a DialogPresenter object based on a figure handle, or
% a handle to a parent uipanel or other graphical container.
%
% If no DialogPresenter is present, returns empty.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:14 $

if nargin<1
    hfig = gcf;
end
hParent = findobj(hfig,'type','uipanel','tag','DialogPresenterParent');
if isempty(hParent)
    dp = [];
else
    dp = get(hParent,'userdata');
end

