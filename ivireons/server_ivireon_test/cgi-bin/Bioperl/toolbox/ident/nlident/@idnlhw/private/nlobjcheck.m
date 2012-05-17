function [value, msg] = nlobjcheck(nlobj, nch, io)
%NLOBJCHECK Nonlinearity object checking (and conversion if necessary)
%
%[value, msg] = nlobjcheck(nlobj, nch, io)
%
%nlobj is either an idnlfun object or a string.
%nch is nu or ny.
%io is 'Input' or 'Output'.
%
%The returned value is an idnlfun object in the SO case or an idnlfunVector
%object in the MO case.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/06/13 15:24:25 $

% Author(s): Qinghua Zhang

msg = struct([]);
value = struct([]);

if isempty(nlobj)
    nlobj = unitgain;
end

if strcmpi(io,'Input')
    nlstr = 'InputNonlinearity';
else
    nlstr = 'OutputNonlinearity';
end


if isa(nlobj, 'idnlfun')
    if numel(nlobj)==1 && nch>1
        nlobj = nlobj(ones(nch,1));
    elseif numel(nlobj)~=nch
        if nch==1
            msg = sprintf('The value of the "%s" property must be specified as a scalar object.',nlstr);
            msg = struct('identifier','Ident:idnlmodel:idnlhwNlobjCheck1','message',msg);
        else
            msg = sprintf('The value of the "%s" property must be a %d-by-1 array of nonlinearity estimator objects.',...
                nlstr,nch);
            msg = struct('identifier','Ident:idnlmodel:idnlhwNlobjCheck2','message',msg);
        end
        return
    end
elseif ischar(nlobj)
    nlnames = idnlfunclasses;
    ind = strmatch(lower(strtrim(nlobj)), nlnames);
    if length(ind)>1
        msg = struct('identifier','Ident:idnlmodel:ambiguousNL',...
            'message',sprintf('The specified nonlinearity name ''%s'' is ambiguous. Specify more characters.',nlobj));
        return
    end
    if ~isempty(ind)
        nlobj = nlnames{ind(1)};
    else
        msg = sprintf(['''%s'' is not a valid name for a nonlinearity estimator.\n'...
            'Use ''unitgain'' for absence of nonlinearity.'], nlobj);
        msg = struct('identifier','Ident:idnlmodel:idnlhwNlobjCheck3','message',msg);
        return
    end
    nlobj = feval(nlobj);
    nlobj = nlobj(ones(nch,1));
else
    msg = sprintf(['The value of the "%s" property must be specified using a nonlinearity estimator object or a string representing the name of the estimator. ',...
        'Type "idprops idnlestimators" or "help idnlhw" for more information.'],nlstr);
    msg = struct('identifier','Ident:idnlmodel:idnlhwNlobjCheck4','message',msg);
    return
end

if ~isdifferentiable(nlobj)
    msg = sprintf(['The value of the "%s" property must be differentiable nonlinearity estimator(s). '...
        'Type "idprops idnlestimators" for more information.'],nlstr);
    msg = struct('identifier','Ident:idnlmodel:idnlhwNlobjCheck5','message',msg);
    return
end

if isany(nlobj, 'linear')
    msg = 'Nonlinearity estimator LINEAR cannot be used with an IDNLHW model. Use UNITGAIN to denote absence of nonlinearity in an IDNLARX model.';
    msg = struct('identifier','Ident:idnlmodel:idnlhwNlobjCheck6','message',msg);
    return
end

for kc=1:nch
    if regdimension(nlobj(kc))>1
        %msg = [io, ' nonlinearity must be single input nonlinearity estimator(s).'];
        msg = 'The nonlinearity estimators used with IDNLHW models must have exactly one input.';
        msg = struct('identifier','Ident:idnlmodel:idnlhwNlobjCheck7','message',msg);
        return
    end
end

% Use idnlfunVector in MO case
if nch>1 && ~isa(nlobj, 'idnlfunVector')
    valuec = cell(1,nch);
    for ky=1:nch
        valuec{ky} = nlobj(ky);
    end
    value = [valuec{:}]; % Converting to idnlfunVector
else
    value = nlobj;
end


% FILE END