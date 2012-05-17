function Model = utApproxDelay(this,Model)
% Helper function for approximating delays

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/05/23 07:53:00 $

if hasdelay(Model)
    if isequal(getTs(Model),0)
        PadeOrder = this.Preference.PadeOrder;
        Model = pade(Model,PadeOrder,PadeOrder,PadeOrder);
    else
        Model = delay2z(Model);
    end
end