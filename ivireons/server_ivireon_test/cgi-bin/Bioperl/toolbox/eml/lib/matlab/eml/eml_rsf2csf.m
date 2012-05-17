function [T,U] = eml_rsf2csf(Tr,Ur)
%Embedded MATLAB Private Function

%   This implements the RSF2CSF algorithm.  The arguments are reversed here
%   because this function supports nargin == 1 (with nargout == 1, of
%   course).

%   Copyright 1984-2010 The MathWorks, Inc.
%#eml

% Find complex unitary similarities to zero subdiagonal elements.
T = complex(Tr);
% Inputs should be 2-D square matrices of the same size, but defining n to
% be the minimum of all dimensions makes this safe without array bounds
% checking even if the inputs are not valid.
if nargin == 2
    U = complex(Ur);
    n = cast(min(min(size(Tr)),min(size(Ur))),eml_index_class);
else
    n = cast(min(size(Tr)),eml_index_class);
end
if n == 0
    return
end
m = n;
while m >= cast(2,eml_index_class);
    mm1 = eml_index_minus(m,1);
    % We are honouring the deflation from SCHUR. It may not work correctly if
    % the input is not an output of SCHUR.
    if Tr(m,mm1) ~= 0
        [rt1r,rt1i] = ...
            eml_dlanv2(Tr(mm1,mm1),Tr(mm1,m),Tr(m,mm1),Tr(m,m));
        mu1 = complex(rt1r-Tr(m,m),rt1i);
        r = hypot(mu1,Tr(m,mm1));
        c = mu1/r;
        s = Tr(m,mm1)/r;
        % G = [c' s; -s c];
        % G  =  c'  s
        %      -s   c
        % T(mm1:m,mm1:n) = G*T(m-1:m,m-1:n);
        for j = mm1:n
            t1 = T(mm1,j);
            T(mm1,j) = eml_conjtimes(c,t1) + s*T(m,j);
            T(m,j) = c*T(m,j) - s*t1;
        end
        % G' =  c  -s'
        %       s'  c'
        % T(1:m,mm1:m) = T(1:m,m-1:m)*G';
        for i = 1:m
            t1 = T(i,mm1);
            T(i,mm1) = c*t1 + eml_conjtimes(s,T(i,m));
            T(i,m) = eml_conjtimes(c,T(i,m)) - eml_conjtimes(s,t1);
        end
        if nargin == 2
            % U(:,mm1:m) = U(:,m-1:m)*G';
            for i = 1:n
                t1 = U(i,mm1);
                U(i,mm1) = c*t1 + eml_conjtimes(s,U(i,m));
                U(i,m) = eml_conjtimes(c,U(i,m)) - eml_conjtimes(s,t1);
            end
        end
        T(m,mm1) = 0;
    end
    m = mm1;
end
