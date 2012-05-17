function this = lpisinccutoffwatten(varargin)
%LPISINCCUTOFFWATTEN   Construct a LPISINCCUTOFFWATTEN object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:01:58 $

this = fspecs.lpisinccutoffwatten;

fstart = 2;
fstop = 2;
nargsnoFs = 6;
fsconstructor(this,'Inverse-sinc lowpass',fstart,fstop,nargsnoFs,varargin{:});

% [EOF]
