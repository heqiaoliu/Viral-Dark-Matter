function [SelectedIndex,flag]=checkBlankTimePoint(h,timeValue,option)

% Copyright 2004-2005 The MathWorks, Inc.

SelectedIndex=[1:length(timeValue)];
flag=true;
if iscell(timeValue)
    if sum(cellfun('isempty',timeValue))>0 || sum(isnan(cell2mat(timeValue(cellfun('isclass',timeValue,'double')))))>0
        ButtonBlank=questdlg('The time vector contains blank time points. Do you want to remove all the blank points?', ...
        'Time Series Tools', 'Remove', ...
        'Abort',...
        'Remove');
        drawnow;
        ButtonBlank = xlate(ButtonBlank);
        switch ButtonBlank
            case xlate('Remove')
                ;
            case xlate('Abort')                    
                SelectedIndex=[];
                flag=false;
                return;
        end
        tmpIndex=find(cellfun('isclass',timeValue,'double')==1);
        tmpIndex=tmpIndex(isnan(cell2mat(timeValue(tmpIndex))));
        timeValue(tmpIndex)={''};
        SelectedIndex=~cellfun('isempty',timeValue);
        flag=true;
    end
elseif isnumeric(timeValue)
    if sum(isnan(timeValue))>0
        ButtonBlank=questdlg('The time vector contains blank time points. Do you want to remove all the blank points?', ...
        'Time Series Tools', 'Remove', ...
        'Abort',...
        'Remove');
        ButtonBlank = xlate(ButtonBlank);
        drawnow;
        switch ButtonBlank
            case xlate('Remove')
                ;
            case xlate('Abort')                    
                SelectedIndex=[];
                flag=false;
                return;
        end
        SelectedIndex=~isnan(timeValue);
        flag=true;
    end
elseif ischar(timeValue) && isvector(timeValue)
    SelectedIndex=1;
end