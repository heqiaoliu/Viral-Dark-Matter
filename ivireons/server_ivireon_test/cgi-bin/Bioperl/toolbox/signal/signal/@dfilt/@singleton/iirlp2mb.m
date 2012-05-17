function [Ht, anum, aden] = iirlp2mb(Ho, varargin)
%IIRLP2MB IIR lowpass to multiband frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:23 $

[Ht, anum, aden] = iirxform(Ho, @iirlp2mb, varargin{:});

% [EOF]
