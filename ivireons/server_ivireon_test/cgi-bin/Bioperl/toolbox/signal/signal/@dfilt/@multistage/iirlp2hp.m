function [Ht, anum, aden] = iirlp2hp(Hd, varargin)
%IIRLP2HP IIR Lowpass to highpass transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:26 $

[Ht, anum, aden] = iirxform(Hd, @iirlp2hp, varargin{:});

% [EOF]
