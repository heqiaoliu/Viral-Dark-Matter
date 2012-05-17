function setAppData(this, field, appData)
%SETAPPDATA Set the application data for the specified field
%   SETAPPDATA(H, FIELD, DATA) sets the application data specified by the
%   variable DATA in the field specified by FIELD.  GENVARNAME is used to
%   make sure that FIELD is a valid field name.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:40:02 $

this.ApplicationData.(genvarname(field)) = appData;

% [EOF]
