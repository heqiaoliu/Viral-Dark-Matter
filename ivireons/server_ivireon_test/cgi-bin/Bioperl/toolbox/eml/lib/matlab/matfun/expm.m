function F = expm(A)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 1,'Not enough input arguments.');
eml_lib_assert(ndims(A) == 2 && size(A,1) == size(A,2), 'MATLAB:square', ...
    'Input must be a square matrix.');
if isa(A,'double')
    m_vals = [3 5 7 9 13];
    theta = [
        %3.650024139523051e-008
        %5.317232856892575e-004
        1.495585217958292e-002  % m_vals = 3
        %8.536352760102745e-002
        2.539398330063230e-001  % m_vals = 5
        %5.414660951208968e-001
        9.504178996162932e-001  % m_vals = 7
        %1.473163964234804e+000
        2.097847961257068e+000  % m_vals = 9
        %2.811644121620263e+000
        %3.602330066265032e+000
        %4.458935413036850e+000
        5.371920351148152e+000];% m_vals = 13
elseif isa(A,'single')
    m_vals = [3 5 7];
    % theta_m for m=1:7.
    theta = [
        %8.457278879935396e-004
        %8.093024012430565e-002
        4.258730016922831e-001  % m_vals = 3
        %1.049003250386875e+000
        1.880152677804762e+000  % m_vals = 5
        %2.854332750593825e+000
        3.925724783138660e+000];% m_vals = 7
else
    eml_assert(false,'Input must be single or double.')
end
F = eml.nullcopy(A);
if isempty(A)
    return
end
normA = norm(A,1);
if normA <= theta(end)
    % no scaling and squaring is required.
    for i = 1:eml_numel(m_vals)
        if normA <= theta(i)
            F = PadeApproximantOfDegree(A,m_vals(i));
            break
        end
    end
else
    [t s] = log2(eml_rdivide(normA,theta(end)));
    if t == 0.5 % adjust s if normA/theta(end) is a power of 2
        s = s - 1;
    end
    A = eml_div(A,pow2(s)); % Scaling
    F = PadeApproximantOfDegree(A,m_vals(end));
    for j = 1:s
        F = F*F;  % Squaring
    end
end

%--------------------------------------------------------------------------

function F = PadeApproximantOfDegree(A,m)
%PADEAPPROXIMANTOFDEGREE  Pade approximant to exponential.
%   F = PADEAPPROXIMANTOFDEGREE(M) is the degree M diagonal
%   Pade approximant to EXP(A), where M = 3, 5, 7, 9 or 13.
%   Series are evaluated in decreasing order of powers, which is
%   in approx. increasing order of maximum norms of the terms.
n = size(A,1);
% Constant coefficients
C31 = 120;
C32 = 60;
C33 = 12;
C51 = 30240;
C52 = 15120;
C53 = 3360;
C54 = 420;
C55 = 30;
C71 = 17297280;
C72 = 8648640;
C73 = 1995840;
C74 = 277200;
C75 = 25200;
C76 = 1512;
C77 = 56;
C91 = 17643225600;
C92 = 8821612800;
C93 = 2075673600;
C94 = 302702400;
C95 = 30270240;
C96 = 2162160;
C97 = 110880;
C98 = 3960;
C99 = 90;
C131 = 64764752532480000;
C132 = 32382376266240000;
C133 = 7771770303897600;
C134 = 1187353796428800;
C135 = 129060195264000;
C136 = 10559470521600;
C137 = 670442572800;
C138 = 33522128640;
C139 = 1323241920;
C1310 = 40840800;
C1311 = 960960;
C1312 = 16380;
C1313 = 182;
% Compute the approximation.
% A switch statement on m would be clearer, but this way we can share some
% code between the cases to do matrix powers.
A2 = A*A;
if m == 3
    U = A2;
    for k = 1:n
        U(k,k) = U(k,k) + C32;
    end
    U = A*U;
    V = C33*A2;
    d = C31;
else
    A3 = A2*A2;
    if m == 5
        U = A3 + C54*A2;
        for k = 1:n
            U(k,k) = U(k,k) + C52;
        end
        U = A*U;
        V = C55*A3 + C53*A2;
        d = C51;
    else
        A4 = A3*A2;
        if m == 7 || isa(A,'single') % Help compiler clip off unused cases.
            U = A4 + C76*A3 + C74*A2;
            for k = 1:n
                U(k,k) = U(k,k) + C72;
            end
            U = A*U;
            V = C77*A4 + C75*A3 + C73*A2;
            d = C71;
        elseif m == 9
            V = A4*A2;
            U = V + C98*A4 + C96*A3 + C94*A2;
            for k = 1:n
                U(k,k) = U(k,k) + C92;
            end
            U = A*U;
            V = C99*V + C97*A4 + C95*A3 + C93*A2;
            d = C91;
        else % m == 13
            U = C138*A4 + C136*A3 + C134*A2;
            for k = 1:n
                U(k,k) = U(k,k) + C132;
            end
            U = A*(A4*(A4 + C1312*A3 + C1310*A2) + U);
            V = A4*(C1313*A4 + C1311*A3 + C139*A2) + C137*A4 + C135*A3 + C133*A2;
            d = C131;
        end
    end
end
for k = 1:n
    V(k,k) = V(k,k) + d;
end
for k = 1:numel(U)
    uk = U(k);
    U(k) = V(k) - uk;
    V(k) = V(k) + uk;
end
F = U \ V;

%--------------------------------------------------------------------------
