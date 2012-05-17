function tf = firstfilter(this,var)
% BROWSEFILTER 
% Checks if given variable should be included in the import browser

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2010/04/21 21:10:33 $

% Only check for class because size check will be done in secondfilter
% Size can not be determined from a mat file for matlab objects it must be
% loaded.
if any(strcmp(var.class,{'tf','ss','zpk','frd','idpoly','idss','idarx'})) 
    tf = true;
else
    tf = false;
end
