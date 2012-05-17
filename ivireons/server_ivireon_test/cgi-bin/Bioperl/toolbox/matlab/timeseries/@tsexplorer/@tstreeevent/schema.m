function schema
%SCHEMA Subclass of EVENTDATA to handle tree structure changes

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:14:33 $


% Register class 
cEventData = findclass(findpackage('handle'),'EventData');
c = schema.class(findpackage('tsexplorer'),'tstreeevent',cEventData);

% Define properties
schema.prop(c,'Action','MATLAB array');  % Stores add/remove string
%schema.prop(c,'Pathspec','MATLAB array');  % Stores parent path 
schema.prop(c,'Node','MATLAB array');  % Stores node
    
%Note: This class is now being used to track node name changes too.