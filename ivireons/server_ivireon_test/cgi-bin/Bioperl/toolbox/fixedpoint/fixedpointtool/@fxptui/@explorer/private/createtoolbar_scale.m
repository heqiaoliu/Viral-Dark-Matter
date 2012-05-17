function tb = createtoolbar_scale(h, varargin)
%CREATETOOLBAR_DATA

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/09/13 06:52:56 $

if(nargin > 1)
  tb = varargin{1};
else
  am = DAStudio.ActionManager;
  tb = am.createToolBar(h);
end

action = h.getaction('SCALE_PROPOSE');
tb.addAction(action);

action = h.getaction('SCALE_APPLY');
tb.addAction(action);

action = h.getaction('VIEW_AUTOSCALEINFO');
tb.addAction(action);

% [EOF]
