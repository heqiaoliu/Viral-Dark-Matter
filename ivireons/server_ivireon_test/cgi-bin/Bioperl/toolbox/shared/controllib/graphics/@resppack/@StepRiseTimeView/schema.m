function schema
%SCHEMA  Defines properties for @StepRiseTimeView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:40 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'PointCharView');
c = schema.class(findpackage('resppack'), 'StepRiseTimeView', superclass);

% Public attributes
schema.prop(c, 'HLines', 'MATLAB array');    % Handles of horizontal lines 
schema.prop(c, 'UpperVLines', 'MATLAB array');    % Handles of vertical lines 
schema.prop(c, 'LowerVLines', 'MATLAB array');    % Handles of vertical lines 