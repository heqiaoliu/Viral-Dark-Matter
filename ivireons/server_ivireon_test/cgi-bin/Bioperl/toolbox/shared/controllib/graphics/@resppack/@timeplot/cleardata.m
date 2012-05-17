function cleardata(this,Domain)
%CLEARDATA  Clear dependent data from all data objects.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:25:16 $
if strcmpi(Domain,'Time')
    % Clear mag and phase data (will force reevaluation of the DataFcn)
    if ~isempty(this.Responses)
        for r=find(this.Responses,'-not','DataSrc',[],'-not','DataFcn',[])'
            clear(r.Data)
        end
    end
end