function this = pssqrtrcosmin(varargin)
%PSRCOSMIN Construct a PSSQRTRCOSMIN object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:15:33 $

this = fspecs.pssqrtrcosmin;

this.ResponseType = 'Minimum order square root raised cosine pulse shaping';

% This is the half of the default raised cosine stop band attenuation, which is
% 60 dB.
this.Astop = 30;

this.setspecs(varargin{:});

% [EOF]