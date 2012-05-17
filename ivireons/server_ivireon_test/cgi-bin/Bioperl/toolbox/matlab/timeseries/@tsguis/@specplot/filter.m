function filter(h,varargin)

% Copyright 2004-2006 The MathWorks, Inc.

%% Create transaction
T = tsguis.transaction;
recorder = tsguis.recorder;

%% Get filter type
if nargin==2 && strcmpi(varargin{1},'pass')
    type = 'pass';
else
    type = 'notch';
end

%% Filter in selected intervals
for k=1:length(h.Waves)
    if h.Waves(k).isvisible && ~isempty(h.Waves(k).View.SelectedInterval)
        thists = h.Waves(k).DataSrc.Timeseries; 
        T.ObjectsCell = {T.ObjectsCell{:}, thists};
        timeunitconv = tsunitconv(thists.TimeInfo.Units,...
            sprintf('%ss',h.AxesGrid.Xunits(5:end)));
        [startInd,endInd] = utTrimNans(thists);
        if startInd>1 || endInd<thists.TimeInfo.Length
            thists.delsample('index',[1:startInd-1,endInd+1:thists.TimeInfo.Length]);
        end   
        idealfilter(thists,h.Waves(k).View.SelectedInterval/timeunitconv,type); 

        if strcmp(recorder.Recording,'on')
            freqint = h.Waves(k).View.SelectedInterval/timeunitconv;
            T.addbuffer(xlate('%% Filtering'));
            if size(freqint,1)>1
                T.addbuffer(['freqint = reshape([' num2str(freqint(:)') '],[' ...
                    num2str(size(freqint)) ']);']);
            else
                T.addbuffer(['freqint = [' num2str(freqint) '];']);
            end
            T.addbuffer(sprintf('%s = idealfilter(%s,freqint,%s);',...
                thists.Name,thists.Name,['''' type '''']),thists);
        end

        % Clear selection
        h.Waves(k).View.SelectedInterval = [];
        h.draw
    end
end

%% Store transaction
T.commit;
recorder = tsguis.recorder;
recorder.pushundo(T);

