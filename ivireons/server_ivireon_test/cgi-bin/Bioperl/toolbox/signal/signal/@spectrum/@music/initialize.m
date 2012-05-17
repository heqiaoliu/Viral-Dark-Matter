function initialize(this,nsinusoids,segmentlength,overlappercent,...
                     winName,threshold,varargin)
%INITIALIZE   Initialize the object with defaults or user input.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/08/11 15:48:29 $

% Parse the input to the constructor and initialize the object.
if nargin < 6,
	threshold = 0;
	if nargin < 5,
		winName = 'Rectangular';
		if nargin < 4,
			overlappercent = 50;
			if nargin < 3,
				if nargin < 2,
					nsinusoids = 2; % Valid for 1 real or 2 complex sinusoids
				end
				segmentlength = 2*nsinusoids;
			end
		end
	end
end

% Handle the new spec where FFTLength is no longer valid, but we must
% support it for backwards compatibility.
validInputTypeStrs = set(this,'InputType');

inputType = 'Vector'; % default
lenvars = length(varargin);
if lenvars,
	% Check if new syntax (InputType is the 7th input arg) is being used.
	inputTypeIdxs = regexpi(validInputTypeStrs,varargin{1});

	if any([inputTypeIdxs{:}]),  % new syntax
		inputType = varargin{1};
	end

	if lenvars ==2,
		inputType = varargin{2};
	end
end

set(this,...
    'SegmentLength', segmentlength,...
    'OverlapPercent', overlappercent,...
    'NSinusoids', nsinusoids,...
    'SubspaceThreshold', threshold,...
    'InputType',inputType);

setwindownamenparam(this,winName);  % Accepts string or cell array for winName.

% [EOF]
