function h = magnitude(varargin)
%MAGNITUDE Construct a magresp object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/28 18:04:48 $

h = filtresp.magnitude;

h.magnitude_construct(varargin{:});

% [EOF]
