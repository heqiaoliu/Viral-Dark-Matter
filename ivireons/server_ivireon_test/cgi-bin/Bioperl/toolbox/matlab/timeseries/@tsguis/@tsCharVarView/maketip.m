function str = maketip(this,tip,info)
%MAKETIP  Build data tips for tsCharViewView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/15 20:57:20 $
r = info.Carrier;
AxGrid = info.View.AxesGrid;
str0 = sprintf('Time series: %s\n',r.Name);
str1 = sprintf('Variance fraction: %0.4g\n',...
    100*(info.Data.RVariance(info.Row)-info.Data.LVariance(info.Row))/info.Data.Variance(info.Row));
str2 = sprintf('Variance: %0.4g\n',...
    info.Data.RVariance(info.Row)-info.Data.LVariance(info.Row));
str3 = sprintf('Standard deviation: %0.4g',...
    sqrt(info.Data.RVariance(info.Row)-info.Data.LVariance(info.Row)));
str = {[str0,str1,str2,str3]};

if length(info.Data.Variance)>1
    str{end+1,1} = sprintf('Column: %d',info.Row);
end

TipText = str;