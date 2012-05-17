function this = diffmin(varargin)
%DIFFMIN   Construct a DIFFMIN object.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:30:43 $

this = fspecs.diffmin;

this.ResponseType = 'Minimum-order Differentiator';

this.setspecs(varargin{:});

% [EOF]
