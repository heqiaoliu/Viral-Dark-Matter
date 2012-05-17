function this = combq(varargin)
%COMBBW   Construct a COMBQ object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:48 $

this = fspecs.combq;

set(this, 'ResponseType', 'Comb Filter');

this.setspecs(varargin{:});

% [EOF]
