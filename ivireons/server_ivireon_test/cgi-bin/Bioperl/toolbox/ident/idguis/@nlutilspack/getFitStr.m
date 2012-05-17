function str = getFitStr(data,Fit)
%GETFITSTR Get a nicely formatted string representation of fit % data.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.12.1 $ $Date: 2009/07/09 20:52:22 $

[~,ny, ~, ne] = size(data);
Fit = squeeze(Fit);

if ny==1 && ne==1
    % single output, single-experiment
    str = [': <b>',num2str(Fit,'%3.4g'),'%</b><br>'];
    return
end

yna = data.OutputName;
expna = data.ExperimentName;

if ny==1
    str = ' (per experiment):<br>';
    for ke = 1:ne
        str = sprintf('%s&nbsp;%s: <b>%3.4g%%</b><br>',str,expna{ke},Fit(ke));
    end
elseif ne==1
    str = ' (per output):<br>';
    for ky = 1:ny
        str = sprintf('%s&nbsp;Output %d (%s): <b>%3.4g%%</b><br>',str,ky,yna{ky},Fit(ky));
    end
else
    str = ' (per experiment, per output):<br>';
    for ke = 1:ne
        str = sprintf('%s&nbsp;<b>%s:</b><br>',str,expna{ke});
        for ky = 1:ny
            str = sprintf('%s&nbsp;&nbsp;&nbsp;Output %d (%s): <b>%3.4g%%</b><br>',str,ky,yna{ky},Fit(ke,ky));
        end
    end
end