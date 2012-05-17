function [h,info,z] = eml_matlab_dhseqr(h,z)
%Embedded MATLAB Private Function

%    Based on:
%        -- LAPACK auxiliary routine DHSEQR (version 3.2) --

%   Copyright 2010 The MathWorks, Inc.
%#eml

if nargout == 3
    [h,info,z] = eml_dlahqr(h,z);
else
    [h,info] = eml_dlahqr(h);
end
h = triu(h,-2);

%--------------------------------------------------------------------------

function [h,info,z] = eml_dlahqr(h,z)
% SUBROUTINE DLAHQR(WANTT,WANTZ,N,ILO,IHI,H,LDH,WR,WI,ILOZ,IHIZ,Z,LDZ,INFO)
cls = class(h);
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
WANTZ = nargout == 3 && nargin == 2;
% WANTT = true;
itmax = cast(30,eml_index_class);
n = cast(size(h,1),eml_index_class);
ilo = ones(eml_index_class);
ihi = n;
ldh = cast(size(h,1),eml_index_class);
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
    % WR(ILO) = H(ILO,ILO)
    % WI(ILO) = 0
    return
end
% Allocate v.
v = eml.nullcopy(zeros(3,1,cls));
% ==== clear out the trash ====
for j = ilo:eml_index_minus(ihi,3)
    h(eml_index_plus(j,2),j) = 0;
    h(eml_index_plus(j,3),j) = 0;
end
if ilo <= eml_index_minus(ihi,2)
    h(ihi,eml_index_minus(ihi,2)) = 0;
end
nh = eml_index_plus(eml_index_minus(ihi,ilo),1);
if WANTZ
    nz = eml_index_plus(eml_index_minus(ihiz,iloz),1);
end
% Set machine-dependent constants for the stopping criterion.
SAFMIN = realmin(cls);
ULP = eps(cls);
SMLNUM = SAFMIN*(cast(nh,cls)/ULP);
DAT1 = 0.75;
DAT2 = -0.4375;
% I1 and I2 are the indices of the first row and last column of H
% to which transformations must be applied. If eigenvalues only are
% being computed,I1 and I2 are set inside the main loop.
i1 = ONE;
i2 = n;
% The main loop begins here. I is the loop index and decreases from
% IHI to ILO in steps of 1 or 2. Each iteration of the loop works
% with the active submatrix in rows and columns L to I.
% Eigenvalues I+1 to IHI have already converged. Either L = ILO or
% H(L,L-1) is negligible so that the matrix splits.
i = ihi;
while i >= ilo % 20 CONTINUE
    % Perform QR iterations on rows and columns ILO to I until a
    % submatrix of order 1 or 2 splits off at the bottom because a
    % subdiagonal element has become negligible.
    L = ilo;
    goto150 = false;
    for its = ZERO:itmax
        % Look for a single small subdiagonal element.
        k = i;
        while k > L
            if abs(h(k,eml_index_minus(k,1))) <= SMLNUM
                break
            end
            tst = abs(h(eml_index_minus(k,1),eml_index_minus(k,1))) + abs(h(k,k));
            if tst == 0
                if eml_index_minus(k,2) >= ilo
                    tst = tst + abs(h(eml_index_minus(k,1),eml_index_minus(k,2)));
                end
                if eml_index_plus(k,1) <= ihi
                    tst = tst + abs(h(eml_index_plus(k,1),k));
                end
            end
            % ==== The following is a conservative small subdiagonal
            % .    deflation criterion due to Ahues & Tisseur (LAWN 122,
            % .    1997). It has better mathematical foundation and
            % .    improves accuracy in some examples.  ====
            if abs(h(k,eml_index_minus(k,1))) <= ULP*tst
                % AB = MAX(ABS(H(K,K-1)),ABS(H(K-1,K)))
                % BA = MIN(ABS(H(K,K-1)),ABS(H(K-1,K)))
                htmp1 = abs(h(k,eml_index_minus(k,1)));
                htmp2 = abs(h(eml_index_minus(k,1),k));
                if htmp1 > htmp2
                    ab = htmp1;
                    ba = htmp2;
                else
                    ab = htmp2;
                    ba = htmp1;
                end
                % AA = MAX(ABS(H(K,K)),ABS(H(K-1,K-1)-H(K,K)))
                % BB = MIN(ABS(H(K,K)),ABS(H(K-1,K-1)-H(K,K)))
                htmp1 = abs(h(k,k));
                htmp2 = abs(h(eml_index_minus(k,1),eml_index_minus(k,1))-h(k,k));
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
        % Exit from loop if a submatrix of order 1 or 2 has split off.
        if L >= eml_index_minus(i,1)
            goto150 = true;
            break % go to 150
        end
        % Now the active submatrix is in rows and columns L to I. If
        % eigenvalues only are being computed,only the active submatrix
        % need be transformed.
        % if (~true)
        %     I1 = L
        %     I2 = I
        % end
        if its == 10
            % Exceptional shift.
            s = abs(h(eml_index_plus(L,1),L)) + ...
                abs(h(eml_index_plus(L,2),eml_index_plus(L,1)));
            h11 = DAT1*s + h(L,L);
            h12 = DAT2*s;
            h21 = s;
            h22 = h11;
        elseif its == 20
            % Exceptional shift.
            s = abs(h(i,eml_index_minus(i,1))) + ...
                abs(h(eml_index_minus(i,1),eml_index_minus(i,2)));
            h11 = DAT1*s + h(i,i);
            h12 = DAT2*s;
            h21 = s;
            h22 = h11;
        else
            % Prepare to use Francis' double shift
            % (i.e. 2nd degree generalized Rayleigh quotient)
            h11 = h(eml_index_minus(i,1),eml_index_minus(i,1));
            h21 = h(i,eml_index_minus(i,1));
            h12 = h(eml_index_minus(i,1),i);
            h22 = h(i,i);
        end
        s = abs(h11) + abs(h12) + abs(h21) + abs(h22);
        if s == 0
            rt1r = zeros(class(h));
            rt1i = zeros(class(h));
            rt2r = zeros(class(h));
            rt2i = zeros(class(h));
        else
            h11 = h11 / s;
            h21 = h21 / s;
            h12 = h12 / s;
            h22 = h22 / s;
            tr = (h11 + h22) / 2;
            det = (h11-tr)*(h22-tr) - h12*h21;
            rtdisc = sqrt(abs(det));
            if det >= 0
                % ==== complex conjugate shifts ====
                rt1r = tr*s;
                rt2r = rt1r;
                rt1i = rtdisc*s;
                rt2i = -rt1i;
            else
                % ==== real shifts (use only one of them)  ====
                rt1r = tr + rtdisc;
                rt2r = tr - rtdisc;
                if (abs(rt1r-h22) <= abs(rt2r-h22))
                    rt1r = rt1r*s;
                    rt2r = rt1r;
                else
                    rt2r = rt2r*s;
                    rt1r = rt2r;
                end
                rt1i = zeros(class(h));
                rt2i = zeros(class(h));
            end
        end
        % Look for two consecutive small subdiagonal elements.
        m = eml_index_minus(i,2);
        while m >= L
            % Determine the effect of starting the double-shift QR
            % iteration at row M,and see if this would make H(M,M-1)
            % negligible.  (The following uses scaling to avoid
            % overflows and most underflows.)
            h21s = h(eml_index_plus(m,1),m);
            s = abs(h(m,m)-rt2r) + abs(rt2i) + abs(h21s);
            h21s = h(eml_index_plus(m,1),m) / s;
            v(1) = h21s*h(m,eml_index_plus(m,1)) + ...
                (h(m,m)-rt1r)*((h(m,m)-rt2r) / s) - rt1i*(rt2i / s);
            v(2) = h21s*(h(m,m)+h(eml_index_plus(m,1),eml_index_plus(m,1))-rt1r-rt2r);
            v(3) = h21s*h(eml_index_plus(m,2),eml_index_plus(m,1));
            s = abs(v(1)) + abs(v(2)) + abs(v(3));
            v(1) = v(1) / s;
            v(2) = v(2) / s;
            v(3) = v(3) / s;
            if m == L
                break
            end
            if abs(h(m,eml_index_minus(m,1)))*(abs(v(2))+abs(v(3))) <= ...
                    ULP*abs(v(1))*(abs(h(eml_index_minus(m,1),eml_index_minus(m,1)))+ ...
                    abs(h(m,m))+abs(h(eml_index_plus(m,1),eml_index_plus(m,1))))
                break
            end
            m = eml_index_minus(m,1);
        end
        % Double-shift QR step
        for k = m:eml_index_minus(i,1)
            % The first iteration of this loop determines a reflection G
            % from the vector V and applies it from left and right to H,
            % thus creating a nonzero bulge below the subdiagonal.
            % *
            % Each subsequent iteration determines a reflection G to
            % restore the Hessenberg form in the (K-1)th column,and thus
            % chases the bulge one step toward the bottom of the active
            % submatrix. NR is the order of G.
            nr = min(cast(3,eml_index_class), ...
                eml_index_plus(eml_index_minus(i,k),1));
            if k > m
                % call dcopy(nr,h(k,eml_index_minus(k,1)),1,v,1)
                % v = eml_xcopy(nr,h, ...
                %    eml_index_plus(k,eml_index_times(ldh,eml_index_minus(k,2))), ...
                %    ONE,v,ONE,ONE);
                hoffset = eml_index_plus( ...
                    eml_index_minus(k,1), ...
                    eml_index_times(ldh,eml_index_minus(k,2)));
                for j = 1:nr
                    v(j) = h(eml_index_plus(j,hoffset));
                end   
            end
            % CALL DLARFG(NR,V(1),V(2),1,T1)
            alpha = v(1);
            [alpha,v,t1] = eml_matlab_zlarfg(nr,alpha,v,cast(2,eml_index_class),ONE);
            v(1) = alpha;
            if k > m
                h(k,eml_index_minus(k,1)) = v(1);
                h(eml_index_plus(k,1),eml_index_minus(k,1)) = 0;
                if k < eml_index_minus(i,1)
                    h(eml_index_plus(k,2),eml_index_minus(k,1)) = 0;
                end
            elseif m > L
                % ==== Use the following instead of
                % .    H(K,K-1) = -H(K,K-1) to
                % .    avoid a bug when v(2) and v(3)
                % .    underflow. ====
                h(k,eml_index_minus(k,1)) = h(k,eml_index_minus(k,1))*(1-t1);
            end
            v2 = v(2);
            t2 = t1*v2;
            if nr == 3
                v3 = v(3);
                t3 = t1*v3;
                % Apply G from the left to transform the rows of the matrix
                % in columns K to I2.
                for j = k:i2
                    sum1 = h(k,j) + v2*h(eml_index_plus(k,1),j) + v3*h(eml_index_plus(k,2),j);
                    h(k,j) = h(k,j) - sum1*t1;
                    h(eml_index_plus(k,1),j) = h(eml_index_plus(k,1),j) - sum1*t2;
                    h(eml_index_plus(k,2),j) = h(eml_index_plus(k,2),j) - sum1*t3;
                end
                % Apply G from the right to transform the columns of the
                % matrix in rows I1 to min(K+3,I).
                for j = i1:min(eml_index_plus(k,3),i)
                    sum1 = h(j,k) + v2*h(j,eml_index_plus(k,1)) + v3*h(j,eml_index_plus(k,2));
                    h(j,k) = h(j,k) - sum1*t1;
                    h(j,eml_index_plus(k,1)) = h(j,eml_index_plus(k,1)) - sum1*t2;
                    h(j,eml_index_plus(k,2)) = h(j,eml_index_plus(k,2)) - sum1*t3;
                end
                if WANTZ
                    % Accumulate transformations in the matrix Z
                    for j = iloz:ihiz
                        sum1 = z(j,k) + v2*z(j,eml_index_plus(k,1)) + v3*z(j,eml_index_plus(k,2));
                        z(j,k) = z(j,k) - sum1*t1;
                        z(j,eml_index_plus(k,1)) = z(j,eml_index_plus(k,1)) - sum1*t2;
                        z(j,eml_index_plus(k,2)) = z(j,eml_index_plus(k,2)) - sum1*t3;
                    end
                end
            elseif nr == 2
                % Apply G from the left to transform the rows of the matrix
                % in columns K to I2.
                for j = k:i2
                    sum1 = h(k,j) + v2*h(eml_index_plus(k,1),j);
                    h(k,j) = h(k,j) - sum1*t1;
                    h(eml_index_plus(k,1),j) = h(eml_index_plus(k,1),j) - sum1*t2;
                end
                % Apply G from the right to transform the columns of the
                % matrix in rows I1 to min(K+3,I).
                for j = i1:i
                    sum1 = h(j,k) + v2*h(j,eml_index_plus(k,1));
                    h(j,k) = h(j,k) - sum1*t1;
                    h(j,eml_index_plus(k,1)) = h(j,eml_index_plus(k,1)) - sum1*t2;
                end
                if WANTZ
                    % Accumulate transformations in the matrix Z
                    for j = iloz:ihiz
                        sum1 = z(j,k) + v2*z(j,eml_index_plus(k,1));
                        z(j,k) = z(j,k) - sum1*t1;
                        z(j,eml_index_plus(k,1)) = z(j,eml_index_plus(k,1)) - sum1*t2;
                    end
                end
            end
        end
    end
    if ~goto150
        % Failure to converge in remaining number of iterations
        info = i;
        return
    end
    % 150 CONTINUE
    if L == i
        % H(I,I-1) is negligible: one eigenvalue has converged.
        %          WR(I) = H(I,I)
        %          WI(I) = 0
    elseif L == eml_index_minus(i,1)
        % H(I-1,I-2) is negligible: a pair of eigenvalues have converged.
        % Transform the 2-by-2 submatrix to standard Schur form,
        % and compute and store the eigenvalues.
        % CALL DLANV2(H(I-1,I-1),H(I-1,I),H(I,I-1),H(I,I),WR(I-1),WI(I-1),WR(I),WI(I),CS,SN)
        im1 = eml_index_minus(i,1);
        [~,~,~,~,h(im1,im1),h(im1,i),h(i,im1),h(i,i),cs,sn] = ...
            eml_dlanv2(h(im1,im1),h(im1,i),h(i,im1),h(i,i));
        % Apply the transformation to the rest of H.
        if i2 > i
            % CALL DROT(I2-I,H(I-1,I+1),LDH,H(I,I+1),LDH,CS,SN)
            h = eml_xrot(eml_index_minus(i2,i), ...
                h,eml_index_plus(im1,eml_index_times(i,ldh)),ldh, ...
                [],eml_index_plus(i,eml_index_times(i,ldh)),ldh, ...
                cs,sn);
        end
        % CALL DROT(I-I1-1,H(I1,I-1),1,H(I1,I),1,CS,SN)
        h = eml_xrot(eml_index_minus(im1,i1), ...
            h,eml_index_plus(i1,eml_index_times(eml_index_minus(i,2),ldh)),ONE, ...
            [],eml_index_plus(i1,eml_index_times(im1,ldh)),ONE, ...
            cs,sn);
        if WANTZ
            % Apply the transformation to Z.
            % CALL DROT(NZ,Z(ILOZ,I-1),1,Z(ILOZ,I),1,CS,SN)
            z = eml_xrot(nz, ...
                z,eml_index_plus(iloz,eml_index_times(eml_index_minus(i,2),ldz)),ONE, ...
                [],eml_index_plus(iloz,eml_index_times(im1,ldz)),ONE, ...
                cs,sn);
        end
    end
    % return to start of the main loop with new value of I.
    i = eml_index_minus(L,1);
end % while (i >= ilo)
% 160 CONTINUE
% End of DLAHQR

%--------------------------------------------------------------------------
