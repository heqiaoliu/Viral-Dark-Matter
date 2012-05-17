function this = lpisincstopapass(varargin)
%LPISINCSTOPAPASS   Construct a LPISINCSTOPAPASS object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:02:20 $

this = fspecs.lpisincstopapass;

fsconstructor(this,'Inverse-sinc lowpass',2,2,6,varargin{:});

% [EOF]
