function this = cicdecimspecs
%CICDECIMSPECS   Construct a CICDECIMSPECS object.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:30:31 $

this = fspecs.cicdecimspecs;

this.ResponseType = 'CIC Decimator';

% Set the default normalized passband frequency to a small value which will
% result in a design of N = 2
this.Fpass = .01;

% [EOF]
