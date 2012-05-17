function tf = secondfilter(this,var) %#ok<*INUSL>
% BROWSEFILTER 
% Checks if given variable should be included in the import browser

%   Author(s): R. Chen
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:13:11 $

if isa(var,'ltipack.SingleRateSystem')
    sz = size(var);
    tf = issiso(var) && isequal(sz,[1 1]) && var.Ts>=0;
elseif isa(var,'idmodel') || isa(var,'idfrd')
    sz = size(var);
    tf = isequal(sz([1 2]),[1 1]) && var.Ts>=0;
else
    tf = false;
end
