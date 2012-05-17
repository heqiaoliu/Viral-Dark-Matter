function [info,alpha1,beta1,A,B,Z] = eml_matlab_zhgeqz(A,B,ilo,ihi,Z)
%Embedded MATLAB Private Function

% ZHGEQZ implements a single-shift version of the QZ
% method for finding the generalized eigenvalues w(i)=ALPHA(i)/BETA(i)
% of the equation det(A - Z(:,i) B) = 0.  If eigenvectors are not needed,
% Z should be an empty matrix on input.
% INFO (output) INTEGER
%   = 0: successful exit
%   = 1,...,N:  the QZ iteration did not converge.  (A,B) is not
%               in Schur form, but ALPHA(i) and BETA(i),
%               i=INFO+1,...,N should be correct.
%   < 0:        an "impossible" error occurred.
% eml_must_inline;

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

info = 0;
IONE = ones(eml_index_class);
IZERO = zeros(eml_index_class);
compz = nargin == 5 && ~isempty(Z);
isgen = ~(eml_is_const(size(B)) && isempty(B));
% Allocate alpha1 and beta1.
n = cast(size(A,1),eml_index_class);
alpha1 = complex(zeros(n,1,class(A)));
beta1 = complex(ones(n,1,class(A)));
ULP = eps(class(A));
SAFMIN = realmin(class(A));
% Miscellaneous scalar initializations needed to set correct types.
eshift = complex(zeros(class(A)));
ctemp = complex(zeros(class(A)));
rho = complex(zeros(class(A)));
anorm = eml_matlab_zlanhs(A,ilo,ihi);
atol = max2(SAFMIN,ULP*anorm);
ascale = eml_rdivide(1,max2(SAFMIN,anorm));
if isgen
    bnorm = eml_matlab_zlanhs(B,ilo,ihi);
    btol = max2(SAFMIN,ULP*bnorm);
    %     bscale = 1 / max2(SAFMIN,bnorm);
else
    btol = zeros(class(B)); % Dummy initialisation.
    %     bscale = cast(1/sqrt(double(n)),class(A));
end
failed = true;
% Set eigenvalues ihi+1:n
for j = eml_index_plus(ihi,IONE) : n
    if isgen
        absb = abs(B(j,j));
        if absb > SAFMIN
            signbc = conj(eml_div(B(j,j),absb));
            B(j,j) = absb;
            if compz
                for k = IONE : eml_index_minus(j,IONE)
                    B(k,j) = B(k,j)*signbc;
                end
                for k = IONE : j
                    A(k,j) = A(k,j)*signbc;
                end
                for k = IONE : n
                    Z(k,j) = Z(k,j)*signbc;
                end
            else
                A(j,j) = A(j,j)*signbc;
            end
        else
            B(j,j) = 0;
        end
        beta1(j) = B(j,j);
    end
    alpha1(j) = A(j,j);
end
% if ihi < ilo,skip QZ steps
if ihi >= ilo
    % MAIN QZ ITERATION LOOP
    % Initialize dynamic indices
    % Eigenvalues ILAST+1:N have been found.
    % Column operations modify rows IFRSTM:whatever
    % Row operations modify columns whatever:ILASTM
    % If only eigenvalues are being computed, then
    % IFRSTM is the row of the last splitting row above row ILAST;
    % this is always at least ILO.
    % IITER counts iterations since the last eigenvalue was found,
    % to tell when to use an extraordinary shift.
    % MAXIT is the maximum number of QZ sweeps allowed.
    ifirst = ilo; % Just to set the correct type.
    istart = ilo; % Just to set the correct type.
    ilast = ihi;
    ilastm1 = eml_index_minus(ilast,IONE);
    if compz
        ifrstm = IONE;
        ilastm = n;
    else
        ifrstm = ilo;
        ilastm = ihi;
    end
    iiter = IZERO;
    maxit = eml_index_times(30,eml_index_plus(eml_index_minus(ihi,ilo),IONE)); % 30*(ihi-ilo+1);
    % We reluctantly retain the organization of ZHGEQZ but emulate the
    % goto's through the use of break, continue, and auxiliary variables.
    % The virtue of this approach is that it facilitates maintenance by
    % via direct comparison to the FORTRAN version.
    goto50 = false;
    goto60 = false;
    goto70 = false;
    goto90 = false;
    for jiter = IONE : maxit
        % Split the matrix if possible.
        % Two tests:
        % 1: A(j,j-1)=0  or  j=ilo
        % 2: B(j,j)=0
        % Special case: j=ilast
        if ilast == ilo
            goto60 = true;
        elseif abs1(A(ilast,ilastm1)) <= atol
            A(ilast,ilastm1) = 0;
            goto60 = true;
        elseif isgen && abs(B(ilast,ilast)) <= btol
            B(ilast,ilast) = 0;
            goto50 = true;
        else
            % General case: j<ilast
            j = ilastm1;
            jp1 = eml_index_plus(j,IONE);
            while j >= ilo % for j = ilast-1 : -1 : ilo
                jm1 = eml_index_minus(j,IONE);
                % test 1: for A(j,j-1)=0 or j=ilo
                if j == ilo
                    ilazro = true;
                elseif abs1(A(j,jm1)) <= atol
                    A(j,jm1) = 0;
                    ilazro = true;
                else
                    ilazro = false;
                end
                % Test 2: for B(j,j)=0
                if isgen && abs(B(j,j)) < btol
                    B(j,j) = 0;
                    % Test 1a: check for 2 consecutive small subdiagonals in A
                    ilazr2 = ~ilazro && (abs1(A(j,jm1))*(ascale*abs1(A(jp1,j))) ...
                        <= abs1(A(j,j))*(ascale*atol));
                    % If both tests pass (1 & 2), i.e., the leading diagonal
                    % element of b in the block is zero,split a 1x1 block
                    % off at the top. (i.e., at the j-th row/column) the leading
                    % diagonal element of the remainder can also be zero, so
                    % this may have to be done repeatedly.
                    if ilazro || ilazr2
                        jch = j;
                        jchm1 = eml_index_minus(jch,IONE);
                        while jch < ilast % for jch = j : ilast-1
                            jchp1 = eml_index_plus(jch,IONE);
                            [c,s,A(jch,jch)] = eml_matlab_zlartg(A(jch,jch),A(jchp1,jch));
                            A(jchp1,jch) = 0;
                            A = eml_zrot_rows(A,c,s,jch,jchp1,jch,ilastm);
                            B = eml_zrot_rows(B,c,s,jch,jchp1,jch,ilastm);
                            if ilazr2
                                A(jch,jchm1) = A(jch,jchm1)*c;
                            end
                            ilazr2 = false;
                            if abs1(B(jchp1,jchp1)) >= btol
                                if jchp1 >= ilast
                                    goto60 = true;
                                else
                                    ifirst = jchp1;
                                    goto70 = true;
                                end
                                break % for jch = j : ilast-1
                            end
                            B(jchp1,jchp1) = 0;
                            jchm1 = jch;
                            jch = jchp1;
                        end
                        if ~(goto60 || goto70)
                            goto50 = true;
                        end % for jch = j : ilast-1
                        break % for j = ilast-1 : -1 : ilo
                    else
                        % Only test 2 passed -- chase the zero to B(ilast,ilast)
                        % then process as in the case B(ilast,ilast)=0
                        jch = j;
                        jchm1 = eml_index_minus(jch,IONE);
                        while jch < ilast % for jch = j : ilast-1
                            jchp1 = eml_index_plus(jch,IONE);
                            [c,s,B(jch,jchp1)] = eml_matlab_zlartg(B(jch,jchp1),B(jchp1,jchp1));
                            B(jchp1,jchp1) = 0;
                            if jch < eml_index_minus(ilastm,IONE);
                                B = eml_zrot_rows(B,c,s,jch,jchp1,eml_index_plus(jchp1,IONE),ilastm);
                            end
                            A = eml_zrot_rows(A,c,s,jch,jchp1,jchm1,ilastm);
                            [c,s,A(jchp1,jch)] = eml_matlab_zlartg(A(jchp1,jch),A(jchp1,jchm1));
                            A(jchp1,jchm1) = 0;
                            A = eml_zrot_cols(A,c,s,jch,jchm1,ifrstm,jch);
                            B = eml_zrot_cols(B,c,s,jch,jchm1,ifrstm,jchm1);
                            if compz
                                Z = eml_zrot_cols(Z,c,s,jch,jchm1,IONE,n);
                            end
                            jchm1 = jch;
                            jch = jchp1;
                        end
                        goto50 = true;
                        break % for j = ilast-1 : -1 : ilo
                    end
                elseif ilazro
                    % Only test 1 passed -- work on j:ilast
                    ifirst = j;
                    goto70 = true;
                    break % for j = ilast-1 : -1 : ilo
                end
                % Neither test passed -- try next j
                jp1 = j;
                j = jm1;
            end % for j = ilast-1 : -1 : ilo
        end
        if ~(goto50 || goto60 || goto70)
            % (drop-through is "impossible")
            alpha1(:) = eml_guarded_nan;
            beta1(:) = eml_guarded_nan;
            if compz
                Z(:) = eml_guarded_nan;
            end
            info = -1;
            return
        end
        % B(ilast,ilast)=0.  Clear A(ilast,ilast-1) to split off a 1x1 block.
        if goto50
            goto50 = false;
            [c,s,A(ilast,ilast)] = eml_matlab_zlartg(A(ilast,ilast),A(ilast,ilastm1));
            A(ilast,ilastm1) = 0;
            A = eml_zrot_cols(A,c,s,ilast,ilastm1,ifrstm,ilastm1);
            if isgen
                B = eml_zrot_cols(B,c,s,ilast,ilastm1,ifrstm,ilastm1);
            end
            if compz
                Z = eml_zrot_cols(Z,c,s,ilast,ilastm1,IONE,n);
            end
            goto60 = true;
        end
        if goto60
            goto60 = false;
            if isgen
                % A(ilast,ilast-1)=0.  Standardize b, set alpha1 and beta1
                absb = abs(B(ilast,ilast));
                if absb > SAFMIN
                    signbc = conj(eml_div(B(ilast,ilast),absb));
                    B(ilast,ilast) = absb;
                    if compz
                        for k = ifrstm : ilastm1
                            B(k,ilast) = B(k,ilast)*signbc;
                        end
                        for k = ifrstm : ilastm
                            A(k,ilast) = A(k,ilast)*signbc;
                        end
                        for k = IONE : n
                            Z(k,ilast) = Z(k,ilast)*signbc;
                        end
                    else
                        A(ilast,ilast) = A(ilast,ilast)*signbc;
                    end
                else
                    B(ilast,ilast) = 0;
                end
                beta1(ilast) = B(ilast,ilast);
            end
            alpha1(ilast) = A(ilast,ilast);
            % Goto next block -- exit if finished.
            ilast = ilastm1;
            ilastm1 = eml_index_minus(ilast,IONE);
            if ilast < ilo
                failed = false;
                break
            end
            % Reset counters
            iiter = IZERO;
            eshift = complex(zeros(class(A)));
            if ~compz
                ilastm = ilast;
                if ifrstm > ilast
                    ifrstm = ilo;
                end
            end
            continue % goto 160
        end
        if goto70
            goto70 = false;
            % QZ step
            % This iteration only involves rows/columns ifirst:ilast.  We
            % assume ifirst < ilast,and that the diagonal of b is non-zero.
            iiter = eml_index_plus(iiter,IONE);
            if ~compz
                ifrstm = ifirst;
            end
            % Compute the shift.
            % At this point,ifirst < ilast,and the diagonal elements of
            % B(ifirst:ilast,ifirst,ilast) are larger than btol (in
            % magnitude)
            if isgen
                if mod(iiter,cast(10,eml_index_class)) ~= 0
                    % sigma = eigenvalues of lower 2x2 A - lambda*B
                    % rho = A(1,1) - (sigma closest to A(2,2)/B(2,2))*B(1,1)
                    % [rho; A(2,1)] is the initial vector for implicit 2-by-2 QZ.
                    % Form (A - r1*B)/diag(B) and B/diag(B) where r1 = A(1,1)/B(1,1)
                    r1 = eml_div(A(ilastm1,ilastm1),B(ilastm1,ilastm1));
                    r2 = eml_div(A(ilast,ilast),B(ilast,ilast));
                    a12 = eml_div(A(ilastm1,ilast)-r1*B(ilastm1,ilast),B(ilast,ilast));
                    a21 = eml_div(A(ilast,ilastm1),B(ilastm1,ilastm1));
                    a22 = r2 - r1;
                    b12 = eml_div(B(ilastm1,ilast),B(ilast,ilast));
                    t1 = eml_div(a21*b12 - a22,2);
                    d = sqrt(t1*t1 + a12*a21);
                    % Solve quadratic equation without destructive roundoff
                    % or under/overflow.
                    sigma1 = r1 - (t1-d);
                    sigma2 = r1 - (t1+d);
                    % Choose eigenvalue closest to r2.
                    % Compute rho without subtracting r1 from sigma.
                    if abs(sigma1 - r2) <= abs(sigma2 - r2)
                        shift = sigma1;
                        rho = B(ilastm1,ilastm1)*(t1-d);
                    else
                        shift = sigma2;
                        rho = B(ilastm1,ilastm1)*(t1+d);
                    end
                else
                    % Exceptional shift.
                    eshift = eshift + eml_div(A(ilast,ilastm1),B(ilastm1,ilastm1));
                    shift = eshift;
                end
            else
                if mod(iiter,10) ~= 0
                    r1 = A(ilastm1,ilastm1);
                    r2 = A(ilast,ilast);
                    a12 = A(ilastm1,ilast);
                    a21 = A(ilast,ilastm1);
                    a22 = r2 - r1;
                    t1 = eml_div(-a22,2);
                    d = sqrt(t1*t1 + a12*a21);
                    % Solve quadratic equation without destructive roundoff
                    % or under/overflow.
                    sigma1 = r1 - (t1-d);
                    sigma2 = r1 - (t1+d);
                    % Choose eigenvalue closest to r2.
                    % Compute rho without subtracting r1 from sigma.
                    if abs(sigma1 - r2) <= abs(sigma2 - r2)
                        shift = sigma1;
                        rho = t1 - d;
                    else
                        shift = sigma2;
                        rho = t1 + d;
                    end
                else
                    % Exceptional shift.
                    eshift = eshift + A(ilast,ilastm1);
                    shift = eshift;
                end
            end
            % Now check for two consecutive small subdiagonals.
            j = ilastm1;
            jp1 = eml_index_plus(j,IONE);
            while j > ifirst % for j = ilast-1 : -1 : ifirst+1
                jm1 = eml_index_minus(j,IONE);
                istart = j;
                if isgen
                    ctemp = A(j,j) - shift*B(j,j);
                else
                    ctemp = A(j,j) - shift;
                end
                temp = ascale*abs1(ctemp);
                temp2 = ascale*abs1(A(jp1,j));
                tempr = max2(temp,temp2);
                if (tempr < 1) && (tempr ~= 0)
                    temp = eml_rdivide(temp,tempr);
                    temp2 = eml_rdivide(temp2,tempr);
                end
                if (abs1(A(j,jm1))*temp2 <= temp*atol)
                    goto90 = true;
                    break
                end
                jp1 = j;
                j = jm1;
            end
            if ~goto90
                istart = ifirst;
                if istart == ilastm1
                    ctemp = rho;
                else
                    if isgen
                        ctemp = A(istart,istart) - shift*B(istart,istart);
                    else
                        ctemp = A(istart,istart) - shift;
                    end
                end
                goto90 = true;
            end
        end
        if goto90
            goto90 = false;
            % Do an implicit-shift QZ sweep.
            ctemp2 = A(eml_index_plus(istart,IONE),istart);
            [c,s] = eml_matlab_zlartg(ctemp,ctemp2);
            % Sweep
            j = istart;
            jm1 = eml_index_minus(j,IONE);
            while j < ilast % for j = istart : ilast-1
                jp1 = eml_index_plus(j,IONE);
                if j > istart
                    [c,s,A(j,jm1)] = eml_matlab_zlartg(A(j,jm1),A(jp1,jm1));
                    A(jp1,jm1) = 0;
                end
                A = eml_zrot_rows(A,c,s,j,jp1,j,ilastm);
                if isgen
                    B = eml_zrot_rows(B,c,s,j,jp1,j,ilastm);
                    [c,s,B(jp1,jp1)] = eml_matlab_zlartg(B(jp1,jp1),B(jp1,j));
                    B(jp1,j) = 0;
                    B = eml_zrot_cols(B,c,s,jp1,j,ifrstm,j);
                else
                    s = -s;
                end
                A = eml_zrot_cols(A,c,s,jp1,j,ifrstm,min2(eml_index_plus(jp1,IONE),ilast));
                if compz
                    Z = eml_zrot_cols(Z,c,s,jp1,j,IONE,n);
                end
                jm1 = j;
                j = jp1;
            end
        end
        % 160 continue
    end
    if failed
        % Non-convergence
        info = cast(ilast,class(info));
        % Eigenvalues ilast+1:n should be correct.  Make the others NaN.
        for k = IONE : ilast
            alpha1(k) = eml_guarded_nan;
            beta1(k) = eml_guarded_nan;
        end
        if compz
            Z(:) = eml_guarded_nan;
        end
        return
    end
end
% 190 continue
% Set eigenvalues 1:ilo-1
for j = IONE : eml_index_minus(ilo,IONE)
    if isgen
        absb = abs(B(j,j));
        if absb > SAFMIN
            signbc = conj(eml_div(B(j,j),absb));
            B(j,j) = absb;
            if compz
                for k = IONE : eml_index_minus(j,IONE)
                    B(k,j) = B(k,j)*signbc;
                end
                for k = IONE : j
                    A(k,j) = A(k,j)*signbc;
                end
            else
                A(j,j) = A(j,j)*signbc;
            end
            if compz
                for k = IONE : n
                    Z(k,j) = Z(k,j)*signbc;
                end
            end
        else
            B(j,j) = 0;
        end
        beta1(j) = B(j,j);
    end
    alpha1(j) = A(j,j);
end
% Normal termination
info = 0;

%--------------------------------------------------------------------------

function x = max2(x,y)
eml_must_inline;
% Simple maximum of 2 elements.  Output class is class(x).
if y > x
    x = cast(y,class(x));
end

%--------------------------------------------------------------------------

function x = min2(x,y)
eml_must_inline;
% Simple minimum of 2 elements.  Output class is class(x).
if y < x
    x = cast(y,class(x));
end

%--------------------------------------------------------------------------

function y = abs1(x)
eml_must_inline;
y = abs(real(x)) + abs(imag(x));

%--------------------------------------------------------------------------
