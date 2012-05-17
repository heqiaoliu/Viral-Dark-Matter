function boo =  isNotIterativeEstimation(Model)
% Determine if estimation is iterative or not
% Return true if estimaiton is non-iterative

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:43 $

boo = false;
allWave = true;
allTreeOrMLnet = true;
iterw = Model.Algorithm.IterWavenet;
foc = 'prediction';

switch class(Model)
    case 'idnlarx'
        foc = Model.Focus;
        NL = Model.Nonlinearity;
        % check if all are tree or mlnet
        MlnetTreeInd = [];
        for k = 1:length(NL)
            if ~(isa(NL(k),'neuralnet') || isa(NL(k),'treepartition'))
                allTreeOrMLnet = allTreeOrMLnet && false;
            else
                MlnetTreeInd(end+1) = k;
            end
        end

        if allTreeOrMLnet
            boo = true;
            return;
        end

        % check if remaining are all wavenet
        for k = setdiff(1:length(NL),MlnetTreeInd)
            if ~isa(NL(k),'wavenet')
                allWave = false;
                break;
            end
        end
        %-----------------------------------------------------------------
    case 'idnlhw'
        return; % currently, all idnlhw is iterative
        
        %{
        for k = 1:length(Model.InputNonlinearity)
            if ~isa(Model.InputNonlinearity(k),'wavenet')
                allWave = false;
                break;
            end
        end
        if allWave
            for k = 1:length(Model.OutputNonlinearity)
                if ~isa(Model.OutputNonlinearity(k),'wavenet')
                    allWave = false;
                    break;
                end
            end
        end
        %}
end %switch

if allWave && (strcmpi(iterw,'off') || (strcmpi(iterw,'auto') &&...
        ~isestimated(Model))) && strcmpi(foc,'prediction') 
    boo = true;
    return;
end


