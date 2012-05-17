function [lib, srcblk] = blocklib(Hd)
%BLOCKPARAMS Returns the library and source block for BLOCKPARAMS

% This should be a private method

% Author(s): V. Pellissier
% Copyright 1988-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:34:28 $

% Library, block
lib = 'dsparch4';
srcblk = 'Overlap-Add FFT Filter';
