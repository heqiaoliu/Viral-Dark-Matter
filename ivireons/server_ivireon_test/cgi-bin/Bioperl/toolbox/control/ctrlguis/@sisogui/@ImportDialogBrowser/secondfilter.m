function tf = secondfilter(this,var)
% BROWSEFILTER 
% Checks if given variable should be included in the import browser

%   Author(s): John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/04/21 21:10:34 $

if any(strcmp(class(var),{'tf','ss','zpk','frd'}))
    sz = size(var);
    if isequal(length(sz),2)
        tf = isequal(sz,[1 1]);
    elseif isequal(length(sz),4)
        tf = any(sz(3:4)==1);
    else
        tf = false;
    end
elseif any(strcmp(class(var),{'idpoly','idss','idarx'}))
    sz = size(var);
    tf = isequal(sz([1 2]),[1 1]);
else
    tf = false;
end
