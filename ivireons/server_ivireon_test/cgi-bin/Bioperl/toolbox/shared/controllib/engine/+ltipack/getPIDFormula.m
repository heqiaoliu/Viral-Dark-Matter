function Fout = getPIDFormula(Fs, Ts) 
%GETPIDFORMULA  Reconstructs I/D formula from stored value.
%
%   FS is the value stored in @piddata or ltiblock.pid objects, FOUT
%   is the formula shown to users.
 
% Author(s): Rong Chen 07-Dec-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:36:02 $
if Ts==0 
    Fout = '';
else
    switch Fs
        case 'F'
            Fout = 'ForwardEuler';
        case 'B'
            Fout = 'BackwardEuler';
        case 'T'
            Fout = 'Trapezoidal';                        
    end
end
