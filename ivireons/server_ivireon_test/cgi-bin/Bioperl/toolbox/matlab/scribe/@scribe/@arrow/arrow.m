function hThis = arrow(varargin)
% Create an instance of a scribe arrow

%   Copyright 1984-2006 The MathWorks, Inc.

% Deal with parenting properly:
[scribeaxes varargin] = graph2dhelper('findScribeLayer',varargin{:});

hThis = scribe.arrow('Parent',double(scribeaxes));
% Call a helper-method to set up the 1-D scribe object
hThis.createArrow(varargin{:});