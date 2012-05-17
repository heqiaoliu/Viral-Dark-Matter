function schema
%SCHEMA Schema for subclass of EVENTDATA to handle mxArray-valued event data.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:14 $


% Register class 
cEventData = findclass(findpackage('handle'),'EventData');
c = schema.class(findpackage('ctrluis'),'dataevent',cEventData);

% Define properties
schema.prop(c,'Data','MATLAB array');  % Stores user-defined event data 
    
