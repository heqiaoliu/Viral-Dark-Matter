function [idx,History] = feval(h,ts,varargin)
%FEVAL

% Author(s): James G. Owen
% Revised:
% Copyright 2001-2005 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2007/05/29 21:16:20 $

%% Overloaed feval to incorerate logical combinations of rules

s = size(ts.data);
recorder = tsguis.recorder;
History = {};

%% Define rule switches
outliersactive =  ~isempty(h.Outlierwindow) && h.Outlierwindow<s(1) && ...
        h.Outlierwindow>0 && ~isempty(h.Outlierconf) && h.Outlierconf>0 && (nargin==2 || ...
        strcmpi(varargin{1},'Outliers'));
flatlineactive =  ~isempty(h.Flatlinelength) && h.Flatlinelength>1 && ...
        size(ts.data,1)>2 && (nargin==2 || strcmpi(varargin{1},'Flatline'));
expressionactive =  length(deblank(h.Mexpression))>1 && ...
        (nargin==2 || strcmpi(varargin{1},'Expression'));
boundsactive = (~isempty(h.Yhigh) || ~isempty(h.Ylow) || ...
        ~isempty(h.Xhigh) || ~isempty(h.Xlow)) && ...
        (nargin==2 || strcmpi(varargin{1},'Bounds'));

%% Process time/data bounds
if boundsactive
    if strcmp(h.AbsoluteTime,'on')
         t = ts.Time*tsunitconv('days',ts.TimeInfo.Units)+datenum(ts.TimeInfo.StartDate);
         unitconv = 1; % All units are conveted to datenums
    else
         t = ts.Time;
         unitconv = tsunitconv(h.Xunits,ts.TimeInfo.Units);
    end
    idxBounds = false(s);
    History = localAddHistory(History,['idxBounds = false(size(' ts.Name '.Data));']);
    X = ts.Data;
    % Bounds Error checking
    if ~isempty(h.Ylow) && (length(h.Ylow)~=1 && length(h.Ylow)~=s(2))
        error('exclusion:feval:ylowbounds', ...
            'The Y lower bound must either be a scalar or have length equal to the number of data columns');
    end
    if ~isempty(h.Yhigh) && (length(h.Yhigh)~=1 && length(h.Yhigh)~=s(2))
        error('exclusion:feval:yhighbounds', ...
            'The Y upper bound must either be a scalar or have length equal to the number of data columns');
    end
    if (~isempty(h.Xlow) && ~isscalar(h.Xlow)) && (~isempty(h.Xhigh) && ~isscalar(h.Xhigh))
        error('exclusion:feval:xbounds', ...
            'The time upper and lower bounds must be scalar');
    end  
    % Bounds comparison
    if ~isempty(h.Xlow) && isfinite(h.Xlow) 
        if strcmp(h.Xlowstrict,'on')
            idxBounds(t*unitconv>=h.Xlow,:) = true;
            symb = '>=';
        else
            idxBounds(t*unitconv>h.Xlow,:) = true;
            symb = '>';
        end
        % Update logical bound var in macro history
        if strcmp(h.AbsoluteTime,'on')
            History = localAddHistory(History,'%% Rule selection: Lower time bound',...
                      ['t = ', ts.Name, '.Time * tsunitconv(''days'',', ts.Name, '.TimeInfo.Units)+datenum(',...
                       ts.Name,'.TimeInfo.StartDate);']);
            History = localAddHistory(History,...
                    ['idxBounds(t ' symb sprintf('%f',h.Xlow/unitconv) ',:) = true;']);             
        else    
            History = localAddHistory(History,'%% Rule selection: Lower time bound',...
                    ['idxBounds(' ts.Name '.Time ' symb sprintf('%f',h.Xlow/unitconv) ',:) = true;']); 
        end        
    end
    if ~isempty(h.Xhigh) && isfinite(h.Xhigh)
        if strcmp(h.Xhighstrict,'on')
            idxBounds(t*unitconv<=h.Xhigh,:) = true;
            symb = '<=';
        else
            idxBounds(t*unitconv<h.Xhigh,:) = true;
            symb = '<';
        end   
        % Update logical bound var in macro history
        if strcmp(h.AbsoluteTime,'on')
            History = localAddHistory(History,'%% Rule selection: Upper time bound',...
                      ['t = ', ts.Name, '.Time * tsunitconv(''days'',', ts.Name, '.TimeInfo.Units)+datenum(',...
                       ts.Name,'.TimeInfo.StartDate);']);
            History = localAddHistory(History,...
                    ['idxBounds(t ' symb sprintf('%f',h.Xhigh/unitconv) ',:) = true;']);                   
        else    
            History = localAddHistory(History,'%% Rule selection: Upper time bound',...
               ['idxBounds(' ts.Name '.Time ' symb sprintf('%f',h.Xhigh/unitconv) ',:) = true;']);
        end
    end
    if length(h.Ylow)>1 && any(isfinite(h.Ylow))
        if strcmp(h.Ylowstrict,'on')
            idxBounds(any((X>=ones(size(X,1),1)*(h.Ylow(:)'))')') = true;
            symb = '>=';
        else
            idxBounds(any((X>ones(size(X,1),1)*(h.Ylow(:)'))')') = true;
            symb = '>';
        end
        % Update logical bound var in macro history
        History = localAddHistory(History,'%% Rule selection: Upper data bound',...
                    ['idxBounds(any((' ts.Name '.Data ' symb  'ones(size(' ts.Name ...
                    '.TimeInfo.Length,1),1)*['  num2str(h.Ylow(:)') '])'' )'');']);        
    elseif length(h.Ylow)==1 && isfinite(h.Ylow)
        if strcmp(h.Ylowstrict,'on')
            idxBounds(X>=h.Ylow) = true;
            symb = '>=';
        else
            idxBounds(X>h.Ylow) = true;
            symb = '>';
        end
        % Update logical bound var in macro history
        History = localAddHistory(History,'%% Rule selection: Upper data bound',...
            ['idxBounds(' ts.Name '.Data ' symb sprintf('%f',h.Ylow) ') = true;']); 
    end
    if length(h.Yhigh)>1 && any(isfinite(h.Yhigh))
        if strcmp(h.Yhighstrict,'on')
            idxBounds(any((X<=ones(size(X,1),1)*(h.Yhigh(:)'))')') = true;
            symb = '<=';
        else
            idxBounds(any((X<ones(size(X,1),1)*(h.Yhigh(:)'))')') = true;
            symb = '<';
        end
        % Update logical bound var in macro history
        History = localAddHistory(History,'%% Rule selection: Lower data bound',...
            ['idxBounds(any((' ts.Name '.Data ' symb  'ones(size(' ts.Name ...
            '.TimeInfo.Length,1),1)*['  num2str(h.Yhigh(:)') '])'' )'');']);        
    elseif length(h.Yhigh)==1 && isfinite(h.Yhigh)
        if strcmp(h.Yhighstrict,'on')
            idxBounds(X<=h.Yhigh) = true;
            symb = '<=';
        else
            idxBounds(X<h.Yhigh) = true;
            symb = '<';
        end
        % Update logical bound var in macro history
        History = localAddHistory(History,'%% Rule selection: Lower data bound',...
            ['idxBounds(' ts.Name '.Data ' symb sprintf('%f',h.Yhigh) ') = true;']);
    end    
end

%% Process outliers and flatlines bounds      
if outliersactive
    idxOutliers = ts.select('outliers',h.Outlierwindow,h.Outlierconf);    
    History = localAddHistory(History,['idxOutliers = false(size(' ts.Name '.Data));'],...
        '%% Rule selection: Outlier selection',...
        ['idxOutliers = select(tsdata.timeseries(' ts.Name '),''outliers'',' ...
        sprintf('%f',h.Outlierwindow) ',' sprintf('%f',h.Outlierconf) ');']); 
end
if flatlineactive 
    idxFlatlines = ts.select('flatlines',h.Flatlinelength);
    History = localAddHistory(History,['idxFlatlines = false(size(' ts.Name '.Data));'],...
        '%% Rule selection: Flatline selection',...
        ['idxFlatlines = select(tsdata.timeseries(' ts.Name '),''flatlines'',' ...
        sprintf('%f',h.Flatlinelength) ');']);
end 
if expressionactive
    try 
        x = ts.Data;
        idxExpression = eval(h.Mexpression);        
        History = localAddHistory(History,...
            ['idxExpression = false(size(' ts.Name '.Data));'],...
            '%% Rule selection: MATLAB expression selection',['x = ' ts.Name '.Data;'],...
            ['idxExpression = ' h.Mexpression ';']);
    catch
        msgbox('Invalid MATLAB expression. Use the variable ''x'' to represent data.',...
              'Time Series Tools')
    end
end

%% Combine the selected points using the logical rules
if ~any([boundsactive outliersactive flatlineactive  expressionactive])
    idx = false(s); % Nothing selected
    if strcmp(recorder.Recording,'on')        
        History = [History;...
           {['idx = false(size(' ts.Name '.Data));']}];
    end
else 
    initialRule = true;
    if boundsactive
       idx = ~idxBounds;
       History = localAddHistory(History,'%% Rule based selection: Combining selection rules',...
           'idx = ~idxBounds;');
       initialRule = false;
    end
    if outliersactive
        if ~initialRule && strcmp(h.LogicalOp,'and')
           idx = idx & idxOutliers;
           History = localAddHistory(History,'idx = idx & idxOutliers;');
        elseif ~initialRule && strcmp(h.LogicalOp,'or')
           idx = idx | idxOutliers;
           History = localAddHistory(History,'idx = idx | idxOutliers;');
        else
            idx = idxOutliers;
            History = localAddHistory(History,'idx = idxOutliers;');          
        end
        initialRule = false;
    end
    if flatlineactive
        if ~initialRule && strcmp(h.LogicalOp,'and')
           idx = idx & idxFlatlines;
           History = localAddHistory(History,'idx = idx & idxFlatlines;');
        elseif ~initialRule && strcmp(h.LogicalOp,'or')
           idx = idx | idxFlatlines;
           History = localAddHistory(History,'idx = idx | idxFlatlines;');
        else
            idx = idxFlatlines;
            History = localAddHistory(History,'idx = idxFlatlines;');           
        end
        initialRule = false;
    end
    if expressionactive
        if ~initialRule && strcmp(h.LogicalOp,'and')
           idx = idx & idxExpression;
           History = localAddHistory(History,'idx = idx & idxExpression;');
        elseif ~initialRule && strcmp(h.LogicalOp,'or')
           idx = idx | idxExpression;
           History = localAddHistory(History,'idx = idx | idxExpression;');
        else
            idx = idxExpression;
            History = localAddHistory(History,'idx = idxExpression;');          
        end
    end
end

function outArray = localAddHistory(histArray,varargin)

recorder = tsguis.recorder;
if strcmp(recorder.Recording,'on') 
    for k=1:length(varargin)
        histArray = [histArray; ...
                     varargin(k)];
    end
end
outArray = histArray;