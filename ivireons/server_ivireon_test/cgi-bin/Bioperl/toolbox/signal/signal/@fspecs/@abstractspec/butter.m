function Hd = butter(this, varargin)
%BUTTER   Butterworth digital filter design.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:27:07 $

Hd = design(this, 'butter', varargin{:});

% [EOF]
