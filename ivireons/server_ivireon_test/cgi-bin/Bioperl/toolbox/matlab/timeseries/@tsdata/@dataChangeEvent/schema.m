function schema
%SCHEMA Subclass of EVENTDATA to handle passing of indices of changed
%data rows.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:11:50 $


% Register class 
cEventData = findclass(findpackage('handle'),'EventData');
c = schema.class(findpackage('tsdata'),'dataChangeEvent',cEventData);

% Define properties
schema.prop(c,'Action','MATLAB array');  % Stores add/remove string
schema.prop(c,'Index','MATLAB array');  % Stores indices of affected time rows.
