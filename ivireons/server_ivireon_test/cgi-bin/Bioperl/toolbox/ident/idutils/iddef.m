function [str,props,type,values] = iddef(arg)
%IDDEF  basic definition of structures used in IDENT
%

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.14.4.13 $ $Date: 2008/10/02 18:51:25 $

switch arg
    case 'algorithm'
        props    = {'Focus','MaxIter','Tolerance','LimitError','MaxSize',...
            'SearchMethod','Criterion','Weighting','FixedParameter','Display','N4Weight',...
            'N4Horizon','Advanced'};

        sea = struct('GnPinvConst',1e4,'InitGnaTol',1e-4,'LmStep',2,'StepReduction',2,'MaxBisections',25,...
            'LmStartValue',0.001,'RelImprovement',0);
        thresh = struct('Zstability',1+sqrt(eps),'Sstability',0,'AutoInitialState',1.05);
        advanced = struct('Search',sea,'Threshold',thresh);
        values   = {'Prediction',20,0.01,0,'Auto','Auto','det',[],[],'Off',...
            'Auto','Auto',advanced};
        str      = cell2struct(values,props,2);
        if nargout > 2
            type = {{'Prediction','Simulation','Stability'},...
                {'integer'},{'positive'},{'positive'},...
                {'integer'},{'Auto','gna','lm','gn','grad','lsqnonlin'},...
                {'det','trace'},{''},{''},{'Off','On','Full'},...
                {'Auto','MOESP','CVA'},{'intarray'},{'struct'}};
        end

    case 'structpoly'
        props  = {'na','nb','nc','nd','nf','nk','InitialState'};
        values = {0,[],0,0,[],[],'Zero'};
        str    = cell2struct(values,props,2);
        if nargout > 2
            type  = {{'integer'},{'integer'},{'integer'},{'integer'},{'integer'},...
                {'integer'},{'Zero','Estimate','Backcast','Auto'}};
        end

    case 'estimation'
        props = {'Status','Method','LossFcn','FPE','DataName','DataLength','DataTs',...
            'DataDomain','DataInterSample','WhyStop','UpdateNorm','LastImprovement',...
            'Iterations','InitialState','Warning'};
        values={'Not estimated',[],[],[],[],[],[],'Time',[],[],[],[],[],[],'None'};
        str = cell2struct(values,props,2);
        if nargout > 2
            type  ={{'Not estimated','Estimated model',...
                'Model modified after last estimate'},...
                {'positive'},{'positive'},{'string'},{'integer'},{'positive'},...
                {'Zero order hold','First order hold','BandLimited'},{'string'},...
                {'positive'},{'positive'},{'integer'},{'string'}};
        end
    otherwise
        ctrlMsgUtils.error('Ident:utility:iddef1')
end
