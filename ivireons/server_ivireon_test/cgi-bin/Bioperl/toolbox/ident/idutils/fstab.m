function B = fstab(A,T,thresh)
%FSTAB	stabilizes MONIC polynomial A.
%
% B = FSTAB(A) performs stabilization with respect to the unit circle or
% imaginary axis. Returned polynomial B is also monic.
%
% B = FSTAB(A, T) allows specification of continuous- or discrete-time domain
% stability criteria. T is assumed to be 1 if not specified.
%   Set T>0 if polynomial A must be stabilized in discrete-time domain.
%   Roots whose magnitudes are greater than one are reflected into the unit
%   circle.
%   Set T=0 to stabilize the polynomial in continuous-time domain.
%   Roots whose real parts are greater than zero (right half place roots)
%   are reflected in the left half plane.
%
% B = FSTAB(A, T, THRESH) allows specification of threshold for stability
% checks. Default value of THRESH is 1 if T>0 and 0 if T=0.

%       L.Ljung 2-10-92
%	Copyright 1992-2009 The MathWorks, Inc.
% $Revision: 1.8.4.6 $ $Date: 2009/10/16 04:56:35 $

if nargin==1,T=1;end
if nargin<3
    if T
        thresh = 1;
    else
        thresh = 0;
    end
end
[nr,nc] = size(A);
if nr==1 || nc==1
    A=A(:).';
    [nr,nc]=size(A);
end
B  = A;
if nr == 1 && nc == 1
    return
end
for kr =1:nr
    v = roots(A(kr,:));
    if T>0
        %         ind=(abs(v)>eps);
        %         vs = 0.5*(sign(abs(v(ind))-1)+1);
        %         v(ind) = (1-vs).*v(ind) + vs./ (conj(v(ind)));
        ind = find(abs(v)>thresh);
        v(ind) = thresh^2*ones(size(ind))./v(ind);
    else
        ind = find(real(v)>thresh);
        if ~isempty(ind)
            v(ind)=2*thresh - real(v(ind))+1i*imag(v(ind));
        end
    end
    bv  = poly(v);lbv = length(bv);
    if T
        B(kr,1:lbv)=bv;
    else
        B(kr,nc-lbv+1:end) = bv;
    end
end
if isreal(A),B=real(B);end
