function mmgr = uigetmodemanager(varargin)
% This function is undocumented and will change in a future release

% Returns the mode manager associated with the current figure

%   Copyright 2005-2006 The MathWorks, Inc.

if nargin == 0
    hFig = gcf;
elseif nargin == 1
    hFig = varargin{1};
else
    error('MATLAB:uigetmodemanager:InvalidInput','Too many input arguments');
end

if ~ishghandle(hFig,'figure')
    error('MATLAB:uigetmodemanager:InvalidInput','First argument must be a figure handle');
end

[ lmsg lid ] = lastwarn;
ws = warning('query','MATLAB:handle:hg2');
warning('off','MATLAB:handle:hg2')

hFig = handle(hFig);

warning(ws.state,ws.identifier)
lastwarn( lmsg, lid );

mmgr = [];
if isprop(hFig,'ModeManager')
    mmgr = get(hFig,'ModeManager');
end
if isempty(mmgr) || ~ishandle(mmgr)
    mmgr = uitools.uimodemanager(hFig);
end