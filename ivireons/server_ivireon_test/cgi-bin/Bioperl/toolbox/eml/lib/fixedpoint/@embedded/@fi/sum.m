function Y = sum(X,dim,dummyinput) %#ok<INUSD>
% Embedded MATLAB Library function for fixed point sum
%
% Limitations:
% 1) Dimensions of X or the second input 'dim' must be less than or equal to 2.
  
% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/sum.m $
% Copyright 2002-2010 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.23 $  $Date: 2010/05/20 02:16:10 $
  
% The third input is a dummy that is there just to match the signature of the sum library function
% in eml/lib/matlab

eml.extrinsic('emlGetNTypeForSum');

Tx = eml_typeof(X);
Fx = eml_fimath(X);

szX = size(X);
if nargin<2
    dim = eml_const_nonsingleton_dim(X);
    eml_lib_assert(eml_is_const(size(X,double(dim))) || ...
        isscalar(X) || ...
        size(X,double(dim)) ~= 1, ...
        'EmbeddedMATLAB:sum:autoDimIncompatibility', ...
        ['The working dimension was selected automatically, is ', ...
        'variable-length, and has length 1 at run-time. This is not ', ...
        'supported. Manually select the working dimension by ', ...
        'supplying the DIM argument.']);
else
    eml_prefer_const(dim);
    eml_assert(eml_is_const(dim),'Dimension argument must be a constant.');
    eml_assert_valid_dim(double(dim));
end

if isfixed(X)
    % Fixed FI

    % Check to see if scaling is not slope bias. Error out if it is.
    bias = eml_const(get(Tx,'Bias'));
    eml_assert(bias==0,'fi math operations require fixed-point, binary-point scaling.');

    fullPrecSum = eml_const(strcmpi(get(Fx,'SumMode'),'FullPrecision'));
    cb4sum      = eml_const(get(Fx,'CastBeforeSum'));
    if ~(fullPrecSum || cb4sum)
        eml_assert(0,'fi math operations require CastBeforeSum to be true when SumMode is not FullPrecision');
    end
    maxWL = eml_option('FixedPointWidthLimit');
    if eml_is_const(szX)
        [Ty,errmsg] = eml_const(emlGetNTypeForSum(Tx,Fx,szX,true,double(dim),maxWL));
    else
        % When input sizes can change at run-time, we only allow SumModes
	% 'KeepLSB' and 'SpecifyPrecision'; For these two modes the output
	% NumericType does not depend on the input size; we pass ones(1,dim) as a
	% dummy size argument
        
        % If the Sum dim is >> ndims(X) the output type == input type
        if dim > eml_ndims(X)
            Ty = Tx; errmsg = '';
        else
            [Ty,errmsg] = eml_const(emlGetNTypeForSum(Tx,Fx,ones(1,double(dim)),false,double(dim),maxWL));
        end
    end
    if ~isempty(errmsg)
        eml_assert(0,errmsg);
    end

    if eml_is_const(size(X,double(dim))) && size(X,double(dim)) == 1
        Y = eml_fimathislocal(eml_cast(X,Ty,Fx),eml_fimathislocal(X));
    elseif isempty(X)
        Y = fiSumAlloc(X,Ty,Fx,double(dim));
    elseif eml_is_const(isvector(X)) && isvector(X)
        Y = eml_fimathislocal(eml_cast(X(1),Ty,Fx),eml_fimathislocal(X));
        for k = 2:eml_numel(X)
            Y(1) = eml_plus(Y(1),X(k),Ty,Fx);
        end
    else
        Y = eml.nullcopy(fiSumAlloc(X,Ty,Fx,double(dim)));
        vlen = size(X,double(dim));
        vstride = eml_matrix_vstride(X,double(dim));
        npages = eml_matrix_npages(X,double(dim));
        ix = zeros(eml_index_class);
        iy = zeros(eml_index_class);
        for i = 1:npages
            ixstart = ix;
            for j = 1:vstride
                ixstart = eml_index_plus(ixstart,1);
                ix = ixstart;
                s = eml_cast(X(ix),Ty,Fx);
                for k = 2:vlen
                    ix = eml_index_plus(ix,vstride);
                    s(1) = eml_plus(s(1),X(ix),Ty,Fx);
                end
                iy = eml_index_plus(iy,1);
                Y(iy) = s;
            end
        end
    end

elseif isfloat(X)
    % True Double or True Single FI

    xTemp = eml_cast(X,eml_fi_getDType(X));
    xSum  = sum(xTemp,double(dim));
    Y     = eml_fimathislocal(eml_cast(xSum,Tx,Fx),eml_fimathislocal(X));

else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('SUM','fixed-point,double, or single');
end

%----------------------------------------------------------------------------------
function Y = fiSumAlloc(X,Ty,Fx,dim)
% Initialize Y to the proper size and complexity
% This function is never called with dim > ndims(X).
sz = size(X);
sz(double(dim)) = 1;
ZERO = eml_fimathislocal(eml_cast(0,Ty,Fx),eml_fimathislocal(X));
if isreal(X)
    Y = eml_expand(ZERO,sz);
else
    Y = eml_expand(complex(ZERO,ZERO),sz);
end

%----------------------------------------------------------------------------------
