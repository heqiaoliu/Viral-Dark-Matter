function setappdata(h,name,val)
%SETAPPDATA Set application-defined data.
%  SETAPPDATA(H, NAME, VALUE) sets application-defined data for
%  the UIMgr object with handle H.  The application-defined data,
%  which is created if it does not already exist, is
%  assigned a NAME and a VALUE.  VALUE may be anything.
%
%  SETAPPDATA(H,S) replaces the entire application data for
%  the UIMgr object with structure S.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:30:15 $

if nargin<3
    % Replace entire struct with new struct in variable "name"
    if ~isstruct(name)
        error('uimgr:setappdata:MustBeStruct', ...
            'Replacing all data requires a struct argument.')
    end
    h.AppData = name;
else
    % Set/add one field to struct
    h.AppData.(name) = val;
end

% [EOF]
