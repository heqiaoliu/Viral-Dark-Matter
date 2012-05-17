function desfcn = getdesignfunction(this)
%GETDESIGNFUNCTION   Return the design function to be used in the
%coefficients design

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/01/05 18:00:11 $


if this.MinPhase || (isprop(this,'MaxPhase') && this.MaxPhase) ||...
        (isprop(this,'MinOrder') && ~isequal(this.MinOrder,'any')) ||...
        (isprop(this,'StopbandShape') && ~isequal(this.StopbandShape,'flat')) ||...
        (isprop(this,'UniformGrid') && ~this.UniformGrid) || ...
        (~isprop(this,'UniformGrid') && isfdtbxinstalled)
        
   desfcn = @firgr;

else
    desfcn = @firpm;
end
           
% [EOF]
