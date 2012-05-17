function schema
%SCHEMA Schema for subclass of EVENTDATA to handle mxArray-valued event data.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:40 $

% Register class 
cEventData = findclass(findpackage('handle'),'EventData');
c = schema.class(findpackage('nlutilspack'),'dataevent',cEventData);

% Define properties
schema.prop(c,'Data','MATLAB array');  % Stores user-defined event data 
