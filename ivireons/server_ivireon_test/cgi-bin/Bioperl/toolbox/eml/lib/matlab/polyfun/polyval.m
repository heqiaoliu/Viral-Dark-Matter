function [y,delta] = polyval(p,x,S,mu)
%Embedded MATLAB Library Function

%   Limitations:
%   Matrix S input from previous versions of POLYFIT is not supported.

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
eml_lib_assert(isvector(p), ...
    'MATLAB:polyval:InvalidP', ...
    'P must be a vector.');
eml_assert(isa(p,'float'), ...
    ['Function ''polyval'' is not defined for values of class ''' class(p) '''.']);
eml_assert(isa(x,'float'), ...
    ['Function ''polyval'' is not defined for values of class ''' class(x) '''.']);
if nargin == 4
    eml_lib_assert(isa(mu,'float') && eml_numel(mu) >= 2, ...
        'EmbeddedMATLAB:polyval:invalidMu', ...
        'MU must be a float array with at least two elements.');
    if isa(x,'double') && isa(mu,'single')
        % Must convert x to single.
        [y,delta] = polyval(p,single(x),S,mu);
        return
    end
    if isreal(x) && ~isreal(mu)
        % Must make x complex.
        [y,delta] = polyval(p,complex(x),S,mu);
        return
    end
    x = eml_div(x-mu(1),mu(2));
end
y = eml.nullcopy(eml_expand(eml_scalar_eg(x,p),size(x)));
nc = eml_numel(p);
if ~(isempty(y) || isempty(p))
    % Use Horner's method.
    y(:) = p(1);
    for k = 2:nc
        y = (x .* y) + p(k);
    end
end
if nargout > 1
    eml_assert(nargin >= 3 && ~isempty(S), ...
        'S is required to compute error estimates.');
    eml_assert(isstruct(S), 'S must be a struct as returned by POLYFIT.');
    % S is a structure containing three elements: the triangular factor of
    % the Vandermonde matrix for the original X, the degrees of freedom,
    % and the norm of the residuals.
    % What follows is a streamlined algorithm for evaluating:
    %     E = V/R;
    %     e = sqrt(1+sum(E.*E,2));
    %     delta = normr/sqrt(df)*e;
    delta = eml.nullcopy(eml_expand(eml_scalar_eg(x,S.R),size(x)));
    ZERO = eml_scalar_eg(x,S.R);
    normrddf = eml_div(S.normr,sqrt(S.df));
    if S.df == 0
        eml_warning('MATLAB:polyval:ZeroDOF',['Zero degrees of freedom implies ' ...
            'infinite error bounds.']);
        delta(:) = inf;
    elseif nc == 0
        delta(:) = normrddf;
    else
        w = eml.nullcopy(eml_expand(eml_scalar_eg(x,S.R),[nc,1])); % Work vector.
        ncm1 = nc - 1;
        nx = eml_numel(x);
        for k = 1:nx
            w(nc) = 1;
            for j = ncm1:-1:1
                w(j) = w(j+1)*x(k);
            end
            s2 = ZERO;
            for j = 1:nc
                wj = eml_div(w(j),S.R(j,j));
                s2 = s2 + wj*wj;
                for i = j+1:nc
                    w(i) = w(i) - wj*S.R(j,i);
                end
            end
            delta(k) = normrddf * sqrt(1 + s2);
        end
    end
end
