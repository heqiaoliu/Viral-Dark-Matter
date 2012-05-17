function schema
% Defines properties for @ftransaction class.
% Transaction where undo/redo actions are explicitly defined
% as function handles.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:41 $
c = schema.class(findpackage('ctrluis'),'ftransaction');

% Editor data
schema.prop(c, 'Name', 'String');            % Name
schema.prop(c, 'UndoFcn', 'MATLAB array');   % Undo function
schema.prop(c, 'RedoFcn', 'MATLAB array');   % Redo function
