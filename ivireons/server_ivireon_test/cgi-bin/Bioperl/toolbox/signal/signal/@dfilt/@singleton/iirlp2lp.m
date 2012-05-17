function [Ht, anum, aden] = iirlp2lp(Ho, varargin)
%IIRLP2LP IIR lowpass to lowpass frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:22 $

[Ht, anum, aden] = iirxform(Ho, @iirlp2lp, varargin{:});

% [EOF]
