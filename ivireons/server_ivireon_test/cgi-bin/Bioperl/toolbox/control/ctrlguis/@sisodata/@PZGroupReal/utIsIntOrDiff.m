function b = utIsIntOrDiff(this,Ts)
% checks if pzgroup is an integrator or differentiator

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2006/06/20 20:00:51 $

if isequal(Ts,0);
    sz = 0;
else 
    sz = 1;
end

if isequal(this.Zero,sz) || isequal(this.Pole,sz)
    b = true;
else
    b = false;
end


    