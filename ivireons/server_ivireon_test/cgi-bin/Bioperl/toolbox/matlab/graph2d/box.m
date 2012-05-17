function box(arg1, arg2)
%BOX    Axis box.
%   BOX ON adds a box to the current axes.
%   BOX OFF takes if off.
%   BOX, by itself, toggles the box state of the current axes.
%   BOX(AX,...) uses axes AX instead of the current axes.
%
%   BOX sets the Box property of an axes.
%
%   See also GRID, AXES.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.11.4.4 $  $Date: 2008/05/23 15:35:15 $

% To ensure the correct current handle is taken in all situations.

opt_box = 0;
if nargin == 0
	ax = gca;
else
	if isempty(arg1)
		opt_box = lower(arg1);
	end
	if ischar(arg1)
		% string input (check for valid option later)
		if nargin == 2
			error('MATLAB:box:HandleExpected', 'First argument must be an axes handle.')
		end
		ax = gca;
		opt_box = lower(arg1);
	else
		% make sure non string is a scalar handle
		if length(arg1) > 1
			error('MATLAB:box:InvalidHandle', 'Axes handle must be a scalar');
		end
		% handle must be a handle and axes handle
		if ~ishghandle(arg1,'axes')
			error('MATLAB:box:ExpectedAxesHandle', 'First argument must be an axes handle.');
		end
		ax = arg1;
		
		% check for string option
		if nargin == 2
			opt_box = lower(arg2);
		end
	end
end

if (isempty(opt_box))
	error('MATLAB:box:UnknownOption', 'Unknown command option.');
end

if (opt_box == 0)
	if (strcmp(get(ax,'Box'),'off'))
		set(ax,'Box','on');
	else
		set(ax,'Box','off');
	end
elseif (strcmp(opt_box, 'on'))
	set(ax,'Box', 'on');
elseif (strcmp(opt_box, 'off'))
	set(ax,'Box', 'off');
else
	error('MATLAB:box:CommandUnknown', 'Unknown command option.');
end
