function [Ht, anum, aden] = iirlp2bs(Ho, varargin)
%IIRLP2BS IIR lowpass to bandstop frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:19 $

[Ht, anum, aden] = iirxform(Ho, @iirlp2bs, varargin{:});

% [EOF]
