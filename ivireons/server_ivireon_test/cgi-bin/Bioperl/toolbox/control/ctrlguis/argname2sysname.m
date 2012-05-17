function ArgsOut = argname2sysname(ArgsIn,ArgNames)
% ARGNAME2SYSNAME
% Helper function which assigns the ArgNames(K) to ArgsIn(k).Name if
% ArgsIn(k) is a LTI or IDMODEL or IDFRD object. Used for functions such as
% step, bode and etc.

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:53:41 $

ArgsOut = cell(size(ArgsIn));

for ct = 1:length(ArgsIn)
    argj = ArgsIn{ct};
    if (isa(argj,'lti') || isa(argj,'idmodel') || isa(argj,'idfrd')) && isempty(argj.Name)
        argj.Name = ArgNames{ct};
    end
    ArgsOut{ct} = argj;
end
   