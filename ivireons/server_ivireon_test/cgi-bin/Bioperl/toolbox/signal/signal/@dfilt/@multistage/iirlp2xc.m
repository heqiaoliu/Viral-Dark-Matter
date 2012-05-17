function [Ht, anum, aden] = iirlp2xc(Hd, varargin)
%IIRLP2XC IIR Lowpass to complex N-Point transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:30 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2xc, varargin{:});

% [EOF]
