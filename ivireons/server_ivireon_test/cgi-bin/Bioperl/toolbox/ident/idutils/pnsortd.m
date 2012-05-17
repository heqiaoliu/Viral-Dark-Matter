function [arg1,arg2] = pnsortd(list1,list2,n)
%PNSORTD sorts a property/value-list into two lists
%
%   [arg1,arg2] = PNSORTD(list1,list2,n)
%   list1: The original list (cell array)
%   list2: The list of properties that should be sorted out
%   n: The number of characters which the comparison is basen on
%   arg1: The PN-list from list1 that do not match the pnames of list2
%   arg2: The PN-list from list1 that match the pnames of list2. The
%   property names are replaced by the full name.

%   Author: L. Ljung 2003-06-18
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $ $Date: 2008/10/02 18:51:54 $

if nargin < 3
    n = 7;
end
was = warning;
if nargin < 2
    warning('off','Ident:idmodel:obsoletePropSearchDir');
    warning('off','Ident:idmodel:obsoletePropTrace');
    warning('off','Ident:idmodel:obsoletePropApproach');
    list2 = {'TimeUnit','InputName','InputUnit','OutputName','OutputUnit'};
end
arg1 = {};pnr = 0;
arg2 = {};fnr = 0;
if floor(length(list1)/2)~=length(list1)/2
    warning(was)
    ctrlMsgUtils.error('Ident:utility:PVPairsExpected')
end
for k = 1:2:length(list1)
    try
        pna = pnmatchd(list1{k},list2,n);
    catch
        pna = [];
    end
    if isempty(pna)
        arg1(pnr+1:pnr+2)=list1(k:k+1);
        pnr = pnr+2;
    else
        arg2(fnr+1:fnr+2)={pna,list1{k+1}};
        fnr = fnr+2;
    end
end
warning(was);
