function thd=thc2thd(thc,T)
%THC2THD  Converts a continuous time model to discrete time.
%   This function is OBSOLETE. Use C2D instead. See HELP IDMODEL/C2D.
%
%   THD = THC2THD(THC,T)
%
%   THC: The continuous time model, specified in THETA format
%           (See also THETA).
%
%   T: The sampling interval
%   THD: The discrete time model, in THETA format
%
%   Note that the covariance matrix is not translated to discrete time
%   for input-output type models
%
%   See also THD2THC.

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2005/12/22 18:12:41 $

if nargin < 2
    disp('Usage: THD = THC2THD(THC,T)')
    return
end
if ~isa(thc,'idmodel')
    error(sprintf(['The argument to thc2thd must be an IDMODEL object.',...
        '\nUse TH2IDO to convert the old THETA-format model to IDMODEL.']))
end

thd = c2d(thc,T);

