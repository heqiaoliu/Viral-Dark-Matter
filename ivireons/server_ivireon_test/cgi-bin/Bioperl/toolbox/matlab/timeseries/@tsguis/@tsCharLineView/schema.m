function schema
%SCHEMA  Defines properties for @eventCharView class

%   Author(s):  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 21:41:52 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('tsguis'), 'tsCharLineView', superclass);

% Public attributes
schema.prop(c, 'Lines', 'MATLAB array');    % Handles of vertical lines 
schema.prop(c, 'LineTips', 'MATLAB array');