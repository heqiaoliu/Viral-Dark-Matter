function schema

%SCHEMA Schema for subclass of EVENTDATA to handle mxArray-valued event
%data.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:19 $

% Register class 
cEventData = findclass(findpackage('handle'),'EventData');
c = schema.class(findpackage('sigselector'),'DDGSelectEvent',cEventData);

% Define properties
schema.prop(c,'Dialog','MATLAB array');
schema.prop(c,'TC','MATLAB array');
    
