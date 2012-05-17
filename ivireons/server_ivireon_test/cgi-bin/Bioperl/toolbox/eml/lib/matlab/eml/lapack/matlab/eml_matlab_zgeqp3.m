function [A,tau,jpvt] = eml_matlab_zgeqp3(A)
%Embedded MATLAB Private Function

%   Adapted from ZLAQP2, then with updates from ZLAQP3.
%    -- LAPACK auxiliary routine (version 3.1) --
%       Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..
%       November 2006

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

ONE = ones(eml_index_class);
m = cast(size(A,1),eml_index_class);
n = cast(size(A,2),eml_index_class);
mn = min(m,n);
tau = eml.nullcopy(eml_expand(eml_scalar_eg(A),[mn,1]));
pivot = nargout == 3;
if pivot
    jpvt = ONE:n;
end
if isempty(A)
    return
end
work = eml_expand(eml_scalar_eg(A),[n,1]); % g467063
TOL3Z = sqrt(eps(class(A)));
if pivot
    % Initialize partial column norms.
    vn1 = eml.nullcopy(eml_expand(eml_scalar_eg(real(A)),[n,1]));
    vn2 = eml.nullcopy(vn1);
    k = ONE;
    for j = ONE:n
        vn1(j) = eml_xnrm2(m,A,k,ONE); % norm(A(:,j))
        vn2(j) = vn1(j);
        k = eml_index_plus(k,m);
    end
end
for i = ONE:mn
    im1 = eml_index_minus(i,1);
    ip1 = eml_index_plus(i,1);
    i_i = eml_index_plus(i,eml_index_times(im1,m)); % i + (i-1)*m;
    nmi = eml_index_minus(n,i);
    mmi = eml_index_minus(m,i);
    mmip1 = eml_index_plus(1,mmi); % m - i + 1
    nmip1 = eml_index_plus(1,nmi); % n - i + 1
    if pivot
        % Determine ith pivot column and swap if necessary.
        pvt = eml_index_plus(im1,eml_ixamax(nmip1,vn1,i,ONE));
        if pvt ~= i
            pvtcol = eml_index_plus(1,eml_index_times(m,eml_index_minus(pvt,1)));
            mcol = eml_index_plus(1,eml_index_times(m,im1)); % 1 + (i-1)*m
            A = eml_xswap(m,A,pvtcol,ONE,[],mcol,ONE);
            itemp = jpvt(pvt);
            jpvt(pvt) = jpvt(i);
            jpvt(i) = itemp;
            vn1(pvt) = vn1(i); % No swap needed.
            vn2(pvt) = vn2(i); % No swap needed.
        end
    end
    % Generate elementary reflector H(i).
    % Using a scalar temporary for A(i_i) disconnects the second and third
    % input arguments to eml_zlarfg, helping to avoid a matrix copy of A.
    atmp = A(i_i); 
    if i < m
        [atmp,A,tau(i)] = eml_matlab_zlarfp(mmip1,atmp,A,eml_index_plus(i_i,1),ONE);
    else
        [atmp,A(i_i),tau(i)] = eml_matlab_zlarfp(ONE,atmp,A(i_i),ONE,ONE);
    end
    A(i_i) = atmp;
    if i < n
        % Apply H(i)' to A(offset+i:m,i+1:n) from the left.
        atmp = A(i_i);
        A(i_i) = 1;
        i_ip1 = eml_index_plus(i,eml_index_times(i,m)); % i + i*m
        [A,work] = eml_matlab_zlarf('L',mmip1,nmi,[],i_i,1,conj(tau(i)),A,i_ip1,m,work);
        A(i_i) = atmp;
    end
    if pivot
        % Update partial column norms.
        for j = ip1:n
            i_j = eml_index_plus(i,eml_index_times(m,eml_index_minus(j,1))); % i + (j-1)*m
            if vn1(j) ~= 0
                % NOTE: The following lines follow from the analysis in
                % Lapack Working Note 176.
                temp1 = eml_rdivide(abs(A(i,j)),vn1(j));
                temp1 = 1 - temp1*temp1;
                if temp1 < 0
                    temp1 = zeros(class(A));
                end
                temp2 = eml_rdivide(vn1(j),vn2(j));
                temp2 = temp1*(temp2*temp2);
                if temp2 <= TOL3Z
                    if i < m
                        vn1(j) = eml_xnrm2(mmi,A,eml_index_plus(i_j,1),1); % norm(A(ip1:m,j)
                        vn2(j) = vn1(j);
                    else
                        vn1(j) = 0;
                        vn2(j) = 0;
                    end
                else
                    vn1(j) = vn1(j) * sqrt(temp1);
                end
            end
        end
    end
end

