function schema
% Defines properties for @recorder class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:08 $

pk = findpackage('ctrluis');

% Register class 
c = schema.class(pk,'recorder');

% Editor data
schema.prop(c, 'History', 'MATLAB array');   % Event history (text)
schema.prop(c, 'Redo', 'handle vector');     % Redo stack
schema.prop(c, 'Undo', 'handle vector');     % Undo stack

