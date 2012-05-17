function tf = firstfilter(this,var) %#ok<*INUSL>
% BROWSEFILTER 
% Checks if given variable should be included in the import browser

%   Author(s): R Chen
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:21:52 $

% Only check for class because size check will be done in secondfilter
% Size can not be determined from a mat file for matlab objects it must be
% loaded.
if any(strcmp(var.class,{'tf','zpk','ss','frd','pid','pidstd','idss','idarx','idgrey','idproc','idpoly','idfrd'})) 
    tf = true;
else
    tf = false;
end
