function schema
%SCHEMA  Defines properties for @UncertainPZView class

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:32 $

% Register class (subclass)
pkg = findpackage('wrfc');
c = schema.class(findpackage('resppack'), 'UncertainPZView', findclass(pkg,'view'));

% Public attributes
schema.prop(c, 'UncertainPoleCurves', 'MATLAB array');    % Handles of HG Lines (matrix)
schema.prop(c, 'UncertainZeroCurves', 'MATLAB array');    % Handles of HG Lines (matrix)

