function vector_init_openfcn(block)
% VECTOR_INIT_OPENFCN Openfcn code for the Vector CAN Configuration block
% This function should be called from the openfcn callback.

%   Copyright 2004 The MathWorks, Inc.

% test to see if vcanconf exists on the
% system path, using Win32 API MEX file
[found, path] = vector_find_conf_util;

if (found)
    % launch vcanconf in the background
    dos('vcanconf &');
else
    % warn the user that vcanconf
    % could not be found
    TargetCommon.ProductInfo.error('can', 'LauchingCANDriverConfiguration');
end

% open block dialog last to try and gain focus
open_system(block,'mask');
