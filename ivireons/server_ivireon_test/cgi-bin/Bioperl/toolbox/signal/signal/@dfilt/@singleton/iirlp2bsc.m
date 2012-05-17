function [Ht, anum, aden] = iirlp2bsc(Ho, varargin)
%IIRLP2BSC IIR lowpass to complex bandstop frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:20 $

[Ht, anum, aden] = iirxform(Ho, @iirlp2bsc, varargin{:});

% [EOF]
