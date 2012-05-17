function Model = utApproxDelay(this,Model)
% Helper function for approximating delays

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:30:20 $

if hasdelay(Model)
    if isequal(Model.Ts,0)
        PadeOrder = this.PadeOrder;
        Model = pade(Model,PadeOrder,PadeOrder,PadeOrder);
    else
        Model = elimDelay(Model);
    end
end