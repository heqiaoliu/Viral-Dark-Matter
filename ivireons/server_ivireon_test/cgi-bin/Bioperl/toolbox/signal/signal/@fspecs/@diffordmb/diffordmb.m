function this = diffordmb(varargin)
%DIFFORDMB   Construct a DIFFORDMB object.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:35:49 $

this = fspecs.diffordmb;

this.ResponseType = 'Multi-band Differentiator with filter order';

% Defaults
this.FilterOrder = 30;
this.Fpass = .7;
this.Fstop = .9;  

this.setspecs(varargin{:});

% [EOF]
