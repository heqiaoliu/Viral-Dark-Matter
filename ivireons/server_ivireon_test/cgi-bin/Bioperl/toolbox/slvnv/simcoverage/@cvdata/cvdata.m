function varargout = cvdata( varargin )
%CVDATA  Coverage data
%
%   CLASS_ID = cvdata( ID ) Create a test data object for the data contained
%   in the coverage tool internal testdata object ID.
%
%   CLASS_ID = cvdata( LHS, RHS, METRICS ) creates a test data object with the
%   supplied data derived from two other cvdata objects, LHS and RHS.
%
%   See also CVLOAD, CVREPORT, CVTEST, CVSIM, CVSAVE.


%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/05/14 18:02:07 $

switch nargin
case 0 % display help message
    cvdata.id = 0;
    cvdata.localData = {};
    varargout{1} = class(cvdata,'cvdata');
case 1 % could be create, or id conversion
	switch class(varargin{1})
	case 'double' % create a new test object for the
        if ~cv('ishandle',varargin{1}),
            error('SLVNV:simcoverage:cvdata:CvObjNotExists','CV object #%d does not exist',varargin{1});
        end
        if cv('get',varargin{1},'.isa')~=cv('get','default','testdata.isa'),
            error('SLVNV:simcoverage:cvdata:CvObjNotTestdata','CV object #%d is not a testdata object',varargin{1});
        end
   		cvdata.id = varargin{1};
        cvdata.localData = {};
        cvdata = class(cvdata,'cvdata');
	    varargout{1} = cvdata;
	case 'cvdata'
		varargout{1} = varargin{1};
	otherwise
        error('SLVNV:simcoverage:cvdata:BadInput','Bad input argument in cvdata')
	end
case 3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check Arguments
    if ~isa(varargin{1},'cvdata') || ~isa(varargin{2},'cvdata')
        error('SLVNV:simcoverage:cvdata:NotCvArguments','First two arguments should be cvdata objects');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create return object
    lhs = varargin{1};
    rhs = varargin{2};
    p.type = '.';
    cvdata.id = 0;
    data.metrics = add_empty_metrics(varargin{3});
    p.subs = 'checksum';
    data.checksum = subsref(lhs,p);
    p.subs = 'startTimeEnum';
    data.startTime = earliest_time(subsref(lhs,p),subsref(rhs,p));
    p.subs = 'stopTimeEnum';
    data.stopTime = latest_time(subsref(lhs,p),subsref(rhs,p));
    p.subs = 'rootId';
    data.rootId = subsref(lhs,p);
    p.subs = 'modelinfo';
    data.modelinfo =  match_modelinfo(subsref(lhs,p), subsref(rhs,p));
    cvdata.localData = data;
    cvdata = class(cvdata,'cvdata');
	varargout{1} = cvdata;
    
otherwise
    error('SLVNV:simcoverage:cvdata:BadSyntax','Bad calling syntax for cvdata');
end

function modelinfo = match_modelinfo(lhs,rhs)
    fieldNames = {'modelVersion','creator','lastModifiedDate','inlineParams','blockReductionStatus','conditionallyExecuteInputs','logicBlkShortcircuit'};
    for fn = fieldNames(:)'
        if ~isequal(lhs.(fn{1}),rhs.(fn{1}))
            lhs.(fn{1}) = 'Not Unique';
        end
    end
    modelinfo = lhs;




function metrics = add_empty_metrics(metrics)

    metricNames = cvi.MetricRegistry.getAllMetricNames;

    for i=1:length(metricNames)
        if ~isfield(metrics,metricNames{i})
            metrics.(metricNames{i}) = [];
        end
    end



function res = earliest_time(time1,time2)

    if isempty(time1) 
       res = time2;
    elseif isempty(time2)
         res = time1;
    else
        try
            if(time1<time1)
                res = time1;
            else
               res = time2;
            end
        catch Mex %#ok<NASGU>
            res = 0;
        end
    end

function res = latest_time(time1,time2)

    if isempty(time1) 
        res = time2;
    elseif isempty(time2)
         res = time1;
    else
        try
            if(time1>time2)
                res = time1;
            else
                res = time2;
            end
        catch Mex %#ok<NASGU>
            res = '';
        end
    end

