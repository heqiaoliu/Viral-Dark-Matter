function schema
%SCHEMA  Defines properties for @rlview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2009/12/22 18:57:44 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'rlview', superclass);

% Public properties
p = schema.prop(c, 'BranchColorList', 'MATLAB array');   % Branch coloring scheme
p.FactoryValue = cell(1,0);  % default = inherit from response style
p = schema.prop(c, 'Locus', 'MATLAB array');  % Handles of locus lines (vector)
p.SetFunction = @LocalConvertToHandle;
p = schema.prop(c, 'SystemZero', 'MATLAB array');    % Handles of system zeros
p.SetFunction = @LocalConvertToHandle;
p = schema.prop(c, 'SystemPole', 'MATLAB array');    % Handles of system poles
p.SetFunction = @LocalConvertToHandle;

function Value = LocalConvertToHandle(this,Value)
% Converts to handle
Value = handle(Value);