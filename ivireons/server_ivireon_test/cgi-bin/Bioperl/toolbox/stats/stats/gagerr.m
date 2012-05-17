function [table, stats] = gagerr(y,group,varargin)
% GAGERR Gage repeatability and reproducibility (R&R) study
%     GAGERR(Y,{PART,OPERATOR}) performs a gage R&R study on measurements 
%     in Y collected by OPERATOR on PART.  Y is a column vector containing 
%     the measurements on different parts.  PART and OPERATOR are
%     categorical variables, numeric vectors, character matrices, or cell
%     arrays of strings.  The number of elements in PART and OPERATOR
%     should be the same as in Y.
%
%     A table is printed in the command window in which the decomposition 
%     of variance, standard deviation, study var (5.15*standard deviation)
%     are listed with respective percentages for different sources.
%     Summary statistics are printed below the table giving the number of 
%     distinct categories (NDC) and the percentage of Gage R&R of total 
%     variations (PRR).
%
%     A bar graph is also plotted showing the percentage of different
%     components of variations. Gage R&R, repeatability, reproducibility,
%     and part to part variations are plotted as four vertical bars.
%     Variance and study var are plotted as two groups.
%
%     The guideline to determine the capability of a measurement system
%     using NDC is the following:
%           (1) If NDC > 5, the measurement system is capable
%           (2) If NDC < 2, the measurement system is not capable
%           (3) Otherwise, the measurement system may be acceptable
%
%     The guideline to determine the capability of a measurement
%     system using PRR is the following:
%           (1) If PRR < 10%, the measurement system is capable
%           (2) If PRR > 30%, the measurement system is not capable
%           (3) Otherwise, the measurement system may be acceptable
% 
%     GAGERR(Y,GROUP) performs a gage R&R study on measurements in Y
%     with PART and OPERATOR represented in GROUP. GROUP is a numeric 
%     matrix whose first and second columns specify different parts and
%     operators respectively. The number of rows in GROUP should be the
%     same as the number of elements in Y.
% 
%     GAGERR(Y,PART) performs a gage R&R study  on measurements in Y
%     without operator information. The assumption is that all variability 
%     is contributed by PART. 
% 
%     GAGERR(...,'PARAM1',val1,'PARAM2',val2,...) performs a gage R&R study
%     using  one or more of the following parameter name/value pairs:
%
%       Parameter       Value
%
%       'spec'          A two element vector which defines the lower and 
%                       upper limit of the process, respectively. In this 
%                       case, summary statistics printed in the command 
%                       window include Precision-to-Tolerance Ratio (PTR). 
%                       Also, the bar graph includes an additional group, 
%                       the percentage of tolerance.
%
%                       The guideline to determine the capability of a
%                       measurement system using PTR is the following: 
%                         (1) If PTR < 0.1, the measurement system is
%                         capable
%                         (2) If PTR > 0.3, the measurement system is not
%                         capable
%                         (3) Otherwise, the measurement system may be
%                         acceptable
%
%      'printtable'     A string with a value 'on' or 'off' which indicates
%                       whether the tabular output should be printed in the
%                       command window or not. The default value is 'on'.
%
%      'printgraph'     A string with a value 'on' or 'off' which indicates
%                       whether the bar graph should be plotted or not. The 
%                       default value is 'on'.
%
%      'randomoperator' A logical value, true or false, which indicates
%                       whether the effect of OPERATOR is random or not. 
%
%      'model'          The model to use, specified by one of:
%                         'linear' -- Main effects only (default)
%                         'interaction' -- Main effects plus two-factor 
%                                          interactions
%                         'nested' -- Nest OPERATOR in PART
%     
%    [TABLE, STATS] = GAGERR(...) returns a 6x5 matrix TABLE and a 
%    structure STATS. The columns of TABLE, from left to right, represent 
%    variance, percentage of variance, standard deviations, study var, and 
%    percentage of study var. The rows of TABLE, from top to bottom, 
%    represent different sources of variations: gage R&R, repeatability, 
%    reproducibility, operator, operator and part interactions, and part. 
%    STATS is a structure containing summary statistics for the performance 
%    of the measurement system. The fields of STATS are:
%          ndc -- Number of distinct categories
%          prr -- Percentage of gage R&R of total variations
%          ptr -- Precision-to-tolerance ratio. The value is NaN if the 
%                 parameter 'spec' is not given. 
%
%  Example 
%    Conduct a gage R&R study for a simulated measurement system using a 
%    mixed ANOVA model without interactions:
%       y = randn(100,1);                                % measurements
%       part = ceil(3*rand(100,1));                      % parts
%       operator = ceil(4*rand(100,1));                  % operators
%       gagerr(y,{part, operator},'randomoperator',true) % analysis
%

% Copyright 2006-2009 The MathWorks, Inc.
if nargin<2
    error('stats:gagerr:FewInput','GAGERR requires at least 2 arguments.');
end

if isa(group,'categorical')  % may be a single categorical variable
    group = {group};
elseif isnumeric(group)      % may be a matrix with one or two columns
    group = num2cell(group,1);
end

if length(group)>2
    error('stats:gagerr:BadGroup','GROUP should not have more than two variables.');
end;
if cellfun(@length,group) ~= size(y,1);
    error('stats:gagerr:MismatchGroup','GROUP should have the same number of items as Y.');
end
 
% Measurements must be a numeric vector
if ~isvector(y) || ~isnumeric(y)
    error('stats:gagerr:BadY','Y must be a numeric vector.');
end
 
% Determine whether the operator factor is given
nooperators = (length(group)==1);
 
 
args =   {'model', 'randomoperator','spec', 'printtable','printgraph'};
defaults = {'linear',true, [],'on', 'on'};
[eid,emsg,model,randomoperator,spec,printtable,printgraph] ...
                   =  internal.stats.getargs(args,defaults,varargin{:});
if ~isempty(eid)
  error(sprintf('stats:gagerr:%s',eid),emsg);
end
 
if ~ischar(model) || size(model,1)>1 
    error('stats:gagerr:BadModel', 'MODEL must be a string.') 
end 
model = lower(model);
if ~any(strcmp(model,{'linear','interaction','nested'}))
    error('stats:gagerr:BadModel', 'MODEL must be a string with value linear,interaction, or,nested.') 
end;
 
if randomoperator ~= 1 && randomoperator ~= 0
    error('stats:gagerr:BadRandomoperator', 'RANDOMOPERATOR must be a logical value.') 
end 
 
switch model 
    case 'linear'
        if randomoperator
            modelnum = 1;
        else
            modelnum = 4;
        end;
    case 'interaction'
        if randomoperator
            modelnum = 2;
        else
            modelnum = 5;
        end;
    case 'nested'
         modelnum = 3;
end;
 
if  ~isnumeric(spec) || (isnumeric(spec)&& numel(spec)~=2 && numel(spec)~=0)
    error('stats:gagerr:BadSpec', 'SPEC must be a numeric vector with two elements.') 
end
 
% check argument printtable
if ~ischar(printtable) || size(printtable,1)>1
    error('stats:gagerr:BadPrinttable', 'PRINTTATBLE must be a string.') 
end
printtable = lower(printtable);
outputtable = strcmp(printtable, 'on');
if ~outputtable && ~strcmp(printtable, 'off');
    error('stats:gagerr:BadPrinttable', 'PRINTTATBLE must be a string with value on or off.')
end;
    
% check argument printgraph
if ~ischar(printgraph)|| size(printgraph,1)>1
    error('stats:gagerr:BadPrintgraph', 'PRINTGRAPH must be a string.') 
end
printgraph = lower(printgraph);
outputgraph = strcmp(printgraph, 'on');
if ~outputgraph && ~strcmp(printgraph, 'off');
    error('stats:gagerr:BadPrintgraph', 'PRINTGRAPH must be a string with value on or off.')
end;
 
if nooperators 
    [p,atab,anovastats] = anovan(y,group,'random',1,'display','off'); 
else
    group = group(:);
    switch modelnum
        case 1 % cross model without interaction
            [p,atab,anovastats] = anovan(y,group, 'random',[1 2],'display','off');
        case 2 % cross model with interaction
            [p,atab,anovastats] = anovan(y,group, ...
                'model','interaction','random',[1 2],'display','off');
        case 3 % nested model 
            [p,atab,anovastats] = anovan(y,group, ...
                'nested',[0 0; 1 0],'random',[1 2],'display','off');
        case 4 % mixed model without interaction
            [p,atab,anovastats] = anovan(y,group, 'random',1,'display','off');     
        case 5 % mixed model with interaction
            [p,atab,anovastats] = anovan(y,group, ...
                'model','interaction','random',1,'display','off');     
    end;          
end
 
% Variance breakdown
repeatabilityvar = anovastats.varest(end);
parttopartvar = max(0, anovastats.varest(1));
 
if nooperators || modelnum>=4            % operator is not random
    operatorvar = 0;
else 
    operatorvar = max(0, anovastats.varest(2));
end; 
 
if any(modelnum ==[2,5])
    interactionvar = max(0, anovastats.varest(end-1));
else
    interactionvar = 0;
end;
 
% variation components 
allvar = [repeatabilityvar operatorvar interactionvar parttopartvar];
%      Gage R&R         |Repeatability | Reproducibility | Operator |Operator*Part |Part to Part
vars = [sum(allvar(1:3)) allvar(1)    sum(allvar(2:3))   allvar(2:end)];    % variance components
totalvar = sum(allvar);                 % total variance 
varspercentage = 100* vars/totalvar;    % percentage of variance
stds =  sqrt(vars);                     % standard deviation components;
totalstd =sqrt(totalvar);               % total standard deviation  
studyvar = 5.15*stds;                    % study var components
stdspercentage = 100* stds/totalstd;    % percentage of standard deviations
 
% summary statistics 
ndc = round(sqrt(2*vars(6)/vars(1)));           % NDC = 1.41*Part to Part/gage RR  
prr = stdspercentage(1);                     % PRR = gage RR / total
% PTR can only be calculated if we have spec.
if ~isempty(spec) 
    ptr = 5.15*stds(1)/abs(spec(2)-spec(1)); % PTR = 5.15*gage RR /diff(spec)
else 
    ptr = NaN;
end;
 
% print results in command window
if outputtable
    fprintf('\n\n  Source            Variance     %% Variance      sigma      5.15*sigma    %% 5.15*sigma \n')
    fprintf('  =============================================================================================\n')
    fprintf('  Gage R&R          %6.2f        %6.2f        %6.2f        %6.2f        %6.2f \n', ...
                       vars(1), varspercentage(1),stds(1),studyvar(1),stdspercentage(1));
    fprintf('    Repeatability   %6.2f        %6.2f        %6.2f        %6.2f        %6.2f \n', ...
                       vars(2), varspercentage(2),stds(2),studyvar(2),stdspercentage(2));
    fprintf('    Reproducibility %6.2f        %6.2f        %6.2f        %6.2f        %6.2f \n', ...
                       vars(3), varspercentage(3),stds(3),studyvar(3),stdspercentage(3));
    if ~nooperators && modelnum<4        % operator item does not show up 
        fprintf('     Operator       %6.2f        %6.2f        %6.2f        %6.2f        %6.2f \n', ...
                      vars(4), varspercentage(4),stds(4),studyvar(4),stdspercentage(4));
    end;
    if any(modelnum ==[2,5]) % interaction item only shows up if the model includes that item  
        fprintf('     Part*Operator  %6.2f        %6.2f        %6.2f        %6.2f        %6.2f \n', ...
                      vars(5), varspercentage(5),stds(5),studyvar(5),stdspercentage(5));
    end      
    fprintf('  Part              %6.2f        %6.2f        %6.2f        %6.2f        %6.2f \n',...
                      vars(6), varspercentage(6),stds(6),studyvar(6),stdspercentage(6));
    fprintf('  Total             %6.2f        %6.2f        %6.2f        %6.2f \n', totalvar, 100,totalstd,5.15*totalstd);
    fprintf('  ---------------------------------------------------------------------------------------------\n\n\n')
    fprintf('               Number of distinct categories (NDC)    : %2d\n', ndc);  
    fprintf('               %% of Gage R&R of total variations (PRR): %6.2f\n', prr);  
    if ~isempty(spec)    % PTR is printed if we have spec.
          fprintf('               Precision-to-tolerance Ratio (PTR)     : %6.2f\n', ptr);  
    end;
    fprintf('\nNote: The last column of the above table does not have to sum to 100%% \n\n\n')
end;
 
if outputgraph 
    % bar plot of variation decomposition
    idx = [1,2,3,6];  % indices for Gage R&R, Repeatability, Reproducibility, and Part to Part
    % PTR is plotted only if we have spec.
    if isempty(spec)        
        bar([varspercentage(idx);stdspercentage(idx)]','grouped')
        legend('%Variance','%StudyVar')
    else
        tolerancepercentage = 5.15*stds/abs(spec(2)-spec(1));
        bar([varspercentage(idx);stdspercentage(idx);tolerancepercentage(idx)]','grouped')
        legend('%Variance','%StudyVar','%Tolerance')
    end;
    set(gca,'xticklabel',{'Gage R&R', 'Repeatability','Reproducibility','Part to Part'})    
    ylabel('Percent')    
end;
 
if nargout>0
    table = [vars; varspercentage; stds; studyvar;stdspercentage]';    
end;
 
if nargout>1
    stats.ndc  = ndc; 
    stats.prr  = prr; 
    stats.ptr  = ptr;
end;
