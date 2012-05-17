function val = getDisplayLabel(this)
%GETDISPLAYLABEL returns string displayed in tree

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:16 $

val = '';
if(isa(this, 'DAStudio.Object'))
  val = this.Name;
end

% EOF



