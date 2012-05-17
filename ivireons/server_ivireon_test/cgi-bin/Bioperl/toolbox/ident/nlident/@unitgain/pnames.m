function [Props,AsgnVals] = pnames(nlobj, flag)
%PNAMES  All UNITGAIN public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(NL) returns the list PROPS of
%   public properties of the object NL, as well as the
%   assignable values ASGNVALS for these properties.  Both
%   PROPS and ASGNVALS are cell vector of strings, and PROPS
%   contains the true case-sensitive property names.
%
%   PNAMES(SYS,'readonly') returns the read-only properties only.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:20:41 $

% Author(s): Qinghua Zhang

Props = {};

if  nargout
  AsgnVals = {};
end
  
% FILE END

