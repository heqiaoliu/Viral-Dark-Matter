function stop = nlmefitoutputfcn(beta,status,state)
% NMLEFITOUTPUTFCN Output function example for NLMEFIT and NLMEFITSA.
%
% STOP = NMLEFITOUTPUTFCN(BETA,STATUS,STATE) initializes or updates a plot
% with the fixed-effects (BETA) and the variance of the random-effects
% (diag(STATUS.Psi)). For NLMEFIT, the plot also includes the
% log-likelihood (STATUS.fval). NMLEFITOUTPUTFCN stops NLMEFIT or NLMEFITSA
% when the figure is closed.
%
%     BETA   the current fixed effects
%
%     STATUS is a structure with fields that include the following:
%         iteration:      an integer starting from 0
%         fval:           the current log-likelihood (this field is not
%                         included by NLMEFITSA)
%         Psi:            the current random effects covariance matrix
%
%     STATE   'init', 'iter', or 'done'
%
% The STATUS structure also contains other fields not used by this output
% function. For NLMEFIT, these include:
%
%         procedure:      'ALT' or 'LAP'
%         inner:          a structure describing the current status of the
%                         inner iterations within the ALT and LAP
%                         procedures, with the fields:
%             procedure:  'PNLS','LME', or 'none' when procedure is 'ALT'
%                         'PNLS','PLM', or 'none' when procedure is 'LAP'
%             state:      'init', 'iter', 'done', or 'none'
%             iteration:  an integer starting from 0, or NaN
%         theta:          the current parameterization of Psi
%         mse:            the current error variance
%
% For NLMEFITSA with burn-in iterations, the output function is called
% after each of those iterations with a negative value for
% STATUS.iteration.
%
% Abbreviations:
% ALT  - Alternating Algorithm for the optimization of the LME or RELME
%        approximations
% LAP  - Optimization of the Laplacian Approximation for FO or FOCE
% LME  - Linear Mixed-Effects Estimation
% PNLS - Penalized Non-Linear Least Squares
% PLM  - Profiled Likelihood Maximization
%
% See also NLMEFIT, NLMEFITSA.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:59:01 $

stop = false;
if isvector(status.Psi)
    Psidiag = status.Psi;
else
    Psidiag = diag(status.Psi);       % Random-effects variances
end
have_lik = isfield(status,'fval');
switch state
    case 'init'
        stop = setup(beta,status,Psidiag,have_lik);
    case 'iter'
        stop = update(beta,status,Psidiag,have_lik);
    case 'done'
        [rep,nreps] = getrep(status);
        fh = findobj('Tag','nlmefitplot_active');
        if isempty(fh)
            stop = true;
        elseif rep==nreps
            set(fh,'Tag','nlmefitplot')
        end
end
end

% Set up figure with subplots for graphing
function stop = setup(beta,status,Psidiag,have_lik)

stop = false;
s = numel(beta)+numel(Psidiag)+have_lik;  % num of subplots
n = floor(sqrt(s)); m = ceil(s./n);% figure out number of rows and cols
h = zeros(s,1);                    % a vector to store HG handles to lines

[rep,nreps] = getrep(status);

clr = jet(max(2,nreps)); % insures blue will be first
clr = clr(rep,:);

if rep==1
    close(findobj('Tag','nlmefitplot_active'));
    fh = figure('Tag','nlmefitplot_active');
    numaxes = numel(beta)+numel(Psidiag)+have_lik;
    ax = zeros(numaxes,1);
    for k=1:numaxes
        ax(k) = subplot(m,n,k);
    end
else
    fh = findobj('Tag','nlmefitplot_active');
    if isempty(fh)
        stop = true;
        return
    end
    ax = getappdata(fh,'subplots');
end

k = 1;
for i = 1:numel(beta)              % initialize fixed-effects plots
    h(k) = line(0,beta(i),'Parent',ax(k),'Color',clr);
    title(ax(k),['\beta_' num2str(i)])
    k = k+1;
end
for i = 1:numel(Psidiag)          % initialize random-effects variance plots
    h(k) = line(0,Psidiag(i),'Parent',ax(k),'Color',clr);
    title(ax(k),['\Psi_' num2str(i) '_' num2str(i)])
    k = k+1;
end
if have_lik
    h(k) = line(0,status.fval,'Parent',ax(k),'Color',clr);
    title(ax(k),'loglikelihood')
end
set(h,'DisplayName',sprintf('Rep %d',rep));
setappdata(fh,'handles',h)
setappdata(fh,'lastDraw',clock)
setappdata(fh,'subplots',ax)
end

function stop = update(beta,status,Psidiag,have_lik)
fh = findobj('Tag','nlmefitplot_active');
if ~isempty(fh)
    h = getappdata(fh,'handles');
    k = 1;
    for i = 1:numel(beta)
        Xdata = get(h(k),'Xdata');
        Ydata = get(h(k),'Ydata');
        set(h(k),'Xdata',[Xdata max(Xdata)+1],'Ydata',[Ydata beta(i)])
        k = k+1;
    end
    for i = 1:numel(Psidiag)
        Xdata = get(h(k),'Xdata');
        Ydata = get(h(k),'Ydata');
        set(h(k),'Xdata',[Xdata max(Xdata)+1],'Ydata',[Ydata Psidiag(i)])
        k = k+1;
    end
    if have_lik
        Xdata = get(h(k),'Xdata');
        Ydata = get(h(k),'Ydata');
        set(h(k),'Xdata',[Xdata max(Xdata)+1],'Ydata',[Ydata status.fval])
    end
    if etime(clock,getappdata(fh,'lastDraw'))>1
        setappdata(fh,'lastDraw',clock)
        drawnow
    end
    stop = false;
else
    stop = true;
end
end

function [rep,nreps] = getrep(status)
if isfield(status,'nreplicates')
    nreps = status.nreplicates;
else
    nreps = 1;
end
if isfield(status,'replicate')
    rep = status.replicate;
else
    rep = 1;
end
end
