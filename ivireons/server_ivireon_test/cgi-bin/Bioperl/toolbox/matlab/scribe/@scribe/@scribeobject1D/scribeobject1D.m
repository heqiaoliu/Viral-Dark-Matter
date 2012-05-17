function hThis = scribeobject1D(varargin)
% Create an instance of a 1-Dimensional scribe object

%   Copyright 2006 The MathWorks, Inc.

% Deal with parenting properly:
scribeaxes = graph2dhelper('findScribeLayer',varargin{:});

hThis = scribe.scribeobject1D('Parent',double(scribeaxes));
% Call a helper-method to set up the 1-D scribe object
hThis.createScribeObject1D(varargin{:});