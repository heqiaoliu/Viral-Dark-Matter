function [Ht, anum, aden] = iirlp2xn(Hd, varargin)
%IIRLP2XN IIR Lowpass to N-Point transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:31 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2xn, varargin{:});

% [EOF]
