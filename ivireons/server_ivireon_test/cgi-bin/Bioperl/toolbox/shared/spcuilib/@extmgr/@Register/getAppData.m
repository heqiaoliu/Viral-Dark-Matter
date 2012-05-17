function appData = getAppData(this, field)
%GETAPPDATA Get the application data for the specified field.
%   GETAPPDATA(H, FIELD) gets the application data for the field specified
%   by the string FIELD.  GENVARNAME is used to make sure that FIELD is a
%   valid field name.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:40:00 $

if nargin < 2
    appData = get(this, 'ApplicationData');
else
    field = genvarname(field);
    
    if ~isfield(this.ApplicationData, field)
        appData = [];
    else
        appData = this.ApplicationData.(field);
    end
end

% [EOF]
