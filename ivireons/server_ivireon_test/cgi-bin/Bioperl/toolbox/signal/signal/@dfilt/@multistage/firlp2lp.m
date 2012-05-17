function Ht = firlp2lp(Hd, varargin)
%FIRLP2LP FIR Lowpass to lowpass transformation

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:19:00 $

Ht = firxform(Hd, @firlp2lp, varargin{:});

% [EOF]
