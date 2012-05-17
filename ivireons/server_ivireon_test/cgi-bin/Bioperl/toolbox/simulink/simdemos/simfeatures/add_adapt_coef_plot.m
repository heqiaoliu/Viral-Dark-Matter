%
% Add a callback for PostOutputs event
%

% Copyright 2004-2009 The MathWorks, Inc.

blk = 'sldemo_msfcn_lms/LMS Adaptive';
h = add_exec_event_listener(blk, 'PostOutputs', @plot_adapt_coefs);

