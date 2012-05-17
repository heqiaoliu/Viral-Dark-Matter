function [models,helper,harn] = pcgd_assignModels(evalName)

%   Copyright 2007 The MathWorks, Inc.

    models = {};
    harn = {};
    if (strcmp(evalName,'auto'))
        models = {'rtwdemo_PCG_Eval_P1','rtwdemo_PCG_Eval_P2','rtwdemo_PCG_Eval_P3',...
                  'rtwdemo_PCG_Eval_P4','rtwdemo_PCG_Eval_P5','rtwdemo_PCG_Eval_P6',...
                  'rtwdemo_PCG_Eval_P7'};
        helper = {'rtwdemo_pi_controller',...
                  'rtwdemo_ValidateLegacyCodeVrsSim',...
                  'PCG_Eval_Sfun_5'};
        harn   = {'rtwdemo_PCGEvalHarness','rtwdemo_PCGEvalHarnessSFun'};
    else
        fprintf('Evaluation not found: %s not a valid PCG evaluation\n',...
                 evalName);
    end
end
