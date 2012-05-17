function [sos,g] = alpastop(h,N,Wp,Apass,Astop)
%ALPASTOP   

%   Author(s): R. Losada
%   Copyright 1999-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/12/28 04:36:03 $

 
[~,~,~,B,A] = ellipap2(N,Apass,Astop);

g = ones(1,size(A,1)-1);
if rem(N,2) == 1,
    g(1) = 1/A(1,2);
    A(1,:) = A(1,:)/A(1,2);    
else
    g(1) = B(1,1);  
end
if N > 1,
    g = g./A(2:end,3)';
    A(2:end,:) = A(2:end,:)./repmat(A(2:end,3),1,3);
    g = g.*B(2:end,3)';
    B(2:end,:) = B(2:end,:)./repmat(B(2:end,3),1,3);
    
    if rem(N,2) == 0,
        B = B(2:end,:);
        A = A(2:end,:);
    end
end

sos2 = [fliplr(B), fliplr(A)];


% Make transformation s -> s/Wp, ensure first order section is last
sos = stosbywc(h,sos2([2:end,1],:),Wp);

% [EOF]
