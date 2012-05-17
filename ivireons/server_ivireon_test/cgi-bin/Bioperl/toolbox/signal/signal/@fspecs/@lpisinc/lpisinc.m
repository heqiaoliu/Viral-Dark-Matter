function this = lpisinc(varargin)
%LPISINC   Construct a LPISINC object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:01:53 $

this = fspecs.lpisinc;

fsconstructor(this,'Inverse-sinc Lowpass',2,2,5,varargin{:});

% [EOF]
