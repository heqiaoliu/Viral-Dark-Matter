function objH = sf_copyobj(varargin)
%
% Do a native copy: objH type MUST be double
%

%	Copyright 1995-2003 The MathWorks, Inc.

if sf('Feature','javaphigs')
	objH = double(copyobj(varargin{:})); % double "cast" for HG2
else
	jFigFeature = feature('JavaFigures');
	feature('JavaFigures', 0);
	objH = double(copyobj(varargin{:})); % double "cast" for HG2
	feature('JavaFigures', jFigFeature);
end
objH = double(objH);
