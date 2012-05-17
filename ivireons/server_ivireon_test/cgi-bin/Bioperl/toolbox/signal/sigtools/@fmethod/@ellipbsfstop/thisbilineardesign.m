function [s,g] = thisbilineardesign(h,N,sa,ga,c)
%THISBILINEARDESIGN   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2007/10/23 18:55:22 $

if N ~= 2,
    % Compute coeffs
    msf = floor(N/4);
    for k = 1:msf
        den = sum(sa(k,4:6));
        ai1(k) = -(4*c*sa(k,6)+2*c*sa(k,5))./den;
        ai2(k) = (sa(k,6)*(2+4*c^2)-2*sa(k,4))./den;
        ai3(k) = (-4*c*sa(k,6)+2*c*sa(k,5))./den;
        ai4(k) = (sa(k,4)-sa(k,5)+sa(k,6))./den;
        bi0(k) = (sa(k,1)+sa(k,3))./den;
        bi1(k) = -4*c*sa(k,3)./den;
        bi2(k) = (sa(k,3)*(2+4*c^2)-2*sa(k,1))./den;
    end

    % Compute fourth-order gains
    fog = bi0.*ga;

    % Initialize matrix
    [s,g] = sosinitbpbs(h,N,ai1(:),ai2(:),ai3(:),ai4(:),fog(:));

    % Set all numerators
    M = [ones(length(bi0),1),bi1(:)./bi0(:),bi2(:)./bi0(:),bi1(:)./bi0(:),ones(length(bi0),1)];
    for k = 1:2:2*msf-1,
        r = roots(M(ceil(k/2),:));
        p1 = poly(r(1:2));
        p2 = poly(r(3:4));
        s(k,2:3) = [p1(2), 1];
        s(k+1,2:3) = [p2(2), 1];
    end
else
    s = [0 0 0 0 0 0];
    g = 1;
end

if rem(N,4),
    s(end,1:3) = [1 -2*c 1];
    den = sa(end,5) + sa(end,6);
    s(end,4:6) = [1 -2*c*sa(end,6)/den (sa(end,6) - sa(end,5))/den];
    g(end) = sa(end,3)/den;
end

if N == 2,
    % Special case 2nd order
    g = g*ga;
end

% [EOF]
