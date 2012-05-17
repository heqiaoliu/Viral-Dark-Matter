function Req = exportRequirement(this) 
% EXPORTREQUIREMENT  method to convert plotconstr object to equivalent
% srorequirement object
%
 
% Author(s): A. Stothert 28-Jul-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:40 $

Req = clone(this.Requirement);

%Ensure requirement has correct normalization value
Req.NormalizeValue = 1;