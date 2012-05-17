function [Ht, anum, aden] = iirbpc2bpc(Hd, varargin)
%IIRBPC2BPC IIR complex bandpass to complex bandpass transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/11/18 14:24:21 $

[Ht, anum, aden] = iirxform(Hd, @iirbpc2bpc, varargin{:});

% [EOF]
