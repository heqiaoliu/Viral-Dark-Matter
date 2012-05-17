function h = stepz(varargin)
%STEPZ Construct an stepz object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/28 19:34:31 $

h = filtresp.stepz;

set(h, 'Name', 'Step Response');

h.timeresp_construct(varargin{:});

% [EOF]
