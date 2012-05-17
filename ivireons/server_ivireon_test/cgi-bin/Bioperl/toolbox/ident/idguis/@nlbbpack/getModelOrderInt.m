function val = getModelOrderInt(m,row,col,ynum)
% obtain model order integer (package method)

% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/03/22 03:48:55 $

[ny,nu] = size(m);
if isa(m,'idnlarx')
    % note that rows are offset by header rows: Input Channels and Output
    % Channels
    if row<=nu+1
        % fetch nb/nk
        if col==2
            % nk
            val = m.nk(ynum,row-1);
        else
            % nb
            val = m.nb(ynum,row-1);
        end
    else
        % fetch na
        if col==3
            val = m.na(ynum,row-nu-2);
        else
            val = 1;
        end
    end
elseif isa(m,'idnlhw')
   % idnlhw case
   if (col==2)
       val = m.nb(ynum,row);
   elseif (col==3)
       val = m.nf(ynum,row);
   elseif (col==4)
       val = m.nk(ynum,row);
   end
end
