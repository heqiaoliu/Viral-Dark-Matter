function showHistogram(ntx,show)
% Show or hide histogram and related readouts

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:51 $

if nargin<2, show=true; end

% Update histogram state
ntx.ShowHistogram = show;

% Update SignLine dialog prompts
setSignLineVisible(ntx.hOptionsDialog,show);

% Set panel visibility
hBodyPanel = getBodyPanelAndSize(ntx.dp);
set(hBodyPanel,'vis',dialogpanel.logicalToOnOff(show));
