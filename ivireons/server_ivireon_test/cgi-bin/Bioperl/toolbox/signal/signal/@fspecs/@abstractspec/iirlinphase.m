function  Hd = iirlinphase(this,varargin)
%IIRLINPHASE   IIR quasi linear phase digital filter design.
%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/04 18:03:46 $

Hd = design(this, 'iirlinphase', varargin{:});

% [EOF]
