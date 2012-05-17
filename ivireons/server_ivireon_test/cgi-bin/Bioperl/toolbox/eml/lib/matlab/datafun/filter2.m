function y = filter2(b,x,shape)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
if nargin < 3
    shape = 's';
end
if ~isa(b,'float')
    y = filter2(double(b),x,shape);
    return
elseif ~isa(x,'float')
    y = filter2(b,double(x),shape);
    return
end
eml_assert(ischar(shape) && ( ...
    strcmp(shape,'s') || strcmp(shape,'same') || ...
    strcmp(shape,'v') || strcmp(shape,'valid') || ...
    strcmp(shape,'f') || strcmp(shape,'full')), ...
    'Unknown shape parameter.');
stencil = rot90(b,2);
[ms,ns] = size(stencil);
% Handle separable cases.
if ms == 1
    y = conv2(1,stencil,x,shape);
    return
elseif ns == 1
    y = conv2(stencil,1,x,shape);
    return
elseif ~isempty(stencil) && eml_numel(stencil) <= eml_numel(x)
    trysepp = true;
    for k = 1:eml_numel(stencil)
        if ~isfinite(stencil(k))
            trysepp = false;
            break;
        end
    end
    if trysepp
        % Check rank (separability) of stencil
        [u,s,v] = svd(stencil);
        % sd = diag(s);
        % tol = length(stencil)*eps(sd(end));
        % rank = sum(sd > tol);
        n = min(size(s));
        tol = length(stencil)*eps(s(n,n));
        rank = zeros(eml_index_class);
        for k = 1:n
            if s(k,k) > tol
                rank = eml_index_plus(rank,1);
            end 
        end
        if rank == 1
            % Separable stencil
            sqrts1 = sqrt(s(1));
            hcol = u(:,1) * sqrts1;
            hrow = conj(v(:,1)) * sqrts1;
            y = conv2(hcol,hrow,x,shape);
            % We're basically done.  If all the inputs are integers, we'll
            % round the result y before returning.
            for k = 1:eml_numel(stencil)
                if floor(stencil(k)) ~= stencil(k)
                    return
                end
            end
            for k = 1:eml_numel(x)
                if floor(x(k)) ~= x(k)
                    return
                end
            end
            y = round(y);
            return
        end
    end
end
y = conv2(x,stencil,shape);
