function schema
% Defines properties for @SelectAnalysisResponseDlg class

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:45:46 $

% Find parent package
pkg = findpackage('sisogui');

% Find parent class (superclass)
supclass = findclass(pkg, 'SelectAnalysisResponseDlg');

% Register class (subclass) in package
inpkg = findpackage('jDialogs');
c = schema.class(inpkg, 'SelectAnalysisResponseDlg', supclass);