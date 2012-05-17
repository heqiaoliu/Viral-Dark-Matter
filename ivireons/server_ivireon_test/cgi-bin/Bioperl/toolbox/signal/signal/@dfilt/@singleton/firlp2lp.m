function Ht = firlp2lp(Ho)
%FIRLP2LP FIR Lowpass to lowpass frequency transformation

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:09:43 $

if ~isfir(Ho) | ~islinphase(Ho) | firtype(Ho) ~= 1,
    error(generatemsgid('DFILTErr'),'Filter must be a type I linear phase FIR.');
end

% Special case for scalars
if isscalar(Ho),
    % Ensure that the gain is preserved 
    Ht = copy(Ho);
    return;
end
    
Ht = firxform(Ho, @firlp2lp);

% [EOF]
