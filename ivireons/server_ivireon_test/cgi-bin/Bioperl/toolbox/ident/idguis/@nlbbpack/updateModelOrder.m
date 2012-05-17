function m = updateModelOrder(m,row,col,val,ynum)
% update model orders (package method)

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:50:22 $
% Written by Rajiv Singh.

[ny,nu] = size(m);
if ynum==0
    ynum = 1:ny;
end

messenger = nlutilspack.getMessengerInstance;
Ns = min(size(messenger.getCurrentEstimationData,'n'));
if isa(m,'idnlarx')
    if row<nu+2
        % update nb/nk
        if col==2
            % nk
            if (val+m.nb(ynum,row-1) < Ns/2) %todo: check with QZ on this heuristic
                m.nk(ynum,row-1) = val;
            else
                ctrlMsgUtils.error('Ident:idguis:tooHighDelay')
            end
        else
            % nb
            if (val+m.nk(ynum,row-1) < Ns/2)
                m.nb(ynum,row-1) = val;
            else
                ctrlMsgUtils.error('Ident:idguis:tooHighOrder')
            end
        end
    else
        % update na
        if col==3 && (val<Ns/2)
            m.na(ynum,row-nu-2) = val;
        else
            ctrlMsgUtils.error('Ident:idguis:tooHighOrder')
        end
        % do nothing if col==2 has changed because it must be 1 and
        % unchangeable
    end
elseif isa(m,'idnlhw') 
    if (col==3)
        % update nf
        if (val<Ns/2)
            m.nf(ynum,row) = val;
        else
            ctrlMsgUtils.error('Ident:idguis:tooHighPoleNum')
        end
    elseif (col==2)
        % update nb
        if (val+m.nk(ynum,row) < Ns/2)
            m.nb(ynum,row) = val;
        else
            ctrlMsgUtils.error('Ident:idguis:tooHighZeroNum')
        end
    elseif (col==4)
        % nk
        if (val+m.nb(ynum,row) < Ns/2) 
            m.nk(ynum,row) = val;
        else
            ctrlMsgUtils.error('Ident:idguis:tooHighDelay')
        end
    end
end
