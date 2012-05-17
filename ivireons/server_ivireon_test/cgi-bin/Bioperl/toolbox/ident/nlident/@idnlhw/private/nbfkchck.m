function msg = nbfkchck(nb,nf,nk)
%NBFKCHCK: nb, nf, nk consistency check

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:24:23 $

% Author(s): Qinghua Zhang

msg = struct([]);

if ~isnonnegintmat(nb)
    msg = sprintf('The value of the "%s" property must be a matrix of non-negative integers.','nb');
    msg = struct('identifier','Ident:general:nonnegIntMatPropVal','message',msg);
    return
end

if ~all(any(nb>0,2))
    msg = 'Each row of the "nb" property must have at least one non-zero entry.';
    msg = struct('identifier','Ident:general:allZeroNb','message',msg);
    return
end

if ~isnonnegintmat(nf)
    msg = sprintf('The value of the "%s" property must be a matrix of non-negative integers.','nf');
    msg = struct('identifier','Ident:general:nonnegIntMatPropVal','message',msg);
    return
end
if ~isnonnegintmat(nk)
    msg = sprintf('The value of the "%s" property must be a matrix of non-negative integers.','nk');
    msg = struct('identifier','Ident:general:nonnegIntMatPropVal','message',msg);
    return
end

if ~isequal(size(nb), size(nf), size(nk))
    msg = sprintf('The values of the properties "nb", "nf" and "nk" must have the same size. Type "idprops idnlhw" for more information.');
    msg = struct('identifier','Ident:idnlmodel:idnlhwOrderSizes','message',msg);
end

% FILE END