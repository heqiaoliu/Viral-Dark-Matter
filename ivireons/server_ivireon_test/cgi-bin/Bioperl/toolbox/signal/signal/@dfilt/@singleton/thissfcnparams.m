function varargout = thissfcnparams(Hd)
%THISSFCNPARAMS Returns the parameters for SDSPFILTER

% Author(s): J. Schickler
% Copyright 1988-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/12/22 18:59:56 $

error('signal:dfilt:notSupported', ...
    sprintf('%s structure not supported by the Signal Processing Blockset.', ...
    Hd.FilterStructure));

% [EOF]
