function varargout = bertool(varargin)
%BERTOOL Bit Error Rate Analysis Tool.
%   BERTOOL launches the Bit Error Rate Analysis Tool (BERTool). BERTool is
%   a Graphical User Interface (GUI) that enables you to analyze
%   communications links' BER performance via theoretical, semianalytic, or
%   Monte Carlo simulation-based approach.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.41 $  $Date: 2010/05/20 01:57:57 $

import com.mathworks.toolbox.comm.BERTool

persistent fig ax xAxis yAxis params data lines linesShown colors ...
    nextColor marks nextMark legends legendsShown legendHandle figFile ...
    figSaved modelPath modelName modelFullName pathName EbNoString EbNo ...
    berName maxNumErrs maxNumBits rmpathNeeded stopFun simIndex berVector ...
    numBitsVector tempLineHandle; % tempLineHandle added to enable point-by-point plot for Monte-Carlo simulations
mlock;

if nargin < 1
    if isempty(fig)
        if usejava('swing')
            
            BERTool.show;
            BERTool.setDefaultParams(exist('commgraycode.mdl', 'file') == 4);

            fig = figure('name', 'BER Figure', ...
                'numberTitle', 'off', ...
                'visible', 'off', ...
                'tag', 'BERToolFigure', ...
                'toolbar', 'none', ...
                'IntegerHandle', 'off', ...
                'menu', 'none');
            set(fig, 'closeRequestFcn', ...
                @(hSrc,eData)set(hSrc, 'visible', 'off'));

            plotedit(fig, 'off');

            ax = gca;
            set(ax, 'yscale', 'log');
            xlabel('E_b/N_0 (dB)');
            ylabel('BER');
            grid on;
            set(ax, 'buttonDownFcn', 'bertool(''resetLineWidth'')');
            hold on;
            set(fig, 'renderer', 'zbuffer');

            dm = datacursormode(fig);
            set(dm, 'DisplayStyle', 'datatip');

            % figure menu (copied from figuretools.m)
            menus = {
                '&File',                '',            'filemenufcn FilePost';
                '>&Save^S',             'figMenuFileSave',   'bertool(''saveFigure'')';
                '>Save &As...',         'figMenuFileSaveAs', 'bertool(''saveFigureAs'')';
                '>-----',               '',            '%-----';
                '>Pa&ge Setup...',      '',            'filemenufcn(gcbf,''FilePageSetup'')';
                '>Print Set&up...',     '',            'filemenufcn(gcbf,''FilePrintSetup'')';
                '>Print Pre&view...',   '',            'filemenufcn(gcbf,''FilePrintPreview'')';
                '>&Print...^P',         '',            'printdlg(gcbf)';
                '>-----',               '',            '%-----';
                '>&Close^W',            '',            'filemenufcn(gcbf,''FileClose'')';

                '&Edit',                'figMenuEdit', 'editmenufcn(gcbf,''EditPost'')';
                '>&Y Axis Limits...',   'figMenuEditGCA', 'bertool(''YAxis'')';

                '&Tools',               'figMenuTools',     'toolsmenufcn ToolsPost';
                '>&Zoom In',            'figMenuZoomIn',    'toolsmenufcn ZoomIn';
                '>Zoom &Out',           'figMenuZoomOut',   'toolsmenufcn ZoomOut';
                '>Pa&n',                'figMenuPan',       'toolsmenufcn Pan';
                '>D&ata Cursor',        'figMenuDatatip',   'toolsmenufcn Datatip';
                '>Options',             'figMenuOptions',         'toolsmenufcn Options';
                '>>Unconstrained Zoom'  'figMenuOptionsXYZoom',   'toolsmenufcn ZoomXY';
                '>>Horizontal Zoom'     'figMenuOptionsXZoom',    'toolsmenufcn ZoomX';
                '>>Vertical Zoom'       'figMenuOptionsYZoom',    'toolsmenufcn ZoomY';
                '>>-----',              '',                       '%-----';
                '>>Unconstrained Pan '  'figMenuOptionsXYPan',    'toolsmenufcn PanXY';
                '>>Horizontal Pan'      'figMenuOptionsXPan',     'toolsmenufcn PanX';
                '>>Vertical Pan'        'figMenuOptionsYPan',     'toolsmenufcn PanY';
                '>>-----',              '',                       '%-----';
                '>>Display Cursor as Datatip'  'figMenuOptionsDatatip',  'toolsmenufcn DatatipStyle';
                '>>Display Cursor in Window'   'figMenuOptionsDataBar',  'toolsmenufcn DataBarStyle';

                '&Window',              'figMenuWindow',           'winmenu(gcbo)';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                '>blank',               '',                        '';
                };
            makemenu(fig, str2mat(menus{:,1}), str2mat(menus{:,3}), str2mat(menus{:,2}));

            % figure toolbar
            toolbar = uitoolbar('parent', fig, 'handleVisibility', 'off');
            uitoolfactory(toolbar, 'Standard.PrintFigure');
            uitoolfactory(toolbar, 'Exploration.ZoomIn');
            uitoolfactory(toolbar, 'Exploration.ZoomOut');
            uitoolfactory(toolbar, 'Exploration.Pan');
            uitoolfactory(toolbar, 'Exploration.DataCursor');
            leg = uitoolfactory(toolbar, 'Annotation.InsertLegend');
            set(leg, 'ToolTipString', 'Show Legend');
            set(leg, 'ClickedCallBack', 'bertool(''showLegend'')');

            screenSize = get(0, 'screenSize');
            figWidth = 500;
            figHeight = 420;
            set(fig, 'position', ...
                [min(BERTool.getFrameRightEdge, screenSize(3)-figWidth), ...
                (screenSize(4)-figHeight)/3, ...
                figWidth, ...
                figHeight]);

            set(fig, 'handleVisibility', 'off');

            params = {};
            data = {};
            colors = {[0 0 1], [0 .9 0], [1 0 0], [0 .7 .7], [.7 0 .7], [.7 .7 0], [0 0 0]};
            nextColor = 1;
            marks = {'*', '+', 'o', 'd', 'v', 's', '^'};
            nextMark = 1;
            legends = {};
            linesShown = [];
            legendsShown = {};
            figFile = 'untitled.fig';
            figSaved = false;
            rmpathNeeded = false;
            xAxis = [inf -inf];
            yAxis = [1e-8 1];
            tempLineHandle = 0; % default value for handle
        else
            error('comm:bertool:JavaSupport', 'BERTool requires Java Swing.');
        end
    else
        BERTool.show;
    end
else
    switch varargin{1}
        case 'simulationInit'
            [mode, modelPath, EbNoString, berName, maxNumErrs, maxNumBits] = ...
                deal(varargin{:}); %#ok<ASGLU>

            try
                EbNo = sort(evalin('base', EbNoString));

                if (~is(EbNo, 'real') || ~is(EbNo, 'vector'))
                    varargout{1} = 'failed';
                    varargout{2} = 'invalid EbNo';
                    varargout{3} = 0;
                    return;
                end
            catch %#ok
                varargout{1} = 'failed';
                varargout{2} = 'invalid EbNo';
                varargout{3} = 0;
                return;
            end

            try
                maxNumErrs = evalin('base', maxNumErrs);
            catch %#ok
                varargout{1} = 'failed';
                varargout{2} = 'invalid maxNumErrs';
                varargout{3} = 0;
                return;
            end

            try
                maxNumBits = evalin('base', maxNumBits);
            catch %#ok
                varargout{1} = 'failed';
                varargout{2} = 'invalid maxNumBits';
                varargout{3} = 0;
                return;
            end

            [fPath, fName, ext] = fileparts(modelPath);
            base = fullfile(fPath, fName);
            
            if ~(strcmp(strtok(ext), '.m') || strcmp(strtok(ext), '.mdl'))
                fullPath = which(base);

                if (isempty(fullPath) || ...
                        ~isempty(strfind(fullPath, strcat(filesep, 'fullfile.m'))))
                    try
                        modelPath = eval(modelPath);
                        [fPath, fName, ext] = fileparts(modelPath);
                        base = fullfile(fPath, fName);
                        if isempty(ext)
                            fullPath = which(base);
                            [b, ext] = strtok(fullPath, '.'); %#ok<ASGLU>
                        end
                    catch %#ok
                        varargout{1} = 'failed';
                        varargout{2} = 'invalid MATLABFileOrModel';
                        varargout{3} = 0;
                        return;
                    end
                else
                    [b, ext] = strtok(fullPath, '.'); %#ok<ASGLU>
                end
            end

            [modelFullName, pathName] = strtok(fliplr(modelPath), filesep);
            modelFullName = fliplr(modelFullName);
            modelName = strtok(modelFullName, '.');
            pathName = fliplr(pathName);

            if ~exist(modelName, 'file') && ~isempty(pathName)
                addpath(pathName);
                rmpathNeeded = true;
            end

            if strcmp(ext, '.mdl')
                try
                    load_system(modelPath);
                catch %#ok
                    varargout{1} = 'failed';
                    varargout{2} = 'invalid model';
                    varargout{3} = 0;
                    return;
                end

                assignin('base', 'maxNumErrs', maxNumErrs);
                assignin('base', 'maxNumBits', maxNumBits);
                stopFun = get_param(modelName, 'stopfcn');
                set_param(modelName, 'stopfcn', strcat(stopFun, ';bertool(''stopped'')'));
                sllasterror([]);
            end

            varargout{1} = 'successful';
            varargout{2} = strcmp(ext, '.mdl');
            varargout{3} = length(EbNo);
        case 'runModel'
            if evalin('base', strcat('exist(''', berName, ''',''var'')'))
                evalin('base', strcat(berName, '=[];'));
            end
            simIndex = varargin{2};
            BERTool.setSimulatingEbNo(modelFullName, num2str(EbNo(simIndex)));
            assignin('base', 'EbNo', EbNo(simIndex));
            set_param(modelName, 'simulationcommand', 'start');

            
        case 'checkModelStatus'
            if strcmpi(get_param(modelName, 'SimulationStatus'), 'stopped')
                varargout{1} = sllasterror;
            else
                varargout{1} = [];
            end
        case 'stop'
            set_param(modelName, 'simulationcommand', 'stop');
        case 'stopped'
            if evalin('base', strcat('exist(''', berName, ''',''var'')'))
                if evalin('base', strcat('length(', berName, ')>=3'))
                    berVector(simIndex) = evalin('base', strcat(berName, '(1)'));
                    numBitsVector(simIndex) = evalin('base', strcat(berName, '(3);'));
                end
                msg = '';
            else
                set_param(modelName, 'stopfcn', stopFun);
                open(modelPath);
                msg = 'berName mismatch';
            end

            BERTool.stopped(msg);
            % enable point-by-point plot for monte-carlo simulations:
            bertool('simulationplot_point',berVector,EbNo(1:simIndex));
           
            
        case 'finished'
            simLength = length(berVector);

            paramSet = {modelPath, EbNo, maxNumErrs, maxNumBits};
            dataSet = {EbNo(1:simLength), berVector, numBitsVector};

            params = [params, {paramSet}];
            data = [data, {dataSet}];
            
            varargout{1} = 'successful';
            varargout{2} = EbNo(1:simLength);
            varargout{3} = berVector;
            varargout{4} = numBitsVector;
            varargout{5} = mat2str(EbNo(1:simLength));
            
            berVector = [];
            numBitsVector = [];
        case 'simCleanUp'
            if rmpathNeeded
                s = warning('off', 'MATLAB:rmpath:DirNotFound');
                rmpath(pathName);
                warning(s.state, s.identifier);
            end

            if varargin{2}
                set_param(modelName, 'stopfcn', stopFun);
            end

            berVector = [];
            numBitsVector = [];
        case 'matlabSimulation'
            for i = 1:length(EbNo)
                BERTool.setSimulatingEbNo(modelFullName, num2str(EbNo(i)));
                
                try
                    [ber, numBits] = feval(modelName, EbNo(i), maxNumErrs, maxNumBits);
                catch %#ok
                    varargout{1} = 'failed';
                    varargout{2} = [];
                    varargout{3} = [];
                    varargout{4} = [];
                    varargout{5} = '';
                    return;
                end

                berVector(i) = ber;
                numBitsVector(i) = numBits;
                
                if BERTool.getSimulationStop
                    break;
                end
                
               % enable point-by-point plot for monte-carlo simulations:
               bertool('simulationplot_point',berVector,EbNo(1:i));
               pause(0.01); % the plot lags the Ebno value in status bar by one point. pause takes care of problem.
                   
            end

            paramSet = {modelPath, EbNo, maxNumErrs, maxNumBits};
            dataSet = {EbNo(1:i), berVector, numBitsVector};

            params = [params, {paramSet}];
            data = [data, {dataSet}];
            
            varargout{1} = 'successful';
            varargout{2} = EbNo(1:i);
            varargout{3} = berVector;
            varargout{4} = numBitsVector;
            varargout{5} = mat2str(EbNo(1:i));
            
            if rmpathNeeded
                rmpath(pathName);
            end

            berVector = [];
            numBitsVector = [];
        case 'calculate'
            fun = varargin{2};
            args = varargin{3};
            varargout{4} = [];
            varargout{5} = [];

            if (strcmpi(fun, 'bersync'))
                indices = [1, 2];
            elseif (strcmpi(fun, 'berfading'))
                if (length(args) < 6) ...
                        || (strcmpi(args{2}, 'fsk') && (length(args) < 7)) % Rayleigh
                    if strcmpi(args{2}, 'oqpsk')
                        indices = [1, 3];
                    elseif strcmpi(args{2}, 'fsk')
                        indices = [1, 3:4, 6];
                    else
                        indices = [1, 3, 4];
                    end
                else                    % Rician
                    if strcmpi(args{2}, 'psk')
                        indices = [1, 3:6];
                    else
                        indices = [1, 3:4, 6:7];
                    end
                end
            elseif (strcmpi(fun, 'bercoding'))
                if strcmpi(args{2}, 'conv')
                    try
                        trellis = evalin('base', args{4});
                    catch exception
                        varargout{1} = 'failed';
                        varargout{2} = exception.message;
                        varargout{3} = 'invalidTrellis';
                        return;
                    end
                    
                    if ~istrellis(trellis)
                        varargout{1} = 'failed';
                        varargout{2} = '';
                        varargout{3} = 'invalidTrellis';
                        return;
                    end
                    
                    indices = 1;
                    
                    % codeRate
                    args{4} = log2(trellis.numInputSymbols) / ...
                        log2(trellis.numOutputSymbols);
                    
                    try
                        args{5} = distspec(trellis, 8);
                    catch exception
                        varargout{1} = 'failed';
                        varargout{2} = exception.message;
                        varargout{3} = 'catastrophicTrellis';
                        return;
                    end
                else
                    switch args{2}
                        case 'block'
                            indices = [1, 4:6, 8];
                        case {'Hamming', 'Golay'}
                            indices = [1, 4, 6];
                        case 'RS'
                            indices = [1, 4:5, 7];
                    end
                    if any(strcmpi(args, 'oqpsk')) || ...
                            any(strcmpi(args, 'msk'))
                        indices = indices(1:end-1);
                    end
                end
            elseif (strcmpi(fun, 'berawgn'))
                if strcmpi(args{2}, 'msk')
                    indices = 1;
                elseif strcmpi(args{2}, 'cpfsk')
                    indices = [1, 3:length(args)];
                elseif strcmpi(args{2}, 'oqpsk')
                    indices = 1;
                else
                    indices = [1, 3];
                end
            else        % semianalytic
                indices = [1, 2, 4:8];
            end

            for i = indices
                try
                    args{i} = evalin('base', args{i});
                catch %#ok
                    % Do not return, so that more detailed error messages
                    % can be caught later.
                end
            end

            % Sort EbNo
            if strcmpi(fun, 'semianalytic')
                args{end} = sort(args{end});
            else
                args{1} = sort(args{1});
            end

            i = checkParamDuplicate(params, args);

            if (i > 0)
                varargout{1} = 'duplicate';
                varargout{2} = i - 1;   % Java index is 0 based
                varargout{3} = [];

                if strcmp(fun, 'semianalytic')
                    varargout{4} = [];
                end

                return;
            else
                try
                    ber = feval(fun, args{:});
                catch exception
                    varargout{1} = 'failed';
                    varargout{2} = exception.message;
                    varargout{3} = '';

                    if strcmp(fun, 'semianalytic')
                        varargout{4} = [];
                    end

                    return;
                end

                varargout{1} = 'unique';

                if strcmp(fun, 'semianalytic')
                    ebnoEvaled = args{end};

                    % number of bits
                    varargout{4} = length(args{1}) * args{4} / args{5};
                else
                    ebnoEvaled = args{1};
                end

                varargout{2} = ebnoEvaled;
                varargout{3} = ber;
                varargout{5} = mat2str(ebnoEvaled);

                if ~isempty(ebnoEvaled)
                    params = [params, {args}];
                    data = [data, {{ebnoEvaled, ber, varargout{3}}}];
                end

                return;
            end
            
        case 'plot'
            if isa(varargin{2}, 'char')
                plotEbNo = evalin('base', varargin{2});
            else
                plotEbNo = varargin{2};
            end
            ber = varargin{3};
            label = varargin{4};

            if (nargin > 4)
                mark = varargin{5};
            else
                mark = '';
            end

            figure(fig);
            set(fig, 'handleVisibility', 'on');

            lineHandle = semilogy(plotEbNo, ber, mark);
            
            set(lineHandle, 'color', colors{nextColor});
            lines = [lines; lineHandle];
            linesShown = [linesShown; lineHandle];
            legends = [legends, {label}];
            legendsShown = [legendsShown, {label}];

            % feval required for legend
            legendHandle = feval('legend', linesShown, legendsShown);
            delete(get(legendHandle, 'uicontextmenu'));

            varargout{2} = colors{nextColor};

            if (nextColor >= length(colors))
                nextColor = 1;
            else
                nextColor = nextColor + 1;
            end

            axisScale(yAxis);

            xAxis(1) = min(xAxis(1), plotEbNo(1));
            xAxis(2) = max(xAxis(2), plotEbNo(end));

            set(fig, 'handleVisibility', 'off');
            varargout{1} = lineHandle;
        case 'connectFigureAndTable'
            % Since the table row entry for the 'line' is not ready at the
            % 'plot' stage, we need to wait until the Java code has completed
            % rendering the row.  JAva code will call this
            % 'connectFigureAndTable' once it is done with rendering and connect
            % the line in the figure and the row in the table.
            
            lineHandle = varargin{2};
            if ishghandle(lineHandle)
                set(lineHandle, 'buttonDownFcn', ...
                    @(src,edata)bertool('selectLine', get(fig, 'currentObject')));
            end
        case 'simulationPlot'
            % delete the last line left by simulationplot_point
            if (tempLineHandle~=0)
                delete(tempLineHandle);
                tempLineHandle = 0;
            end
            
            simEbNo = varargin{2};
            ber = varargin{3};
            numBits = varargin{4};
            label = varargin{5};

            [varargout{1} color] = bertool('plot', simEbNo, ber, label, marks{nextMark});
            
                if ~(isempty(ber) || any(isnan(ber)))
                    varargout{2} = bertool('confint', simEbNo, ber, numBits, color, marks{nextMark});
                end

                % Remove invalid BER due to requirement of BERFIT
                indices = (ber>=0) & (ber<=0.5);
                simEbNo = simEbNo(indices);
                ber = ber(indices);

                if length(ber) > 3

                    try
                        varargout{3} = bertool('fit', simEbNo, ber, color);
                    catch exception
                        varargout{3} = [];
                        warning('comm:bertool:BerfitError', 'The following warnings are caused by BERTool trying to perform curve fit.');
                        warning(exception.identifier, exception.message);
                    end
                else
                    varargout{3} = [];
                    warning('comm:bertool:NotenoughBERvalues', 'Curve fit cannot be done for less than 4 BER values');
                end
                
                if (nextMark >= length(marks))
                    nextMark = 1;
                else
                    nextMark = nextMark + 1;
                end

        % enable point-by-point plot for monte Carlo simulations        
        case 'simulationplot_point'
            % ber and plotEbNo hold the cumulative results up to the current simulation point      
            % example: EbNo = 0:5;
            % first pass: plotEbNo = [0], ber = [ber0];
            % second pass:  plotEbNo = [0 1], ber = [ber0 ber1];
            % sixth pass:   plotEbNo = [0 1 2 3 4 5], ber = [ber0 ber1 ber2 ber3 ber4 ber5];
            ber = varargin{2};
            plotEbNo = varargin{3};

            mark = marks{nextMark};
            
            figure(fig);
            set(fig, 'handleVisibility', 'on');
            
            % delete previous temporary plot 
            % done to keep legend correct
            if (tempLineHandle~=0)
                delete(tempLineHandle);
            end

            lineHandle = semilogy(plotEbNo, ber, mark);
            tempLineHandle = lineHandle; % will delete handle at next pass
            
            set(lineHandle, 'color', colors{nextColor});

            varargout{2} = colors{nextColor};

            axisScale(yAxis);

            xAxis(1) = min(xAxis(1), plotEbNo(1));
            xAxis(2) = max(xAxis(2), plotEbNo(end));

            set(fig, 'handleVisibility', 'off');
            varargout{1} = lineHandle;

        case 'fit'
            empEbNo = varargin{2};
            empBER = varargin{3};
            fitEbNo = linspace(empEbNo(1), empEbNo(end), 100);
            
            % Store any previous warnings
            [prevWarnMsg, prevWarnID] = lastwarn;
            lastwarn('');  
            
            warnState = warning('query', 'all');
            warning('off', 'comm:berfit:noDesirableFit');
            warning('off', 'comm:berfit:maxNumFunctionEval');
            warning('off', 'comm:berfit:BERNaN');
            fitBER = berfit(empEbNo, empBER, fitEbNo);
            warning(warnState);
            
            % Check if berfit returned any warnings
            [warnMsg, warnID] = lastwarn;
            if ( ~isempty(warnID) )
                warning('comm:bertool:BerfitError',...
                    ['The following warnings are caused by BERTool trying '...
                    'to perform a curve fit.']);
                warning(warnID, warnMsg);
            else
                % If not, restore any previous warnings
                lastwarn(prevWarnMsg, prevWarnID);
            end;
            
            if ( ~isempty(fitBER) )
                figure(fig);
                set(fig, 'handleVisibility', 'on');
                lineHandle = semilogy(fitEbNo, fitBER);
                set(lineHandle, 'color', varargin{4});

                set(lineHandle, 'visible', 'off');
                set(fig, 'handleVisibility', 'off');
                varargout{1} = lineHandle;
            else
                varargout{1} = [];
            end;
        case 'confint'
            simEbNo = varargin{2};
            ber = varargin{3}(:);
            numBits = varargin{4}(:);
            numErrs = round(ber .* numBits);
            mark = varargin{6};

            % First determine the EbNo points that are simulated.  If the
            % simulation is stopped in the middle, then some numBits will be
            % zero and we cannot determine confidence interval for those points.
            % Remove those points from the results vectors.
            runSims = (numBits > 0);
            simEbNo = simEbNo(runSims);
            ber = ber(runSims);
            numBits = numBits(runSims);
            numErrs = numErrs(runSims);
            
            confInt = cell(3,1);
            i = 1;
            for level = [.9, .95, .99]
                [tmp, confInt{i}] = berconfint(numErrs, numBits, level); %#ok<ASGLU>
                i = i + 1;
            end

            figure(fig);
            set(fig, 'handleVisibility', 'on');

            % for confidence level 90%
            e = ber - confInt{1}(:, 1);
            confInt90 = errorbar(simEbNo, ber, e, mark);
            set(confInt90, 'color', varargin{5});
            set(confInt90, 'visible', 'off');

            % for confidence level 95%
            e = ber - confInt{2}(:, 1);
            confInt95 = errorbar(simEbNo, ber, e, mark);
            set(confInt95, 'color', varargin{5});
            set(confInt95, 'visible', 'off');

            % for confidence level 99%
            e = ber - confInt{3}(:, 1);
            confInt99 = errorbar(simEbNo, ber, e, mark);
            set(confInt99, 'color', varargin{5});
            set(confInt99, 'visible', 'off');

            set(fig, 'handleVisibility', 'off');
            varargout{1} = [confInt90, confInt95, confInt99];
        case 'showFigure'
            figure(fig);
        case 'setVisible'
            handles = varargin{2};
            visibilities = varargin{3};

            for i = 1:length(handles)
                set(handles(i), 'visible', visibilities{i});
            end

            if nargin > 3
                plot = varargin{4};
                index = varargin{5} + 1;
                precedingLinesShown = varargin{6};

                if plot
                    toAddLegend = true;
                    if (length(linesShown) > precedingLinesShown)
                        toAddLegend = (lines(index) ~= linesShown(precedingLinesShown+1));
                    end

                    if toAddLegend

                        % Insert line
                        tmpLines = zeros(length(linesShown)+1, 1);
                        tmpLines(1:precedingLinesShown) = linesShown(1:precedingLinesShown);
                        tmpLines(precedingLinesShown+1) = lines(index);
                        tmpLines(precedingLinesShown+2 : length(linesShown)+1) = ...
                            linesShown(precedingLinesShown+1:end);
                        linesShown = tmpLines;

                        % Insert legend
                        tmp = cell(1, length(legendsShown)+1);
                        tmp(1:precedingLinesShown) = legendsShown(1:precedingLinesShown);
                        tmp{precedingLinesShown+1} = legends{index};
                        tmp(precedingLinesShown+2 : length(legendsShown)+1) = ...
                            legendsShown(precedingLinesShown+1:end);
                        legendsShown = tmp;
                    end
                else
                    if length(linesShown) > precedingLinesShown
                        linesShown(precedingLinesShown+1) = [];
                        legendsShown(precedingLinesShown+1) = [];
                    end
                end
            end

            figure(fig);
            set(fig, 'handleVisibility', 'on');

            if isempty(legendsShown)
                feval('legend', 'off');
            else
                legendHandle = feval('legend', linesShown, legendsShown);
                delete(get(legendHandle, 'uicontextmenu'));
            end

            if ~isempty(linesShown)
                axisScale(yAxis);
            end
            set(fig, 'handleVisibility', 'off');
        case 'selectLine'
           set(varargin{2}, 'lineWidth', 2);
          BERTool.selectDataSetOf(varargin{2});
        case 'setLineWidth'
            index = varargin{2} + 1;
            for i = 1:length(lines)
                if (i == index)
                    set(lines(i), 'lineWidth', 2);
                else
                    set(lines(i), 'lineWidth', 1);
                end
            end
        case 'resetLineWidth'
            for i = 1:length(lines)
                set(lines(i), 'lineWidth', 1);
            end
        case 'setLegend'
            label = varargin{2};
            index = varargin{3} + 1;
            precedingLinesShown = varargin{4};
            plot = varargin{5};
            legends{index} = label;
            if plot
                legendsShown{precedingLinesShown+1} = label;
            end
            if ~isempty(linesShown)
                legendHandle = feval('legend', linesShown, legendsShown);
                delete(get(legendHandle, 'uicontextmenu'));
            end
        case 'showLegend'
            htoolbar = findall(fig,'type','uitoolbar');
            ltogg = findall(htoolbar,'Tag','Annotation.InsertLegend');
            set(fig, 'handleVisibility', 'on');

            if (~isempty(ltogg) && ...
                    isequal(ltogg, gcbo) && ...
                    strcmpi(get(ltogg,'state'),'on'))

                figure(fig);
                legend show;
            else
                figure(fig);
                legend hide;
            end
            set(fig, 'handleVisibility', 'off');
        case 'YAxis'
            lower = 10;
            upper = 1;
            answer = '1';
            invalid = false;

            while ((invalid || (lower >= upper) || (lower <= 0) || (upper > 1)) ...
                    && ~isempty(answer))

                lower = yAxis(1);
                upper = yAxis(2);
                answer = inputdlg({'Lower limit:', 'Upper limit:'}, ...
                    'Y Axis Limits', 1, {num2str(yAxis(1)), num2str(yAxis(2))});

                if length(answer) >= 2
                    try
                        lower = eval(answer{1});
                        upper = eval(answer{2});
                    catch %#ok
                        invalid = true;
                    end
                end
            end

            if (lower < upper)
                yAxis = [lower upper];
                set(fig, 'handleVisibility', 'on');
                axisScale(yAxis);
                set(fig, 'handleVisibility', 'off');
            end
        case 'open'
            params = varargin{2};
            data = varargin{3};
            numDataSets = length(params);
            lines = [];
            linesShown = [];
            legends = {};
            legendsShown = {};
            colors = varargin{7};
            nextColor = 1;
            marks = varargin{8};
            nextMark = 1;
            yAxis = varargin{9};
            cla(ax);

            try
                confIntervals = cell(1, numDataSets);
                fits = cell(1, numDataSets);
                for i = 1:numDataSets
                    if varargin{5}{i}
                        mark = '*';
                    else
                        mark = '';
                    end

                    [lineHandle, confInterval, fit] = ...
                        importData(varargin{4}{i}, ...
                        data{i}, ...
                        {varargin{5}{i}, varargin{6}{i}}, ...
                        mark, ...
                        linesShown); %#ok<ASGLU>

                    confIntervals{i} = confInterval;
                    fits{i} = fit;
                end

                varargout{1} = 'successful';
            catch %#ok
                bertool('cleanUp');
                yAxis = [1e-8 1];
                confIntervals = {};
                fits = {};
                varargout{1} = 'failed';
            end

            varargout{2} = lines;
            varargout{3} = confIntervals;
            varargout{4} = fits;
        case 'save'
            varargout{1} = params;
            varargout{2} = data;
            varargout{3} = colors;
            varargout{4} = marks;
            varargout{5} = yAxis;
        case 'import'
            file = varargin{2};
            if isempty(file)        % import from workspace structure
                BERs = varargin{3}; % structure name

                try
                    paramSet = struct2cell(evalin('base', strcat(BERs, '.paramsEvaled'))).';
                    dataSet = evalin('base', strcat(BERs, '.data'));
                    cellEditabilities = evalin('base', strcat(BERs, '.cellEditabilities'));

                    if cellEditabilities{1}

                        % Synchronize with import from file:
                        % The following line decides whether to check
                        % duplicate:
                        i = 0;

                        mark = marks{nextMark};

                        if (nextMark == length(marks))
                            nextMark = 1;
                        else
                            nextMark = nextMark + 1;
                        end
                    else
                        i = checkParamDuplicate(params, paramSet);
                        mark = '';
                    end

                    if (i > 0)
                        varargout{1} = 'duplicate';
                        varargout{2} = i - 1;
                        varargout{3} = [];
                        varargout{4} = [];
                        varargout{5} = [];
                        varargout{6} = [];
                    else
                        params = [params, {paramSet}];
                        data = [data, {dataSet}];

                        varargout{1} = struct2cell(evalin('base', strcat(varargin{3}, '.params')));
                        varargout{2} = evalin('base', strcat(varargin{3}, '.dataView'));
                        varargout{3} = cellEditabilities;

                        [varargout{4}, varargout{5}, varargout{6}] = ...
                            importData(varargout{2}, dataSet, cellEditabilities, mark, linesShown);
                    end
                catch exception
                    varargout{1} = 'invalidStructure';
                    varargout{2} = exception.message;
                    varargout{3} = [];
                    varargout{4} = [];
                    varargout{5} = [];
                    varargout{6} = [];
                end
            else    % import from file
                try
                    s = load(file);
                    ber = fieldnames(s);
                    ber = ber{1};
                    paramSet = struct2cell(eval(strcat('s.', ber, '.paramsEvaled'))).';
                    dataSet = eval(strcat('s.', ber, '.data'));
                    cellEditabilities = eval(strcat('s.', ber, '.cellEditabilities'));

                    if cellEditabilities{1}

                        % Synchronize with import from workspace:
                        % The following line decides whether to check
                        % duplicate:
                        i = 0;

                        mark = marks{nextMark};

                        if (nextMark == length(marks))
                            nextMark = 1;
                        else
                            nextMark = nextMark + 1;
                        end
                    else
                        i = checkParamDuplicate(params, paramSet);
                        mark = '';
                    end

                    if (i > 0)
                        varargout{1} = 'duplicate';
                        varargout{2} = i - 1;
                        varargout{3} = [];
                        varargout{4} = [];
                        varargout{5} = [];
                        varargout{6} = [];
                    else
                        params = [params, {paramSet}];
                        data = [data, {dataSet}];

                        varargout{1} = struct2cell(eval(strcat('s.', ber, '.params')));
                        varargout{2} = eval(strcat('s.', ber, '.dataView'));
                        varargout{3} = cellEditabilities;

                        [varargout{4}, varargout{5}, varargout{6}] = ...
                            importData(varargout{2}, dataSet, cellEditabilities, mark, linesShown);
                    end
                catch exception
                    varargout{1} = 'invalidFile';
                    varargout{2} = exception.message;
                    varargout{3} = [];
                    varargout{4} = [];
                    varargout{5} = [];
                    varargout{6} = [];
                end
            end
        case 'export'
            target = varargin{2};
            file = varargin{3};
            EbNoVar = varargin{4};
            BER = varargin{5};
            BERs = varargin{6};
            index = varargin{7} + 1;

            berStruct.params.EbNo = varargin{8}{1};

            switch length(varargin{8})  % number of params
                case 19    % theoretical
                    berStruct.params.channel = varargin{8}{2};
                    berStruct.params.kFactor = varargin{8}{3};
                    berStruct.params.divOrder = varargin{8}{4};
                    berStruct.params.modType = varargin{8}{5};
                    berStruct.params.modOrder = varargin{8}{6};
                    berStruct.params.modIndex = varargin{8}{7};
                    berStruct.params.dataEnc = varargin{8}{8};
                    berStruct.params.demodType = varargin{8}{9};
                    berStruct.params.coding = varargin{8}{10};
                    berStruct.params.decision = varargin{8}{11};
                    berStruct.params.trellis = varargin{8}{12};
                    berStruct.params.N = varargin{8}{13};
                    berStruct.params.K = varargin{8}{14};
                    berStruct.params.dmin = varargin{8}{15};
                    berStruct.params.sync = varargin{8}{16};
                    berStruct.params.timerr = varargin{8}{17};
                    berStruct.params.phaserr = varargin{8}{18};
                    berStruct.params.roFSK = varargin{8}{19};
                    berStruct.paramsEvaled.EbNo = params{index}{1};

                    if strcmpi(berStruct.params.channel, 'Rayleigh')
                        berStruct.paramsEvaled.modType = params{index}{2};
                        berStruct.paramsEvaled.modOrder = params{index}{3};
                        berStruct.paramsEvaled.divOrder = params{index}{4};
                        if strcmpi(berStruct.params.modType, 'FSK')
                            berStruct.paramsEvaled.demodType = params{index}{5};
                        end
                    elseif ~strcmpi(berStruct.params.coding, 'none')
                        berStruct.paramsEvaled.coding = params{index}{2};
                        berStruct.paramsEvaled.decision = params{index}{3};
                        if strcmpi(berStruct.paramsEvaled.coding, 'conv')
                            berStruct.paramsEvaled.codeRate = params{index}{4};
                            berStruct.paramsEvaled.distSpec = params{index}{5};                    
                        elseif strcmpi(berStruct.paramsEvaled.coding, 'block')  
                            berStruct.paramsEvaled.N = params{index}{4};
                            berStruct.paramsEvaled.dmin = '';
                            berStruct.paramsEvaled.K = params{index}{5};
                            berStruct.paramsEvaled.dmin = params{index}{6};
                        elseif strcmpi(berStruct.paramsEvaled.coding, 'hamming')
                             berStruct.paramsEvaled.N = params{index}{4};
                             berStruct.paramsEvaled.K = '';
                             berStruct.paramsEvaled.dmin = '';
                        elseif strcmpi(berStruct.paramsEvaled.coding, 'RS')
                            berStruct.paramsEvaled.N = params{index}{4};
                            berStruct.paramsEvaled.K = params{index}{5};
                            berStruct.paramsEvaled.dmin = '';
                        else
                            berStruct.paramsEvaled.N = params{index}{4};
                             berStruct.paramsEvaled.K = '';
                             berStruct.paramsEvaled.dmin = '';
                        end
                    elseif (strcmpi(berStruct.params.modType, 'PSK') && ...
                            ~strcmpi(berStruct.params.sync, 'perfect'))

                        berStruct.paramsEvaled.sync = params{index}{3};
                        if strcmpi(berStruct.params.sync, 'timerr')
                            berStruct.paramsEvaled.timerr = params{index}{2};
                        elseif strcmpi(berStruct.params.sync, 'phaserr')
                            berStruct.paramsEvaled.phaserr = params{index}{2};
                        end
                    else
                        berStruct.paramsEvaled.modType = params{index}{2};
                        if strcmpi(berStruct.params.modType, 'MSK')
                            berStruct.paramsEvaled.dataEnc = params{index}{3};
                        else
                            berStruct.paramsEvaled.modOrder = params{index}{3};
                            if strcmpi(berStruct.params.modType, 'PSK')
                                berStruct.paramsEvaled.dataEnc = params{index}{4};
                            elseif strcmpi(berStruct.params.modType, 'FSK')
                                berStruct.paramsEvaled.demodType = params{index}{4};
                            elseif strcmpi(berStruct.params.modType, 'CPFSK')
                                berStruct.paramsEvaled.modIndex = params{index}{4};
                                berStruct.paramsEvaled.Kmin = 1;
                            end
                        end
                    end
                case 9     % semianalytic
                    berStruct.params.modType = varargin{8}{2};
                    berStruct.params.modOrder = varargin{8}{3};
                    berStruct.params.dataEnc = varargin{8}{4};
                    berStruct.params.nSamp = varargin{8}{5};
                    berStruct.params.txSignal = varargin{8}{6};
                    berStruct.params.rxSignal = varargin{8}{7};
                    berStruct.params.numerator = varargin{8}{8};
                    berStruct.params.denominator = varargin{8}{9};
                    berStruct.paramsEvaled.txSignal = params{index}{1};
                    berStruct.paramsEvaled.rxSignal = params{index}{2};
                    berStruct.paramsEvaled.modType = params{index}{3};
                    berStruct.paramsEvaled.modOrder = params{index}{4};
                    berStruct.paramsEvaled.nSamp = params{index}{5};
                    berStruct.paramsEvaled.numerator = params{index}{6};
                    berStruct.paramsEvaled.denominator = params{index}{7};
                    berStruct.paramsEvaled.EbNo = params{index}{8};
                case 6     % simulation
                    berStruct.params.modelPath = varargin{8}{2};
                    berStruct.params.modelName = varargin{8}{3};
                    berStruct.params.berName = varargin{8}{4};
                    berStruct.params.maxNumErrs = varargin{8}{5};
                    berStruct.params.maxNumBits = varargin{8}{6};

                    berStruct.paramsEvaled.modelPath = params{index}{1};
                    berStruct.paramsEvaled.EbNo = params{index}{2};
                    berStruct.paramsEvaled.maxNumErrs = params{index}{3};
                    berStruct.paramsEvaled.maxNumBits = params{index}{4};
            end

            berStruct.data = data{index};
            berStruct.dataView = varargin{9};
            berStruct.cellEditabilities = varargin{10};

            switch target
                case 0      % workspace arrays
                    if ((varargin{end} == false) && ...     % overwrite unchecked
                            (evalin('base', strcat('exist(''', EbNoVar, ''', ''var'')')) ...
                            || evalin('base', strcat('exist(''', BER, ''', ''var'')'))))

                        varargout{1} = true;
                    else
                        assignin('base', EbNoVar, data{index}{1});
                        assignin('base', BER, data{index}{2});
                        varargout{1} = false;
                    end
                case 1      % workspace structure
                    if ((varargin{end} == false) && ...     % overwrite unchecked
                            evalin('base', strcat('exist(''', BERs, ''', ''var'')')))

                        varargout{1} = true;
                    else
                        assignin('base', BERs, berStruct);
                        varargout{1} = false;
                    end
                case 2      % file structure
                    eval(strcat(BERs, '=berStruct;'));
                    save(file, BERs);
                    varargout{1} = false;
            end
        case 'delete'
            index = varargin{2} + 1;
            precedingLinesShown = varargin{4};
            plot = varargin{5};
            params(index) = [];
            data(index) = [];
            lines(index) = [];
            legends(index) = [];

            if plot
                linesShown(precedingLinesShown+1) = [];
                legendsShown(precedingLinesShown+1) = [];

                set(fig, 'handleVisibility', 'on');
                if isempty(legendsShown)
                    feval('legend', 'off');
                else
                    legendHandle = feval('legend', linesShown, legendsShown);
                    delete(get(legendHandle, 'uicontextmenu'));
                end
                set(fig, 'handleVisibility', 'off');
            end

            index = mod(index, 7);
            if index == 0
                index = 7;
            end

            nextColor = nextColor - 1;
            if nextColor <= 0
                nextColor = 7;
            end

            % Move the deleted color to nextColor
            tmp = colors{index};
            colors(index) = [];
            colors = {colors{1:nextColor-1}, tmp, colors{nextColor:end}};

            if ~isempty(varargin{3}{2})
                nextMark = nextMark - 1;
                if nextMark <= 0
                    nextMark = 7;
                end

                % Move the deleted mark to nextMark
                tmp = marks{index};
                marks(index) = [];
                marks = {marks{1:nextMark-1}, tmp, marks{nextMark:end}};
            end

            delete(varargin{3}{1});

            % confidence intervals
            if ~isempty(varargin{3}{2})
                for i = 1:3
                    delete(varargin{3}{2}(i));
                end
            end

            delete(varargin{3}{3});

            if ~isempty(linesShown)
                figure(fig);
                set(fig, 'handleVisibility', 'on');
                axisScale(yAxis);
                set(fig, 'handleVisibility', 'off');
            end
        case 'saveFigure'
            if figSaved
                saveFigure(figFile, ax);
            else
                bertool('saveFigureAs');
            end
        case 'saveFigureAs'
            [fileName, filePath] = uiputfile('*.fig', 'Save As', figFile);
            if fileName ~= 0
                figFile = strcat(filePath, fileName);
                saveFigure(figFile, ax);
                figSaved = true;
            end

        case 'close'
            bertool('cleanUp');
            set(fig, 'visible', 'off');
            close(fig);
            delete(fig);
            clear bertool;
            fig = [];

       case 'close_session'
            bertool('cleanUp');
            set(fig, 'visible', 'off');
            close(fig);
            
        case 'cleanUp'        
            set(fig, 'handlevisibility', 'on');
            legend off;
            cla(ax);
            figure(fig);
            set(fig, 'handlevisibility', 'off');
            params = {};
            data = {};
            lines = [];
            linesShown = [];
            legends = {};
            legendsShown = {};
            colors = {[0 0 1], [0 .9 0], [1 0 0], [0 .7 .7], [.7 0 .7], [.7 .7 0], [0 0 0]};
            nextColor = 1;
            marks = {'*', '+', 'o', 'd', 'v', 's', '^'};
            nextMark = 1;
            xAxis = [inf -inf];
            yAxis = [1e-8 1];
        case 'help'
            helpview([docroot '/toolbox/comm/comm.map'], 'bertool_main');
        case 'version'
            aboutcommtlbx;
        case 'tooltip'
             % Case added to setup string for tooltip in the BER table
             % tooltip displays EbNo, BER and # BITS (for monte carlo case) in tabular
             % format.
             % The EbNo values are read from the corresponding table cell
             % (e.g.: 0:18)
             % The values are then converted into string
             % The character @ is an arbitrary separator and is removed
             % later
            args = varargin{2};
            varargout{1} = 'Done';
            X = sort(evalin('base', args));
            str = '';
            for i=1:length(X)
                str = strcat(str,'@',num2str(X(i)));
            end
            varargout{2} = str;
    end
end
end     % bertool


%%%
function saveFigure(figFile, ax)
figHandle = figure();

% Find all the siblings of ax
hSiblings = get(get(ax,'Parent'), 'children');
% Find the ones that are axes.  One of them is the figure axes, the other one is
% the legend
hAxes = hSiblings(strmatch('axes', get(hSiblings, 'type')));

% Make a copy of the figure without the custom toolbar
newAxes = copyobj(hAxes, figHandle);

children = allchild(newAxes);
set(newAxes, 'buttonDownFcn', '');
for i = 1:length(children)
    set(children{i}, 'buttonDownFcn', '');
end

% hgsave(figHandle, figFile);
set(figHandle, 'filename', figFile);
filemenufcn(figHandle, 'FileSave');
delete(figHandle);
end     % saveFigure


%%%
function out = checkParamDuplicate(params, paramSet)
out = 0;
for i = 1:length(params)
    if isequal(paramSet, params{i})
        out = i;
        break;
    end
end
end     % checkParamDuplicate


%%%
function varargout = importData(dataView, dataSet, cellEditabilities, mark, linesShown)
[varargout{1}, color] = bertool('plot', dataSet{1}, dataSet{2}, dataView{4}, mark);
if dataView{3}
    bertool('setVisible', varargout{1}, {'on'});
else
    bertool('setVisible', varargout{1}, {'off'}, false, -1, length(linesShown));
end

if cellEditabilities{1}
    varargout{2} = bertool('confint', dataSet{1}, dataSet{2}, dataSet{3}, color, mark);

    visibility = {'off', 'off', 'off'};
    if strcmpi(dataView{1}, '90%')
        visibility{1} = 'on';
    elseif strcmpi(dataView{1}, '95%')
        visibility{2} = 'on';
    elseif strcmpi(dataView{1}, '99%')
        visibility{3} = 'on';
    end

    bertool('setVisible', varargout{2}, visibility);
else
    varargout{2} = [];
end

if cellEditabilities{2}

    % Remove invalid BER due to requirement of BERFIT
    indices = (dataSet{2}>0) & (dataSet{2}<1);
    dataSet{1} = dataSet{1}(indices);
    dataSet{2} = dataSet{2}(indices);

    try                      
        varargout{3} = bertool('fit', dataSet{1}, dataSet{2}, color);
    catch exception
        varargout{3} = [];
        warning('comm:bertool:BerfitError', 'The following warnings are caused by BERTool trying to perform curve fit.');
        warning(exception.identifier, exception.message);
    end
    if dataView{2}
        visibility = {'on'};
    else
        visibility = {'off'};
    end
    bertool('setVisible', varargout{3}, visibility);
else
    varargout{3} = [];
end
end     % importData


%%%
function axisScale(yAxis)
% Set figure axis limits
axis auto;
a = axis;
if (a(3) < yAxis(1))
    a(3) = yAxis(1);
end
if (a(4) > yAxis(2))
    a(4) = yAxis(2);
end
axis(a);
end     % axisScale
