function [element,type,max_val] = getLimitingConstraint(this)
% GETLIMITINGCONSTRAINT  Get the name of the element of the largest
% constraint violation.
%
 
% Author(s): John W. Glass 24-Aug-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 15:26:57 $

[max_dx,ind_dx] = max([abs(this.F_dx(:));0]);
[max_y,ind_y] = max([abs(this.F_y(:));0]);
max_const = max([abs(this.F_const(:));0]);

% Find the largest violation
[max_val,ind_max] = max([max_dx,max_y,max_const]);

if max_val > 0
    switch ind_max
        case 1
            element = this.StateConstraintBlocks{ind_dx};
            type = 'block';
        case 2
            element = this.OutputConstraintBlocks{ind_y};
            type = 'block';
        case 3
            element = ctrlMsgUtils.message('Slcontrol:findop:InternalAlgConstraint');
            max_val = max_const;
            type = 'constraint';
    end
else
    element = ctrlMsgUtils.message('Slcontrol:findop:NoConstraintError');
    type = 'noerror';
end