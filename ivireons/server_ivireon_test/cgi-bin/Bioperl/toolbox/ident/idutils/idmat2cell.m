function xcell = idmat2cell(x,Ts)
% Utility to convert B or F polynomial from matrix to cell format. The
% format conversion is performed only in multi-input case (nu>1). This
% utility supports double format phase-out plan for IDPOLY.
% Trailing zeros (if Ts>0) or leading zeros (if Ts==0) are removed upon
% conversion. 

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2009/10/16 04:56:39 $

nu = size(x,1);
if nu<=1
    xcell = x; %return double data in single input case
    return;
end

xcell = cell(1,nu);
for ku = 1:nu
    xvec = x(ku,:);
    if Ts>0
        xcell{ku} = xvec(1:find(xvec,1,'last'));
    else
        xcell{ku} = xvec(find(xvec,1,'first'):end);
    end
end
