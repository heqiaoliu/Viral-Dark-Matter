function schema
% Defines properties for @SelectAnalysisResponseDlg class

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:50:14 $

% Register class 
c = schema.class(findpackage('sisogui'), 'SelectAnalysisResponseDlg');

% Public
schema.prop(c, 'Handles', 'MATLAB array');
schema.prop(c, 'updatefcn', 'MATLAB array');
schema.prop(c, 'mapfile', 'MATLAB array');
schema.prop(c, 'loopdata', 'MATLAB array');