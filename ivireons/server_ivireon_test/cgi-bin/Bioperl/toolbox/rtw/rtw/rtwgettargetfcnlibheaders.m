function headers = rtwgettargetfcnlibheaders(model)
% This function is called from block TLC code to get header files
%  from the target function library
%

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

    libH = get_param(model,'TargetFcnLibHandle');
    if isempty(libH)
        headers = [];
    else
        headers = libH.getUsedHeaders();
    end
    
    
                         
                         
