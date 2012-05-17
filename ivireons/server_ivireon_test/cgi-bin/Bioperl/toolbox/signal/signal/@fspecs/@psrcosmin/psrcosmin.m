function this = psrcosmin(varargin)
%PSRCOSMIN Construct a PSRCOSMIN object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:27:18 $

this = fspecs.psrcosmin;

this.ResponseType = 'Minimum order raised cosine pulse shaping';

this.Astop = 60;

this.setspecs(varargin{:});

% [EOF]
