function toggleLinearizationMode(this,flag)
%TOGGLELINEARIZATIONMODE Toggle the linearization mode between block by
%block and numerical perturbation

%   Author(s): J. Glass
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/03/13 17:39:54 $

% Use Model Perturbation disable for block linearization
if strcmp(flag,'numericalpert')
    if isa(this,'ModelLinearizationNodes.ModelLinearizationSettings')
        javaMethodEDT('enablePanel',this.Dialog.IOPanel,false)       
    end
elseif strcmp(flag,'blockbyblock')
    if isa(this,'ModelLinearizationNodes.ModelLinearizationSettings')
        javaMethodEDT('enablePanel',this.Dialog.IOPanel,true)
    end
end