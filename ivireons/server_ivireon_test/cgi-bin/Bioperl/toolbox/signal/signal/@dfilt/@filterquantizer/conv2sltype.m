function sltype = conv2sltype(this, varargin)
%CONV2SLTYPE Returns SLTYPE for the given DFILT's quantizer
%   SLTYPE = CONV2SLTYPE(ARGS)
%   This method returns the SLTYPE for the quantizer.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/09/18 02:30:45 $

% always 'double' for double quantizer
sltype = 'double';


% [EOF]
