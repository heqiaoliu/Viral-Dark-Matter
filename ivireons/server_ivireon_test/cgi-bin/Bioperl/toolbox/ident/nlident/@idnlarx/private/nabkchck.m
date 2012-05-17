function msg = nabkchck(na,nb,nk)
%NABKCHCK: na, nb, nk consistency check

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:23:01 $

% Author(s): Qinghua Zhang

msg = struct([]);

if ~isnonnegintmat(na) || ~(isnonnegintmat(nb)||isempty(nb)) || ~(isnonnegintmat(nk)||isempty(nk))
    msg = 'The values of the properties "na", "nb" and "nk" must be non-negative integer matrices. Type "idprops idnlarx" for more information.';
    msg = struct('identifier','Ident:idnlmodel:idnlarxOrders','message',msg);
    return
end

[ny1,ny2] = size(na);
if ny1~=ny2
    msg = 'The value of the property "na" must be a square matrix. Type "idprops idnlarx" for more information.';
    msg = struct('identifier','Ident:idnlmodel:idnlarxOrderNa','message',msg);
    return
end

if isempty(nb) && isempty(nk)
    nb = zeros(ny1,0);
    nk = zeros(ny1,0);
end

[ny2,nu1]  = size(nb);
if ny1~=ny2
    msg = sprintf('The values of the properties "%s" and "%s" must have the same number of rows. Type "idprops idnlarx" for more information.','na','nb');
    msg = struct('identifier','Ident:idnlmodel:idnlarxOrderRows','message',msg);
    return
end

[ny2,nu2] = size(nk);
if ny1~=ny2
    msg = sprintf('The values of the properties "%s" and "%s" must have the same number of rows. Type "idprops idnlarx" for more information.','na','nk');
    msg = struct('identifier','Ident:idnlmodel:idnlarxOrderRows','message',msg);
    return
end

if nu1~=nu2
    msg = sprintf('The values of the properties "%s" and "%s" must have the same number of rows. Type "idprops idnlarx" for more information.','nb','nk');
    msg = struct('identifier','Ident:idnlmodel:idnlarxOrderRows','message',msg);    
    return
end

NANBNK = [na,nb,nk];
if ~isempty(NANBNK) && any(any((fix(NANBNK)~=NANBNK) | NANBNK<0))
    msg = 'The values of the properties "na", "nb" and "nk" must be non-negative integer matrices. Type "idprops idnlarx" for more information.';
    msg = struct('identifier','Ident:idnlmodel:idnlarxOrders','message',msg);
    return
end

% Note: All zeros should be allowed: there may be customreg
% if ~any([na(:);nb(:)])
%   msg = 'na and nb cannot be all zeros.';
%   return
% end

% FILE END

