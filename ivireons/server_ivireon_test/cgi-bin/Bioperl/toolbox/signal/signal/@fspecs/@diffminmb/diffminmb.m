function this = diffminmb(varargin)
%DIFFMINMB   Construct a DIFFMINMB object.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:30:50 $

this = fspecs.diffminmb;

this.ResponseType = 'Minimum-order multi-band Differentiator';

this.setspecs(varargin{:});


% [EOF]
