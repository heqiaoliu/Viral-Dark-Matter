function [Ht, anum, aden] = iirlp2bpc(Ho, varargin)
%IIRLP2BPC IIR lowpass to complex bandpass frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:18 $

[Ht, anum, aden] = iirxform(Ho, @iirlp2bpc, varargin{:});

% [EOF]
