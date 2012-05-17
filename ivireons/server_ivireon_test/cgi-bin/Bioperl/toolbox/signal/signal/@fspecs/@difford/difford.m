function this = difford(varargin)
%DIFFORD   Construct a DIFFORD object.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:30:57 $

this = fspecs.difford;

this.ResponseType = 'Differentiator with filter order';

% Since this specification type can only be used to design type IV
% differentiators, set the default to an odd filter order.
this.FilterOrder = 31;

this.setspecs(varargin{:});


% [EOF]
