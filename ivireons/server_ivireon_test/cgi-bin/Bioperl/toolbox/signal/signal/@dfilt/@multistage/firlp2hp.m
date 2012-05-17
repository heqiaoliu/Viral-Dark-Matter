function Ht = firlp2hp(Hd, varargin)
%FIRLP2HP FIR Lowpass to highpass transformation

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:18:59 $

Ht = firxform(Hd, @firlp2hp, varargin{:});

% [EOF]
