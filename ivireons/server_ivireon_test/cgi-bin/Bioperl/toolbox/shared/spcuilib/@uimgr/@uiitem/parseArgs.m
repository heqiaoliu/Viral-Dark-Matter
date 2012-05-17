function parseArgs(h,vargs)
%parseArgs Parse constructor arguments.
%    Assumes that vargs is passed varargin from caller,
%    keeping the args in a single cell-array.
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

% Copyright 2006 The MathWorks, Inc.

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
if (N>0) && isa(vargs{i},'function_handle')
    % FCN
    if ~h.allowWidgetFcnArg
        error('uimgr:WidgetNotSupported', ...
            'Widget functions are not supported by %s objects.', ...
            class(h));
    end
    h.WidgetFcn = vargs{i};
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

% [EOF]
