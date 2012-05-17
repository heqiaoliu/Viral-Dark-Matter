function [lib, srcblk] = blocklib(Hd)
%BLOCKPARAMS Returns the library and source block for BLOCKPARAMS

% This should be a private method

% Author(s): V. Pellissier
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/01/20 15:34:53 $

% Library, block

lib = 'dsparch4';

checksv(Hd)
srcblk = 'Biquad Filter';




% [EOF]
