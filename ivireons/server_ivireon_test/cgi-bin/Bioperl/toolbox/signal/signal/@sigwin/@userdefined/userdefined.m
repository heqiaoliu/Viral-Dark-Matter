function hWIN = userdefined(expression)
%USERDEFINED Constructor of the userdefined class

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:16:11 $

hWIN = sigwin.userdefined;
hWIN.Name = 'User Defined';
if nargin > 0, hWIN.MATLABExpression = expression; end

% [EOF]
