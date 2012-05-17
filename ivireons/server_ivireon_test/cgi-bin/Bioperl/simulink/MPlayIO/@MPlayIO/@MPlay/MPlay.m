function h = MPlay(blk)
% Constructor for MPlayIO.MPlay
% Creates and manages an instance of MPlay
% for Simulink's "Signal and Scope Manager"

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/08/23 19:40:13 $

h = MPlayIO.MPlay;

% Create an instance of a child of MPlay
h.hMPlay = uiscopes.new(MPlayIOScopeCfg);

% Create listeners for selected events
%
% Listen for a change in source object
if ~(strcmp(get_param(blk,'iotype'), 'none'))
  h.hListen = handle.listener(h.hMPlay, ...
      'DataSourceChanged', @(h1,e1)SourceChange(h));
  % Turn it off to avoid listen to the first event (g368739)
  h.hListen.Enabled = 'off';
else
  h.hListen = [];
end

% Cache handle to Simulink Block
h.hBlk = blk;

% [EOF]
