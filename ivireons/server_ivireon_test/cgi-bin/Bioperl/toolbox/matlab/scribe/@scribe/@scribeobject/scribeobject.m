function hThis = scribeobject(varargin)
% Create an instance of a scribe object

%   Copyright 2006 The MathWorks, Inc.

% Deal with parenting properly:
scribeaxes = graph2dhelper('findScribeLayer',varargin{:});

hThis = scribe.scribeobject('Parent',double(scribeaxes));
% Since we cannot call super() from UDD, call a helper-method:
hThis.createScribeObject(varargin{:});