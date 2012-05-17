function utCheckParZPKFcn(this)
% Checks to make sure the Par2ZPKFcn and ZPK2ParFcn are valid

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2008/05/31 23:15:57 $

if isempty(this.Value)
    this.Value = 1;
end

% Check that function handles are valid g292839
try
    if iscell(this.Par2ZpkFcn)
        [junk,junk1] = feval(this.Par2ZpkFcn{1});
    else
        [junk,junk1] = feval(this.Par2ZpkFcn);
    end
catch ME
    if strcmp(ME.identifier,'MATLAB:UndefinedFunction')
        ctrlMsgUtils.error('Control:compDesignTask:UnableToFindCompensatorFcns')
    end
end

