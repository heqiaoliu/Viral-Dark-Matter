function utConfigureAlgorithOptionsObject(this)
% Common config for algorithm options objects and their subclasses.

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 14:45:40 $

this.Advanced_Properties = nloptionspack.advancedalgorithmoptions(this);

% attach property post-set listeners
L1 = handle.listener(this,findprop(this,'Maximum_Iterations'),'PropertyPostSet',...
    @(es,ed) LocalMaximumIterationsCallback(ed,this));

L2 = handle.listener(this,findprop(this,'Tolerance'),'PropertyPostSet',...
    @(es,ed) LocalToleranceCallback(ed,this));

L3 = handle.listener(this,findprop(this,'Robustification_Limit'),'PropertyPostSet',...
    @(es,ed) LocalRobustificationLimitCallback(ed,this));

L4 = handle.listener(this,findprop(this,'Maximum_Size'),'PropertyPostSet',...
    @(es,ed) LocalMaximumSizeCallback(ed,this));


L5 = handle.listener(this,findprop(this,'Search_Method'),'PropertyPostSet',...
    @(es,ed) LocalSearchMethodCallback(ed,this));

L6 = [];
p = findprop(this,'Iterative_Wavenet');
if ~isempty(p)
    L6 = handle.listener(this,p,'PropertyPostSet',@(es,ed) LocalIterWavenetCallback(ed,this));
end

L7 = handle.listener(this,findprop(this,'Search_Criterion'),'PropertyPostSet',...
    @(es,ed) LocalSearchCriterionCallback(ed,this));

L8 = handle.listener(this,findprop(this,'Trace_Criterion_Weighting'),'PropertyPostSet',...
    @(es,ed) LocalWeightingCallback(ed,this));


% L7 = handle.listener(this,findprop(this,'Advanced_Properties'),'PropertyPostSet',...
%     @(es,ed) LocalAdvancedPropCallback(ed,this));

this.Listeners = [L1,L2,L3,L4,L5,L6,L7,L8];

%--------------------------------------------------------------------------
function LocalMaximumIterationsCallback(ed,this)
% post-change callback

OldValue = this.Algorithm.MaxIter;
if isposintscalar(ed.NewValue)
    this.Algorithm.MaxIter = ed.NewValue;
else
    errordlg('Maximum Iterations must be a positive integer.',...
        'Invalid Algorithm Setting','modal');
    this.Maximum_Iterations = OldValue;
end

%--------------------------------------------------------------------------
function LocalToleranceCallback(ed,this)
% post-change callback

OldValue = this.Algorithm.Tolerance;
if isposrealscalar(ed.NewValue)
    this.Algorithm.Tolerance = ed.NewValue;
else
    errordlg('Tolerance must be a positive real number.',...
        'Invalid Algorithm Setting','modal');
    this.Tolerance = OldValue;
end

%--------------------------------------------------------------------------
function LocalRobustificationLimitCallback(ed,this)
% post-change callback

OldValue = this.Algorithm.LimitError;
x = ed.NewValue;
Accept = (~isempty(x)) && isnumeric(x) && isreal(x) && isscalar(x) && isfinite(x) && (x>=0);
if Accept
    this.Algorithm.LimitError = x;
else
    errordlg('Robustification Limit must be a non-negative real number.',...
        'Invalid Algorithm Setting','modal');
    this.Robustification_Limit = OldValue;
end


%--------------------------------------------------------------------------
function LocalMaximumSizeCallback(ed,this)
% post-change callback

OldValue = this.Algorithm.MaxSize;
if isposintscalar(ed.NewValue)
    this.Algorithm.MaxSize = ed.NewValue;
else
    errordlg('Maximum Size must be a positive integer.',...
        'Invalid Algorithm Setting','modal');
    this.Maximum_Size = OldValue;
end

%--------------------------------------------------------------------------
function LocalSearchMethodCallback(ed,this)

sm = ed.NewValue;
f = fieldnames(this.SearchMethodLookUp);
searchoptions = struct2cell(this.SearchMethodLookUp);
Loc = strcmpi(sm,searchoptions);
this.Algorithm.SearchMethod = f{Loc};

%--------------------------------------------------------------------------
function LocalIterWavenetCallback(ed,this)

this.Algorithm.IterWavenet = ed.NewValue;

%--------------------------------------------------------------------------
function LocalSearchCriterionCallback(ed,this)

sm = ed.NewValue;
if strncmpi(sm,'det',3)
    this.Algorithm.Criterion = 'det';
else
    this.Algorithm.Criterion = 'trace';
end

%--------------------------------------------------------------------------
function LocalWeightingCallback(ed,this)

sm = ed.NewValue;
[sr,sc] = size(sm);
OldValue = this.Algorithm.Weighting;
ny = size(OldValue,1);
if (sr~=sc) || (sr~=ny) || ~(isrealmat(sm) && ...
        all(isfinite(sm(:))) && (~isempty(sm) && min(eig(sm))>=0))
    errordlg(sprintf('Weighting should be a positive semi-definite matrix of size %d.',ny))
    this.Trace_Criterion_Weighting = OldValue; 
else
    this.Algorithm.Weighting = sm;
end
