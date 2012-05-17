function hThis = doublearrow(varargin)
% Create an instance of a scribe double arrow

%   Copyright 1984-2006 The MathWorks, Inc.

% Deal with parenting properly:
[scribeaxes varargin] = graph2dhelper('findScribeLayer',varargin{:});

hThis = scribe.doublearrow('Parent',double(scribeaxes));
% Call a helper-method to set up the 1-D scribe object
hThis.createDoubleArrow(varargin{:});