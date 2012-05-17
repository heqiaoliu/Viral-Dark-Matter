function [answ,status] = chkmdinteg(Tsmod,Tsdata,inters,verb)
% This function is not in use.

% Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2008/04/28 03:21:25 $

if nargin<4,
    verb = 1;
end

Nexp = length(Tsdata);

answ = 0;
status = '';

if Tsmod>0, % DT model
    is = inters{1};
    td = Tsdata{1};
    switch lower(inters{1}),
        case 'bl'
            answ = -1;
            id = 'Ident:estimation:chkmdinteg1';
            status = ['Estimation of discrete time modeles from band limited data might produce inaccurate models.' ...
                ' Estimation of continuous time model might yield better results.'];

        case {'foh'}
            answ = -1;
            id = 'Ident:estimation:chkmdinteg2';
            status = ['Estimation of discrete time modeles from first order hold data might produce inaccurate models.' ...
                'Estimation of a continuous time model might yield better results.'];
        otherwise
    end
    for kexp=2:Nexp,
        if ~strcmp(is,inters{kexp}),
            answ = 1;
            id = 'Ident:estimation:chkmdinteg3';
            status = 'When estimating discrete time models, all experiments in the data set must have same intersample behavior.';
            break;
        end
        if td ~= Tsdata{kexp}
            answ = 1;
            id = 'Ident:estimation:chkmdinteg4';
            status = 'When estimating discrete time models, all experiments in the data set must have same sampling interval.';
            break;
        end
    end
else %CT model
end
if verb
    switch answ
        case 1
            error(id,status);
        case -1
            warning(id,status);
        otherwise
    end
end


