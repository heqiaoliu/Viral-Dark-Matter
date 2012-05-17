function [y, z] = filter(b,a,x,zi,dim_in) 
%Embedded MATLAB Library Function
    
% Limitations: 
% [y, zf] = filter(b,a,x,zi,dim) 
%   a must be equal to 1
%   dim must be const
%   All local fimaths must match

% Copyright 2009 The MathWorks, Inc.
%#eml    

    eml_allow_mx_inputs;

    maxWordLength = eml_option('FixedPointWidthLimit');
    eml.extrinsic('emlGetNTypeForMTimes');
    eml.extrinsic('emlGetNTypeForTimes');
    eml_lib_assert(nargin>=3, 'fi:filter:notEnoughInputs', 'Not enough input arguments.');
    eml_lib_assert(nargin<=5, 'fi:filter:tooManyInputs',   'Too many input arguments.');

    % Default initial conditions.
    if nargin<4, 
        zi=[];  
    end

    % Default dim
    if nargin<5, 
        dim=eml_const_nonsingleton_dim(x); 
        eml_lib_assert(eml_is_const(size(x,dim)) || ...
                       isscalar(x) || ...
                       size(x,dim) ~= 1, ...
                       'EmbeddedMATLAB:filter:autoDimIncompatibility', ...
                       ['The working dimension was selected automatically, is ', ...
                        'variable-length, and has length 1 at run-time. This is not ', ...
                        'supported. Manually select the working dimension by ', ...
                        'supplying the DIM argument.']);
    else
      
        eml_assert(eml_is_const(dim_in), ...
                   'Dimension argument must be a constant.');
        if isfi(dim_in)
            % Let dimensions that happen to get cast to fi objects
            % "just work".
            dim = eml_const(double(dim_in));
        else
            dim = dim_in;
        end
        eml_assert_valid_dim(dim);
    end

    % Validate b
    eml_lib_assert(eml_is_const(size(b)),...
                   'fi:filter:numeratorSizeNotConst',...
                   'The dimensions of the numerator must not change.');

    eml_lib_assert(isvector(b) && ~isempty(b),'fi:filter:numVectorOnly', ...
                   'The numerator must be a non-empty vector.');

    % Compute the dimensions of the states, z.
    % The leading dimension of z is numel(b)-1, and the rest of the
    % dimensions are the same as size(x) with dimension dim missing. 
    size_x = size(x);
    if dim>ndims(x)
        p = numel(x);
    else
        p = eml_prodsize_except_dim(x,dim);
    end
    if eml_is_const(iscolumnvector(x)) && iscolumnvector(x)
        % x is a column vector
        size_zf = [numel(b)-1 p];
    else
        if dim<=ndims(x)
            size_zf = [numel(b)-1 size_x(1:dim-1) size_x(dim+1:end)];
        else
            size_zf = [numel(b)-1 size_x];
        end
    end

    isreal_output = isreal(b) && isreal(x) && isreal(zi);

    if eml_ambiguous_types && (isfi(b) || isfi(x) || isfi(zi))
        % The type resolution hasn't finished yet, so just return with the correct
        % size output. 
        if isreal_output
            y = eml_not_const(zeros(size(x)));
            z = eml_not_const(zeros(size_zf));
        else
            y = eml_not_const(complex(zeros(size(x))));
            z = eml_not_const(complex(zeros(size_zf)));
        end
        return
    end

    % Validate the inputs b, a, x
    eml_lib_assert(eml_is_const(size(zi,1)),...
                   'fi:filter:ziSizeNotConst',...
                   'The leading dimension of the initial conditions must not change.');

    eml_lib_assert(isfi(b) && isfi(x) && (isempty(zi) || isfi(zi)), ...
                   'fi:filter:NonFiInputs',...
                   ['The filter coefficients, input data, and initial conditions '...
                    '(if present) must all be FI objects.']);

    eml_lib_assert(isequal(get(b,'datatype'), get(x,'datatype')) && ...
                   (isempty(zi) || isequal(get(b,'datatype'), get(zi,'datatype'))), ...
                   'fi:filter:notSameDataTypes',...
                   ['The filter coefficients, input data, and initial conditions ',...
                    '(if present) must all have the same data type.']);

    eml_lib_assert(isnumeric(a) && isequal(a,1),'fi:filter:supportFIROnly', ...
                   'FILTER only supports denominators equal to 1 (FIR).');

    % Assert that all local fimaths match (if there are any local fimaths)
    if isfimathlocal(b) && isfimathlocal(x) && isfi(zi) && isfimathlocal(zi)
        % b & x & zi local
        local_fimaths_are_equal = isequal(eml_fimath(b),eml_fimath(x)) && isequal(eml_fimath(b),eml_fimath(zi));
    elseif isfimathlocal(b) && isfimathlocal(x)
        % b & x local
        local_fimaths_are_equal = isequal(eml_fimath(b),eml_fimath(x));
    elseif isfimathlocal(b) && isfi(zi) && isfimathlocal(zi)
        % b & zi local
        local_fimaths_are_equal = isequal(eml_fimath(b),eml_fimath(zi));
    elseif isfimathlocal(x) && isfi(zi) && isfimathlocal(zi)
        % x & zi local
        local_fimaths_are_equal = isequal(eml_fimath(x),eml_fimath(zi));
    else
        local_fimaths_are_equal = true;
    end
    eml_lib_assert(local_fimaths_are_equal,...
                   'fi:filter:fimathNotEqual',...
                   'The local fimaths do not match.');

    % Prefer a local fimath to the global one.
    if isfi(b) && isfimathlocal(b)
        F0 = eml_fimath(b);
    elseif isfi(x) && isfimathlocal(x)
        F0 = eml_fimath(x);
    elseif isfi(zi) && isfimathlocal(zi)
        F0 = eml_fimath(zi);
    else
        % All inputs have global fimath
        F0 = fimath;
    end
    
    % The output type is the same as the inner product b*x(1:length(b)) using fimath F0.
    if isfloat(b)
        Tout = numerictype(b);
    else
        [Tout,errmsg] = eml_const(emlGetNTypeForMTimes(numerictype(b),numerictype(x),...
                                                       F0,...  % fimath to use
                                                       isreal(b),isreal(x),...
                                                       numel(b),...
                                                       true,... % eml_is_const(size(b)) asserted to be true earlier
                                                       maxWordLength,...
                                                       'FILTER'));
        eml_lib_assert(isempty(errmsg), 'fi:filter:emlGetNTypeForMTimes', errmsg);
    end
    
    % The scalar product type.
    [Tproduct,errmsg2] = eml_const(emlGetNTypeForTimes(numerictype(b),numerictype(x),...
                                                      F0,isreal(b),isreal(x),...
                                                      maxWordLength));
    eml_lib_assert(isempty(errmsg2), 'fi:filter:emlGetNTypeForTimes', errmsg);

    % Update the fimath with the sum type which is the same as the output
    % type, and the product type. 
    F = fimath(F0,...
               'ProductMode','SpecifyPrecision',...
               'ProductWordLength',Tproduct.WordLength,...
               'ProductFractionLength',Tproduct.FractionLength,...
               'SumMode','SpecifyPrecision',...
               'SumWordLength',Tout.WordLength,...
               'SumFractionLength',Tout.FractionLength,...
               'CastBeforeSum',true);

    if isfixed(Tout)
        eml_lib_assert(isempty(zi) || isfi(zi) && isequal(numerictype(zi), Tout), ...
                       'fi:filter:IncorrectStateNumerictype',...
                       eml_const(sprintf(['The states must be a FI object matching the output numerictype, ',...
                            'which is DataType = %s, Signedness = %s, WordLength = %d, FractionLength = %d.'],...
                                         get(Tout,'DataType'), get(Tout,'Signedness'), ...
                                         get(Tout,'WordLength'), get(Tout,'FractionLength'))));
    end        

    eml_lib_assert(isempty(zi) || isequal(isreal(zi),isreal_output), ...
                   'fi:filter:initialConditionComplexityMismatch',...
                   'The complexity of the initial conditions must match the compexity of the output.');

    % Define the states, z.
    if nargin<4 || eml_is_const(isempty(zi)) && isempty(zi)
        % Default zi.  Expand to all zeros, and match local/global fimath of zi if zi is a fi.
        if isfi(zi)
            if isreal_output
                z = eml_fimathislocal(eml_cast(zeros(size_zf),Tout,fimath(zi)),eml_fimathislocal(zi));
            else
                z = eml_fimathislocal(eml_cast(complex(zeros(size_zf)),Tout,fimath(zi)),eml_fimathislocal(zi));
            end
        else
            % Default zi, but zi is not a fi.  z has global fimath.
            if isreal_output
                z = eml_fimathislocal(eml_cast(zeros(size_zf),Tout),false);
            else
                z = eml_fimathislocal(eml_cast(complex(zeros(size_zf)),Tout),false);
            end
        end
    else
        eml_lib_assert(iscolumnvector(zi) && isequal(size(zi,1),size_zf(1)) || ... % A column to be expanded
                       isequal(size(zi),size_zf),...                               % Or match size exactly
                       'fi:filter:invalidInitialConditions',...
                       ['Initial conditions must be a vector of length length(b)-1, ',...
                        'or an array with the leading dimension of size length(b)-1 ',...
                        'and with remaining dimensions matching those of x.']);
        if iscolumnvector(zi)
            % zi was specified as a column vector.
            % When zi is not empty, then we have asserted that it is a fi object earlier.
            % Expand vector z, retaining the local/global fimath of zi
            z = eml_fimathislocal(reshape(repmat(zi,1,p), size_zf),eml_fimathislocal(zi));
        else
            % zi was given in full
            % When zi is not empty, then we have asserted that it is a fi object earlier.
            z = zi;
        end
    end

    % Call the filter functions.
    if isempty(x)
        % No operations
        y = eml_fimathislocal(eml_cast(x,Tout),false);
    else
        % Define y
        if isreal_output
            y = eml.nullcopy(eml_fimathislocal(eml_cast(zeros(size(x)),Tout,F),false));
        else
            y = eml.nullcopy(eml_fimathislocal(eml_cast(complex(zeros(size(x))),Tout,F),false));
        end
        if isscalar(b)
            % b is a scalar, so y = b * x
            y = scalar_b(b,x,y,F);
        elseif isvector(x) && dim==eml_const_nonsingleton_dim(x)
            % x is a vector with dim aligned with it
            [y,z] = vector_filter(b,x,z,y,F);
        elseif size(x,1)>1 && dim==1
            % x is an array with dim naturally going down columns
            [y,z] = matrix_filter(b,x,z,y,F);
        else
            % Generic array case
            [y,z] = array_filter(b,x,z,dim,y,F);
        end
    end
end

function y = scalar_b(b,x,y,F)
% b is a scalar, so y = b*x.
    for i=1:numel(x)
        % y(i) = b*x(i);
        y(i) = mpy(F,b,x(i));
    end
end

function [y,z] = vector_filter(b,x,z,y,F)
% x is a vector, and we are filtering along the natural dimension of x. 
    for i=1:length(x)
        % y(i) = z(1) + b(1)*x(i);
        y(i) = add(F,z(1), mpy(F,b(1),x(i)));
        for k=1:size(z,1)-1
            % z(k) = z(k+1) + b(k+1)*x(i);
            z(k) = add(F,z(k+1), mpy(F,b(k+1),x(i)));
        end
        % z(end) = b(end)*x(i);
        z(end) = mpy(F,b(end),x(i));
    end
end

function [y,z] = matrix_filter(b,x,z,y,F)
% Filter down the natural columns of x.  Because of the way multi-dimensional
% arrays are stored in memory, they can be indexed into the same as
% two-dimensional matrices.
    number_of_columns = eml_prodsize_except_dim(x,1);
    for j=1:number_of_columns
        for i=1:size(x,1)
            % y(i,j) = z(1,j) + b(1)*x(i,j);
            y(i,j) = add(F,z(1,j), mpy(F,b(1),x(i,j)));
            for k=1:size(z,1)-1
                % z(k,j) = z(k+1,j) + b(k+1)*x(i,j);
                z(k,j) = add(F,z(k+1,j), mpy(F,b(k+1),x(i,j)));
            end
            % z(end,j) = b(end)*x(i,j);
            z(end,j) = mpy(F,b(end),x(i,j));
        end
    end
end

function [y,z] = array_filter(b,x,z,dim,y,F)
% The dimension dim we are filtering along is not a natural column of x, so
% we discontiguously stride through x and y.
    if dim>ndims(x)
        number_of_channels = numel(x);
    else
        number_of_channels = eml_const(eml_prodsize_except_dim(x,dim));
    end
    leading_dimension_of_x = eml_const(prodsize_up_to_dim(x,dim));
    nx = size(x,dim);
    nz = size(z,1);
    base_offset = zeros(eml_index_class);
    jj = ones(eml_index_class);
    jp = ones(eml_index_class);
    for j=1:number_of_channels
        if jj>leading_dimension_of_x
            % Start the next channel
            jj = ones(eml_index_class);
            offset = eml_index_plus(jp,1);
            base_offset = offset;
        else
            % Continue with the next input in this channel
            base_offset = eml_index_plus(base_offset,1);
            offset = base_offset;
        end
        jj = eml_index_plus(jj,1);
        for i=1:nx
            jp = offset;
            xjp = x(jp);
            % y(jp) = z(1,j) + b(1)*xjp;
            y(jp) = add(F,z(1,j), mpy(F,b(1),xjp));
            for k=1:nz-1
                kp1 = eml_index_plus(k,1);
                % z(k,j) = z(kp1,j) + b(kp1)*xjp;
                z(k,j) = add(F,z(kp1,j), mpy(F,b(kp1),xjp));
            end
            % z(end,j) = b(end)*xjp;
            z(end,j) = mpy(F,b(end),xjp);
            offset = eml_index_plus(offset, leading_dimension_of_x);
        end
    end
end

function n = prodsize_up_to_dim(x,dim)
% Product of all the dimensions up to dimension dim.
    if dim>ndims(x)
        n = numel(x);
    else
        sx = size(x);
        n = 1;
        for k=1:dim-1
            n = n*sx(k);
        end
    end
end

function t = iscolumnvector(x)
    t = ~isempty(x) && ndims(x)==2 && size(x,2)==1;
end
