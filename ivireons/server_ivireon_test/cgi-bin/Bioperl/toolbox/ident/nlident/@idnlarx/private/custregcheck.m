function [reg, msg] = custregcheck(reg, ny)
%custregcheck: custom regressor validity preliminary check
%
%msg returns error message in case of error, otherwise empty.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/06/13 15:22:57 $

% Author(s): Qinghua Zhang


error(nargchk(2, 2, nargin,'struct'))
msg = struct([]);

if ny==1
    if iscellstr(reg) || isa(reg, 'customreg')
        % do nothing
    elseif ischar(reg)
        % tolerate single string
        reg = {reg};
    elseif iscell(reg) && length(reg)==1 && (iscellstr(reg{1}) || isa(reg{1}, 'customreg'))
        % tolerate one more cell level
        reg = reg{1};
    else
        msg = 'The value of the "CustomRegressors" property must be a CUSTOMREG object array or a cell array of strings.';
        msg = struct('identifier','Ident:idnlmodel:customregType1', 'message',msg);
    end
    
elseif ny>1
    errflag = 0;
    if iscell(reg) && length(reg)==ny
        for ky=1:ny
            if ~iscellstr(reg{ky}) && ~isa(reg{ky}, 'customreg')
                errflag = 1;
                break
            end
        end
    else
        errflag = 1;
    end
    if errflag
        msg = 'The value of the "CustomRegressors" property must be an Ny-by-1 cell array of CUSTOMREG object arrays or of cell arrays of strings, where Ny = number of model outputs.';
        msg = struct('identifier','Ident:idnlmodel:customregTypeWithSize', 'message',msg);
    end
else
    msg = 'In the "custregcheck(REG, NY)" command, NY must be larger than or equal to 1.';
    msg = struct('identifier','Ident:utility:custregcheck1', 'message',msg);
end

% FILE END