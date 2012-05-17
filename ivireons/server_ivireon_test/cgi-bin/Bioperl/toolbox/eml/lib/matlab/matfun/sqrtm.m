function [X,arg2,condest] = sqrtm(A) %#eml
%Embedded MATLAB Library Function

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ...
    ['Function ''sqrtm'' is not defined for values of class ''' class(A) '''.']);
eml_lib_assert(ndims(A) == 2 && size(A,1) == size(A,2), ...
    'MATLAB:square', ...
    'Matrix must be square.');
[Q,T] = schur(A,'complex');  % T is complex Schur form.
n = cast(size(A,1),eml_index_class);
R = eml_expand(eml_scalar_eg(T),size(T));
if isUTmatD(T) % Check if T is diagonal.
    % Square root always exists.
    for j = 1:n
        R(j,j) = sqrt(T(j,j));
    end
else
    % Compute upper triangular square root R of T, a column at a time.
    for j = 1:n
        R(j,j) = sqrt(T(j,j));
        % Changing branches in some cases improves accuracy and
        % reliability, but the resulting square root would not be the
        % principal one.
        % if imag(R(j,j)) < 0 && real(T(j,j)) < 0
        %     R(j,j) = -R(j,j);
        % end
        for i = eml_index_minus(j,1):-1:1
            s = eml_scalar_eg(R);
            for k = eml_index_plus(i,1):eml_index_minus(j,1)
                s = s + R(i,k)*R(k,j);
            end
            R(i,j) = (T(i,j) - s) / (R(i,i) + R(j,j));
        end
    end
end
X = Q*R*Q';
if nargout ~= 2
    % Calculate: nzeig = any(diag(T)==0);
    nzeig = false;
    for k = 1:n
        if T(k,k) == 0
            nzeig = true;
            eml_warning('MATLAB:sqrtm:SingularMatrix', ...
                'Matrix is singular and may not have a square root.');
            break
        end
    end
    check_for_cancellation(R);
end
if nargout == 1
elseif nargout == 2
    arg2 = norm(X*X-A,'fro') / norm(A,'fro');
elseif nargout == 3
    arg2 = norm(R,'fro')^2 / norm(T,'fro');
    if nzeig
        condest = eml_guarded_inf(class(A));
    else
        % Power method to get condition number estimate.
        tol = 1e-2;
        x = complex(ones(n*n,1,class(A)));    % Starting vector.
        cnt = ones(eml_index_class);
        e = ones(class(A));
        e0 = zeros(class(A));
        while abs(e-e0) > tol*e && cnt <= 6
            x = x/norm(x);
            x0 = x;
            e0 = e;
            Sx = tksolve(R,x);
            x = tksolveT(R,Sx);
            e = sqrt(real(dot(x0,x)));  % sqrt of Rayleigh quotient.
            cnt = eml_index_plus(cnt,1);
        end
        condest = e*norm(A,'fro')/norm(X,'fro');
    end
end
% As in FUNM:
if isreal(A) && norm(imag(X),1) <= 10*cast(n,class(X))*eps*norm(X,1)
    % Zero the imaginary parts.
    for j = 1:n
        for i = 1:n
            X(i,j) = real(X(i,j));
        end
    end
end

%--------------------------------------------------------------------------

function x = tksolve(R,b)
%TKSOLVE     Solves block triangular Kronecker system.
%            x = TKSOLVE(R, b) solves
%                  A*x = b
%            where A = KRON(EYE,R) + KRON(TRANSPOSE(R),EYE).
n = cast(size(R,1),eml_index_class);
x = eml.nullcopy(eml_expand(eml_scalar_eg(R,b),[eml_index_times(n,n),1]));
temp = eml.nullcopy(eml_expand(eml_scalar_eg(R,b),[n,1]));
% Forward substitution.
for i = 1:n
    i0 = eml_index_times(eml_index_minus(i,1),n);
    for j = 1:n
        temp(j) = b(eml_index_plus(i0,j));
    end
    for j = 1:eml_index_minus(i,1)
        j0 = eml_index_times(eml_index_minus(j,1),n);
        for k = 1:n
            temp(k) = temp(k) - R(j,i)*x(eml_index_plus(j0,k));
        end
    end
    Rtemp = R;
    for j = 1:n
        Rtemp(j,j) = Rtemp(j,j) + R(i,i);
    end
    temp = linsolve(Rtemp,temp,struct('UT',true));
    for j = 1:n
        x(eml_index_plus(i0,j)) = temp(j);
    end
end

%--------------------------------------------------------------------------

function x = tksolveT(R,b)
%TKSOLVE     Solves block triangular Kronecker system.
%            x = TKSOLVET(R,b) solves
%                 A'*x = b
%            where A = KRON(EYE,R) + KRON(TRANSPOSE(R),EYE).
n = cast(size(R,1),eml_index_class);
x = eml.nullcopy(eml_expand(eml_scalar_eg(R,b),[eml_index_times(n,n),1]));
temp = eml.nullcopy(eml_expand(eml_scalar_eg(R,b),[n,1]));
% Back substitution.
for i = n:-1:1
    i0 = eml_index_times(eml_index_minus(i,1),n);
    for j = 1:n
        temp(j) = b(eml_index_plus(i0,j));
    end
    for j = eml_index_plus(i,1):n
        j0 = eml_index_times(eml_index_minus(j,1),n);
        for k = 1:n
            temp(k) = temp(k) - conj(R(i,j))*x(eml_index_plus(j0,k));
        end
    end
    Rtemp = R';
    for j = 1:n
        Rtemp(j,j) = Rtemp(j,j) + conj(R(i,i));
    end
    temp = linsolve(Rtemp,temp,struct('LT',true));
    for j = 1:n
        x(eml_index_plus(i0,j)) = temp(j);
    end
end

%--------------------------------------------------------------------------

function p = isUTmatD(T)
% Returns true if upper triangular matrix T is diagonal, false otherwise.
n = cast(size(T,2),eml_index_class);
for j = 1:n
    for i = 1:eml_index_minus(j,1);
        if T(i,j) ~= 0
            p = false;
            return
        end
    end
end
p = true;

%--------------------------------------------------------------------------

function y = abs1(x)
y = abs(real(x)) + abs(imag(x));

%--------------------------------------------------------------------------

function check_for_cancellation(R)
% Warn if there is substantial cancellation of principal square roots of
% eigenvalues.
n = cast(size(R,2),eml_index_class);
for j = 1:eml_index_minus(n,1)
    for i = eml_index_plus(j,1):n
        if abs1(R(i,i)+R(j,j)) <=  ...
                10*sqrt(eps(class(R)))*(abs1(R(i,i))+abs1(R(j,j)))
            eml_warning( ...
                'EmbeddedMATLAB:sqrtm:rootEigenCancel', ...
                ['The principal square roots of two or more ', ...
                'eigenvalues approximately cancel. ', ...
                'The results may be inaccurate.']);
            return
        end
    end
end

%--------------------------------------------------------------------------
