function schema
%SCHEMA  Class definition for @PointCharView (dot-marked characteristics) 

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:49 $

% Register class (subclass of wfrc/view)
pkg = findpackage('wrfc');
c = schema.class(pkg, 'PointCharView', findclass(pkg,'view'));

% Public attributes
schema.prop(c, 'Points', 'MATLAB array');     % Handles of dot markers
schema.prop(c, 'PointTips', 'MATLAB array');  % Handles of marker tips (cell array)