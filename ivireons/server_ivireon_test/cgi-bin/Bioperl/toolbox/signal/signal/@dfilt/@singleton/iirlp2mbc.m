function [Ht, anum, aden] = iirlp2mbc(Ho, varargin)
%IIRLP2MBC IIR lowpass to complex multiband frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:24 $

[Ht, anum, aden] = iirxform(Ho, @iirlp2mbc, varargin{:});

% [EOF]
