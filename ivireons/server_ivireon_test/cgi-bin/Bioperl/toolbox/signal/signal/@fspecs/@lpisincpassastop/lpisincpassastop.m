function this = lpisincpassastop(varargin)
%LPISINCPASSASTOP   Construct a LPISINCPASSASTOP object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/04/04 17:02:15 $

this = fspecs.lpisincpassastop;

fsconstructor(this,'Inverse-sinc lowpass',2,2,6,varargin{:});

% [EOF]
