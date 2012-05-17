function [Ht, anum, aden] = iirxform(Ho,fun,varargin)
%IIRXFORM IIR Transformations

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:27 $

% This should be private
error([get(Ho, 'FilterStructure') ' structure does not support frequency transformations.  ' ...
        char(10) 'Convert to a direct-form filter to perform frequency transformations.']);


% [EOF]
