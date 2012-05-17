function hThis = scribeobject2D(varargin)
% Create an instance of a 2-Dimensional scribe object

%   Copyright 2006 The MathWorks, Inc.

% Deal with parenting properly:
scribeaxes = graph2dhelper('findScribeLayer',varargin{:});

hThis = scribe.scribeobject2D('Parent',double(scribeaxes));
% Call a helper-method to set up the 1-D scribe object
hThis.createScribeObject2D(varargin{:});