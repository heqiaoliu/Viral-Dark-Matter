function legendcolorbarlayoutHGUsingMATLABClasses(hAx, action, varargin)
%LEGENDCOLORBARLAYOUT Layout legend and/or colorbar around axes
%   This is a helper function for legend and colorbar. Do not call
%   directly.

%   LEGENDCOLORBARLAYOUT(AX,'layout') lays out any
%   objects around axes AX
%   LEGENDCOLORBARLAYOUT(AX,'remove') deletes the listeners.
%   LEGENDCOLORBARLAYOUT(AX,'addToInner',h, location) adds h to the inner 
%   layout list with the set location.
%   LEGENDCOLORBARLAYOUT(AX,'addToOuter',h, location) adds h to the outer 
%   layout list with the set location.
%   LEGENDCOLORBARLAYOUT(AX,'removeFromLayoutList',h) removes h
%   from layout list.

%   Copyright 2009 The MathWorks, Inc.

% First, make sure we have a valid axes:
if ~isvalid(hAx) || ~ishghandle(hAx,'axes')
    error('MATLAB:scribe:legendcolorbarlayout:InvalidAxes',...
        'The first argument must be a valid axes handle.');
end

hManager  = scribeTwo.internal.AxesLayoutManager.getManager(hAx);

switch action
    case 'layout'
        hManager.layout;
    case 'remove'
        delete(hManager);
    case 'addToInner'
        hManager.addToLayout(varargin{1},'inner',varargin{2});
    case 'addToOuter'
        hManager.addToLayout(varargin{1},'outer',varargin{2});
    case 'removeFromLayoutList'
        hManager.removeFromLayout(varargin{:});
end
