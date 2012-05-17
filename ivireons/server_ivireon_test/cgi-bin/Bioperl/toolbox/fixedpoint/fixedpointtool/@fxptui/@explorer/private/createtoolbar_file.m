function tb = createtoolbar_file(h, varargin)
%CREATETOOLBAR_FILE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:07 $

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;	
	tb = am.createToolBar(h);
end

action = h.getaction('FILE_NEW');
tb.addAction(action);

action = h.getaction('FILE_OPEN');
tb.addAction(action);

action = h.getaction('FILE_CLOSE');
tb.addAction(action);

% [EOF]