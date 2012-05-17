function [Ht, anum, aden] = iirlp2bpc(Hd, varargin)
%IIRLP2BPC IIR Lowpass to complex bandpass transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:23 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2bpc, varargin{:});

% [EOF]
