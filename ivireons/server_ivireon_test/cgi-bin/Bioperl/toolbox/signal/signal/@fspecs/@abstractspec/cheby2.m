function Hd = cheby2(this, varargin)
%CHEBY2   Chebyshev Type II digital filter design.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:27:09 $

Hd = design(this, 'cheby2', varargin{:});

% [EOF]
