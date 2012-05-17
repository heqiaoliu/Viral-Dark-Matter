function schema
% Defines properties for @tooldlg class

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $ $Date: 2009/02/06 14:16:36 $

% REVISIT: This class belongs to the @plotconstr package and 
% has been moved to @sisogui until the scope of transactions
% can be defined more precisely (don't want to record editor 
% changes as part of transactions, becomes unmanageable for
% undo/redo add/delete)

% Register class 
c = schema.class(findpackage('sisogui'), 'tooldlg');

% Public
schema.prop(c, 'Container',     'handle');          % Targeted constraint container
schema.prop(c, 'ContainerList', 'handle vector');   % List of constraint containers
schema.prop(c, 'Constraint',    'mxArray');         % Edited constraint
schema.prop(c, 'ConstraintList', 'mxArray');        % All constraints in targeted Container

% Private
schema.prop(c, 'ParamEditor', 'mxArray');             % Parameter editor handles
schema.prop(c, 'Handles',     'mxArray');             % Other handles
schema.prop(c, 'Listeners',     'handle vector');     % Permanent Listeners
% Listeners associated w/ targeted constraint (temporary)
schema.prop(c, 'TempListeners', 'mxArray');
