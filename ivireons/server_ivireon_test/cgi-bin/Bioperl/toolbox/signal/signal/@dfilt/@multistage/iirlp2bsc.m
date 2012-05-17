function [Ht, anum, aden] = iirlp2bsc(Hd, varargin)
%IIRLP2BSC IIR Lowpass to complex bandstop transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:25 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2bsc, varargin{:});

% [EOF]
