function Hd = createobj(this,coeffs)
%CREATEOBJ   

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:42:17 $


struct = get(this, 'FilterStructure');

Hd = feval(['dfilt.' struct], coeffs{:});

% [EOF]
