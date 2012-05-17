function [SelectedIndex,flag] = checkBlankTimePoint(h,timeValue,option)
%

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2009/09/28 20:28:28 $

SelectedIndex = 1:length(timeValue);
flag=true;
if iscell(timeValue)
    nanI = cellfun(@(x) isnumeric(x) && isnan(x),timeValue);
    emptyI = cellfun('isempty',timeValue);
    if sum(nanI)>0 || sum(emptyI)>0
        ButtonBlank=questdlg(xlate('The time vector contains blank time points.  Do you want to remove all the blank points?'), ...
        'Time Series Tools', xlate('Remove'), ...
        xlate('Abort'),...
        xlate('Remove'));
        drawnow;
        ButtonBlank = xlate(ButtonBlank);
        switch ButtonBlank
            case xlate('Remove')
                ; %#ok<*NOSEM>
            case xlate('Abort')                    
                SelectedIndex=[];
                flag=false;
                return;
        end
        timeValue(nanI) = {''};
        SelectedIndex=~cellfun('isempty',timeValue);
        flag=true;
    end
elseif isnumeric(timeValue)
    if sum(isnan(timeValue))>0
        ButtonBlank=questdlg(xlate('The time vector contains blank time points.  Do you want to remove all the blank points?'), ...
        'Time Series Tools', xlate('Remove'), ...
        xlate('Abort'),...
        xlate('Remove'));
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
        SelectedIndex=~isnan(timeValue);
        flag=true;
    end
elseif ischar(timeValue) && isvector(timeValue)
    SelectedIndex=1;
end
