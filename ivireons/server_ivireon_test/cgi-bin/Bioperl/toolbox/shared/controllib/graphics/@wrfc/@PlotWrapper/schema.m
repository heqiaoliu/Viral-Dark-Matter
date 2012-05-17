function schema
%SCHEMA  Defines properties for @PlotWrapper class
% This is a wrapper class for the property editor behavior object.

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:44 $

% Register class
c = schema.class(findpackage('wrfc'), 'PlotWrapper');

% Public attributes
schema.prop(c, 'Plot', 'MATLAB array'); % handle to @plot

