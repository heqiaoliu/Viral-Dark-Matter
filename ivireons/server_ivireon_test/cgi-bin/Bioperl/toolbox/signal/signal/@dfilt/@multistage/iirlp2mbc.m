function [Ht, anum, aden] = iirlp2mbc(Hd, varargin)
%IIRLP2MBC IIR Lowpass to complex multiband transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:29 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2mbc, varargin{:});

% [EOF]
