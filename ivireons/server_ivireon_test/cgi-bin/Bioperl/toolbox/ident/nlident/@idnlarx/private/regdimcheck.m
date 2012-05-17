function msgs = regdimcheck(nlobj, sys)
%REGDIMCHECK checks the consistency between nlobj and regressors in IDNLARX
%
% msg = regdimcheck(nlobj, sys)
%
% Note: this function cannot be part of nlobjcheck, because nlobjcheck can
% be called before regressors are defined in a model.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:23:03 $

% Author(s): Qinghua Zhang

msgs = struct([]);
ny = size(sys, 'ny');
regs = getreg(sys);

if ny>1
    regdim = cellfun(@numel, regs);
else
    regdim = numel(regs);
end

if ny~=numel(nlobj)    
    if ny==1
        msg = 'The value of the "Nonlinearity" property must be specified as a scalar object.';
        msgs = struct('identifier','Ident:idnlmodel:idnlarxNlobjCheck1','message',msg);
    else
        msg = sprintf('The value of the "Nonlinearity" property must be a %d-by-1 array of nonlinearity estimator objects.',ny);
        msgs = struct('identifier','Ident:idnlmodel:idnlarxNlobjCheck2','message',msg);
    end
    return
end

for ky=1:ny
    rdk = regdimension(nlobj(ky));
    if rdk>0 && rdk~=regdim(ky)
        %todo: use message ids for each string
        msg = 'Nonlinearity estimator dimension is inconsistent with model regressors.';
        if ~ismultiinput(nlobj(ky))
            
            %msgadd = sprintf('The %s estimator is typically used in IDNLHW models. Type "idprops idnlestimators" for more information.',...
            %    upper(class(nlobj(ky))));
            msg = sprintf(['The %s estimator cannot be used in IDNLARX models containing more than one regressors. ',...
                'It is typically used in IDNLHW models. Type "idprops idnlestimators" for more information.'],...
                upper(class(nlobj(ky))));
            %msg = sprintf('%s %s',msg,msgadd);
        end
        msgs = struct('identifier','Ident:idnlmodel:idnlarxRegDimCheck','message',msg);
        return
    end
end

% FILE END