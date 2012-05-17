function [A,B,Q,Z] = eml_matlab_zgghrd(compq,compz,ilo,ihi,A,B,Q,Z)
%Embedded MATLAB Private Function

%   ZGGHRD reduces a pair of complex matrices (A,B) to generalized upper
%   Hessenberg form using unitary transformations.  B can be an empty 
%   matrix. 
%
%   If compq == 'N', Q will be empty.
%   If compz == 'N;, Z will be empty.

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

n = cast(size(A,1),eml_index_class);
ONE = ones(eml_index_class);
if compq == 'N'
    Q = zeros(0,class(A));
    ilq = false;
else
    if compq == 'I'
        Q = complex(eye(n,class(A)));
    end
    ilq = true;
end
if compz == 'N'
    Z = zeros(0,class(A));
    ilz = false;
else
    if compz == 'I'
        Z = complex(eye(n,class(A)));
    end
    ilz = true;
end
% Quick return if possible
if n <= 1
    return
end
isgen = ~isempty(B);
if isgen
    % Zero out lower triangle of B
    jcol = ilo;
    while jcol < ihi % for jcol = ilo : jcolend
        jcolp1 = eml_index_plus(jcol,ONE);
        for jrow = jcolp1 : ihi
            B(jrow,jcol) = 0;
        end
        jcol = jcolp1;
    end
end
if ihi < eml_index_plus(ilo,2)
    return
end
% Reduce A and B
ihim1 = eml_index_minus(ihi,ONE);
jcol = ilo;
while jcol < ihim1 % for jcol = ilo : ihi-2
    jcolp1 = eml_index_plus(jcol,ONE);
    jrow = ihi;
    while jrow > jcolp1 % for jrow = ihi : -1 : jcol+2
        jrowm1 = eml_index_minus(jrow,ONE);
        % Step 1: rotate rows JROW-1,JROW to kill A(JROW,JCOL)
        [c,s,A(jrowm1,jcol)] = eml_matlab_zlartg(A(jrowm1,jcol),A(jrow,jcol));
        A(jrow,jcol) = 0;
        A = eml_zrot_rows(A,c,s,jrowm1,jrow,jcolp1,ihi);
        if isgen
            B = eml_zrot_rows(B,c,s,jrowm1,jrow,jrowm1,ihi);
            if ilq
               Q = eml_zrot_rows(Q,c,conj(s),jrowm1,jrow,ONE,n);
            end            
            % Step 2: rotate columns JROW,JROW-1 to kill B(JROW,JROW-1)
            [c,s,B(jrow,jrow)] = eml_matlab_zlartg(B(jrow,jrow),B(jrow,jrowm1));
            B(jrow,jrowm1) = 0;
            B = eml_zrot_cols(B,c,s,jrow,jrowm1,ilo,jrowm1);
        else
            s = -s;
        end
        A = eml_zrot_cols(A,c,s,jrow,jrowm1,ilo,ihi);
        if ilz
            Z = eml_zrot_cols(Z,c,s,jrow,jrowm1,ONE,n);
        end
        jrow = jrowm1;
    end
    jcol = jcolp1;
end
