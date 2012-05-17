function [Ht, anum, aden] = iirlp2bp(Hd, varargin)
%IIRLP2BP IIR Lowpass to bandpass transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:22 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2bp, varargin{:});

% [EOF]
