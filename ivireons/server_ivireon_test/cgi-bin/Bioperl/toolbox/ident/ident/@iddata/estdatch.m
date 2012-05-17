function zt = estdatch(z,Tmod)
%ESTDATCH Checking an IDDATA object before estimation.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.7 $  $Date: 2009/12/07 20:42:24 $

zt = z;
docheck = 1;
if nargin<2
    Tmod = 1;
end

if isfield(z.Utility,'Checkdone') && z.Utility.Checkdone
    docheck = 0;
end

if docheck
    zt.Utility.Checkdone = 1;
    td = unique(cat(1,z.Ts{:}));
    
    if length(td)>1
        % non-unique Ts
        if Tmod
            ctrlMsgUtils.warning('Ident:dataprocess:estdatch1',...
                sprintf('%g',z.Ts{1}))
        else
            ctrlMsgUtils.warning('Ident:dataprocess:estdatch2',...
                sprintf('%g', z.Ts{1}))
        end        
    end
    
   ints = unique(z.InterSample);
   if length(ints)>1
       % non-unique intersample (could be in inputs of same exp or in
       % different experiments
       if Tmod
            ctrlMsgUtils.warning('Ident:dataprocess:estdatch3',ints{1})
       else
            ctrlMsgUtils.warning('Ident:dataprocess:estdatch4',ints{1})
       end 
   end
    
    blnr = find(strcmp(ints,'bl'));
    if ~isempty(blnr)
        if strcmpi(z.Domain,'time')
            zt.InterSample(blnr) = {'foh'};
            if Tmod
                ctrlMsgUtils.warning('Ident:dataprocess:estdatch5')
            else
                ctrlMsgUtils.warning('Ident:dataprocess:estdatch6')
            end
        else
            if zt.Ts{1}
                ctrlMsgUtils.warning('Ident:dataprocess:estdatch7');
                zt.InterSample(blnr) = {'foh'};
            end
        end
    end
end
