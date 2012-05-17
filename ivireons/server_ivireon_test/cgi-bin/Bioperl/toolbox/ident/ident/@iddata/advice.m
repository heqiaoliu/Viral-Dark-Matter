function varargout = advice(d,Type)
%ADVICE gives advice and suggestions on properties of IDDATA objects.
%
%   ADVICE(DATA) displays advice in MATLAB Command Window.
%
%   ADVICE(DATA, TYPE) issues advice related to requested aspects only.
%   TYPE can take following values:
%   TYPE = 'general' issues advice on general aspects related to handling
%          absence of I/O channels, input inter-sample behavior, missing
%          data samples and presence of trends and offsets.
%   TYPE = 'excitation' issues advice on information content and order of
%           persistence (excitation) in input signals.
%   TYPE = 'feedback' issues advice related to possibility of feedback in
%           data and how to estimate models in presence of feedback.
%   TYPE = 'nonlinearity' issues advice on possibility of nonlinearity in
%           data (time domain data only).
%   TYPE = 'all' (default) returns advice on all of the above aspects.
%
%   ADV = ADVICE(DATA) returns the advice text as a struct with selected
%         TYPE as a field (all types in case Type = 'all') rather than
%         displaying it in MATLAB Command Window.
%
%   See also iddata/feedback, iddata/pexcit, iddata/isnlarx, misdata.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.11.4.13 $  $Date: 2009/03/09 19:13:21 $

if nargin<2
    Type = 'All';
end

if ~ischar(Type)
    ctrlMsgUtils.error('Ident:iddata:adviceType')
end

isAuto = false;
if isempty(d)
    adv.General = {'Data set is empty. No advice available.'};
else
    [N,ny,nu,ne] = size(d);
    dom = d.Domain; %dom = lower(dom(1));
    
    was = warning('off'); [lw,lwid]=lastwarn;
    if strncmpi(Type,'a',1)
        isAuto = true;
        CurrentTypes = {'General','Excitation','Feedback','Nonlinearity'};
        for k = 1:length(CurrentTypes)
            try
                [advcell,TypeName,emptyTs] = LocalGetAdvice(CurrentTypes{k},d,N,ny,nu,ne,dom);
                if any(emptyTs)
                    advcell{end+1} = sprintf('%s\n%s',...
                        'Assessment of input excitation levels or indication of ',...
                        'feedback or nonlinearity cannot be performed for such data.');
                    adv.(TypeName) = advcell;
                    break;
                end
            catch E
                warning(was); lastwarn(lw,lwid)
                throw(E)
            end
            adv.(TypeName) = advcell;
        end
    else
        [advcell,TypeName] = LocalGetAdvice(Type,d,N,ny,nu,ne,dom);
        adv.(TypeName) = advcell;
    end
    warning(was); lastwarn(lw,lwid)
end

if nargout
    varargout{1} = adv;
else
    f = fieldnames(adv);
    for i = 1:length(f)
        advi = adv.(f{i});
        if isAuto
            Titl = LocalGetTitle(f{i});
            fprintf('%s:\n%s\n',Titl,repmat('-',1,length(Titl)+1));
        end
        for k = 1:length(advi)
            fprintf('%s\n\n',advi{k});
        end
    end
end

%--------------------------------------------------------------------------
function [adv,TypeName,emptyTs] = LocalGetAdvice(Type,d,N,ny,nu,ne,dom)
% issue context (Type) specific advice

u=d.InputData; % cell array since called from own method
y=d.OutputData;
Ts = pvget(d,'Ts');
isTimeData = strcmpi(dom,'time');

emptyTs = cellfun('isempty',Ts);
adv = {};
switch lower(Type(1))
    case 'g'
        TypeName = 'General';
        % general info
        if ne>1
            str = ['[',int2str(N),']'];
        else
            str = int2str(N);
        end
        adv{end+1} = sprintf('This is a %s domain data set with %d input(s) and %d output(s),\n%s samples and %d experiment(s).',...
            lower(dom),nu,ny,str,ne);
        
        if any(emptyTs)
            if sum(emptyTs)>1
                adv{end+1} = sprintf('%s\n%s',...
                    ['Data in experiment numbers ',mat2str(find(emptyTs)),' are irregularly sampled.'],...
                    'As a result, this data set cannot be used for estimation or analysis.');
            else
                adv{end+1} = sprintf('%s\n%s','Data is irregularly sampled.',...
                    'As a result, it cannot be used for estimation or analysis.');
            end
            return;
        end
        
        % check number of channels vs number of samples
        if ne>1
            str = ' (in at least one experiment)';
        else
            str = '';
        end
        if any(ny>N | nu>N)
            adv{end+1} = sprintf('%s%s.\n%s',...
                'There are more channels than samples in this dataset',str,...
                'Verify that data values are not accidentally transposed.');
        end
        
        % no output data
        if ny==0
            adv{end+1} = sprintf('%s\n%s\n%s',...
                'There is no output signal in this data set. Such data sets are usually used',...
                'for simulation of models. Models cannot be estimated using such data, but input',...
                'spectra can be estimated by using ETFE, SPA, and SPAFDR commands.');
        end
        
        % no input data
        if nu==0
            if isTimeData
                adv{end+1} = sprintf('%s\n%s\n%s',...
                    'There is no input signal in this data set. Parametric models of output ',...
                    'spectra can be estimated using ARX, ARMAX, N4SID and PEM commands. ',...
                    'Non-parametric models can be estimated using SPA, ETFE and SPAFDR commands.');
            else
                adv{end+1} = sprintf('%s\n%s\n%s',...
                    'There is no input signal in this data set. For frequency domain data,',...
                    'parametric models of spectra can only be estimated using the ARX command.',...
                    'Non-parametric models can be estimated using SPA, ETFE and SPAFDR commmands.');
            end
        end
        
        % inter-sample behavior
        if nu >0 && isTimeData
            inter = unique(d.InterSample(:));
            if strcmp(inter{1},'zoh')
                adv{end+1} = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s',...
                    'All inputs in the data have been denoted as ''zero order hold'' (''zoh''), i.e. they are',...
                    'assumed to be piecewise constant over the sampling interval.',...
                    'If the input is a sampled continuous signal and you plan to build or convert to',...
                    'continuous-time models, it is recommended to mark the InterSample property as',...
                    '''First order hold'': Data.InterSample = ''foh'' or Data.int = {''foh'',''foh'', ...} for',...
                    'multi-input signals.');
            end
        end
        
        % missing data
        if isnan(d)
            adv{end+1} = sprintf('%s\n%s',...
                'Your data contains missing data points (marked as NaN). You must run MISDATA',...
                'before you use the estimation routines.');
        end
        
        % offsets and trends
        if ~isTimeData
            return
        end
        for kexp=1:ne
            uu = u{kexp};
            yy = y{kexp};
            
            my = 0; % to handle ny=0 case %zeros(1,ny);
            for ky = 1:ny
                my(ky) = mean(yy(:,ky));
            end
            
            mu = zeros(1,nu);
            for ku=1:nu
                mu(ku) = mean(uu(:,ku));
            end
            
            if nu>0
                if any(my>0.0001/max(my))||any(mu>0.001/max(mu))
                    adv{end+1} = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s',...
                        'Some inputs and/or outputs have non-zero means. It is generally recommended to',...
                        'remove the means by DAT = DETREND(DAT), except in the following cases:',...
                        '1. The signals are measured relative to a level that corresponds to a',...
                        '   physical equilibrium. This could e.g. be the case if step responses',...
                        '   are recorded from an equilibrium point. In this case, it is advisable',...
                        '   to remove the equilibrium values rather than data means. You may do so',...
                        '   using a TrendInfo object with DETREND command. Type "help idutils.TrendInfo"',...
                        '   for more information.',...
                        '2. There is an integrator in the system, and the input and output ',...
                        '   levels are essential to describe the effect of the integration.',...
                        '3. You are going to use the data to estimate nonlinear ARX models.');
                end
            else
                if any(my>0.0001/max(my))
                    adv{end+1} = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s',...
                        'All outputs are not zero mean. It is generally recommended to',...
                        'remove the means by DAT = DETREND(DAT), except in the following cases:',...
                        '1. The signals are measured relative to a level that corresponds to a',...
                        '   physical equilibrium. This could e.g. be the case if step responses',...
                        '   are recorded from an equilibrium point. In this case, it is advisable',...
                        '   to remove the equilibrium values rather than data means. You may do so',...
                        '   using a TrendInfo object with DETREND command. Type "help idutils.TrendInfo"',...
                        '   for more information.',...
                        '2. There is an integrator in the system, and the output ',...
                        '   levels are essential to describe the effect of the integration.',...
                        '3. You are going to use the data to estimate nonlinear ARX models.');
                end
            end
        end
        
    case 'e'
        TypeName = 'Excitation';
        
        if any(emptyTs)
            if sum(emptyTs)>1
                adv{end+1} = sprintf('%s\n%s',...
                    ['Data in experiment numbers ',mat2str(find(emptyTs)),' are irregularly sampled.'],...
                    'Information on excitation level cannot be obtained for such data.');
            else
                adv{end+1} = sprintf('%s\n%s','Data is irregularly sampled.',...
                    'Information on excitation level cannot be obtained for such data.');
            end
            return;
        end
        
        if isTimeData
            for kexp=1:ne
                if ne==1
                    txtkexp = '';
                else
                    txtkexp = [' in experiment number ',int2str(kexp)];
                end
                uu = u{kexp};
                yy = y{kexp};
                
                my = zeros(1,ny);
                for ky = 1:ny
                    my(ky) = mean(yy(:,ky));
                end
                
                mu = zeros(1,nu);
                for ku=1:nu
                    % First test if some inputs are identical
                    nonzeroInd1 = find(uu(:,ku)~=0);
                    ll1 = uu(nonzeroInd1,ku);
                    for kuu=ku+1:nu
                        if norm(uu(:,kuu)-uu(:,ku)) == 0
                            adv{end+1} = sprintf('%s%s%s%s','The inputs ',int2str(ku),' and ',...
                                int2str(kuu),' are identical. A model may not be identifiable using these inputs.');
                        else
                            nonzeroInd2 = find(uu(:,kuu)~=0);
                            ll2 = uu(nonzeroInd2,kuu);
                            if isequal(nonzeroInd1,nonzeroInd2) && length(ll1)==length(ll2) && (all(ll1./ll2==ll1(1)/ll2(1)) || all(diff([ll1(:),ll2(:)],1,2)==ll2(1)-ll1(1)))
                                adv{end+1} = sprintf('%s%s%s%s','The inputs ',int2str(ku),' and ',...
                                    int2str(kuu),' are parallel. A model may not be identifiable using these inputs.');
                            end
                        end
                    end
                    if nu == 1
                        txtku = 'The input';
                    else
                        txtku= ['Input number ',int2str(ku)];
                    end
                    du = diff(uu(:,ku));
                    ns = find(abs(du)>0.0001*max(uu(:,ku)))+1;
                    mu(ku) = mean(uu(:,ku));
                    
                    if isempty(ns)
                        if nu==1
                            adv{end+1} = sprintf('%s%s%s\n%s\n%s\n%s',txtku,txtkexp,...
                                ' is essentially a constant. Estimating parameters',...
                                'associated with this input will be difficult.',...
                                'If the input is a step occurring at time 0, then shift the data,',...
                                'and prepend zeros, to let the step happen at sample 10 or so.');
                        else
                            adv{end+1} = sprintf('%s%s%s\n%s\n%s',txtku,txtkexp,...
                                ' is essentiallly a constant. Estimating',...
                                'parameters associated with this input will be difficult,',...
                                'unless the other experiments support this input.');
                            
                        end
                    elseif length(ns)==1%&ns<25
                        adv{end+1} = sprintf('%s%s %s %d.\n%s\n%s\n%s\n%s\n%s',txtku,txtkexp,...
                            'is essentially a step occurring at sample number',ns,...
                            'Estimating models of orders larger than this number will not take advantage',...
                            'of the information in this input.',...
                            'If models of higher order are of interest, it is recommended to use more steps,',...
                            'or to let the step occur later or to prepend the input output data with signals',...
                            'of constant levels, corresponding to a system equilibrium.');
                    elseif max(ns)<N/2
                        adv{end+1} = sprintf('%s%s %s %d.\n%s\n%s\n%s\n%s\n%s',txtku,txtkexp,...
                            'has all its variation occurring before sample number',max(ns),...
                            'Estimating models of orders larger than this number will not take advantage',...
                            'of the information in this input.',...
                            'If models of higher order are of interest, it is recommended to use more variation,',...
                            'or to let the variation occur later, or to prepend the input output data with signals',...
                            'of constant levels, corresponding to a system equilibrium.');
                    end
                    
                end
            end
        end
        
        % order of persistence
        try
            if nu>0
                [pe,maxnr] = pexcit(d);
                pemu = find(pe==maxnr-1);
                %notpemu = setdiff([1:nu],pemu);
                if ~isempty(pemu) && all(pemu == 1:nu)
                    if nu == 1
                        txt = 'The input is';
                    else
                        txt = 'All inputs are';
                    end
                    adv{end+1} = sprintf('%s %s\n%s %d %s',txt,...
                        'persistently exciting of high order.',...
                        'This means that you should be able to build models of orders up to',...
                        maxnr,'or so, if necessary.');
                else
                    if nu ==1
                        adv{end+1} = sprintf('%s %d. %s\n%s',...
                            'The input is persistently exciting of order',pe(1),'This means that you',...
                            ['will encounter problems if estimating models of order higher than ',num2str(pe(1)),'.']);
                    else
                        [mpr,mu] = min(pe);
                        adv{end+1} = sprintf('%s %d %s %d.\n%s\n%s\n%s [%s].',...
                            'Input number',mu,'is persistently exciting of order',mpr,...
                            'This means that you will have problems when estimation models of order',...
                            ['higher than ' num2str(mpr),', at least for model parameters associated with this input.'],...
                            'The excitation orders for all the inputs are',num2str(pe));
                    end
                end
            else
                adv{end+1} = 'Excitation level cannot be determined for time series data.';
            end
        catch
            adv{end+1} =  sprintf('%s\n%s',...
                'Information on excitation level could not be obtained from data.',...
                'Use the "pexcit" command to test the data for degree of excitation.');
        end
        
    case 'f'
        TypeName = 'Feedback';
        
        if any(emptyTs)
            if sum(emptyTs)>1
                adv{end+1} = sprintf('%s\n%s',...
                    ['Data in experiment numbers ',mat2str(find(emptyTs)),' are irregularly sampled.'],...
                    'Possibility of feedback cannot be determined for such data.');
            else
                adv{end+1} = sprintf('%s\n%s','Data is irregularly sampled.',...
                    'Possibility of feedback cannot be determined for such data.');
            end
            return;
        end
        
        if ny>0 && nu>0
            try
                was = warning('off'); [lw,lwid] = lastwarn;
                [fbck,fbck0,nudir] = feedback(d);
                warning(was), lastwarn(lw,lwid)
                if any(nudir)
                    adv{end+1} = sprintf('%s\n%s %s %s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s',...
                        'There is an indication that the system has a direct response from',...
                        'input number(s)',int2str(nudir),'at time t to y(t).',...
                        'There may be two reasons for this:',...
                        ' 1. There is direct feedback from y(t) to u(t) (like a P-regulator).',...
                        '    In that case it is essential not to let this feedback influence the model.',...
                        '    It is thus important always to use nk>0 for these inputs in state-space and',...
                        '    input-output models.',...
                        ' 2. The system has a direct term (relative degree zero). Then it is essential',...
                        '    to use nk = 0 for these inputs in all models. (Note that state-space models',...
                        '    have nk = 1 as default, so use:',...
                        '    MODEL = PEM(Data,n,''nk'',0), where n is the model order.)');
                end
                % This could be done as i/o pairs:
                
                fblev = max(max(fbck)');
                if ~isnan(fblev)
                    if fblev < 60
                        str = 'There is no significant indication of feedback in the data.';
                        if any(nudir)
                            str = sprintf('%s\n%s',str,...
                                '(Unless you decide that the direct term is due to feedback.)');
                        end
                        str = sprintf('%s\n%s',str,...
                            'Use the "feedback" command for assessment of feedback with more options.');
                        adv{end+1} = str;
                    else
                        if fblev>99
                            txt = 'a very strong indication';
                        elseif fblev>90
                            txt = 'a strong indication';
                        else
                            txt = 'a possible indication';
                        end
                        adv{end+1} = sprintf('%s %s %s\n%s\n%s\n%s\n%s\n%s\n%s',...
                            'There is',txt,'of feedback in the data.',...
                            'You should be careful when interpreting the results of SPA and also interpret',...
                            'the results of output error models with care (Output error models result from',...
                            'the OE command or setting ''DisturbanceModel''= ''None'' in state-space models.).',...
                            'With feedback in data, it is recommended to use estimate a model with large enough ',...
                            'disturbance model. For example, use BJ models in place of OE models and estimate ',...
                            'state space models using ''DisturbanceModel''= ''Estimate''.');
                    end
                end
            catch
                adv{end+1} = sprintf('%s\n%s','Possibility of feedback could not be determined.',...
                    'Use the "feedback" command for assessment of feedback in data with more options.');
            end
        elseif ny>0
            adv{end+1} = 'Possibility of feedback cannot be determined for time series data.';
        elseif nu>0
            adv{end+1} = 'Possibility of feedback cannot be determined because data contains no output signals.';
        end % if ny>0
    case 'n'
        TypeName = 'Nonlinearity';
        
        if any(emptyTs)
            if sum(emptyTs)>1
                adv{end+1} = sprintf('%s\n%s',...
                    ['Data in experiment numbers ',mat2str(find(emptyTs)),' are irregularly sampled.'],...
                    'Possibility of nonlinearity cannot be determined for such data.');
            else
                adv{end+1} = sprintf('%s\n%s','Data is irregularly sampled.',...
                    'Possibility of nonlinearity cannot be determined for such data.');
            end
            return;
        end
        
        
        if isTimeData
            advnl = {};
            for kexp=1:ne
                if ne==1
                    txtkexp = '';
                else
                    txtkexp = [' in experiment number ',int2str(kexp)];
                end
                uu = u{kexp};
                %yy = y{kexp};
                binu = [];
                for ku=1:nu
                    if all(uu(:,ku)==max(uu(:,ku)) | uu(:,ku)==min(uu(:,ku)))
                        binu(end+1) = ku;
                    end
                end
                if ~isempty(binu)
                    isare = 'is';
                    if nu == 1
                        txtku = 'The input';
                    elseif numel(binu)==1
                        txtku = ['Input number ',int2str(ku)];
                    else
                        txtku = ['Inputs ', mat2str(binu)];
                        isare = 'are';
                    end
                    
                    advnl{end+1} = sprintf('%s%s %s %s %s\n%s\n%s',txtku,txtkexp,isare,'binary.',...
                        'Building nonlinear models with this data may be difficult.',...
                        'In particular, Hammerstein models (IDNLHW with only input nonlinearity) ',...
                        'cannot be supported.');
                end
                
            end
            
            if (nu ~=0) && (ny~=0) && isreal(d) && ~isnan(d)
                adv = [adv;advnl];
                try
                    nl = isnlarx(d,[4*eye(ny),4*ones(ny,nu),ones(ny,nu)]);
                    if any(nl)
                        nnly = find(nl==1);
                        if ny>1
                            chn = 'output channel(s) ';
                            chn = [chn,mat2str(nnly)];
                        else
                            chn = 'the data';
                        end
                        
                        if ny==1 && nu==1
                            ord = '[4 4 1]';
                        elseif nu>1 && ny==1
                            ord = sprintf('[4 4*ones(1,%d) 4*ones(1,%d)]',nu,nu);
                        else
                            ord = sprintf('[4*eye(%d) 4*ones(%d,%d) 4*ones(%d,%d)]',ny,ny,nu,ny,nu);
                        end
                        
                        adv{end+1} = sprintf('%s %s.\n%s%s%s\n%s\n%s\n%s\n%s',...
                            'There is an indication of nonlinearity in',chn,...
                            'A nonlinear ARX model of order ',ord,' and treepartition nonlinearity',...
                            'estimator performs better prediction of output than the corresponding ',...
                            'ARX model of the same order. Consider using nonlinear models, such as IDNLARX, ',...
                            'or IDNLHW. You may also use the "isnlarx" command to test for ',...
                            'nonlinearity with more options.');
                    else
                        adv{end+1} = sprintf('%s\n%s','There is no clear indication of nonlinearities in this data set.',...
                            'Use the "isnlarx" command to perform the assessment of nonlinearity with more options.');
                    end
                catch
                    adv{end+1} = sprintf('%s\n%s','Possibility of nonlinearity could not be determined.',...
                        'Use the "isnlarx" command for assessment of nonlinearity in data.');
                end
            elseif isnan(d)
                adv{end+1} = sprintf('%s\n%s',...
                    'Data contains missing samples (NaNs). Possibility of nonlinearity cannot be determined for such data.',...
                    'Note that estimation of nonlinear models requires data with no missing samples.');
            elseif ny>0 && isreal(d)
                adv{end+1} = 'Possibility of nonlinearity cannot be determined for time series data.';
            elseif nu>0 && isreal(d)
                adv{end+1} = 'Possibility of nonlinearity cannot be determined for data containing no output signals.';
            elseif ~isreal(d)
                adv{end+1} = sprintf('%s\n%s','Possibility of nonlinearity cannot be determined for complex data.',...
                    'Note that estimation of nonlinear models requires real data.');
            end
        else
            adv{end+1} = sprintf('%s\n%s',...
                'No assessment of nonlinearity is available for frequency domain data.',...
                'Note that estimation of nonlinear models requires time domain data.');
        end
    otherwise
        ctrlMsgUtils.error('Ident:analysis:adviceInvalidInput',Type)
end

%--------------------------------------------------------------------------
function str = LocalGetTitle(f)

switch lower(f(1))
    case 'g'
        str = 'General data characteristics';
    case 'e'
        str = 'Excitation level in data';
    case 'f'
        str = 'Possibility of feedback in data';
    case 'n'
        str = 'Possibility of nonlinearity';
end

