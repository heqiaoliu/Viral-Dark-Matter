function [strs, targs] = getconvertstructchoices(this)
% GETCONVERTSTRUCTCHOICES  Get the Filter Structure choices for the current Filter

%   Author(s): P. Costa 
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.5 $  $Date: 2004/10/18 21:10:17 $ 

[targs, strs] = convertchoices(this.Filter);

% Keep only what DSPBlockset supports
if get(this, 'DSPMode'),
    [targs i] = intersect(targs, dspblkstructures);
    strs = strs(i);
end

% State space is no longer supported in FDATool.
indx = find(strcmpi(targs, 'statespace'));
targs(indx) = [];
strs(indx) = [];

% [EOF]
