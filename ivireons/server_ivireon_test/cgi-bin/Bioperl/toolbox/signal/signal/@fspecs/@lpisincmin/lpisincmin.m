function this = lpisincmin(varargin)
%LPISINCMIN   Construct a LPISINCMIN object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:02:03 $

this = fspecs.lpisincmin;

fsconstructor(this,'Inverse-sinc Lowpass',2,2,7,varargin{:});

% [EOF]
