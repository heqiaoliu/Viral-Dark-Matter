function schema
%SCHEMA  Defines properties for @TimeFinalValueView class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:02:09 $

% Register class
superclass = findclass(findpackage('tsguis'),'tsCharLineView');
c = schema.class(findpackage('tsguis'), 'tsMeanView', superclass);

% Public attributes
