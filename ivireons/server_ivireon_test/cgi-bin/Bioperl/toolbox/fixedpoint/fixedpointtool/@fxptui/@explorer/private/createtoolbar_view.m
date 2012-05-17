function tb = createtoolbar_view(h, varargin)
%CREATETOOLBAR_VIEW   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/10 21:34:00 $

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;	
	tb = am.createToolBar(h);
end

action = h.getaction('VIEW_TSINFIGURE');
tb.addAction(action);

action = h.getaction('VIEW_HISTINFIGURE');
tb.addAction(action);

action = h.getaction('VIEW_DIFFINFIGURE');
tb.addAction(action);

% [EOF]