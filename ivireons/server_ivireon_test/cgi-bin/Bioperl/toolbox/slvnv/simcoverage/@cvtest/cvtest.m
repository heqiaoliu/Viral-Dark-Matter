function varargout = cvtest( varargin )
%CVTEST  Test Specification
%
%   CLASS_ID = CVTEST( ROOT ) Create a test specification for the Simulink
%   model containing ROOT.  ROOT can be the name of the Simulink model or the 
%   handle to a Simulink model.  ROOT can also be a name or handle to a 
%   subsystem within the model, in which case only this subsystem and its 
%   descendents are instrumented for analysis.
%
%   CLASS_ID = CVTEST( ROOT, LABEL) creates a test with the given label. The
%   label is used when reporting results. 
%
%   CLASS_ID = CVTEST( ROOT, LABEL, SETUPCMD) creates a test with a setup
%   command that is executed in the base MATLAB workspace just prior to running
%   the instrumented simulation.  The setup command is useful for loading data
%   just prior to a test.
%
%   See also CVSIM, CVSAVE, CVLOAD.

% 	Bill Aldrich
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/05/14 18:02:13 $

if check_cv_license==0
    error('slvnv:simcoverage:LicenseCheckoutFailed', ['Failed to check out Simulink Verification and Validation license,', ...
           ' required for model coverage']);
end

cv('Private','model_name_refresh');  % Check for renamed models and update data dictionary   
modelId = [];
switch nargin
case 0 % display help message
	if nargout==0, help('cvtest');
    else varargout{1} = help('cvtest');
	end
case 1 % could be create, or id conversion
	switch class(varargin{1})
	case 'double' % create a new test object for the
        if ishandle(varargin{1})
    		[modelId,path] = resolve_model_and_path(varargin{1});
    		cvtest.id = create_new_test(modelId,path);
        elseif cv('ishandle',varargin{1})
            if cv('get',varargin{1},'.isa')==cv('get','default','testdata.isa'),
           		cvtest.id = varargin{1};
            else
                error('slvnv:simcoverage:InvalidArgument','CV object #%s should be a testdata object',varargin{1});
            end
        else
            error('slvnv:simcoverage:InvalidArgument','Bad input');
        end
	case 'char' % create a new test object for the
		[modelId,path] = resolve_model_and_path(varargin{1});
		cvtest.id = create_new_test(modelId,path);
	case 'cvtest'
		varargout{1} = varargin{1};
        return;
	otherwise
	end

case 2 
	[modelId,path] = resolve_model_and_path(varargin{1});
	cvtest.id = create_new_test(modelId,path);
	install_test_label(cvtest.id,varargin{2})
case 3 
	[modelId,path] = resolve_model_and_path(varargin{1});
	cvtest.id = create_new_test(modelId,path);
	install_test_label(cvtest.id,varargin{2})
	install_setup_cmd(cvtest.id,varargin{3})
otherwise
	[modelId,path] = resolve_model_and_path(varargin{1});
	cvtest.id = create_new_test(modelId,path);
	install_test_label(cvtest.id,varargin{2})
	install_setup_cmd(cvtest.id,varargin{3})
	
end
cvt = class(cvtest,'cvtest');
if ~isempty(modelId)
    cvt = copyMetricsFromModel(cvt, cv('get', modelId, '.name'));
end
varargout{1} = cvt;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLVE_MODEL_AND_PATH - Find the Simulink model and
% its associated coverage object and resolve the path
% to the coverage root.
function [modelId,path] = resolve_model_and_path(block)

	try
		if ischar(block)
			block = get_param(block,'Handle');
		end
		model = bdroot(block);
    catch Mex
		error('slvnv:simcoverage:InvalidArgument','Invalid cvtest object. The related model must be open while coverage simulation is executed');
	end
		
	path = '';
	if (block ~= model)
		path = get_param(block,'Parent');
		path = [path '/' get_param(block,'Name')];
        bdName = get_param(model,'Name');
		bdlength = length(bdName);
		path = path((bdlength+2):end);	
	end

	modelId = get_param(model,'CoverageId');
	if ~cv('ishandle',modelId)
		[~, modelId] = cvi.TopModelCov.setup(model);
	end	
					

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_NEW_TEST - Find the Simulink model and
% its associated coverage object and resolve the path
% to the coverage root.
function testId = create_new_test(modelId,path)

	% Create the testdata object
	testId = cv('new', 	'testdata'  					...
			,'.type',				    'CMDLINE_TST' 	...
			,'.modelcov',				modelId 		...
			,'.rootPath',				path	 		...
			);


    mldName = cv('get', modelId, '.name');
    value  = get_param(mldName, 'CovModelRefEnable');
    cv('set', testId, 'testdata.mldref_enable', value);
    
    value = get_param(mldName, 'CovModelRefExcluded');
    cv('set', testId, 'testdata.mldref_excludedModels', value);
    
    value = get_param(mldName, 'RecordCoverage');
    cv('set', testId, 'testdata.mldref_excludeTopModel', ~strcmpi(value,'on'));
    
    value = get_param(mldName, 'CovExternalEMLEnable');
    cv('set', testId, 'testdata.covExternalEMLEnable', strcmpi(value,'on'));
    
    value = get_param(mldName, 'CovForceBlockReductionOff');
    cv('set', testId, 'testdata.forceBlockReductionOff', strcmpi(value,'on'));

	% Add this test to the link-list of pending tests
	cv('PendingTestAdd',modelId,testId);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTALL_TEST_NAME - Set the setupcmd string.
function install_test_label(testId,label)

	if ~ischar(label)
		error('slvnv:simcoverage:InvalidArgument','Bad argument type for the test name')
	end

	cv('set',testId,'.label',label);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTALL_SETUP_CMD - Set the setupcmd string.
function install_setup_cmd(testId,cmd)

	if ~ischar(cmd)
		error('slvnv:simcoverage:InvalidArgument','Bad argument type for the MATLAB setup command string')
	end

	cv('set',testId,'.mlSetupCmd',cmd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK_CV_LICENSE 
function status = check_cv_license

[wState] = warning;
warning('off');%#ok
try
    a = cv('get','default','slsfobj.isa');
    if isempty(a)
        status = 0;
    else
    	status = 1;
    end
catch Mex   %#ok<NASGU>
    status = 0;
end
warning(wState);

