function Dr = minreal(D,tol)
% Pole/zero cancellations in ZPK models

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:50 $
Dr = tf(minreal(zpk(D),tol));