function sigbuild_resume_callback(modelH)
% SIGBUILD_RESUME_CALLBACK Callback for the Play button in the Signal
% Builder GUI while the model is paused.
%

% When the Play button is pushed while the model is paused, the
% SimulationCommand is set to 'Continue' (in sl_command).

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/07/18 15:54:22 $

try
    sigbuilder_block('modelresume',modelH);
catch SigBuilderBlockError %#ok<NASGU>
    % suppress any errors from the call to sigbuilder_block
end
