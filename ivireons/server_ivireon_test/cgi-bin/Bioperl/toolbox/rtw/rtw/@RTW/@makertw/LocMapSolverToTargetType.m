function output = LocMapSolverToTargetType(h, hModel, solver, tlcTargetType)
% Abstract:
%      Given the solver type (and tlcTargetType) determine the type of
%      target: RT or NRT.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2009/03/05 18:51:40 $


switch (solver)
    case getSolversByParameter('SolverType','Fixed Step')
        output = 'RT';
    case getSolversByParameter('SolverType','Variable Step')
        output = 'NRT';
        if strcmp(tlcTargetType,'RT')
            msg = DAStudio.message('RTW:makertw:invalidSolverOption', h.ModelName);
            cmd = sprintf( ...
                ['open_system(''%s'');',...
                 'slCfgPrmDlg(''%s'', ''Open'');', ...
                 'slCfgPrmDlg(''%s'', ''TurnToPage'', ''Solver'');'], ...
                h.ModelName,h.ModelName,h.ModelName);
            slprivate('slNagOpenFcn','set',msg,cmd);
            DAStudio.slerror('RTW:makertw:invalidSolverOption', hModel, h.ModelName);

        end
 
  otherwise
    DAStudio.error('RTW:makertw:unknownSolver',solver);
end
%endfunction LocMapSolverToTargetType
