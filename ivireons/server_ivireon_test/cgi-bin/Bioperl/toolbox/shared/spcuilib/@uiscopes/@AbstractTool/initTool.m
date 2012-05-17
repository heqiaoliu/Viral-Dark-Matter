function initTool(this, varargin)
%INITTOOL Initialize the Tool.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/23 19:08:52 $

this.init(varargin{:});

this.EnableGUIListener = handle.listener(this.Application, 'DataLoadedEvent', ...
    @(hScope, ev) enableGUIHandler(this, ev));

%% ------------------------------------------------------------------------
function enableGUIHandler(this, ev)

if ev.Data
    val = 'on';
else
    val = 'off';
end
this.enableGUI(val);

% [EOF]
