function sigbuild_pause_callback(modelH)
% SIGBUILD_PAUSE_CALLBACK Callback for the Pause button in the Signal
% Builder GUI.
%

% When the Pause button is pushed, the SimulationCommand is set to
% 'Pause' (in sl_command).

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/07/18 15:54:21 $

try
    sigbuilder_block('modelpause',modelH);
catch SigBuilderBlockError %#ok<NASGU>
    % suppress any errors from the call to sigbuilder_block
end
