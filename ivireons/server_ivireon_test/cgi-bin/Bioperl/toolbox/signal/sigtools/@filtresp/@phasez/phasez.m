function h = phasez(varargin)
%PHASEZ Construct a phaseresp object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/28 19:34:34 $

h = filtresp.phasez;

h.phasez_construct(varargin{:});

% [EOF]
