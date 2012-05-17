function hnr=iduiwok(k)
%IDUIWOK Checks if window number k in the ident GUI exists.
%      If it does, its handle number is returned, otherwise [] is returned.

%   L. Ljung 9-27-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2006/06/20 20:09:08 $

tag=['sitb',int2str(k)];
hnr=findobj(allchild(0),'flat','tag',tag);