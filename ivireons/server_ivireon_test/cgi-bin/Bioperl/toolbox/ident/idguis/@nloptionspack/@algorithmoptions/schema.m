function schema
% SCHEMA  Class definition for ALGORITHMOPTIONS

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/03/09 19:14:16 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'algorithmoptions');

n0 = idnlarx([2 2 1],'tree');

% Add new enumeration type
SearchMethods = {'Choose Automatically (Auto)','Gauss-Newton (gn)','Adaptive Gauss-Newton (gna)',...
    'Levenberg-Marquardt (lm)','Trust-Region Reflective Newton (lsqnonlin)',...
    'Gradient Search (grad)'};
SearchFields = {'Auto','gn','gna','lm','lsqnonlin','grad'};

if isempty( findtype('IdSearchMethods') )
  schema.EnumType( 'IdSearchMethods', SearchMethods);
end

if isempty( findtype('Idonoff') )
  schema.EnumType( 'Idonoff', {'On','Off'});
end

if isempty( findtype('IterWavenet') )
  schema.EnumType( 'IterWavenet', {'Auto','On','Off'});
end

if isempty( findtype('IdSearchCriterion') )
  schema.EnumType( 'IdSearchCriterion', {'Determinant','Trace'});
end

% Define properties
p = schema.prop(c,'Listeners','MATLAB array');
p.Visible = 'off';

% data for edit-box components
p = schema.prop(c,'Algorithm','MATLAB array');
p.Visible = 'off';
p.FactoryValue = n0.Algorithm; %struct('MaxIter',maxiter,'Tolerance',tol,'LimitError',limerr);

p = schema.prop(c,'SearchMethodLookUp','MATLAB array');
p.Visible = 'off';
p.FactoryValue = cell2struct(SearchMethods,SearchFields,2);

%--------------------------------------------------------------------------
p = schema.prop(c, 'Search_Method', 'IdSearchMethods');
p.FactoryValue = SearchMethods{1};

p = schema.prop(c, 'Search_Criterion', 'IdSearchCriterion');

p = schema.prop(c, 'Trace_Criterion_Weighting', 'MATLAB array');

% p = schema.prop(c,'Iterative_Wavenet','IterWavenet');
% p.FactoryValue = 'Auto'; 

p = schema.prop(c,'Maximum_Iterations','double');
p.FactoryValue = n0.Algorithm.MaxIter;

p = schema.prop(c,'Tolerance','double');
p.FactoryValue = n0.Algorithm.Tolerance;

p = schema.prop(c,'Robustification_Limit','double');
p.FactoryValue = n0.Algorithm.LimitError;

p = schema.prop(c,'Covariance_Estimation','Idonoff');
p.FactoryValue = 'Off';
p.Visible = 'off'; %todo: re-enable when covariance computation is re-enabled

p = schema.prop(c,'Maximum_Size','double');
p.FactoryValue = n0.Algorithm.MaxSize;

p = schema.prop(c,'Advanced_Properties','handle');
p.Description = 'Advanced Properties of Estimation Algorithm';
