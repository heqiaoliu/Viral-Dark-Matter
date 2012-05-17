function str = getDatatipText(this,dataCursor)

% Specify datatip string

% Copyright 2003-2004 The MathWorks, Inc.

N_DIGITS = 3;
ind = get(dataCursor,'DataIndex');
pos = get(dataCursor,'Position');
is_horz = strcmpi(get(this,'Horizontal'),'on');
is_stacked = strcmpi(get(this,'BarLayout'),'stacked');

if is_horz
    if is_stacked
        str = {['X = ',num2str(pos(1),N_DIGITS),' (Stacked)'], ...
               ['X = ', num2str(this.ydata(ind),N_DIGITS),' (Segment)'], ...
               ['Y = ', num2str(this.xdata(ind),N_DIGITS)]};
    else
        str = {['X = ', num2str(this.ydata(ind),N_DIGITS)], ...
               ['Y = ', num2str(this.xdata(ind),N_DIGITS)]};
    end    
else
    if is_stacked
        str = {['X = ', num2str(this.xdata(ind),N_DIGITS)], ...
               ['Y = ',num2str(pos(2),N_DIGITS), ' (Stacked)'], ...
               ['Y = ', num2str(this.ydata(ind),N_DIGITS), ' (Segment)']};
    else
        str = {['X = ', num2str(this.xdata(ind),N_DIGITS)], ...
               ['Y = ', num2str(this.ydata(ind),N_DIGITS)]};
    end  
end

