function h = selectrules(varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Show the (singleton) shift dialog

mlock
persistent dlg;

if nargin==0
    if isempty(dlg) || ~ishandle(dlg)
        h = tsguis.selectrules;
    else
        h = dlg;       
    end
    return
end

%% If necessary build the merge dialog
if isempty(dlg) || ~ishandle(dlg)
    dlg = tsguis.selectrules;
    % Restrict to time views
    dlg.Nodeclass = 'tsguis.tsseriesview';
    if nargin>=1
        % The viewnode must be set for the viewnode grandparent to be set
        dlg.ViewNode = varargin{1};
        dlg.initialize
        centerfig(dlg.Figure,0);
    end
elseif nargin>=1 % Set the view combo to this node
    dlg.ViewNode = varargin{1};
end

%% Return the handle
h = dlg;