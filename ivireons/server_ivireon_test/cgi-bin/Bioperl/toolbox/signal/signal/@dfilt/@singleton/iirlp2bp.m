function [Ht, anum, aden] = iirlp2bp(Ho, varargin)
%IIRLP2BP IIR lowpass to bandpass frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:17 $

[Ht, anum, aden] = iirxform(Ho, @iirlp2bp, varargin{:});

% [EOF]
