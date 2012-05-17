function Ht = firlp2hp(Ho, varargin)
%FIRLP2HP FIR Lowpass to highpass frequency transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:09:42 $

if ~isfir(Ho)
    error(generatemsgid('DFILTErr'),'Filter must be an FIR.');
end

if nargin > 1 && (~islinphase(Ho) || firtype(Ho) ~= 1) && strcmpi(varargin{1},'wide'),
    error(generatemsgid('DFILTErr'),'Filter must be a type I linear phase FIR.');
end

Ht = firxform(Ho, @firlp2hp, varargin{:});

% [EOF]
