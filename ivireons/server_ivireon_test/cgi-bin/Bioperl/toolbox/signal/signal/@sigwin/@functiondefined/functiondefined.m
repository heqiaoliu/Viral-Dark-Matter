function hWIN = functiondefined(fcnname, n, params)
%FDEFWIN Constructor of the functiondefined class

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:15:48 $

hWIN = sigwin.functiondefined;
hWIN.Name = 'User Defined';

if nargin>0,
    hWIN.MATLABExpression = fcnname;
end

if nargin>1,
    hWIN.Length = n;
end

if nargin>2,
    hWIN.Parameters = params;
end

% [EOF]
