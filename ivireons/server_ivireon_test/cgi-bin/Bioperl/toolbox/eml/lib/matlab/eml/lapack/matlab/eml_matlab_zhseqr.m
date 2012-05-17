function [h,info,z] = eml_matlab_zhseqr(h,z)
%Embedded MATLAB Private Function

%    Based on:
%        -- LAPACK auxiliary routine ZHSEQR (version 3.2) --

%   Copyright 2010 The MathWorks, Inc.
%#eml

% if nargin < 2
%     z = complex(eye(size(h,1),class(h)));
% end
if nargout == 3
    [h,info,z] = eml_zlahqr(h,z);
else
    [h,info] = eml_zlahqr(h);
end
h = triu(h,-2);

%--------------------------------------------------------------------------

function [h,info,z] = eml_zlahqr(h,z)
% Based on:  ZLAHQR (version 3.2)
eml_must_inline;
cls = class(h);
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
DAT1 = cast(0.75,cls);
WANTZ = nargout == 3 && nargin == 2;
% WANTT = true;
itmax = cast(30,eml_index_class);
n = cast(size(h,1),eml_index_class);
ilo = ones(eml_index_class);
ihi = n;
ldh = cast(size(h,1),eml_index_class);
% We don't need to return the vector of eigenvalues.
% w = eml.nullcopy(complex(zeros(n,1,cls)));
if WANTZ
    iloz = ilo;
    ihiz = ihi;
    ldz = cast(size(z,1),eml_index_class);
end
info = ZERO;
% Quick return if possible
if n == 0
    return
end
if ilo == ihi
    % w(ilo) = h(ilo,ilo);
    return
end
v = eml.nullcopy(complex(zeros(2,1,cls)));
% ==== clear out the trash ====
for j = ilo:eml_index_minus(ihi,3)
    h(eml_index_plus(j,2),j) = 0;
    h(eml_index_plus(j,3),j) = 0;
end %10
if ilo <= eml_index_minus(ihi,2)
    h(ihi,eml_index_minus(ihi,2)) = 0;
end
% ==== ensure that subdiagonal entries are real ====
jlo = ONE;
jhi = n;
for i = eml_index_plus(ilo,1):ihi
    if imag(h(i,eml_index_minus(i,1))) ~= 0
        % ==== the following redundant normalization
        % .    avoids problems with both gradual and
        % .    sudden underflow in abs(h(i,i-1)) ====
        sc = h(i,eml_index_minus(i,1)) / abs1(h(i,eml_index_minus(i,1)));
        sc = conj(sc) / abs(sc);
        h(i,eml_index_minus(i,1)) = abs(h(i,eml_index_minus(i,1)));
        % zscal(jhi-i+1,sc,h(i,i),ldh)
        h = eml_xscal(eml_index_minus(jhi,eml_index_minus(i,1)), ...
            sc,h, ...
            eml_index_plus(i,eml_index_times(eml_index_minus(i,1),ldh)), ...
            ldh);
        % zscal(min(jhi,i+1)-jlo+1,dconjg(sc),h(jlo,i),1)
        h = eml_xscal(eml_index_plus(eml_index_minus(min(jhi,eml_index_plus(i,1)),jlo),1), ...
            conj(sc),h, ...
            eml_index_plus(jlo,eml_index_times(eml_index_minus(i,1),ldh)), ...
            ONE);
        if WANTZ
            % zscal(ihiz-iloz+1,dconjg(sc),z(iloz,i),1)
            z = eml_xscal(eml_index_plus(eml_index_minus(ihiz,iloz),1), ...
                conj(sc),z, ...
                eml_index_plus(iloz,eml_index_times(eml_index_minus(i,1),ldz)), ...
                ONE);
        end
    end
end %20
nh = eml_index_plus(eml_index_minus(ihi,ilo),1);
if WANTZ
    nz = eml_index_plus(eml_index_minus(ihiz,iloz),1);
end
% Set machine-dependent constants for the stopping criterion.
SAFMIN = realmin(cls);
ULP = eps(cls);
SMLNUM = SAFMIN*(cast(nh,cls)/ULP);
% I1 and I2 are the indices of the first row and last column of H
% to which transformations must be applied. If eigenvalues only are
% being computed,I1 and I2 are set inside the main loop.
i1 = ONE;
i2 = n;
% The main loop begins here. I is the loop index and decreases from
% IHI to ILO in steps of 1. Each iteration of the loop works
% with the active submatrix in rows and columns L to I.
% Eigenvalues I+1 to IHI have already converged. Either L = ILO,or
% H(L,L-1) is negligible so that the matrix splits.
i = ihi;
while i >= ilo % 30 CONTINUE
    % Perform QR iterations on rows and columns ILO to I until a
    % submatrix of order 1 splits off at the bottom because a
    % subdiagonal element has become negligible.
    L = ilo;
    goto140 = false;
    for its = ZERO:itmax
        % Look for a single small subdiagonal element.
        k = i;
        while k > L
            if abs1(h(k,eml_index_minus(k,1))) <= SMLNUM
                break
            end
            tst = abs1(h(eml_index_minus(k,1),eml_index_minus(k,1))) + abs1(h(k,k));
            if tst == 0
                if eml_index_minus(k,2) >= ilo
                    tst = tst + abs(real(h(eml_index_minus(k,1),eml_index_minus(k,2))));
                end
                if eml_index_plus(k,1) <= ihi
                    tst = tst + abs(real(h(eml_index_plus(k,1),k)));
                end
            end
            % ==== The following is a conservative small subdiagonal
            % .    deflation criterion due to Ahues & Tisseur (LAWN 122,
            % .    1997). It has better mathematical foundation and
            % .    improves accuracy in some examples.  ====
            if abs(real(h(k,eml_index_minus(k,1)))) <= ULP*tst
                % AB = MAX(ABS(H(K,K-1)),ABS(H(K-1,K)))
                % BA = MIN(ABS(H(K,K-1)),ABS(H(K-1,K)))
                htmp1 = abs1(h(k,eml_index_minus(k,1)));
                htmp2 = abs1(h(eml_index_minus(k,1),k));
                if htmp1 > htmp2
                    ab = htmp1;
                    ba = htmp2;
                else
                    ab = htmp2;
                    ba = htmp1;
                end
                % AA = MAX(ABS(H(K,K)),ABS(H(K-1,K-1)-H(K,K)))
                % BB = MIN(ABS(H(K,K)),ABS(H(K-1,K-1)-H(K,K)))
                htmp1 = abs1(h(k,k));
                htmp2 = abs1(h(eml_index_minus(k,1),eml_index_minus(k,1))-h(k,k));
                if htmp1 > htmp2
                    aa = htmp1;
                    bb = htmp2;
                else
                    aa = htmp2;
                    bb = htmp1;
                end
                s = aa + ab;
                if ba*(ab/s) <= max(SMLNUM,ULP*(bb*(aa/s)))
                    break
                end
            end
            k = eml_index_minus(k,1);
        end %40
        L = k;
        if L > ilo
            % H(L,L-1) is negligible
            h(L,eml_index_minus(L,1)) = 0;
        end
        % Exit from loop if a submatrix of order 1 has split off.
        if L >= i
            goto140 = true;
            break % go to 140
        end
        % Now the active submatrix is in rows and columns L to I. If
        % eigenvalues only are being computed,only the active submatrix
        % need be transformed.
        if its == 10
            % Exceptional shift.
            s = DAT1*abs(real(h(eml_index_plus(L,1),L)));
            t = s + h(L,L);
        elseif its == 20
            % Exceptional shift.
            s = DAT1*abs(real(h(i,eml_index_minus(i,1))));
            t = s + h(i,i);
        else
            % Wilkinson's shift.
            t = h(i,i);
            u = sqrt(h(eml_index_minus(i,1),i))*sqrt(h(i,eml_index_minus(i,1)));
            s = abs1(u);
            if s ~= 0
                x = 0.5*(h(eml_index_minus(i,1),eml_index_minus(i,1))-t);
                sx = abs1(x);
                s = max(s,abs1(x));
                x2 = x/s;
                x2 = x2*x2;
                u2 = u/s;
                u2 = u2*u2;
                y = s*sqrt(x2+u2);
                if sx > 0
                    x2 = x/sx;
                    if real(x2)*real(y)+imag(x2)*imag(y) < 0
                        y = -y;
                    end
                end
                % t = t - u*zladiv(u,(x+y));
                t = t - u*(u/(x+y));
            end
        end
        % Look for two consecutive small subdiagonal elements.
        goto70 = false;
        m = eml_index_minus(i,1);
        while m > L
            % Determine the effect of starting the single-shift QR
            % iteration at row M,and see if this would make H(M,M-1)
            % negligible.
            h11 = h(m,m);
            h22 = h(eml_index_plus(m,1),eml_index_plus(m,1));
            h11s = h11 - t;
            h21 = real(h(eml_index_plus(m,1),m));
            s = abs1(h11s) + abs(h21);
            h11s = h11s/s;
            h21 = h21/s;
            v(1) = h11s;
            v(2) = h21;
            h10 = real(h(m,eml_index_minus(m,1)));
            if abs(h10)*abs(h21) <= ULP*(abs1(h11s)*(abs1(h11)+abs1(h22)))
                goto70 = true;
                break
            end
            m = eml_index_minus(m,1);
        end %60
        if ~goto70
            h11 = h(L,L);
            % h22 = h(L+1,L+1); % unused
            h11s = h11 - t;
            h21 = real(h(eml_index_plus(L,1),L));
            s = abs1(h11s) + abs(h21);
            h11s = h11s / s;
            h21 = h21 / s;
            v(1) = h11s;
            v(2) = h21;
        end
        % 70 CONTINUE
        % Single-shift QR step
        for k = m:eml_index_minus(i,1)
            % The first iteration of this loop determines a reflection G
            % from the vector V and applies it from left and right to H,
            % thus creating a nonzero bulge below the subdiagonal.
            %
            % Each subsequent iteration determines a reflection G to
            % restore the Hessenberg form in the (K-1)th column,and thus
            % chases the bulge one step toward the bottom of the active
            % submatrix.
            %
            % V(2) is always real before the call to ZLARFG,and hence
            % after the call T2 (= T1*V(2)) is also real.
            if k > m
                % zcopy(2,h(k,k-1),1,v,1)
                v(1) = h(k,eml_index_minus(k,1));
                v(2) = h(eml_index_plus(k,1),eml_index_minus(k,1));
            end
            % zlarfg(2,v(1),v(2),1,t1)
            [v(1),v(2),t1] = eml_matlab_zlarfg(cast(2,eml_index_class),v(1),v(2),ONE,ONE);
            if k > m
                h(k,eml_index_minus(k,1)) = v(1);
                h(eml_index_plus(k,1),eml_index_minus(k,1)) = 0;
            end
            v2 = v(2);
            t2 = real(t1*v2);
            % Apply G from the left to transform the rows of the matrix
            % in columns K to I2.
            for j = k:i2
                sum1 = conj(t1)*h(k,j) + t2*h(eml_index_plus(k,1),j);
                h(k,j) = h(k,j) - sum1;
                h(eml_index_plus(k,1),j) = h(eml_index_plus(k,1),j) - sum1*v2;
            end %80
            % Apply G from the right to transform the columns of the
            % matrix in rows I1 to min(K+2,I).
            for j = i1:min(k+2,i)
                sum1 = t1*h(j,k) + t2*h(j,eml_index_plus(k,1));
                h(j,k) = h(j,k) - sum1;
                h(j,eml_index_plus(k,1)) = h(j,eml_index_plus(k,1)) - sum1*conj(v2);
            end %90
            if WANTZ
                % Accumulate transformations in the matrix Z
                for j = iloz:ihiz
                    sum1 = t1*z(j,k) + t2*z(j,eml_index_plus(k,1));
                    z(j,k) = z(j,k) - sum1;
                    z(j,eml_index_plus(k,1)) = z(j,eml_index_plus(k,1)) - sum1*conj(v2);
                end %100
            end
            if k == m && m > L
                % If the QR step was started at row M > L because two
                % consecutive small subdiagonals were found,then extra
                % scaling must be performed to ensure that H(M,M-1) remains
                % real.
                temp = 1 - t1;
                temp = temp / abs(temp);
                h(eml_index_plus(m,1),m) = h(eml_index_plus(m,1),m)*conj(temp);
                if eml_index_plus(m,2) <= i
                    h(eml_index_plus(m,2),eml_index_plus(m,1)) = ...
                        h(eml_index_plus(m,2),eml_index_plus(m,1))*temp;
                end
                for j = m:i
                    if j ~= eml_index_plus(m,1)
                        if i2 > j
                            % zscal(i2-j,temp,h(j,j+1),ldh)
                            h = eml_xscal(eml_index_minus(i2,j), ...
                                temp,h, ...
                                eml_index_plus(j,eml_index_times(j,ldh)), ...
                                ldh);
                        end
                        % zscal(j-i1,conj(temp),h(i1,j),1)
                        h = eml_xscal(eml_index_minus(j,i1), ...
                            conj(temp),h, ...
                            eml_index_plus(i1,eml_index_times(eml_index_minus(j,1),ldh)), ...
                            ONE);
                        if WANTZ
                            % zscal(nz,conj(temp),z(iloz,j),1)
                            z = eml_xscal(nz, ...
                                conj(temp),z, ...
                                eml_index_plus(iloz,eml_index_times(eml_index_minus(j,1),ldh)), ...
                                ONE);
                        end
                    end
                end %110
            end
        end %120
        % Ensure that H(I,I-1) is real.
        temp = h(i,eml_index_minus(i,1));
        if imag(temp) ~= 0
            rtemp = abs(temp);
            h(i,eml_index_minus(i,1)) = rtemp;
            temp = temp / rtemp;
            if i2 > i
                % zscal(i2-i,conj(temp),h(i,i+1),ldh)
                h = eml_xscal(eml_index_minus(i2,i), ...
                    conj(temp),h, ...
                    eml_index_plus(i,eml_index_times(i,ldh)), ...
                    ldh);
            end
            % zscal(i-i1,temp,h(i1,i),1)
            h = eml_xscal(eml_index_minus(i,i1), ...
                temp,h, ...
                eml_index_plus(i1,eml_index_times(eml_index_minus(i,1),ldh)), ...
                ONE);
            if WANTZ
                % zscal(nz,temp,z(iloz,i),1)
                z = eml_xscal(nz, ...
                    temp,z, ...
                    eml_index_plus(iloz,eml_index_times(eml_index_minus(i,1),ldh)), ...
                    ONE);
            end
        end
    end %130
    if ~goto140
        % Failure to converge in remaining number of iterations
        info = i;
        return
    end
    % 140 CONTINUE
    % H(I,I-1) is negligible: one eigenvalue has converged.
    % w(i) = h(i,i);
    % return to start of the main loop with new value of I.
    i = eml_index_minus(L,1);
end % while (i >= ilo)
% 150 CONTINUE
% End of ZLAHQR

%--------------------------------------------------------------------------

function y = abs1(x)
eml_must_inline;
y = abs(real(x)) + abs(imag(x));

%--------------------------------------------------------------------------