function Hd = lpcreatecaobj(this,struct,branch1,branch2)
%LPCREATECAOBJ   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:46:46 $

ha = feval(['dfilt.' struct], branch1{:});
hb = feval(['dfilt.' struct], branch2{:});
hp = parallel(ha,hb);
Hd = cascade(hp,dfilt.scalar(.5));

% [EOF]
