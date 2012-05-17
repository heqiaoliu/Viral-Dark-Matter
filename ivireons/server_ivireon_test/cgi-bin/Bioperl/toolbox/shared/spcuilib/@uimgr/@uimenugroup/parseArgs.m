function parseArgs(h,vargs)
%parseArgs Parse constructor arguments, overload for UIMENU.
%    Assumes that vargs is passed varargin from caller,
%    keeping the args in a single cell-array.
%
% For uimenugroup constructor call
%    UIMENUGROUP(NAME)
%    UIMENUGROUP(NAME,        C1,C2,...)
%    UIMENUGROUP(NAME,PLACE)
%    UIMENUGROUP(NAME,    FCN)
%    UIMENUGROUP(NAME,PLACE,    C1,C2,...)
%    UIMENUGROUP(NAME,    FCN,C1,C2,...)
%    UIMENUGROUP(NAME,PLACE,FCN)
%    UIMENUGROUP(NAME,PLACE,FCN,C1,C2,...)
%  where C1, C2, etc, are child objects for the class.
%
%    Key difference from default uiitem::parseArgs() is
%    that this allows FCN to be specified by a string, in place of a
%    function handle, as a shorthand way of stating:
%            @(h,s)uimenu(h,'label',str)
%    It's very commmon to have simple, non-callback type uimenu widgets,
%    and that is where this syntax becomes useful.
%
%  If not specified, PLACE defaults to one more than the lowest
%  placement-value child currently in the group.

% Copyright 2006-2009 The MathWorks, Inc.

i = 1;  % current vargs index
N = numel(vargs);  % #args to consider
if (N>0)
    % NAME
    h.Name = vargs{i};
    i=i+1; N=N-1;
else
    error('uimgr:NameNotSpecified','Name must be specified')
end
if (N>0) && isnumeric(vargs{i})
    % PLACE
    h.AutoPlacement = false;
    h.ActualPlacement = vargs{i};
    i=i+1; N=N-1;
end
if (N>0) && (  isa(vargs{i},'function_handle') ...
		    || isa(vargs{i},'char') )
    % FCN
    if ~h.allowWidgetFcnArg
        error('uimgr:WidgetNotSupported', ...
            'Widget functions are not supported by %s objects.', ...
            class(h));
    end
	arg = vargs{i};
	if isa(arg,'function_handle')
	    h.WidgetFcn = arg;
	else
		% char specified - shorthand for a simple HG uimenu widget
		h.WidgetFcn = @(h)createMenu(h, arg);
	end
    i=i+1; N=N-1;
end
if (N>0)
    if ~h.isGroup
        error('uimgr:ChildrenNotAllowed', ...
            'Child objects cannot be attached to %s objects.', ...
            class(h));
    end
    % C1,C2,...
    h.add(vargs{i:end})
end

function hWidget = createMenu(h, arg)

hWidget = uimenu(h.GraphicalParent, 'label', arg, 'tag',  [class(h), '_', h.Name]);
    
% [EOF]
