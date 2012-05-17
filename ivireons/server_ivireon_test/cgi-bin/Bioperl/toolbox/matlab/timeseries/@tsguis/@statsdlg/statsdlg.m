function h = statsdlg(varargin)

% Copyright 2004-2008 The MathWorks, Inc.

%% Show the (singleton) shift dialog
mlock
persistent dlg;
 
if nargin==0
    if isempty(dlg) || ~ishandle(dlg)
        h = tsguis.statsdlg;
    else
        h = dlg;       
    end
    return
else
    hostnode = varargin{1};
end

%% If necessary build the stats dialog. If the tsviewer has been reopened,
%% then the SrcNode will have changed, and the statsdlg must be rebuilt so
%% the listener to the TreeManager visibility will remain valid for the new
%% TreeManager.
if isempty(dlg) || ~ishandle(dlg) || ~isequal(dlg.SrcNode,getRoot(varargin{1}))
    dlg = tsguis.statsdlg;
    if nargin>=2
        % The viewnode must be set for the viewnode grandparent to be set
        dlg.SrcNode = getRoot(varargin{1});
        dlg.initialize(varargin{2});
        dlg.Visible = 'on';
        centerfig(dlg.Figure,0);
    end
end
if ~isempty(dlg.Figure) && ishghandle(dlg.Figure)
    figure(double(dlg.Figure));
end
%% Return the handle
h = dlg;