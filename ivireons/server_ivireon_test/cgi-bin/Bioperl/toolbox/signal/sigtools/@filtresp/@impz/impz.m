function h = impz(varargin)
%IMPZ Construct an impresp object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/28 19:21:19 $

h = filtresp.impz;

set(h, 'Name', 'Impulse Response');

h.timeresp_construct(varargin{:});

% [EOF]
