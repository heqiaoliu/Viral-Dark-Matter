function value = evaluate(nlobj, x)
%EVALUATE: return the value of a nonlinearity estimator at given input.
%
%  VALUE = EVALUATE(NL, X)
%
%  NL: the nonlinearity estimator object. See idprops idnlestimators.
%  X: the input value at which NL should be evaluated. If NL is a single
%    nonlinearity estimator, X is 1-by-nx row vector or a nv-by-nx matrix.
%    Here nx is the dimension of the regression vector input to NL
%    (see  size(NL)) and nv is the number of points where NL is evaluated.
%    If NL is an array of ny nonlinearity estimators, then X is a 1-by-ny
%    cell array of nv-by-nx  matrices.
%  VALUE: the evaluated value, in general an nv-by-ny matrix.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/31 06:14:36 $

% Author(s): Qinghua Zhang

% Note: This function handles idnlfun object array, by calling the single
%   object methods soevaluate of sub-classes

error(nargchk(2,2,nargin,'struct'))

if ~isa(nlobj,'idnlfun')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','evaluate','IDNLFUN')
end

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:unInitializedNL',upper(class(nlobj)))
end

ny = numel(nlobj);

if ny==1
    % Single idnlfun object
    if iscell(x)
        if isscalar(x)
            x = x{1};
        else
            ctrlMsgUtils.error('Ident:idnlfun:evaluateDim1')
        end
    end
    if size(x,2)~=regdimension(nlobj) || ~isreal(x) || ndims(x)~=2
        ctrlMsgUtils.error('Ident:idnlfun:evaluateDim1')
    end
    try
        value = soevaluate(nlobj, x);
    catch E
        %todo: xlate
        msg = 'The nonlinearity could not be evaluated.';
        if isa(nlobj,'customnet') && ~any(strcmp(E.identifier,{'Ident:idnlfun:emptyUnitFcn','Ident:idnlfun:unInitializedNL'}))
            msg = 'Check that the unit function of the CUSTOMNET nonlinearity estimator has been properly defined.';
        end
        msg = sprintf('%s The following error occurred during its evaluation:\n%s',msg,E.message);
        error('Ident:idnlfun:evaluationError',msg) %#ok<SPERR>
    end
    return
end

% Below is for array of idnlfun objects

if ~iscell(x) || ny~=length(x)
    ctrlMsgUtils.error('Ident:idnlfun:evaluateDim2',ny)
end

if ~(all(all(cellfun(@isreal, x))) && all(cellfun(@ndims, x)==2))
    ctrlMsgUtils.error('Ident:idnlfun:evaluateDim3')
end

datasize = cellfun(@size, x, 'UniformOutput',false);
datasize = cell2mat(datasize(:));
if ny>1 && any(diff(datasize(:,1)))
    ctrlMsgUtils.error('Ident:idnlfun:evaluateDim4')
end

idnlfunVecFlag = isa(nlobj,'idnlfunVector');

nobs = datasize(1,1);
value = zeros(nobs, ny);
for ky = 1:ny
    if idnlfunVecFlag
        if datasize(ky,2) ~= regdimension(nlobj.ObjVector{ky})
            ctrlMsgUtils.error('Ident:idnlfun:regDimMismatch',upper(class(nlobj)))
        end
        try
            value(:,ky) = soevaluate(nlobj.ObjVector{ky}, x{ky}) ;
        catch E
            msg = sprintf('The nonlinearity on output no. %d of the model could not be evaluated.',ky);
            if isa(nlobj.ObjVector{ky},'customnet') && ~any(strcmp(E.identifier,{'Ident:idnlfun:emptyUnitFcn','Ident:idnlfun:unInitializedNL'}))
                msg = sprintf('%s Check that the unit function of the nonlinearity estimator has been properly defined.',msg);
            end
            msg = sprintf('%s The following error occurred during its evaluation:\n%s',msg,E.message);
            error('Ident:idnlfun:evaluationError',msg) %#ok<SPERR>
        end
    else
        if datasize(ky,2) ~= regdimension(nlobj(ky))
            ctrlMsgUtils.error('Ident:idnlfun:regDimMismatch',upper(class(nlobj)))
        end
        try
            value(:,ky) = soevaluate(nlobj(ky), x{ky});
        catch E
            
            msg = sprintf('The nonlinearity on output no. %d of the model could not be evaluated.',ky);
            
            if isa(nlobj(ky),'customnet') && ~any(strcmp(E.identifier,{'Ident:idnlfun:emptyUnitFcn','Ident:idnlfun:unInitializedNL'}))
                msg = sprintf('%s Check that the unit function of the nonlinearity estimator has been properly defined.',msg);
            end
            msg = sprintf('%s The following error occurred during its evaluation:\n%s',msg,E.message);
            error('Ident:idnlfun:evaluationError',msg) %#ok<SPERR>
            
        end
    end
end

% FILE END
