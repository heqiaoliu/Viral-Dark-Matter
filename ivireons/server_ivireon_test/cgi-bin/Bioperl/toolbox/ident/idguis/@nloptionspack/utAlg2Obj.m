function utAlg2Obj(OptionObj,Model)
% update the properties by reading off values from algorithm struct
% superclass method of @algorithmoptions that is called by subclass
% @algorithmoptionswithfocus also.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/04/28 03:21:10 $

alg = Model.Algorithm;

OptionObj.Algorithm = alg;

% search method
f = fieldnames(OptionObj.SearchMethodLookUp);
Loc = strcmpi(alg.SearchMethod,f);
searchoptions = struct2cell(OptionObj.SearchMethodLookUp);

OptionObj.Search_Method = searchoptions{Loc};

% % iterWavenet
% if strcmpi(alg.IterWavenet,'auto')
%     OptionObj.Iterative_Wavenet = 'Auto';
% elseif strcmpi(alg.IterWavenet,'on')
%     OptionObj.Iterative_Wavenet = 'On';
% else
%     OptionObj.Iterative_Wavenet = 'Off';
% end

% maxiter
OptionObj.Maximum_Iterations = alg.MaxIter;

% tolerance
OptionObj.Tolerance = alg.Tolerance;

% limit error
OptionObj.Robustification_Limit = alg.LimitError;

% max size
OptionObj.Maximum_Size = alg.MaxSize;

% search criterion
OptionObj.Search_Criterion = alg.Criterion;

% weighting
OptionObj.Trace_Criterion_Weighting = alg.Weighting;

% advanced properties
OptionObj.Advanced_Properties.alg2obj(alg.Advanced);

