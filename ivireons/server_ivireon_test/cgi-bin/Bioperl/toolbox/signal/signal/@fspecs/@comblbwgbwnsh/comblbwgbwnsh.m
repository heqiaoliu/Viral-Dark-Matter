function this = comblbwgbwnsh(varargin)
%COMBLBWGBWNSH   Construct a COMBLBWGBWNSH object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:35 $

this = fspecs.comblbwgbwnsh;

set(this,'CombType','Notch');

set(this, 'ResponseType', 'Comb Filter');

this.setspecs(varargin{:});

% [EOF]
