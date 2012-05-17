function setMetaData(this,var,MD)
% Construct metadata structure

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:13:37 $
if ~isa(MD,'hds.metadata')
   error('Third argument must be a @metadata object.')
end
[var,idx] = findvar(this,var);
if isempty(idx)
   error('Can only retrieve metadata for root-level variables.')
end
this.Data_(idx).MetaData = MD;
