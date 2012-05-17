function h = noisemagnitude(varargin)
%NOISEMAGNITUDE Construct a noisemagresp object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/11 13:22:31 $

h = filtresp.noisemagnitude;

h.nlm_construct(varargin{:});

set(h, 'Name', legendstring(h));

% [EOF]
