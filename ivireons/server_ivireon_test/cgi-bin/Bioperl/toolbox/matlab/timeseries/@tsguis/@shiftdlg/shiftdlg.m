function h = shiftdlg(varargin)

% Copyright 2004-2008 The MathWorks, Inc.

%% Show the (singleton) shift dialog
mlock
persistent dlg;

%% If necessary build the merge dialog
if isempty(dlg) || ~ishandle(dlg) || isempty(dlg.Figure) || ~ishghandle(dlg.Figure)
    dlg = tsguis.shiftdlg;
    if nargin>=1
        % The viewnode must be set for the viewnode grandparent to be set
        dlg.ViewNode = varargin{1};
        dlg.initialize
        centerfig(dlg.Figure,0);
    end
elseif nargin>=1
    dlg.ViewNode = varargin{1};
end

%% Return the handle
h = dlg;