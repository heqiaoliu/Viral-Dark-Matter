function disp(this)
%DISP   Display properties of an eye diagram object
%   DISP(H) displays relevant properties of the eye diagram scope object H
%
%   If a property is not relevant to the object's configuration, it is not
%   displayed. For example, ColorScale property is not relevant when
%   PlotType property is set to '2D Line'.  In this case ColorScale property
%   is not displayed. 
%
%   EXAMPLES:
%
%     % Create an eye diagram scope object
%     h = commscope.eyediagram;
%     % Display object properties
%     disp(h); 
%     h = commscope.eyediagram('PlotType', '2D Line') % note the absence	 
%                                                     % of semicolon
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEDIAGRAM/ANALYZE,
%   COMMSCOPE.EYEDIAGRAM/CLOSE, COMMSCOPE.EYEDIAGRAM/COPY,
%   COMMSCOPE.EYEDIAGRAM/EXPORTDATA, COMMSCOPE.EYEDIAGRAM/PLOT,
%   COMMSCOPE.EYEDIAGRAM/RESET, COMMSCOPE.EYEDIAGRAM/UPDATE.

%   @commscope/@eyediagram
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/12/05 01:58:16 $

% Define the fields to be displayed in order
fieldNames = {'Type', ...
    'SamplingFrequency', ...
    'SamplesPerSymbol', ...
    'SymbolRate', ...
    'SymbolsPerTrace', ...
    'MinimumAmplitude', ...
    'MaximumAmplitude', ...
    'AmplitudeResolution', ...
    'MeasurementDelay', ...
    'OperationMode', ...
    'PlotType', ...
    'NumberOfStoredTraces', ...
    'PlotTimeOffset', ...
    'RefreshPlot', ...
    'PlotPDFRange', ...
    'ColorScale', ...
    'SamplesProcessed', ...
    'Measurements', ...
    'MeasurementSetup'};


excludedFieldNames = {};
%Exclude field names when displaying a single object
if isscalar(this)    
    if ~strcmp(this.PlotType, '2D Color')
        % If PlotType is not 2D Color, do not display PlotPDFRange
        excludedFieldNames = [excludedFieldNames 'PlotPDFRange'];
    end
    
    if ~strcmp(this.PlotType, '2D Line')
        % If PlotType is not 2D Line, do not display NumberOfStoredTraces
        excludedFieldNames = [excludedFieldNames 'NumberOfStoredTraces'];
    else
        % If PlotType is 2D Line, do not display ColorScale
        excludedFieldNames = [excludedFieldNames 'ColorScale'];
    end
end
baseDisp(this, fieldNames, excludedFieldNames);

%-------------------------------------------------------------------------------
% [EOF]
