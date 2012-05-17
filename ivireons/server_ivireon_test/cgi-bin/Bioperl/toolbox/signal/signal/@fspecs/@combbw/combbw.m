function this = combbw(varargin)
%COMBBW   Construct a COMBBW object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:27 $

this = fspecs.combbw;

set(this, 'ResponseType', 'Comb Filter');

this.setspecs(varargin{:});

% [EOF]
