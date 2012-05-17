function parseArgs(this,vargs)
%parseArgs Parse constructor arguments, overload for SPCTOGGLEMENU.
%    Assumes that vargs is passed varargin from caller,
%    keeping the args in a single cell-array.
%
%    Key difference from uiitem::parseArgs()
%      - this allows FCN to be specified by a string, in place of a
%        function handle, as a shorthand way of stating:
%            @(h,s)uimenu(h,'label',str)
%        It's very commmon to have simple, non-callback related
%        menu functions that this becomes useful.
%
% For uiitem constructor call
%    UIITEM(NAME)
%    UIITEM(NAME,PLACE)
%    UIITEM(NAME,    FCN)
%    UIITEM(NAME,PLACE,FCN)
%
% For uigroup constructor call
%    UIGROUP(NAME)
%    UIGROUP(NAME,        C1,C2,...)
%    UIGROUP(NAME,PLACE)
%    UIGROUP(NAME,    FCN)
%    UIGROUP(NAME,PLACE,    C1,C2,...)
%    UIGROUP(NAME,    FCN,C1,C2,...)
%    UIGROUP(NAME,PLACE,FCN)
%    UIGROUP(NAME,PLACE,FCN,C1,C2,...)
%  where C1, C2, etc, are child objects for the class.
%
%  If not specified, PLACE defaults to one more than the highest
%  placement-value child currently in the group.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2009/08/14 04:07:23 $

i = 1;  % current vargs index
N = numel(vargs);  % #args to consider
if (N>0)
    % NAME
    this.Name = vargs{i};
    i=i+1; N=N-1;
else
    error('uimgr:NameNotSpecified','Name must be specified')
end
if (N>0) && isnumeric(vargs{i})
    % PLACE
    this.AutoPlacement = false;
    this.ActualPlacement = vargs{i};
    i=i+1; N=N-1;
end
if (N>0) && (  isa(vargs{i},'function_handle') ...
		    || isa(vargs{i},'char') )
    % FCN
	arg = vargs{i};
	if isa(arg,'function_handle')
        if ~this.allowWidgetFcnArg
            error('uimgr:WidgetNotSupported', ...
                'Widget functions are not supported by %s objects.', ...
                class(this));
        end
	    this.WidgetFcn = arg;
	else
		% char specified - shorthand for a simple HG uimenu widget
		this.WidgetFcn = @(this)createMenu(this, arg);
	end
    i=i+1; N=N-1;
end
if (N>0)
    if ~this.isGroup
        error('uimgr:ChildrenNotAllowed', ...
            'Child objects cannot be attached to %s objects.', ...
            class(this));
    end
    % C1,C2,...
    this.add(vargs{i:end})
end

% ------------------------------------------------------------------------
function hWidget = createMenu(this, arg)

hWidget = spcwidgets.ToggleMenu(this.GraphicalParent, 'Labels', arg, 'Tag', [class(this), '_', this.Name]);

% [EOF]
