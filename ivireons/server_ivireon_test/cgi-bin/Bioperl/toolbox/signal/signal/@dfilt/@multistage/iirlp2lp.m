function [Ht,anum,aden] = iirlp2lp(Hd, varargin)
%IIRLP2LP IIR Lowpass to lowpass transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:27 $

[Ht,anum,aden] = iirxform(Hd, @iirlp2lp, varargin{:});

% [EOF]
