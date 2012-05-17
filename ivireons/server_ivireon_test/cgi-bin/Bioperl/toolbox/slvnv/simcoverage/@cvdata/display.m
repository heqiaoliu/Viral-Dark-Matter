function display( cvdata )

%	Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/14 18:02:08 $

% Use subsref to get the id.  This allows for error checking.
ref.type = '.';
ref.subs = 'id';
id       = subsref(cvdata,ref);

% Build the length structure
allMetrics = numel(cvi.MetricRegistry.getAllMetricNames);
metricCnt = length(allMetrics);

if id > 0    
    rootId = cv('get',id,'.linkNode.parent');
    

    % Print the display
    disp(' ');
    disp([inputname(1),' = ... cvdata']);
    disp(sprintf('           id: %g',id));
    if isDerived(cvdata)
        disp(sprintf('         type: DERIVED_DATA'));
    else
        disp(sprintf('         type: TEST_DATA'));
    end
    disp(sprintf('         test: cvtest object'));
    disp(sprintf('       rootID: %g',rootId));
    disp(sprintf('     checksum: [4x1 struct]'));
    disp(sprintf('    modelinfo: [1x1 struct]'));
    ref.subs = 'startTime';
    disp(sprintf('    startTime: %s',subsref(cvdata,ref)));
    ref.subs = 'stopTime';
    disp(sprintf('     stopTime: %s',subsref(cvdata,ref)));
    disp(sprintf('      metrics: [%dx1 struct]',metricCnt));
    disp(' ');
else

    % Print the display
    disp(' ');
    disp([inputname(1),' = ... cvdata']);
    disp(sprintf('           id: 0'));
    disp(sprintf('         type: DERIVED_DATA'));
    disp(sprintf('         test: []'));
    disp(sprintf('       rootID: %g',cvdata.localData.rootId));
    disp(sprintf('     checksum: [4x1 struct]'));
    disp(sprintf('    modelinfo: [1x1 struct]'));
    disp(sprintf('    startTime: %s',datestr(cvdata.localData.startTime)));
    disp(sprintf('     stopTime: %s',datestr(cvdata.localData.stopTime)));
    disp(sprintf('      metrics: [%dx1 struct]',metricCnt));
    disp(' ');
end