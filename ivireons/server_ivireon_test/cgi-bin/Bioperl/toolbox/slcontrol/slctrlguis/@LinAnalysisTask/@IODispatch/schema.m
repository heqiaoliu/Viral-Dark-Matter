function schema
%  SCHEMA  Defines properties for IODispatch class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/05/18 05:59:59 $

% Find parent package
pkg = findpackage('LinAnalysisTask');

% Register class (subclass) in package
c = schema.class(pkg, 'IODispatch');

% Events
schema.event(c,'ModelIOChanged'); 