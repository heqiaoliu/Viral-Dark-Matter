function tb = createtoolbar_data(h, varargin)
%CREATETOOLBAR_DATA

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/09/13 06:52:55 $

if(nargin > 1)
  tb = varargin{1};
else
  am = DAStudio.ActionManager;
  tb = am.createToolBar(h);
end

action = h.getaction('RESULTS_SWAPRUNS');
tb.addAction(action);

% [EOF]
