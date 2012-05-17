function bfitMCodeConstructor(line, hCode, linetype, datahandle, fit, stattype, xon)
% BFITMCODECONSTRUCTOR code generation constructor for basic fitting and data stats

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/31 18:23:53 $

BFDSFigure = ancestor(datahandle, 'figure');
if ~isappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter') %first time
    numFits = 0;
    numEvalResultsPlots = 0;
    basicFitCurrentData = [];
    if isappdata(double(BFDSFigure), 'Basic_Fit_Current_Data')
        basicFitCurrentData = getappdata(double(BFDSFigure), 'Basic_Fit_Current_Data');
        if isappdata(double(basicFitCurrentData), 'Basic_Fit_Showing')
            numFits = sum(getappdata(double(basicFitCurrentData), 'Basic_Fit_Showing'));
        end
        if isappdata(double(basicFitCurrentData), 'Basic_Fit_EvalResults')
            evalResults = getappdata(double(basicFitCurrentData), 'Basic_Fit_EvalResults');
            if ~isempty(evalResults.handle)
                numEvalResultsPlots = 1;
            end
        end
    end
    
    numDataXStats = 0;
    numDataYStats = 0;
    dataStatsCurrentData = [];
    if isappdata(double(BFDSFigure), 'Data_Stats_Current_Data')  
        dataStatsCurrentData = getappdata(double(BFDSFigure), 'Data_Stats_Current_Data');
        if isappdata(dataStatsCurrentData, 'Data_Stats_X_Showing')
            numDataXStats = sum(getappdata(double(dataStatsCurrentData), 'Data_Stats_X_Showing'));
        end
        if isappdata(dataStatsCurrentData, 'Data_Stats_Y_Showing')
            numDataYStats = sum(getappdata(double(dataStatsCurrentData), 'Data_Stats_Y_Showing'));
        end
    end
    
    itemsLeft = numFits + numEvalResultsPlots + numDataXStats + numDataYStats;
    setappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter', itemsLeft);
    
    % if there are fits or evaluated results plots, use  basic fit
    % data handle, otherwise use data statistics data handle
    if (numFits + numEvalResultsPlots > 0)
        hPlot = basicFitCurrentData;
    else
        hPlot = dataStatsCurrentData;
    end
    
    hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);
    
    hXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
    hYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');

    % getting x and y data from plot to deal with just y input.
    hCode.addText(sprintf('%% Get xdata from plot'));
    hCode.addText(hXdata, ' = get(', hPlotArg, ', ''xdata'');');
    hCode.addText(sprintf('%% Get ydata from plot'));
    hCode.addText(hYdata, ' = get(', hPlotArg, ', ''ydata'');');
    hCode.addText(sprintf('%% Make sure data are column vectors'));
    hCode.addText(hXdata, ' = ', hXdata, '(:);');
    hCode.addText(hYdata, ' = ', hYdata, '(:);');
    hCode.addText(' ');
    
    % if there are both fits (and evaluated plot) and data stats
    % and they are not from the same associated line, we need to get
    % x and y from two different plots
    if (numFits + numEvalResultsPlots > 0) ...
            && (numDataXStats + numDataYStats > 0) ...
            && (dataStatsCurrentData ~= basicFitCurrentData)
        % find the datastats line
        hPlot = dataStatsCurrentData;
        hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);

        hDSXdata = codegen.codeargument('Value', 'BFDSDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xDSdata');
        hDSYdata = codegen.codeargument('Value', 'BFDSDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'yDSdata');

        % getting x and y data from plot to deal with just y input.
        hCode.addText(sprintf('%% Get xdata from plot for data statistics'));
        hCode.addText(hDSXdata, ' = get(', hPlotArg, ', ''xdata'');');
        hCode.addText(sprintf('%% Get ydata from plot for data statistics'));
        hCode.addText(hDSYdata, ' = get(', hPlotArg, ', ''ydata'');');
        hCode.addText(sprintf('%% Make sure data are column vectors'));
        hCode.addText(hDSXdata, ' = ', hDSXdata, '(:);');
        hCode.addText(hDSYdata, ' = ', hDSYdata, '(:);');
        hCode.addText(' ');
        setappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_NeedMoreData', true);
    else
        setappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_NeedMoreData', false);
    end
end

itemsLeft = getappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter');

switch linetype
    case{'fit'}
        fitsMCodeConstructor(hCode, datahandle, fit);
    case{'stat'}
        if isappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_NeedMoreData') ...
            && getappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_NeedMoreData') 
            hDSXdata = codegen.codeargument('Value', 'BFDSDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xDSdata');
            hDSYdata = codegen.codeargument('Value', 'BFDSDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'yDSdata');
        else
            hDSXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
            hDSYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');
        end
        statsMCodeConstructor(hCode, datahandle, stattype, xon, hDSXdata, hDSYdata);
    case{'evalResults'}
        evalResultsMCodeConstructor(hCode, datahandle, fit);
    otherwise
        error('MATLAB:bfitMCodeConstructor:UnknownLineType', 'Unknown line type');
end

if itemsLeft == 1 % last fit 
    if isappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter')
        rmappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter');
    end
    if isappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_NeedMoreData')
        rmappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_NeedMoreData');
    end
else
   itemsLeft = itemsLeft - 1;
   setappdata(double(BFDSFigure), 'Basic_Fit_Data_Stats_Gen_MFile_Item_Counter', itemsLeft);
end
%--------------------------------------------------------------
function evalResultsMCodeConstructor(hCode, datahandle, fit)

% get axes
hAxes = ancestor(datahandle, 'axes');
hAxesArg = codegen.codeargument('Value',hAxes,'IsParameter',true);

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
normalize = guistate.normalize;

hXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
hYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');
 
% find the plot
hPlot = datahandle;
hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);

% Assigning a value here to work around a code gen bug (without this the 
% input argument is repeated as many times as it is referenced in the
% generated code
hXArg = codegen.codeargument('Value', rand(1,1), 'IsParameter',true,'Name', 'valuesToEvaluate');
hCode.addText(sprintf('%% Evaluate input'));

hYArg = codegen.codeargument('IsParameter',true,'Name', 'Y', 'IsOutputArgument',true);

hCode.addText('if ~isa(', hXArg, ', ''double'')');
hCode.addText('    error(''GenerateMFile:InvalidInput'', ...');
hCode.addText('          ''Input value must evaluate to a real scalar, vector or matrix.'');');
hCode.addText('end');

hCode.addText('if ~isreal(', hXArg, ')');
hCode.addText('    warning(''GenerateMFile:ImaginaryPartIgnored'', ...');
hCode.addText('            ''Imaginary part of input will be ignored.'');');
hCode.addText('    ', hXArg, ' = real(', hXArg, ');');
hCode.addText('end');

hCode.addText(' ');

hNormalizedXdata = codegen.codeargument('Value', 'BFDSNormalizedXdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedXdata');
hFitResults = codegen.codeargument('Value', 'BFDSFitResults', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fitResults');
switch fit
    case{0}
        if normalize
            hCode.addText(sprintf('%% Find coefficients for spline interpolant using normalized data'));
            hCode.addText(hNormalizedXdata', ' = (', hXdata, ' - mean(', hXdata, '))./(std(', hXdata, '));');
            hCode.addText(hFitResults, ' = spline(', hNormalizedXdata, ', ', hYdata, ');');
        else
            hCode.addText(sprintf('%% Find coefficients for spline interpolant'));
            hCode.addText(hFitResults, ' = spline(', hXdata, ', ', hYdata, ');');
        end
    case{1}
        if normalize
            hCode.addText(sprintf('%% Find coefficients for shape-preserving interpolant using normalized data'));
            hCode.addText(hNormalizedXdata, ' = (', hXdata, ' - mean(', hXdata, '))./(std(', hXdata, '));');
            hCode.addText(hFitResults, ' = pchip(', hNormalizedXdata, ',',  hYdata, ');');
        else
            hCode.addText(sprintf('%% Find coefficients for shape-preserving interpolant'));
            hCode.addText(hFitResults, ' = pchip(', hXdata, ', ', hYdata, ');');
        end
    otherwise
        hOrderArg = codegen.codeargument('Value', fit-1,'IsParameter',false);
        if normalize
            comment = sprintf('%% Find coefficients for polynomial (order = %d) using normalized data', fit-1);
            hIgnoreArg = codegen.codeargument('Value', 'BFDSignoreArg', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ignoreArg');
            hMu = codegen.codeargument('Value', 'BFDSmu', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'mu');
            hCode.addText('[', hFitResults, ', ', hIgnoreArg, ', ', hMu, '] = polyfit(', hXdata, ', ', hYdata, ', ', hOrderArg, ');');
        else
            comment = sprintf('%% Find coefficients for polynomial (order = %d)', fit-1);
            hCode.addText(hFitResults, ' = polyfit(', hXdata, ', ', hYdata, ', ', hOrderArg, ');');
        end
        hCode.addText(comment); 
end
    
hCode.addText(sprintf('%% Make sure input argument is a column'));
hCode.addText(hXArg, ' = ', hXArg, '(:);');

if normalize
    hCode.addText(sprintf('%% Normalize value'));
    hNormalizedValues = codegen.codeargument('Value', 'BFDSNormalizedValues', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedValues');
end

switch fit
    case{0,1} % spline or pchip
        if normalize
            hCode.addText(hNormalizedValues, ' = (', hXArg, '-mean(', hXdata, '))./(std(', hXdata, '));'); 
        end
        hCode.addText(sprintf('%% Evaluate piecewise polynomial'));
        if normalize
            hCode.addText(hYArg, ' = ppval(', hFitResults, ', ', hNormalizedValues, ');');
        else
            hCode.addText(hYArg, ' = ppval(', hFitResults, ', ', hXArg, ');');
        end
    otherwise
        if normalize
            hCode.addText(hNormalizedValues, ' = (', hXArg, '-', hMu, '(1))./', hMu, '(2);'); 
        end
        hCode.addText(sprintf('%% Evaluate polynomial'));
        if normalize
            hCode.addText(hYArg, ' = polyval(', hFitResults, ', ', hNormalizedValues, ');');
        else
            hCode.addText(hYArg, ' = polyval(', hFitResults, ', ', hXArg, ');');
        end
end

hCode.addText(sprintf('%% Make sure value is a column'));
hCode.addText(hYArg, ' = ', hYArg, '(:);');

% plot (the Constructor)
setConstructorName(hCode, 'plot');
con = getConstructor(hCode);
set(con,'Comment', sprintf('%% Plot the evaluated results'));
hEvalResultsLine = codegen.codeargument('IsParameter',true, 'Name', 'evalResultsLine', 'IsOutputArgument',true);
addConstructorArgout(hCode, hEvalResultsLine);
% plot input argument: x
addConstructorArgin(hCode,hXArg);
% plot input argument: y
addConstructorArgin(hCode,hYArg);
hDisplayName = codegen.codeargument('Value', 'DisplayName', 'IsParameter', false, 'ArgumentType', 'PropertyName');
legendString = bfitgetlegendstring('eval results', 0, 19);
hDisplayNameArg = codegen.codeargument('Value', legendString, 'IsParameter', false, 'ArgumentType', 'PropertyValue');
addConstructorArgin(hCode, hDisplayName);
addConstructorArgin(hCode, hDisplayNameArg);
%%% end plot 

hCode.addPostConstructorText(' ');
hCode.addPostConstructorText(sprintf('%% Reset line order for legend'));

hCodeParent = up(hCode);
hSetLineOrder = hCodeParent.findSubFunction('SetLineOrder');
if isempty(hSetLineOrder)
    hSetLineOrder = createSetLineOrder(hCodeParent);
end

hCode.addPostConstructorText(hSetLineOrder, '(', hAxesArg, ', ', hEvalResultsLine, ', ', hPlotArg, ');');

ignoreProperty(hCode,{'xdata','ydata','zdata', 'DisplayName'});

% Generate param-value syntax for remainder of properties
generateDefaultPropValueSyntaxNoOutput(hCode);

%--------------------------------------------------------
function statsMCodeConstructor(hCode, datahandle, stattype, xon, hDSXdata, hDSYdata)

% get axes
hAxes = ancestor(datahandle, 'axes');
hAxesArg = codegen.codeargument('Value',hAxes,'IsParameter',true);

hAxYLimArg = codegen.codeargument('Value', 'BFDSAxYLim', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'axYLim');
hAxXLimArg = codegen.codeargument('Value', 'BFDSAxXLim', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'axXLim');

xfitsshowing = getappdata(double(datahandle), 'Data_Stats_X_Showing');
numxfits = sum(xfitsshowing);
yfitsshowing = getappdata(double(datahandle), 'Data_Stats_Y_Showing');
numyfits = sum(yfitsshowing);

if ~isappdata(double(datahandle), 'Data_Stats_Gen_MFile_Fit_Counter') %first time
    fitsleft = numxfits + numyfits;
    setappdata(double(datahandle), 'Data_Stats_Gen_MFile_Fit_Counter', fitsleft);
    
    if numxfits > 0;
        % Get axes ylim
        hCode.addText(sprintf('%% Get axes ylim'));
        hCode.addText(hAxYLimArg, ' = get(', hAxesArg, ', ''ylim'');');
    end
    if numyfits > 0;
        % Get axes xlim
        hCode.addText(sprintf('%% Get axes xlim'));
        hCode.addText(hAxXLimArg, ' = get(', hAxesArg, ', ''xlim'');');
    end
    hCode.addText(' ');
    setappdata(double(datahandle), 'Data_Stats_Gen_MFile_Fit_Counter', fitsleft);
end

fitsleft = getappdata(double(datahandle), 'Data_Stats_Gen_MFile_Fit_Counter');

if fitsleft == 1 % last fit 
    rmappdata(double(datahandle), 'Data_Stats_Gen_MFile_Fit_Counter');
else
   fitsleft = fitsleft - 1;
   setappdata(double(datahandle), 'Data_Stats_Gen_MFile_Fit_Counter', fitsleft);
end

hPlot = datahandle;
hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);

argName = [stattype 'Value'];
hStatValueArg = codegen.codeargument('IsParameter',true, 'Name', argName, 'IsOutputArgument',true);

% Generate call to 'stat' e.g. "xmean = mean(x1)" %
if strcmp(stattype, 'std')
    hCode.addText(sprintf('%% Find the std'));
    
    if xon
        hStdData = codegen.codeargument('Value', 'BFDSstddata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xstd');
        hCode.addText(hStdData, ' = std(', hDSXdata, ');');
    else
        hStdData = codegen.codeargument('Value', 'BFDSstddata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ystd');
        hCode.addText(hStdData, ' = std(', hDSYdata, ');');
    end
    hCode.addText(' ');
    
    hCode.addText(sprintf('%% Prepare values to plot std; first find the mean'));
    if xon
        hStat = codegen.codeargument('Value', 'BFDSxmean', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xmean');
        hCode.addText(hStat, '  = mean(', hDSXdata, ');');
    else
        hStat = codegen.codeargument('Value', 'BFDSymean', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ymean');
        hCode.addText(hStat, ' = mean(', hDSYdata, ');');
    end
    
    hCode.addText(sprintf('%% Compute bounds as mean +/- std'));
    hLowVal = codegen.codeargument('Value', 'BFDSLowVal', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'lowerBound');
    hCode.addText(hLowVal, ' = ', hStat, ' - ', hStdData, ';');
    hHighVal = codegen.codeargument('Value', 'BFDSHighVal', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'upperBound');
    hCode.addText(hHighVal, ' = ', hStat, ' + ', hStdData, ';');
    hCode.addText(sprintf('%% Get coordinates for the std bounds line'));
    hCode.addText(hStatValueArg,' = [', hLowVal, ' ', hLowVal, ' NaN ', hHighVal, ' ',  hHighVal, ' NaN];'); 
else
    hCode.addText(sprintf('%% Find the %s', stattype));
    
    if xon
        statArgName = ['x' stattype];
    else
        statArgName = ['y' stattype];
    end
    
    hStat = codegen.codeargument('Value', '', 'IsParameter',true, 'IsOutputArgument', true, 'Name', statArgName);
    if xon
        hCode.addText(hStat, ' = ', stattype, '(', hDSXdata, ');');
    else
        hCode.addText(hStat, ' = ', stattype, '(', hDSYdata, ');');
    end
    hCode.addText(sprintf('%% Get coordinates for the %s line', stattype));
    hCode.addText(hStatValueArg, ' = [', hStat, ' ',  hStat, '];');
end
% End generate code to "stat" %

if strcmp(stattype, 'std')
    if xon
        hAxYStdLimArg = codegen.codeargument('IsParameter',true, 'Name', 'axYStdLim', 'IsOutputArgument',true);
        hCode.addText(hAxYStdLimArg, ' = [', hAxYLimArg,  ' NaN ',  hAxYLimArg, ' NaN];')
    else
        hAxXStdLimArg = codegen.codeargument('IsParameter',true, 'Name', 'axXStdLim', 'IsOutputArgument',true);
        hCode.addText(hAxXStdLimArg, ' = [', hAxXLimArg,  ' NaN ',  hAxXLimArg, ' NaN];')
    end
    hCode.addText(' ');
end

% plot (the Constructor)
setConstructorName(hCode, 'plot');
con = getConstructor(hCode);
if strcmp(stattype, 'std')
    set(con,'Comment', sprintf('%% Plot the bounds'));
else
    set(con,'Comment', sprintf('%% Plot the %s', stattype));
end

hStatLine = codegen.codeargument('IsParameter',true, 'Name', 'statLine', 'IsOutputArgument',true);
addConstructorArgout(hCode, hStatLine);

if xon
    % plot input argument: x
    addConstructorArgin(hCode,hStatValueArg);
    % plot input argument: y
    if strcmp(stattype, 'std')
        addConstructorArgin(hCode,hAxYStdLimArg);
    else
        addConstructorArgin(hCode,hAxYLimArg);
    end
    legendtype = 'xstat';
else
    % plot input argument: x
    if strcmp(stattype, 'std')
        addConstructorArgin(hCode,hAxXStdLimArg);
    else
        addConstructorArgin(hCode,hAxXLimArg);
    end
    % plot input argument: y
    addConstructorArgin(hCode,hStatValueArg);
    legendtype = 'ystat';
end

hDisplayName = codegen.codeargument('Value', 'DisplayName', 'IsParameter', false, 'ArgumentType', 'PropertyName');
legendString = bfitgetlegendstring(legendtype, getlegendstrtype(stattype), 19);
hDisplayNameArg = codegen.codeargument('Value', legendString, 'IsParameter', false, 'ArgumentType', 'PropertyValue');
addConstructorArgin(hCode, hDisplayName);
addConstructorArgin(hCode, hDisplayNameArg);

hCode.addPostConstructorText(' ');
hCode.addPostConstructorText(sprintf('%% Set new line in proper position'));

hCodeParent = up(hCode);
hSetLineOrder = hCodeParent.findSubFunction('SetLineOrder');
if isempty(hSetLineOrder)
    hSetLineOrder = createSetLineOrder(hCodeParent);
end

hCode.addPostConstructorText(hSetLineOrder, '(', hAxesArg, ', ', hStatLine, ', ', hPlotArg, ');');

ignoreProperty(hCode,{'xdata','ydata','zdata', 'DisplayName'});

% Generate param-value syntax for remainder of properties
generateDefaultPropValueSyntaxNoOutput(hCode);

% -------------------------------------------------------------------------
function strtype = getlegendstrtype(stattype)

strtype = 0;
switch stattype
    case {'min'}
        strtype = 1;
    case {'max'}
        strtype = 2;
    case {'mean'}
        strtype = 3;
    case {'median'}
        strtype = 4;
    case {'mode'}
        strtype = 5;
    case {'std'}
        strtype = 6;
end

%--------------------------------------------------------
function fitsMCodeConstructor(hCode, datahandle, fit)

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
plotresids = guistate.plotresids;
plottype = guistate.plottype;
subplot = guistate.subplot;
showresid = guistate.showresid;
digits = guistate.digits;
showequations = guistate.equations;

fitsshowing = find(getappdata(double(datahandle),'Basic_Fit_Showing'));

% find the plot
hPlot = datahandle;
hPlotArg = codegen.codeargument('Value',hPlot,'IsParameter',true);
    
% get the axes
hAxes = ancestor(datahandle, 'axes');
hAxesArg = codegen.codeargument('Value',hAxes,'IsParameter',true);

% create variables for xdata and ydata
hXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
hYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');    

hFittypesArray = codegen.codeargument('Value', 'BFDSfittypesArray', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fittypesArray');
hXPlotArg = codegen.codeargument('Value', 'BFDSXPlotArg', 'IsParameter',true,'IsOutputArgument', true, 'Name', 'xplot');

if plotresids
    % create variable for resid axis
    hResidAxes = codegen.codeargument('Value', 'BFDSResidAxes', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residAxes'); 
    hResidPlot = codegen.codeargument('Value', 'BFDSResidPlot', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residPlot'); 
    hSortedXdata = codegen.codeargument('Value', 'BFDSSortedXdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'sortedXdata'); 
    hXind = codegen.codeargument('Value', 'BFDSXind', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xInd'); 
end

if showequations
    hCoeffs = codegen.codeargument('Value', 'BFDSCoeffs', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'coeffs'); 
end

if ~isappdata(double(datahandle), 'Basic_Fit_Gen_MFile_Fit_Counter') % first fit
    fitsleft = length(fitsshowing);
    setappdata(double(datahandle), 'Basic_Fit_Gen_MFile_Fit_Counter', fitsleft);
   
    % Remove NaN values and warn
    hCode.addText(sprintf('%% Remove NaN values and warn'));
    hNanMask = codegen.codeargument('Value', 'BFDSNanMask', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'nanMask');
    hCode.addText(hNanMask,' = isnan(', hXdata, '(:)) | isnan(', hYdata, '(:));');
    hCode.addText('if any(', hNanMask, ')');
    hCode.addText('warning(''GenerateMFile:IgnoringNaNs'', ...');
    hCode.addText('        ''Data points with NaN coordinates will be ignored.'');');
    hCode.addText(hXdata, '(', hNanMask, ') = [];');
    hCode.addText(hYdata, '(', hNanMask, ') = [];');
    hCode.addText('end');
    hCode.addText(' ');

    hCode.addText(sprintf('%% Find x values for plotting the fit based on xlim'));
    hAxesLimits = codegen.codeargument('Value', 'BFDSaxesLimits', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'axesLimits');
    hCode.addText(hAxesLimits, ' = xlim(', hAxesArg, ');');
    hCode.addText(hXPlotArg, ' = linspace(', hAxesLimits, '(1), ', hAxesLimits, '(2));');
    hCode.addText(' ');

    if plotresids
        hCode.addText(sprintf('%% Prepare for plotting residuals'));
        % subplot values refer to the position in the drop down,
        % therefore 0 = subplot, 1 = separate figure
        if subplot == 0 % subplot
            hCode.addText('set(', hAxesArg,',''position'',[0.1300    0.5811    0.7750    0.3439]);');
            hCode.addText(hResidAxes, ' = axes(''position'', [0.1300    0.1100    0.7750    0.3439], ...');
            hCode.addText('      ''parent'', gcf);');
        else % separate figure
            hResidFigure = codegen.codeargument('Value', 'BFDSResidFigure', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residFigure');
            hResidPos = codegen.codeargument('Value', 'BFDSResidPos', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residPos');    
            hCode.addText(sprintf('%% Create a separate figure for residuals'));
            hCode.addText(hResidFigure, ' = figure();');
            hCode.addText(sprintf('%% Reposition residual figure '));
            hCode.addText('set(', hResidFigure, ',''units'',''pixels'');');
            hCode.addText(hResidPos, ' = get(', hResidFigure, ',''position'');');
            hCode.addText('set(', hResidFigure, ',''position'', ', hResidPos, ' + [50 -50 0 0]);');
            hCode.addText(hResidAxes, ' = axes(''parent'', ', hResidFigure, ');'); 
        end
        hNumFits = codegen.codeargument('Value', length(fitsshowing),'IsParameter',false);
        % By setting the value here and using the same handle with the same
        % value elsewhere makes code generator treat all the variables as
        % the same.
        hSavedResids = codegen.codeargument('Value', 'BFDSSavedResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedResids');
        hCode.addText(hSavedResids, ' = zeros(length(', hXdata, '), ', hNumFits, ');');
        hCode.addText(sprintf('%% Sort residuals'));
        hCode.addText('[', hSortedXdata, ', ', hXind, '] = sort(', hXdata, ');');
        hCode.addText(' ');
    end
    if showequations
        hCode.addText(sprintf('%% Preallocate for "Show equations" coefficients'));
        hNumFits = codegen.codeargument('Value', length(fitsshowing),'IsParameter',false);
        hCode.addText(hCoeffs, ' = cell(', hNumFits, ',1);');
        hCode.addText('  ');
    end
end

fitsleft = getappdata(double(datahandle), 'Basic_Fit_Gen_MFile_Fit_Counter');

% Calculate the fit and plot it.
genmfilecalcfitandplot(hCode, datahandle, fit, hAxesArg, hPlotArg)

if fitsleft == 1 % last fit
    if plotresids
        hSavedResids = codegen.codeargument('Value', 'BFDSSavedResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedResids');
        hCode.addPostConstructorText(' ');
        switch plottype
            case(0) % barplot
                hCode.addPostConstructorText(sprintf('%% Plot residuals in a bar plot'));
                hCode.addPostConstructorText(hResidPlot, ' = bar(', hResidAxes, ', ', hSortedXdata, ', ', hSavedResids, ');');
            case(1) % scatterplot
                hCode.addPostConstructorText(sprintf('%% Plot residuals in a scatter plot'));
                hCode.addPostConstructorText(hResidPlot, ' = plot(', hSortedXdata, ',', hSavedResids, ',''.'',''parent'', ', hResidAxes, ');');
            case(2) % lineplot
                hCode.addPostConstructorText(sprintf('%% Plot residuals in a line plot'));
                hCode.addPostConstructorText(hResidPlot, ' = plot(', hSortedXdata, ',', hSavedResids, ',''parent'', ', hResidAxes, ');');
            otherwise
                error('MATLAB:bfitMCodeConstructor:UnknownPlotType', 'Unknown plot type for residual plot.');
        end
        setresidcolorsandnames(hCode, fitsshowing, plottype, hAxes, subplot);
        hCode.addPostConstructorText(sprintf('%% Set residual plot axis title'));
        hCode.addPostConstructorText('set(get(', hResidAxes, ', ''title''),''string'',''residuals'');');
        % if separate figure turn on legend
        if (subplot == 1)
            hCode.addPostConstructorText(sprintf('%% Show legend on residual plot'));
            hCode.addPostConstructorText('legend(', hResidAxes, ', ''show'');');
        end
        if showresid
            hCode.addPostConstructorText(' ');
            hSubFun = createShowNormOfResiduals(hCode);
            hCode.addPostConstructorText(sprintf('%% "Show norm of residuals" was selected'));
            hSavedNormResids = codegen.codeargument('Value', 'BFDSSavedNormResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedNormResids');
            hCode.addPostConstructorText(hSubFun, '(', hResidAxes, ', ', hFittypesArray, ', ', hSavedNormResids, ');');
        end
    end
    if showequations
        hCode.addPostConstructorText(' ');
        normalized = guistate.normalize;
        if ~any(fitsshowing>2)
            normalized = false;
        end
        hSubFun = createShowEquations(hCode, normalized);
        hCode.addPostConstructorText(sprintf('%% "Show equations" was selected'));
        hDigits = codegen.codeargument('Value', digits,'IsParameter',false);
        if normalized
            hCode.addPostConstructorText(hSubFun, '(', hFittypesArray, ', ', hCoeffs, ', ', hDigits, ', ', hAxesArg, ', ', hXdata, ');');
        else
            hCode.addPostConstructorText(hSubFun, '(', hFittypesArray, ', ', hCoeffs, ', ', hDigits, ', ', hAxesArg, ');');
        end
    end

    rmappdata(double(datahandle), 'Basic_Fit_Gen_MFile_Fit_Counter');
else
   fitsleft = fitsleft - 1;
   setappdata(double(datahandle), 'Basic_Fit_Gen_MFile_Fit_Counter', fitsleft);
end

% ----------------------------------------------------------------
function genmfilecalcfitandplot(hCode, datahandle, fit, hAxesArg, hPlotArg)
% GENMFILECALCFIT Calculate fits and residuals and plot.

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
normalized = guistate.normalize;
plotresids = guistate.plotresids;
showequations = guistate.equations;
showresid = guistate.showresid;

hXPlotArg = codegen.codeargument('Value', 'BFDSXPlotArg', 'IsParameter',true,'IsOutputArgument', true, 'Name', 'xplot');
hYPlotArg = codegen.codeargument('IsParameter',true,'Name', 'yplot', 'IsOutputArgument',true);

hXdata = codegen.codeargument('Value', 'BFDSxdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xdata');
hYdata = codegen.codeargument('Value', 'BFDSydata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ydata');
hFittypesArray = codegen.codeargument('Value', 'BFDSfittypesArray', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fittypesArray');
hFitResults = codegen.codeargument('Value', 'BFDSFitResults', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'fitResults');

if (normalized) && (fit == 0 || fit == 1) % spline or pchip normalized
    %%% Generate code to find the mean of x, e.g. "meanx = mean(x)" %%%
    hCode.addText(sprintf('%% Normalize xdata'));
    hNormalizedXdata = codegen.codeargument('Value', 'BFDSNormalizedXdata', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedXdata');
    hCode.addText(hNormalizedXdata, ' = (', hXdata, ' - mean(', hXdata, '))./(std(', hXdata, '));');
end

%%% If normalized spline or pchip, need to normalize result of linspace
if (normalized) && (fit == 0 || fit == 1) % spline or pchip normalized
    hCode.addText(sprintf('%% Find normalized x values for plotting the fit'));
    hNormalizedXplot = codegen.codeargument('Value', 'BFDSNormalizedXplot', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'normalizedXplot');
    hCode.addText(hNormalizedXplot, ' = (', hXPlotArg, ' - mean(', hXdata, '))./(std(', hXdata, '));');
end

if fit == 0  %spline
    hCode.addText(sprintf('%% Find coefficients for spline interpolant'));
    if normalized
        hCode.addText(hFitResults, ' = spline(', hNormalizedXdata, ', ', hYdata, ');');
    else
        hCode.addText(hFitResults, ' = spline(', hXdata, ', ', hYdata, ');');
    end
    
elseif fit == 1 % pchip
    hCode.addText(sprintf('%% Find coefficients for shape-preserving interpolant'));
    if normalized
        hCode.addText(hFitResults, ' = pchip(', hNormalizedXdata, ', ', hYdata, ');');
    else
        hCode.addText(hFitResults, ' = pchip(', hXdata, ', ', hYdata, ');');
    end
else
    order = fit-1;
    comment = sprintf('%% Find coefficients for polynomial (order = %d)', order);
    hCode.addText(comment);
    hOrderArg = codegen.codeargument('Value',order,'IsParameter',false);
    if normalized
        hIgnoreArg = codegen.codeargument('Value', 'BFDSIgnoreArg', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'ignoreArg');
        hMu = codegen.codeargument('Value', 'BFDSmu', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'mu');
        hCode.addText('[', hFitResults, ', ', hIgnoreArg, ', ', hMu, '] = polyfit(', hXdata, ', ', hYdata, ', ', hOrderArg, ');');
    else
        hCode.addText(hFitResults, ' = polyfit(', hXdata, ', ', hYdata, ', ', hOrderArg, ');');
    end    
end

if fit == 0 || fit == 1 %% spline or pchip
    hCode.addText(sprintf('%% Evaluate piecewise polynomial'));
    if normalized
        hCode.addText(hYPlotArg, ' = ppval(', hFitResults, ', ', hNormalizedXplot', ');');
    else
        hCode.addText(hYPlotArg, ' = ppval(', hFitResults, ', ', hXPlotArg, ');');
    end
else
    hCode.addText(sprintf('%% Evaluate polynomial'));
    if normalized
        hCode.addText(hYPlotArg, ' = polyval(', hFitResults, ', ', hXPlotArg, ', [], ', hMu, ');');
    else
        hCode.addText(hYPlotArg, ' = polyval(', hFitResults, ', ', hXPlotArg, ');');
    end
end

if plotresids || showequations
    fitsshowing = find(getappdata(double(datahandle),'Basic_Fit_Showing'));
    index = find(fitsshowing == fit+1);
    hIndexArg = codegen.codeargument('Value', index, 'IsParameter',false);
end
if (plotresids && showresid) || showequations
    hCode.addText(' ');
    if (plotresids && showresid) && ~showequations  % only show norm of resids
        hCode.addText(sprintf('%% Save type of fit for "Show norm of residuals."'));
    elseif ~(plotresids && showresid) && showequations % only show equations
        hCode.addText(sprintf('%% Save type of fit for "Show equations"'));
    else % both show norm of resids and show equations
        hCode.addText(sprintf('%% Save type of fit for "Show norm of residuals" and "Show equations"'));
    end
    hFittype = codegen.codeargument('Value', fit,'IsParameter',false);
    hCode.addText(hFittypesArray, '(', hIndexArg, ') = ', hFittype, ';');
end
if plotresids
    %% Calculate resid
    hCode.addText(' ');
    hCode.addText(sprintf('%% Calculate and save residuals - evaluate using original xdata'));
    hYfit = codegen.codeargument('Value', 'BFDSYfit', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'Yfit');
    if fit == 0 || fit == 1 %% spline or pchip
        if normalized
            hCode.addText(hYfit, ' = ppval(', hFitResults, ', ', hNormalizedXdata',');');
        else
            hCode.addText(hYfit, ' = ppval(', hFitResults, ', ', hXdata, ');');
        end
    else
        if normalized
            hCode.addText(hYfit, ' = polyval(', hFitResults, ', ', hXdata, ', [], ', hMu', ');');
        else
            hCode.addText(hYfit, ' = polyval(', hFitResults, ', ', hXdata, ');');
        end
    end
    
    % Find the index to store the resid in the matrix used to plot resids
    % We want the resids to be in the same order that fits are plotted
    % Fitsshowing has the order we want; fits are numbered one higher than
    % fit 
     
    hResid = codegen.codeargument('Value', 'BFDSresid', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'resid');
    hCode.addText(hResid, ' = ', hYdata, ' - ', hYfit, '(:);');
    hSavedResids = codegen.codeargument('Value', 'BFDSSavedResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedResids');
    hXind = codegen.codeargument('Value', 'BFDSXind', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'xInd'); 
    hCode.addText(hSavedResids, '(:,', hIndexArg, ') = ', hResid, '(', hXind, ');');
    if showresid
        hSavedNormResids = codegen.codeargument('Value', 'BFDSSavedNormResiduals', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'savedNormResids');
        hCode.addText(hSavedNormResids, '(', hIndexArg, ') = norm(', hResid, ');');
    end
end
if showequations
    hCode.addText(' ');
    hCode.addText(sprintf('%% Save coefficients for "Show Equation"'));
    hCoeffs = codegen.codeargument('Value', 'BFDSCoeffs', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'coeffs'); 
    hCode.addText(hCoeffs, '{', hIndexArg, '} = ', hFitResults, ';');
    hCode.addText(' ');
end

% plot (the Constructor)
setConstructorName(hCode, 'plot');
con = getConstructor(hCode);
set(con,'Comment', sprintf('%% Plot the fit'));

hFitLine = codegen.codeargument('IsParameter',true, 'Name', 'fitLine', 'IsOutputArgument',true);
addConstructorArgout(hCode, hFitLine);

% plot x
addConstructorArgin(hCode,hXPlotArg);
% plot y
addConstructorArgin(hCode,hYPlotArg);
hDisplayName = codegen.codeargument('Value', 'DisplayName', 'IsParameter', false, 'ArgumentType', 'PropertyName');
legendString = bfitgetlegendstring('fit', fit, 19);
hDisplayNameArg = codegen.codeargument('Value', legendString, 'IsParameter', false, 'ArgumentType', 'PropertyValue');
addConstructorArgin(hCode, hDisplayName);
addConstructorArgin(hCode, hDisplayNameArg);

hCode.addPostConstructorText(' ');
hCode.addPostConstructorText(sprintf('%% Set new line in proper position'));
hCodeParent = up(hCode);
hSetLineOrder = hCodeParent.findSubFunction('SetLineOrder');
if isempty(hSetLineOrder)
    hSetLineOrder = createSetLineOrder(hCodeParent);
end
hCode.addPostConstructorText(hSetLineOrder, '(', hAxesArg, ', ', hFitLine, ', ', hPlotArg, ');');
% end plot 

ignoreProperty(hCode,{'xdata','ydata','zdata','DisplayName'});

% Generate param-value syntax for remainder of properties
generateDefaultPropValueSyntaxNoOutput(hCode);
% ---------------------------------------------------
function setresidcolorsandnames(hCode, fitsshowing, plottype, hAxes, subplot)

if (subplot == 0) % subplot
    hCode.addPostConstructorText(sprintf('%% Set colors to match fit lines'));
else % separate figure 
    hCode.addPostConstructorText(sprintf('%% Set colors to match fit lines and set display names'));
end

hResidPlot = codegen.codeargument('Value', 'BFDSResidPlot', 'IsParameter',true, 'IsOutputArgument', true, 'Name', 'residPlot');

for i = 1:length(fitsshowing)
    name = createresiddisplayname(fitsshowing(i)-1);
    % the following is the same as in bfitplotfit so color coincides
    color_order = get(hAxes,'colororder');
    % minus one to fitsshowing(i) so fit type is correct
    colorindex = mod(fitsshowing(i)-1,size(color_order,1)) + 1;
    color = color_order(colorindex,:);
    hColorArg = codegen.codeargument('Value',color,'IsParameter',false);
    hNameArg = codegen.codeargument('Value',name,'IsParameter',false);
    % Don't bother to set the display name if resid are in a subplot
    hIndexArg = codegen.codeargument('Value',i,'IsParameter',false);
    if (plottype == 0) % barplot
        if (subplot == 0) % subplot
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''facecolor'', ', hColorArg, ',''edgecolor'', ', hColorArg, ');');
        else % separate figure
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''facecolor'', ', hColorArg, ',''edgecolor'', ', hColorArg, ', ...');
            hCode.addPostConstructorText('   ''DisplayName'', ', hNameArg, ');');
        end
    else
        if (subplot == 0) % subplot
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''color'', ', hColorArg, ');');
        else % separate figure
            hCode.addPostConstructorText('set(', hResidPlot, '(', hIndexArg, '), ''color'', ', hColorArg, ', ...');
            hCode.addPostConstructorText('   ''DisplayName'', ', hNameArg, ');');
        end
    end
end
   
% --------------------------------------------------------------   
function name = createresiddisplayname(fit)
% CREATERESIDDISPLAYNAME  Create tag name for residual line.

switch fit
    case 0
        name = 'spline';
    case 1
        name = 'shape-preserving';
    case 2
        name = 'linear';
    case 3
        name = 'quadratic';
    case 4
        name = 'cubic';
    otherwise
        name = sprintf('%sth degree',num2str(fit-1));
end

% ---------------------------------------------------
function hSubFun = createSetLineOrder(hCode)
hSubFun = codegen.coderoutine;
hSubFun.Name = 'setLineOrder';
hSubFun.Comment = sprintf('Set line order');

% Create the input arguments
hAxes = codegen.codeargument;
hAxes.IsParameter = true;
hAxes.Name = 'axesh';
hAxes.Comment = sprintf('Axes');

hNewLine = codegen.codeargument;
hNewLine.IsParameter = true;
hNewLine.Name = 'newLine';
hNewLine.Comment = sprintf('New line');

hAssociatedLine = codegen.codeargument;
hAssociatedLine.IsParameter = true;
hAssociatedLine.Name = 'associatedLine';
hAssociatedLine.Comment = sprintf('Associated line');

hSubFun.addArgin(hAxes);
hSubFun.addArgin(hNewLine);
hSubFun.addArgin(hAssociatedLine);

hSubFun.addText(sprintf('%% Get the axes children'));
hSubFun.addText('hChildren = get(', hAxes, ',''Children'');');

hSubFun.addText(sprintf('%% Remove the new line'));
hSubFun.addText('hChildren(hChildren==', hNewLine, ') = [];');

hSubFun.addText(sprintf('%% Get the index to the associatedLine'));
hSubFun.addText('lineIndex = find(hChildren==', hAssociatedLine, ');');

hSubFun.addText(sprintf('%% Reorder lines so the new line appears with associated data'));
hSubFun.addText('hNewChildren = [hChildren(1:lineIndex-1);', hNewLine, ';hChildren(lineIndex:end)];');

hSubFun.addText(sprintf('%% Set the children:'));
hSubFun.addText('set(', hAxes, ',''Children'',hNewChildren);');

hCode.addSubFunction(hSubFun);

%---------------------------------------------------
function hSubFun = createShowEquations(hCode, normalized)

hSubFun = codegen.coderoutine;
hSubFun.Name = 'showEquations';
hSubFun.Comment = sprintf('Show equations');

% Create the input arguments
hFittypes = codegen.codeargument;
hFittypes.IsParameter = true;
hFittypes.Name = 'fittypes';
hFittypes.Comment = sprintf('Types of fits');

hCoeffs = codegen.codeargument;
hCoeffs.IsParameter = true;
hCoeffs.Name = 'coeffs';
hCoeffs.Comment = sprintf('Coefficients');

hDigits = codegen.codeargument;
hDigits.IsParameter = true;
hDigits.Name = 'digits';
hDigits.Comment = sprintf('Number of significant digits');

hAxesh = codegen.codeargument;
hAxesh.IsParameter = true;
hAxesh.Name = 'axesh';
hAxesh.Comment = sprintf('Axes');

if normalized
    hXdata = codegen.codeargument;
    hXdata.IsParameter = true;
    hXdata.Name = 'xdata';
    hXdata.Comment = sprintf('X data');
end

hSubFun.addArgin(hFittypes);
hSubFun.addArgin(hCoeffs);
hSubFun.addArgin(hDigits);
hSubFun.addArgin(hAxesh);
if normalized
    hSubFun.addArgin(hXdata);
end

hSubFun2 = createGetEquationString(hSubFun, normalized);

hSubFun.addText('n = length(', hFittypes, ');');
if normalized
    hSubFun.addText('txt = cell(length(n + 2) ,1);');
else
    hSubFun.addText('txt = cell(length(n + 1) ,1);');
end
hSubFun.addText('txt{1,:} = '' '';');
hSubFun.addText('for i = 1:n');
hSubFun.addText('    txt{i + 1,:} = ', hSubFun2, '(', hFittypes, '(i),', hCoeffs, '{i},', hDigits,',', hAxesh,');');
hSubFun.addText('end');
if normalized
    hSubFun.addText('meanx = mean(', hXdata, ');');
    hSubFun.addText('stdx = std(', hXdata, ');');
    hSubFun.addText('format = [''where z = (x - %0.'', num2str(', hDigits, '), ''g)/%0.'', num2str(', hDigits, '), ''g''];');
    hSubFun.addText('txt{n + 2,:} = sprintf(format, meanx, stdx);');
end
hSubFun.addText('text(.05,.95,txt,''parent'',', hAxesh, ', ...');
hSubFun.addText('    ''verticalalignment'',''top'',''units'',''normalized'');');

hCode.addSubFunction(hSubFun);

%---------------------------------------------------
function hSubFun = createGetEquationString(hCode, normalized)
% Create the subfunction object
hSubFun = codegen.coderoutine;

% Set the name
hSubFun.Name = 'getEquationString';

% Set the comment 
hSubFun.Comment = sprintf('Get show equation string');

% Create the input arguments
hFittype = codegen.codeargument;
hFittype.IsParameter = true;
hFittype.Name = 'fittype';
hFittype.Comment = sprintf('Type of fit');

hCoeffs = codegen.codeargument;
hCoeffs.IsParameter = true;
hCoeffs.Name = 'coeffs';
hCoeffs.Comment = sprintf('Coefficients');

hDigits = codegen.codeargument;
hDigits.IsParameter = true;
hDigits.Name = 'digits';
hDigits.Comment = sprintf('Number of significant digits');

hAxesh = codegen.codeargument;
hAxesh.IsParameter = true;
hAxesh.Name = 'axesh';
hAxesh.Comment = sprintf('Axes');

% Create the output argument
hString = codegen.codeargument;
hString.IsOutputArgument = true;
hString.IsParameter = true;
hString.Name = 's';

hSubFun.addArgin(hFittype);
hSubFun.addArgin(hCoeffs);
hSubFun.addArgin(hDigits);
hSubFun.addArgin(hAxesh);
hSubFun.addArgout(hString);

hSubFun.addText('if isequal(', hFittype, ', 0)');
hSubFun.addText('    ', hString, ' = ''Cubic spline interpolant'';');
hSubFun.addText('elseif isequal(', hFittype,', 1)');
hSubFun.addText('    ', hString,' = ''Shape-preserving interpolant'';');
hSubFun.addText('else');
hSubFun.addText('    op = ''+-'';');
if normalized
   hSubFun.addText('    format1 = [''%s %0.'',num2str(', hDigits, '),''g*z^{%s} %s''];');
else
   hSubFun.addText('    format1 = [''%s %0.'',num2str(', hDigits, '),''g*x^{%s} %s''];');
end
hSubFun.addText('    format2 = [''%s %0.'',num2str(', hDigits, '),''g''];');
hSubFun.addText('    xl = get(', hAxesh,', ''xlim'');');
hSubFun.addText('    fit =  ', hFittype, ' - 1;');
hSubFun.addText('    ', hString, ' = sprintf(''y ='');');
hSubFun.addText('    th = text(xl*[.95;.05],1,', hString, ',''parent'',', hAxesh, ', ''vis'',''off'');');
hSubFun.addText('    if abs(', hCoeffs, '(1) < 0)');
hSubFun.addText('        ', hString, ' = [', hString, ' '' -''];'); 
hSubFun.addText('    end');
hSubFun.addText('    for i = 1:fit');
hSubFun.addText('        sl = length(', hString, ');');
hSubFun.addText('        if ~isequal(', hCoeffs, '(i),0) % if exactly zero, skip it ');
hSubFun.addText('            ', hString, ' = sprintf(format1,', hString, ',abs(', hCoeffs, '(i)),num2str(fit+1-i), op((', hCoeffs, '(i+1)<0)+1));');
hSubFun.addText('        end');
hSubFun.addText('        if (i==fit) && ~isequal(', hCoeffs, '(i),0)');
hSubFun.addText('            ', hString, '(end-5:end-2) = []; % change x^1 to x.');
hSubFun.addText('        end');
hSubFun.addText('        set(th,''string'',', hString, ');');
hSubFun.addText('        et = get(th,''extent'');');
hSubFun.addText('        if et(1)+et(3) > xl(2)');
hSubFun.addText('            ', hString, ' = [', hString, '(1:sl) sprintf(''\n     '') ', hString, '(sl+1:end)];');
hSubFun.addText('        end');
hSubFun.addText('    end');
hSubFun.addText('    if ~isequal(', hCoeffs, '(fit+1),0)');
hSubFun.addText('        sl = length(', hString, ');');
hSubFun.addText('       ', hString, ' = sprintf(format2,', hString, ',abs(', hCoeffs, '(fit+1)));');
hSubFun.addText('        set(th,''string'',', hString, ');');
hSubFun.addText('        et = get(th,''extent'');');
hSubFun.addText('        if et(1)+et(3) > xl(2)');
hSubFun.addText('            ', hString, ' = [', hString, '(1:sl) sprintf(''\n     '') ', hString, '(sl+1:end)];');
hSubFun.addText('        end');
hSubFun.addText('    end');
hSubFun.addText('    delete(th);');
hSubFun.addText('    % Delete last "+"');
hSubFun.addText('    if isequal(', hString, '(end),''+'')');
hSubFun.addText('        ', hString, '(end-1:end) = []; % There is always a space before the +.');
hSubFun.addText('    end');
hSubFun.addText('    if length(', hString, ') == 3');
hSubFun.addText('        ', hString, ' = sprintf(format2,', hString, ',0);');
hSubFun.addText('    end');
hSubFun.addText('end');

hCode.addSubFunction(hSubFun);

% ---------------------------------------------------
function hSubFun = createShowNormOfResiduals(hCode)
hSubFun = codegen.coderoutine;
hSubFun.Name = 'showNormOfResiduals';
hSubFun.Comment = sprintf('Show norm of residuals');

% Create the input arguments
hResidaxes = codegen.codeargument;
hResidaxes.IsParameter = true;
hResidaxes.Name = 'residaxes';
hResidaxes.Comment = sprintf('Axes for residuals');

hFittypes = codegen.codeargument;
hFittypes.IsParameter = true;
hFittypes.Name = 'fittypes';
hFittypes.Comment = sprintf('Types of fits');

hNormResids = codegen.codeargument;
hNormResids.IsParameter = true;
hNormResids.Name = 'normResids';
hNormResids.Comment = sprintf('Norm of Residuals');

hSubFun.addArgin(hResidaxes);
hSubFun.addArgin(hFittypes);
hSubFun.addArgin(hNormResids);

hSubFun2 = createGetResidStrFun(hSubFun);

hSubFun.addText('txt = cell(length(', hFittypes, ') ,1);');
hSubFun.addText('for i = 1:length(', hFittypes, ')');
hSubFun.addText('    txt{i,:} = ', hSubFun2, '(', hFittypes, '(i),', hNormResids, '(i));');
hSubFun.addText('end');

hSubFun.addText(sprintf('%% Save current axis units; then set to normalized'));
hSubFun.addText('axesunits = get(', hResidaxes,',''units'');');
hSubFun.addText('set(', hResidaxes, ',''units'',''normalized'');');

hSubFun.addText('text(.05,.95,txt,''parent'',', hResidaxes, ', ...');
hSubFun.addText('    ''verticalalignment'',''top'',''units'',''normalized'');');

hSubFun.addText(sprintf('%% Reset units'));
hSubFun.addText('set(', hResidaxes,',''units'',axesunits);');

hCode.addSubFunction(hSubFun);

% ---------------------------------------------------
function hSubFun = createGetResidStrFun(hCode)

% Create the subfunction object
hSubFun = codegen.coderoutine;

% Set the name
hSubFun.Name = 'getResidString';

% Set the comment 
hSubFun.Comment = sprintf('Get "Show norm of residuals" string');

% Create the input arguments
hFittype = codegen.codeargument;
hFittype.IsParameter = true;
hFittype.Name = 'fittype';
hFittype.Comment = sprintf('Type of fit');

hNormResid = codegen.codeargument;
hNormResid.IsParameter = true;
hNormResid.Name = 'normResid';
hNormResid.Comment = sprintf('Norm of residuals');

% Create the output argument
hString = codegen.codeargument;
hString.IsOutputArgument = true;
hString.IsParameter = true;
hString.Name = 's';

% Add the arguments to the subroutine
hSubFun.addArgin(hFittype);
hSubFun.addArgin(hNormResid);
hSubFun.addArgout(hString);

hSubFun.addText('switch ', hFittype);
hSubFun.addText('case 0');
hSubFun.addText('    ', hString, ' = ''Spline: norm of residuals = 0'';');
hSubFun.addText('case 1');
hSubFun.addText('    ', hString, ' = ''Shape-preserving: norm of residuals = 0'';');
hSubFun.addText('case 2');
hSubFun.addText('    ', hString, ' = sprintf(''Linear: norm of residuals = %s'', num2str(', hNormResid,'));');
hSubFun.addText('case 3');
hSubFun.addText('    ', hString, ' = sprintf(''Quadratic: norm of residuals = %s'', num2str(', hNormResid, '));');
hSubFun.addText('case 4');
hSubFun.addText('    ', hString, ' = sprintf(''Cubic: norm of residuals = %s'', num2str(', hNormResid, '));');
hSubFun.addText('otherwise');
hSubFun.addText('    ', hString, ' = sprintf(''%sth degree: norm of residuals = %s'', num2str(', hFittype, '-1), num2str(', hNormResid, '));');
hSubFun.addText('end');

hCode.addSubFunction(hSubFun);





