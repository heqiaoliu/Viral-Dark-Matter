function schema
%SCHEMA  Defines properties for @TimeFinalValueView class

%   Author(s): 
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:02:25 $

% Register class
superclass = findclass(findpackage('tsguis'),'tsCharLineView');
c = schema.class(findpackage('tsguis'), 'tsStdView', superclass);

% Public attributes
