function this = hilbmin(varargin)
%HILBMIN   Construct a HILBMIN object.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:31:26 $

this = fspecs.hilbmin;

this.ResponseType = 'Minimum-order Hilbert Transformer';

this.setspecs(varargin{:});


% [EOF]
