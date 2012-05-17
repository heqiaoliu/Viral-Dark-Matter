function [lib, src] = blocklib(Hd)
%BLOCKPARAMS Returns the library and source block for BLOCKPARAMS

% This should be a private method

% Author(s): V. Pellissier
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/02/14 20:38:01 $

b = isspblksinstalled;
if b,
    % Use Signal Processing Blockset block
    lib = 'dspsigops';
    src = 'Delay';
else
    lib = 'simulink';
    src = 'Discrete/Integer Delay';
end
