function data=generate(hWIN)
%GENERATE(hWIN) Generates the userdefined window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:14:15 $

try
data = evalin('base', hWIN.MATLAB_expression);
catch
error(generatemsgid('InvalidParam'),'Invalid MATLAB expression.');
end
% [EOF]
