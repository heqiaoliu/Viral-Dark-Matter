%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6.6.1 $  $Date: 2010/07/06 14:42:36 $

function ddObj = commitdd(mObj)

	%Validate argument
	if ~isa(mObj, 'cvdata')
		error('SLVNV:simcoverage:commitdd:NonCvdataArgument','Argument must be a cvdata object')
	end;
	if ~isDerived(mObj)
		error('SLVNV:simcoverage:commitdd:CvdataNotDerived','cvdata must be derived');
	end;
	
    
	%Get root ID
	p.type = '.';
	p.subs = 'rootId';
	rootId = subsref(mObj, p);
	
    
	%Create new coverage structure
	cvdata.id        = cv('new', 'testdata');
	cvdata.localData = {};
	
	%Mark as not derived in data dictionary
	cv('set', cvdata.id, '.isDerived', 1);
	cv('set', cvdata.id, '.modelcov', cv('get', rootId, '.modelcov'));
	
	%Copy fields/values of object to structure
	structObj = struct(mObj);
	fNames    = fieldnames(structObj.localData.metrics);
	for i = 1:length(fNames)
        mn = fNames{i};
        if strcmpi(mn, 'testobjectives') 
            if ~isempty(structObj.localData.metrics.testobjectives)
                cvt = cvtest(cvdata.id);
                setMetric(cvt, 'testobjectives', 1);
                metricdataIds = cv('get', cvdata.id, '.testobjectives');
                for idx = 1:numel(metricdataIds)
                    if metricdataIds(idx)~=0 
                        mn = cv('get', metricdataIds(idx), '.metricName');
                        if isfield(structObj.localData.metrics.testobjectives,mn)
                            cv('set', metricdataIds(idx), '.data.rawdata',structObj.localData.metrics.testobjectives.(mn)); 
                        end
                    end
                end
            else
                cv('set', cvdata.id, '.testobjectives', []);
            end
        else
        	cv('set', cvdata.id, ['.data.' mn], structObj.localData.metrics.(mn));
        end
	end; %for

        cv('set', cvdata.id, '.startTime', structObj.localData.startTime);
        cv('set', cvdata.id, '.stopTime', structObj.localData.stopTime);

        cv('set', cvdata.id, '.rootPath', cv('get', rootId, '.path'));
    
	%Add to test list for this root
	cv('RootAddTest', rootId, cvdata.id);
	
	%Create object from structure
	cvdata = class(cvdata, 'cvdata');
	
	%Return newly created object
	ddObj = cvdata;
