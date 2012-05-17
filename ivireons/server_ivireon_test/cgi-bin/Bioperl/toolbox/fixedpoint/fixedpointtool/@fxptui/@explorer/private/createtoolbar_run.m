function tb = createtoolbar_run(h, varargin)
%CREATETOOLBAR__RUN   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:08 $

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;
	tb = am.createToolBar(h);
end

action = h.getaction('START');
tb.addAction(action);

action = h.getaction('PAUSE');
tb.addAction(action);

action = h.getaction('STOP');
tb.addAction(action);

% [EOF]