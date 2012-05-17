function [output] = mltimerpackage(option, varargin)

% Copyright 2004 The MathWorks, Inc.

mlock;

persistent List;
if isempty(List)
	List = handle(com.mathworks.timer.TimerTask);
end

if (~ischar(option))
	error('MATLAB:mltimerpackage:IllegalFirstArg', 'First argument must be a string');
end

if strcmpi(option,'GetList')
	output = List;
	return;
elseif strcmpi(option, 'Add')
	orig = varargin{1};
    len = length(orig);
	for i = 1:len
		if isa(orig(i),'javahandle.com.mathworks.timer.TimerTask')
			List(end+1) = orig(i);
		end
	end
	return;
elseif strcmpi(option, 'Delete')
	orig = varargin{1};
    len = length(orig);
	indices = find(List == orig);
	List(indices) = [];			
elseif strcmpi(option, 'Count')
	output = length(List);
else
	error('MATLAB:mltimerpackage:UnknownFirstArg', 'Unknown Option');
end
	