function [value, msgs] = nlobjcheck(nlobj, ny)
%NLOBJCHECK Nonlinearity object checking (and conversion if necessary)
%
%[value, msg] = nlobjcheck(nlobj)
%
%nlobj is either an idnlfun object or a string
%
%The returned value is an idnlfun object in the SO case or an idnlfunVector
%object in the MO case.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/06/13 15:23:02 $

% Author(s): Qinghua Zhang

msgs = struct([]);
value = [];

if isa(nlobj, 'idnlfun')
    if numel(nlobj)==1 && ny>1
        nlobj = nlobj(ones(ny,1));
    elseif numel(nlobj)~=ny
        if ny==1
            msg = 'The value of the "Nonlinearity" property must be specified as a scalar object.';
            msgs = struct('identifier','Ident:idnlmodel:idnlarxNlobjCheck1','message',msg);
        else
            msg = sprintf('The value of the "Nonlinearity" property must be a %d-by-1 array of nonlinearity estimator objects.',ny);
            msgs = struct('identifier','Ident:idnlmodel:idnlarxNlobjCheck2','message',msg);
        end
        return
    end
    
elseif ischar(nlobj)
    nlnames = idnlfunclasses;
    ind = strmatch(lower(strtrim(nlobj)), nlnames);
    if length(ind)>1
        msgs = struct('identifier','Ident:idnlmodel:ambiguousNL',...
            'message',sprintf('The specified nonlinearity name ''%s'' is ambiguous. Specify more characters.',nlobj));
        return
    end
    if ~isempty(ind)
        nlobj = nlnames{ind(1)};
    else
        msg = sprintf(['''%s'' is not a valid name for a nonlinearity estimator.\n'...
            'Use ''linear'' for absence of nonlinearity.'], nlobj);
        msgs = struct('identifier','Ident:idnlmodel:idnlarxNlobjCheck3','message',msg);
        return
    end
    nlobj = feval(nlobj);
    nlobj = nlobj(ones(ny,1));
    
elseif isempty(nlobj) && (isfloat(nlobj) || ischar(nlobj))
    nlobj = linear;
    nlobj = nlobj(ones(ny,1));
else
    msg = ['The value of the "Nonlinearity" property must be specified using a nonlinearity estimator object or a string representing the name of the estimator. ',...
        'Type "idprops idnlestimators" or "help idnlarx" for more information.'];
    msgs = struct('identifier','Ident:idnlmodel:idnlarxNlobjFormat','message',msg);
    return
end

% Use idnlfunVector in MO case
if ny>1 && ~isa(nlobj, 'idnlfunVector')
    valuec = cell(1,ny);
    for ky = 1:ny
        valuec{ky} = nlobj(ky);
    end
    value = [valuec{:}]; % Converting to idnlfunVector
else
    value = nlobj;
end

% Disallow unitgain
if isany(value, 'unitgain')
    msg = 'Nonlinearity estimator UNITGAIN cannot be used with an IDNLARX model. Use LINEAR to denote absence of nonlinearity in an IDNLARX model.';
    msgs = struct('identifier','Ident:idnlmodel:idnlarxNlobjCheck5','message',msg);
    return
end

% FILE END