function bool = isLegalChild(this,ts)
% check if ts is a valid Timeseries data object, that is allowed in the
% GUI under the main Time Series node.
% Currently, there are: timeseries and tscolleciton.
%
% Simulink data objects are not included, since they must appear under
% their own parent node.  

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2006/06/27 23:11:58 $

%Limitation: class names must match explicitly. You lose flexibility of
%specifying the parent's class name available with "isa".

if iscell(ts)
    bool = false;
    for k=1:length(this.legalChildren)
        if all(cellfun('isclass',ts,this.legalChildren{k}))
            nameList = cell(length(ts),1);
            for j=1:length(ts)
                nameList{j} = ts{j}.Name;
            end            
            bool = (length(unique(nameList))==length(nameList));
            return
        end
    end
else
   bool = any(strcmpi(class(ts),this.legalChildren));
end