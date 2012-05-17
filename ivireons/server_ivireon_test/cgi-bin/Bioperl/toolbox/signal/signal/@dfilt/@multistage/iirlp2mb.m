function [Ht, anum, aden] = iirlp2mb(Hd, varargin)
%IIRLP2MB IIR Lowpass to multiband transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:28 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2mb, varargin{:});

% [EOF]
