function Req = exportRequirement(this) 
% EXPORTREQUIREMENT  method to convert plotconstr object to equivalent
% srorequirement object
%
 
% Author(s): A. Stothert 
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:16 $

Req = clone(this.Requirement);

%Ensure requirement has correct feedback sign
Req.FeedbackSign = 1;

%Ensure requirement has correct normalization value
Req.NormalizeValue = 1;