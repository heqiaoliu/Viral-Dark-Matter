function schema
% Defines properties for @SelectNewLoopDlg class

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:45:50 $

% Find parent package
pkg = findpackage('sisogui');

% Find parent class (superclass)
supclass = findclass(pkg, 'SelectNewLoopDlg');

% Register class (subclass) in package
inpkg = findpackage('jDialogs');
c = schema.class(inpkg, 'SelectNewLoopDlg', supclass);

% Store the SCD design object
schema.prop(c, 'SISOTaskNode', 'MATLAB array');
schema.prop(c, 'loopdata', 'MATLAB array');