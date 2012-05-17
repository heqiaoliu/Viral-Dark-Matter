function idm = timemark(idm,w)
%TIMEMARK Mark iddata objects with time stamps
%
%    DAT = TIMEMARK(DAT,w)
%    w = 'l' gives a 'last modified mark'
%    w = 'c' gives a 'created' mark
%    w = 'g' retrieves the timemarks
%    The information is stored in the iddata.Utility property
%    (hidden) under the fields 'last'and 'create', resp.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2009/04/21 03:22:16 $

if nargin<2,w='l';end
ut = idm.Utility;
if strcmp(w,'g')
    try
        tm1 = ut.create;
    catch
        tm1 = [];
    end
    try
        tm2 = ut.last;
    catch
        tm2 = [];
    end
    if ~isempty(tm1)
        idm = sprintf(['Created:       ',datestr(datenum(tm1(1),tm1(2),...
            tm1(3),tm1(4),tm1(5),tm1(6)))]);
    else
        idm = '';
    end
    
    if ~isempty(tm2)
        idm = str2mat(idm,['Last modified: ',...
            datestr(datenum(tm2(1),tm2(2),...
            tm2(3),tm2(4),tm2(5),tm2(6)))]);
    end
    return
end

if strcmp(w,'l');
    idm.Utility.last = clock;
else
    idm.Utility.create = clock;
    idm.Utility.last = idm.Utility.create;        
end

