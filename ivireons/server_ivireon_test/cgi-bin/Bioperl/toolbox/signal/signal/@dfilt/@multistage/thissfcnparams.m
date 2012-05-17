function varargout = thissfcnparams(Hd)
%THISSFCNPARAMS Returns the parameters for SDSPFILTER

% Author(s): J. Schickler
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/06/16 08:19:24 $

error('signal:dfilt:notSupported', ...
    sprintf('%s structure not supported by the Signal Processing Blockset.', ...
    Hd.FilterStructure));

% [EOF]
