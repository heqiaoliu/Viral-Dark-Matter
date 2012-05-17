function errorString = dspFilterRealizedInBasicElemsAlgLoopErrFcnCallback(subSysHandle, errorTypeString)
%dspFilterRealizedInBasicElemsAlgLoopErrFcnCallback - used by REALIZEMDL
%             to replace the (more confusing) algebraic loop error which
%             can result from algebraic loop presence in recursive filters
%             realized using basic elements when the input signal is frame-
%             based.  This function should be used as the ErrorFcn callback
%             for a subsystem realized using basic elements via REALIZEMDL.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/02/25 08:27:00 $
switch (errorTypeString)
    case {'Simulink:Engine:BlkInAlgLoopErrWithInfo','Simulink:Engine:AlgLoopTrouble'}
        errorString = sprintf('This recursive filter subsystem was realized using either the ''Build model using basic elements'' mode in the Filter Design and Analysis Tool (FDATool), or the REALIZEMDL method from the MATLAB command line. These subsystems contain sample-by-sample feedback (recursive processing), and therefore require sample-based inputs and outputs to avoid algebraic loops within the filter structure.\n\nThere are two possible solutions you can implement:\n\n(1) Do not use frame-based signals. Instead, convert the input signal to sample based, for instance with an Unbuffer block. You can convert back to frame-based signals using a Buffer block after the filter output. Note that the use of Unbuffer and/or Buffer blocks will make this a multirate model.\n\n(2) Do not use a filter subsystem built from basic blocks. Instead use the Digital Filter block, which directly supports frame-based signals. Filter Realization Wizard and FDATool use the Digital Filter block instead of a subsystem implementation if you uncheck ''Build model using basic elements'' before you realize the model. This solution is also equivalent to using the BLOCK method from the MATLAB command line.\n\nMost, but not all, filter structures are supported by the second solution. Those that are not supported do not allow you to change the ''Build model using basic elements'' check box or use the BLOCK method from the command line. You can also access the Digital Filter block directly from the Signal Processing Blockset.');
    otherwise
        err         = sllasterror;
        errorString = err.Message;
end
