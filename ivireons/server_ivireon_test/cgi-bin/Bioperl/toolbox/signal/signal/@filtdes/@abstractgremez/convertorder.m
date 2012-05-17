function order = convertorder(this)
%CONVERTORDER Convert the order specifications for design

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2007/12/14 15:12:07 $

if isspecify(this),
    order = get(this, 'Order');
    if any(strcmpi(this.ResponseType, {'bandstop', 'highpass'})) && rem(order, 2)
        order = order+1;
        warning(generatemsgid('MustBeEven'),'Generalized Equiripple %s filters must have even order; increasing order to %d.', ...
            this.ResponseType, order);
    end
else

    if any(strcmpi(this.ResponseType, {'bandstop', 'highpass'}))
        order = {'mineven', 4};
        return;
    end
    
    switch lower(this.orderMode)
        case 'minimum'
            order = 'minorder';
        case 'minimum even'
            order = 'mineven';
        case 'minimum odd'
            order = 'minodd';
    end

    % Add the initial guess.
    if ~isempty(this.initOrder)
        order = {order, this.initOrder};
    end
end

% [EOF]
