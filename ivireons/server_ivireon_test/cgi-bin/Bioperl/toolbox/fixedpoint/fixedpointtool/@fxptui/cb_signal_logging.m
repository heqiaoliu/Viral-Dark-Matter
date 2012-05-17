function cb_signal_logging(varargin)
%CB_SIGNAL_LOGGING turn signal logging on for all blocks in the
%selected subsystem and below

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:00 $

me =  fxptui.explorer;
me.getRoot.enablesiglog;
selection = me.imme.getCurrentTreeNode;
me.sleep;
selection.setlogging(varargin{:});
me.wake;

% [EOF]
