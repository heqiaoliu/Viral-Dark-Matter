function kk=isempty(m)

%   $Revision: 1.5.4.3 $ $Date: 2006/09/30 00:19:19 $
%   Copyright 1986-2006 The MathWorks, Inc.

kk=false;

if isequal(size(m.Ds),[0,0])
    kk = true;
end
if isempty(m.Bs)&&norm(pvget(m,'NoiseVariance')) == 0&& norm(pvget(m,'D'))==0
    kk = true;
end

