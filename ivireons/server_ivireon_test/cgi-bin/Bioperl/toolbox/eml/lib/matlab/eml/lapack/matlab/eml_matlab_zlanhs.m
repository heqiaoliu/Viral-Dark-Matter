function f = eml_matlab_zlanhs(A,ilo,ihi)
%Embedded MATLAB Private Function

%   Frobenius norm of upper Hessenberg matrix A(ilo:ihi,ilo:ihi).
%   A(i,j) for i > j+1 is assumed zero and is not referenced.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

IONE = ones(eml_index_class);
f = zeros(class(A));
if ilo > ihi
    return
end
one = ones(class(A));
zero = zeros(class(A));
scale = zero;
sumsq = zero;
firstNonZero = true;
for j = ilo : ihi
    for i = ilo : min2(eml_index_plus(j,IONE),ihi)
        Aij = A(i,j);
        reAij = real(Aij);
        imAij = imag(Aij);
        if reAij ~= zero
            temp1 = abs(reAij);
            if firstNonZero
                sumsq = one;
                scale = temp1;
                firstNonZero = false;
            elseif scale < temp1
                temp2 = eml_rdivide(scale,temp1);
                sumsq = one + sumsq*temp2*temp2;
                scale = temp1;
            else
                temp2 = eml_rdivide(temp1,scale);
                sumsq = sumsq + temp2*temp2;
            end
        end
        if imAij ~= zero
            temp1 = abs(imAij);
            if firstNonZero
                sumsq = one;
                scale = temp1;
                firstNonZero = false;
            elseif scale < temp1
                temp2 = eml_rdivide(scale,temp1);
                sumsq = one + sumsq*temp2*temp2;
                scale = temp1;
            else
                temp2 = eml_rdivide(temp1,scale);
                sumsq = sumsq + temp2*temp2;
            end
        end
    end
end
f = scale*sqrt(sumsq);

%--------------------------------------------------------------------------

function x = min2(x,y)
eml_must_inline;
% Simple minimum of 2 elements.  Output class is class(x).
if y < x
    x = cast(y,class(x));
end

%--------------------------------------------------------------------------
