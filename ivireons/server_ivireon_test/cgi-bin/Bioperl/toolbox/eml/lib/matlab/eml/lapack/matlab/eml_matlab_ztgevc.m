function V = eml_matlab_ztgevc(A,B,V)
%Embedded MATLAB Private Function

%    ZTGEVC computes some or all of the right and/or left generalized
%    eigenvectors of a pair of complex upper triangular matrices (A,B).
%    eml_must_inline;

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

isgen = ~(eml_is_const(size(B)) && isempty(B));
n = size(A,1);
work1 = complex(zeros(n,1,class(V)));
work2 = complex(zeros(n,1,class(V)));
% Machine constants.
ULP = eps(class(V));
SAFMIN = realmin(class(V));
SMALL = eml_rdivide(SAFMIN*n,ULP);
BIG = eml_rdivide(1,SMALL);
BIGNUM = eml_rdivide(1,SAFMIN*n);
% Compute the 1-norm of each column of the strictly upper triangular
% part of A and B to check for possible overflow in the triangular solver.
rworka = zeros(n,1,class(V));
anorm = abs1(A(1,1));
for j = 2 : n
    for i = 1 : j-1
        rworka(j) = rworka(j) + abs1(A(i,j));
    end
    anorm = max2(anorm,rworka(j)+abs1(A(j,j)));
end
ascale = eml_rdivide(1,max2(anorm,SAFMIN));
if isgen
    rworkb = zeros(n,1,class(V));
    bnorm = abs1(B(1,1));
    for j = 2 : n
        for i = 1 : j-1
            rworkb(j) = rworkb(j) + abs1(B(i,j));
        end
        bnorm = max2(bnorm,rworkb(j)+abs1(B(j,j)));
    end
    bscale = eml_rdivide(1,max2(bnorm,SAFMIN));
else
    bnorm = 1;
    bscale = 1;
end
% ieig = n + 1;
% Main loop over eigenvalues
for je = n : -1 : 1
    %   ieig = ieig - 1;
    ieig = je;
    if isgen && abs1(A(je,je)) <= SAFMIN && abs(real(B(je,je))) <= SAFMIN
        % Singular matrix pencil -- return unit eigenvector
        for jr = 1 : n
            V(jr,ieig) = 0;
        end
        V(ieig,ieig) = 1;
        continue
    end
    % Non-singular eigenvalue:
    % Compute coefficients  a  and  b  in
    % (a A - b B) x  = 0
    if isgen
        temp = eml_rdivide(1,max3(abs1(A(je,je))*ascale,abs(real(B(je,je)))*bscale,SAFMIN));
        sbeta = (temp*real(B(je,je)))*bscale;
    else
        temp = eml_rdivide(1,max2(abs1(A(je,je))*ascale,1));
        sbeta = temp;
    end
    salpha = (temp*A(je,je))*ascale;
    acoeff = sbeta*ascale;
    bcoeff = salpha*bscale;
    % Scale to avoid underflow
    lscalea = (abs(sbeta) >= SAFMIN) && (abs(acoeff) < SMALL);
    lscaleb = (abs1(salpha) >= SAFMIN) && (abs1(bcoeff) < SMALL);
    scale = ones(class(V));
    if lscalea
        scale = eml_rdivide(SMALL,abs(sbeta))*min2(anorm,BIG);
    end
    if lscaleb
        scale = max2(scale,eml_rdivide(SMALL,abs1(salpha))*min2(bnorm,BIG));
    end
    if lscalea || lscaleb
        scale = min2(scale,eml_rdivide(1,SAFMIN*max3(abs(acoeff),1,abs1(bcoeff))));
        if lscalea
            acoeff = ascale*(scale*sbeta);
        else
            acoeff = scale*acoeff;
        end
        if lscaleb
            bcoeff = bscale*(scale*salpha);
        else
            bcoeff = scale*bcoeff;
        end
    end
    acoefa = abs(acoeff);
    bcoefa = abs1(bcoeff);
    for jr = 1 : n
        work1(jr) = 0;
    end
    work1(je) = 1;
    dmin = max3(ULP*acoefa*anorm,ULP*bcoefa*bnorm,SAFMIN);
    % Triangular solve of  (a A - b B) x = 0  (columnwise)
    % WORK(1:j-1) contains sums w,
    % WORK(j+1:JE) contains x
    for jr = 1:je-1
        if isgen
            work1(jr) = acoeff*A(jr,je) - bcoeff*B(jr,je);
        else
            work1(jr) = acoeff*A(jr,je);
        end
    end
    work1(je) = 1;
    for j = je-1 : -1 : 1
        if isgen
            d = acoeff*A(j,j) - bcoeff*B(j,j);
        else
            d = acoeff*A(j,j) - bcoeff;
        end
        if abs1(d) <= dmin
            d = dmin;
        end
        if abs1(d) < 1
            if abs1(work1(j)) >= BIGNUM*abs1(d)
                temp = eml_rdivide(1,abs1(work1(j)));
                for jr = 1 : je
                    work1(jr) = temp*work1(jr);
                end
            end
        end
        work1(j) = -work1(j)/d;
        if j > 1
            if isgen
                % w = w + x(j)*(a A(*,j) - b B(*,j)) with scaling
                if abs1(work1(j)) > 1
                    temp = eml_rdivide(1,abs1(work1(j)));
                    if acoefa*rworka(j) + bcoefa*rworkb(j) >= BIGNUM*temp
                        for jr = 1 : je
                            work1(jr) = temp*work1(jr);
                        end
                    end
                end
                ca = acoeff*work1(j);
                cb = bcoeff*work1(j);
                for jr = 1 : j-1
                    work1(jr) = work1(jr) + ca*A(jr,j) - cb*B(jr,j);
                end
            else
                % w = w + x(j)*(a A(*,j) with scaling
                if abs1(work1(j)) > 1
                    temp = eml_rdivide(1,abs1(work1(j)));
                    if acoefa*rworka(j) >= BIGNUM*temp
                        for jr = 1 : je
                            work1(jr) = temp*work1(jr);
                        end
                    end
                end
                ca = acoeff*work1(j);
                for jr = 1 : j-1
                    work1(jr) = work1(jr) + ca*A(jr,j);
                end
            end
        end
    end
    % Back transform eigenvector if HOWMNY='B'.
    % work2 = V(1:n,1:je)*work1(1:je)
    for jr = 1 : n
        work2(jr) = 0;
    end
    for jc = 1 : je
        for jr = 1 : n
            work2(jr) = work2(jr) + V(jr,jc)*work1(jc);
        end
    end
    % Copy and scale eigenvector into column of V
    xmx = abs1(work2(1));
    if n > 1
        for jr = 2 : n
            xmx = max2(xmx,abs1(work2(jr)));
        end
    end
    if xmx > SAFMIN
        temp = eml_rdivide(1,xmx);
        for jr = 1 : n
            V(jr,ieig) = temp*work2(jr);
        end
    else
        for jr = 1 : n
            V(jr,ieig) = 0;
        end
    end
end

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

function x = max3(x,y,z)
eml_must_inline;
% Simple maximum of 3 elements.  Output class is class(x).
if y > x
    x = cast(y,class(x));
end
if z > x
    x = cast(z,class(x));
end

%--------------------------------------------------------------------------

function y = abs1(x)
eml_must_inline;
y = abs(real(x)) + abs(imag(x));

%--------------------------------------------------------------------------
