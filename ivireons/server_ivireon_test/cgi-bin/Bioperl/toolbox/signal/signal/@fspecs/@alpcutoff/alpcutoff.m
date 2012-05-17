function h = alpcutoff(varargin)
%ALPCUTOFF   Construct an ALPCUTOFF object.
%   H = ALPCUTOFF(N,Wc) Constructs an analog lowpass filter design
%   specifications object H.
%
%   N is the filter order, and must be a positive integer.
%
%   Wc is the cutoff frequency, in radians-per-second.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:13:59 $

error(nargchk(0,2,nargin,'struct'));

h = fspecs.alpcutoff;

constructor(h,varargin{:});

h.ResponseType = 'Analog lowpass with cutoff';


% [EOF]
