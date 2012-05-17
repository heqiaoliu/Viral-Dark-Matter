function Fs = setPIDFormula(Fin)
%SETPIDFORMULA  Derives stored value from user input.
%
%   SETPIDFORMULA takes the user-specified formula string FIN and returns
%   the compressed formula string to be stored in @piddata or ltiblock.pid 
%   objects.
 
% Author(s): Rong Chen 07-Dec-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:46:44 $
if isempty(Fin)
   % Reset to default
   Fs = 'F';
else
   Fs = ltipack.matchKey(Fin,{'ForwardEuler','BackwardEuler','Trapezoidal'});
   if isempty(Fs)
      ctrlMsgUtils.error('Control:ltiobject:pidInvalidFormula');
   else
      Fs = Fs(1);
   end
end
