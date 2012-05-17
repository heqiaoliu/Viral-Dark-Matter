function x = idcell2mat(xcell,Ts)
% Utility to convert B or F polynomial from cell format to double matrix.
% Dimensions are reconciled by zero padding.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2009/10/16 04:56:37 $

nu = numel(xcell);
rownc = cellfun(@(x)size(x,2),xcell);
x = zeros(nu,max(rownc));
for ku = 1:nu
    if Ts>0
        x(ku,1:rownc(ku)) = xcell{ku};
    else
        x(ku,end-rownc(ku)+1:end) = xcell{ku};
    end
end
