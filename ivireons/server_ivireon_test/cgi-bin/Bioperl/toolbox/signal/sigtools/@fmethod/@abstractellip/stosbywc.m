function sos = stosbywc(h,sos,Wc)
%STOSBYWC   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/12/26 22:19:30 $

% Make transformation s -> s/Wc
sos(:,[1,4])=sos(:,[1,4])/Wc^2;

sos(:,5)=sos(:,5)/Wc;


% [EOF]
