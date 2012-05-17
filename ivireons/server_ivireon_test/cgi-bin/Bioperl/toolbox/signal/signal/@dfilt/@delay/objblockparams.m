function s = objblockparams(this, varname)
%OBJBLOCKPARAMS   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/02/14 20:38:04 $

error(generatemsgid('noBlockLink'),...
    'Filter structure cannot be specified as a variable in the block mask.');

% [EOF]
