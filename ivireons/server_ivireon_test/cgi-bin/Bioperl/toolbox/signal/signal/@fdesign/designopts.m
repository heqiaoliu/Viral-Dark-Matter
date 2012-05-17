%DESIGNOPTS   Returns the default design parameters.
%   OPTS = DESIGNOPTS(D, METHOD) returns a structure with the default
%   design parameters used by the design method METHOD. METHOD must be one 
%   of the strings returned by <a href="matlab:help fdesign/designmethods">DESIGNMETHODS</a>. 
%
%   Use HELP(D, METHOD) to get a description of the design parameters. 
%
%   % EXAMPLE - Get the design options for minimum order lowpass
%   %           Butterworth filters.
%   d = fdesign.lowpass;
%   designmethods(d)
%   opts = designopts(d, 'butter')
%   help(d,'butter')
%
%   See also FDESIGN, FDESIGN/DESIGN, FDESIGN/DESIGNMETHODS, FDESIGN/HELP.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:34:54 $

% Help file, no code.

% [EOF]
