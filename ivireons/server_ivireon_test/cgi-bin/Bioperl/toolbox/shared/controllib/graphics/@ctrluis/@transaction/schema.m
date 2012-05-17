function schema
% Defines properties for @transaction class.
% Extension of transaction to support custom 
% refresh method after undo/redo.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:17:15 $

% Register class 
c = schema.class(findpackage('ctrluis'),'transaction');

% Editor data
schema.prop(c, 'Name', 'String');                 % name
schema.prop(c, 'Transaction', 'handle');          % handle.transaction
schema.prop(c, 'RootObjects', 'handle vector');   % Refresh action
