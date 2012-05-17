function Hd = firls(this, varargin)
%FIRLS   Design a FIR Least-Squares filter.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:27:11 $

Hd = design(this, 'firls', varargin{:});

% [EOF]
