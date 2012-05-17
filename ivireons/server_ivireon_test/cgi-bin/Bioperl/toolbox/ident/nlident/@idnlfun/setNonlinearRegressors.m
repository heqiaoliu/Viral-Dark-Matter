function nlobj = setNonlinearRegressors(nlobj, value)
%setNonlinearRegressors: set the NonlinearRegressors property of IDNLFUN objects.
%
%This property is usually copied from IDNLARX before model estimation.
%Array of IDNLFUN objects are handled.
%  nlobj = setNonlinearRegressors(nlobj, value)
%  value is an integer vector for scalor nlobj, or a cell array for an array
%  of objects.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:53:38 $

% Author(s): Qinghua Zhang

if ~isa(nlobj, 'idnlfun')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','setNonlinearRegressors','IDNLFUN');
end

nobj = numel(nlobj);
msg = 'NonlinearRegressors must be a positive integer vector or one of: ''input'',''output'',''standard'',''custom'',''all'',''search''.';
if nobj==1 % Single IDNLFUN object
    [nlobj, eflag] = soSetNLR(nlobj, value);
    if eflag
        %todo
        error('Ident:idnlfun:invalidNlreg', msg)
    end
else
    if ~iscell(value) || numel(value)~=nobj
        %todo
        error('Ident:idnlfun:invalidNlreg',msg)
    end
    idnlfunVecFlag = isa(nlobj,'idnlfunVector');
    for kobj=1:nobj
        if idnlfunVecFlag
            [nlobj.ObjVector{kobj}, eflag] = soSetNLR(nlobj.ObjVector{kobj}, value{kobj});
        else
            [nlobj(kobj), eflag] = soSetNLR(nlobj(kobj), value{kobj});
        end
        if eflag
            %todo
            error('Ident:idnlfun:invalidNlreg',msg)
        end
    end
end

%===========================================
function [nlobj, eflag] = soSetNLR(nlobj, value)
% Single objet set

if isempty(value)
    value = zeros(1,0);
end

if isempty(value) || (isposintmat(value) && isvector(value)) || (ischar(value) && ismember(value, {'all', 'standard','custom','input','output'}))
    nlobj.NonlinearRegressors = value;
    eflag = 0;
else
    eflag = 1;
end

% FILE END