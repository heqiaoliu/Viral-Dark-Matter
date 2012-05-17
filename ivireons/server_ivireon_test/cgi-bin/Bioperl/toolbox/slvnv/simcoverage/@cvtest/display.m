function display( cvtest )

%	Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/14 18:02:14 $

id = cvtest.id;

% Build the length structure
allMetrics = numel(cvi.MetricRegistry.getAllMetricNames);
metricCnt = length(allMetrics);

disp(' ');
disp([inputname(1),' = ... cvtest']);
disp(sprintf('                  id: %g (READ ONLY)',id));
disp(sprintf('            modelcov: %g (READ ONLY)',cv('get',id,'testdata.modelcov')));
disp(sprintf('            rootPath: %s',cv('get',id,'testdata.rootPath')));
disp(sprintf('               label: %s',cv('get',id,'testdata.label')));
disp(sprintf('            setupCmd: %s',cv('get',id,'testdata.mlSetupCmd')));
disp(sprintf('            settings: [%dx1 struct]',metricCnt));
disp(sprintf('    modelRefSettings: [3x1 struct]'));
disp(sprintf('         emlSettings: [1x1 struct]'));
disp(sprintf('             options: [1x1 struct]'));
disp(' ');

