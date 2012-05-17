function displayVal = idGetDisplayVal(f,sitbgui)
%Determine if display checkbox is checked or not and return 'full' or 'off'
% accordingly.
% This function determines whether estimation progress should be displayed
% in Command Window or not.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2008/05/19 23:03:36 $

displayVal = 'off';

if ~idIsValidHandle(f) 
    return;
end

XID = get(sitbgui,'UserData');
if isfield(XID,'iter')
    XIDiter = XID.iter;
else
    return;
end

switch get(f,'Tag')
    case 'sitb20'
        % linear parameter estimation window
        chkb = XIDiter(2);
    case 'sitb37'
        % process model estimation window
        chkb = XIDiter(18);
    otherwise
        % unknown tag; return
        return;
end

if strcmpi(get(chkb,'enable'),'on') && get(chkb,'value')
    displayVal = 'full';
end
