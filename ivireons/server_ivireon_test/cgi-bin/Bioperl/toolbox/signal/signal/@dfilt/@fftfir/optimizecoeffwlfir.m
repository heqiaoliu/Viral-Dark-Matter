function [Hbest,mrfflag] = optimizecoeffwlfir(this,varargin) %#ok<STOUT,INUSD>
%OPTIMIZECOEFFWLFIR Optimize coefficient wordlength for FIR filters.
%   This should be a private method.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:33:24 $

error(generatemsgid('unsupportedFilterStructure'),...
    'This function is not supported for dfilt.fftfir filters.');

% [EOF]
