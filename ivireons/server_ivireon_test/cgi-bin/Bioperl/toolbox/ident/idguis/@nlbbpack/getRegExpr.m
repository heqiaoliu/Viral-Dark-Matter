function str = getRegExpr(m,row,ynum)
% construct string that should fill the 4th column of regressor table

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:53:30 $

[ny,nu] = size(m);
uname = m.uname;
yname = m.yname;
if row<=nu+1
    %var = ['u',int2str(row-1)];
    var = uname{row-1};
    N = m.nb(ynum,row-1);
    Ini = m.nk(ynum,row-1);
else
    var = yname{row-nu-2};
    %var = ['y',int2str(row-nu-2)];
    N = m.na(ynum,row-nu-2);
    Ini = 1;
end

switch N
    case 0
        str = '<none>';
    case 1
        str = sprintf('%s(t-%d)',var,Ini);
    case 2
        str = sprintf('%s(t-%d), %s(t-%d)',var,Ini,var,Ini+1);
    case 3
        str = sprintf('%s(t-%d), %s(t-%d), %s(t-%d)',var,Ini,var,Ini+1,var,Ini+2);
    otherwise
        str = sprintf('%s(t-%d), %s(t-%d), ..., %s(t-%d)',var,Ini,var,Ini+1,var,Ini+N-1);
end