function delay = getdelaylatency(hTar, blockhandle)
%GETDELAYLATENCY Get the latency of the Delay block.

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:34 $

[b, errstr, errid] = isspblksinstalled;
if b,
    % Use Signal Processing Blockset block
    delay = get_param(blockhandle, 'delay');
else
    % Use Simulink block
    delay = get_param(blockhandle, 'NumDelays');
end

        