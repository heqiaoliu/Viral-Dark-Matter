function [Ht, anum, aden] = iirlp2bs(Hd, varargin)
%IIRLP2BS IIR Lowpass to bandstop transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:24 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2bs, varargin{:});

% [EOF]
