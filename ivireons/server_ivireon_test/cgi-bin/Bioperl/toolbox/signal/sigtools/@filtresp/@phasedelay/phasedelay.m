function h = phasedelay(varargin)
%PHASEDELAY Construct a phasedelay object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/04 18:58:19 $

h = filtresp.phasedelay;

h.phasedelay_construct(varargin{:});

% [EOF]
