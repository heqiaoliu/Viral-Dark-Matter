function bd0 = binodeviance(x,np)
%BINODEVIANCE Deviance term for binomial and Poisson probability calculation.
%    BD0=BINODEVIANCE(X,NP) calculates the deviance as defined in equation
%    5.2 in C. Loader, "Fast and Accurate Calculations of Binomial
%    Probabilities", July 9, 2000. X and NP must be of the same size.
%
%    For "x/np" not close to 1:
%        bd0(x,np) = np*f(x/np) where f(e)=e*log(e)+1-e
%    For "x/np" close to 1: 
%         The function is calculated using the formula in Equation 5.2. 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

bd0=zeros(size(x));

% If "x/np" is close to 1:
k = abs(x-np)<0.1*(x+np);
if any(k(:))
    s = (x(k)-np(k)).*(x(k)-np(k))./(x(k)+np(k));
    v = (x(k)-np(k))./(x(k)+np(k));
    ej = 2.*x(k).*v;
    s1 = zeros(size(s));
    ok = true(size(s));
    j = 0;
    while any(ok(:))
        ej(ok) = ej(ok).*v(ok).*v(ok);
        j = j+1;
        s1(ok) = s(ok) + ej(ok)./(2*j+1);
        ok = ok & s1~=s;
        s(ok) = s1(ok);
    end
    bd0(k) = s;
end

% If "x/np" is not close to 1:
k = ~k;
if any(k(:))
    bd0(k)= x(k).*log(x(k)./np(k))+np(k)-x(k);
end

end
