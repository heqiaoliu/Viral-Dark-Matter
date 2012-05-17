function cvhtml_cvdatagroup(fileName, varargin)
%   Copyright 1990-2008 The MathWorks, Inc.


    this = parse_varargin(varargin);
    this.modelName = this.options.topModelName;

    this.fileName = fileName;
    this = prepare_data(this);
    %this = create_fake_data(this);
    if isfield(this, 'allModels')
        this = get_file_handle(this);
        this = report_header(this);
        this = generate_tests_summary(this);
        this = generate_summary(this);     
        this = generate_sigrange(this);
        this = report_end(this);
        if ~this.options.mathWorksTesting && ~this.options.dontShowReport
            show_report(this);
        end
    else
        if isempty(this.options.topModelName)
            disp('There is no coverage information to report.');
        else
            disp('The model "%s" has no coverage information to report.',this.options.topModelName);
        end
    end

%=============================
 function this = generate_sigrange(this)
     
    if isempty(this.allModels.hasSignalRange)
        return;
    end
        
    sigRange = {};

    for idx = 1:length(this.allModels.hasSignalRange)
        cmr = this.allModels.hasSignalRange{idx};
            sigRange = [sigRange {
                        '<tr>' ...
                        {'CellFormat' ...
                         {'&in_href',['$' cmr.name],['$' cmr.refFileName]}, ...
                         1 ...
                         '$left' ...
                        } '</tr>' ...
                   }
                ];  %#ok<AGROW>
    end


    script  = {         
                        sigRange{:} ...
                     }; 

    systableInfo.cols.align = 'CENTER';
    systableInfo.table = 'RULES=GROUPS FRAME = ABOVE  CELLPADDING="2" CELLSPACING="1"';
    systableInfo.textSize = 2;
    systableInfo.imageDir = this.options.imageSubDirectory;
    systableInfo.twoColorBarGraphs = this.options.twoColorBarGraphs;
    systableInfo.barGraphBorder = this.options.barGraphBorder;

    tableStr = html_table(this.allModels,script,systableInfo);
    fprintf(this.outFile,'<H4>The following models have signal range coverage:</H4>\n');
    fprintf(this.outFile,'%s',tableStr);


%=============================
function allModels = computeTotal(allModels)
    allMetricNames = union(allModels.metricNames, allModels.toMetricNames);
    for idx = 1:allModels.testNum
     for j = 1:length(allMetricNames)
        mn = allMetricNames{j};
        totalHits = 0;
        totalCnt = 0;
        for i = 1:length(allModels.mdlref)
            if ~isempty(allModels.mdlref(i).test) && ~isempty(allModels.mdlref(i).test(idx).(mn))
                totalHits = totalHits + allModels.mdlref(i).test(idx).(mn).totalHits;
                totalCnt = totalCnt + allModels.mdlref(i).test(idx).(mn).totalCnt;
            end
        end
        allModels.test(idx).(mn).totalHits =  totalHits;
        allModels.test(idx).(mn).totalCnt = totalCnt;
     end
    end




%==================    
function [metricTitles metricData] = create_metric_data(metricNames, options,  colspan)

    metricTitles = {};
    metricData = {};
    for idx = 1:length(metricNames)
         mn = metricNames{idx};
         mtitle = cvi.MetricRegistry.getShortMetricTxt(mn);
         metricTitles = add_metric_title(metricTitles, mtitle, colspan);        
         metricData = add_metric_data(metricData, mn, options, colspan);
    end
%==================    
 function allModels = order_data(allModels)
     if ~isempty(allModels.metricNames)
        mn = allModels.metricNames{1};
     else
        mn = allModels.toMetricNames{1};
     end
     perc = zeros(1, length(allModels.mdlref));
     for idx = 1:length(allModels.mdlref)
         if  ~isempty(allModels.mdlref(idx).test) &&  ~isempty(allModels.mdlref(idx).test(1).(mn))
             perc(idx) = double(allModels.mdlref(idx).test(1).(mn)(1).totalHits)/allModels.mdlref(idx).test(1).(mn)(1).totalCnt;
         else
             perc(idx) = 100;
         end
     end
     [~, sidx] = sort(perc);
     allModels.mdlref = allModels.mdlref(sidx);
%=============================
function metricData = add_metric_data(metricData, metric_name, options, colspan)
    metric_field = ['#' metric_name];     
    barGr = {};
    if options.barGrInMdlSumm 
        barGr = {{'&in_bargraph',[metric_field '.totalHits'],[metric_field '.totalCnt'],'@2'}};
    end

    
    if options.hitCntInMdlSumm
        metDispFcn = '&in_covperratios';
    else
        metDispFcn = '&in_covpercent';
    end

     metricData = [ metricData , ...
                    {{'Cat' '$&nbsp&nbsp'},... 
                     {'If',{'&isempty',metric_field}, ...
                            {'CellFormat','$--',colspan}, ...
                       'Else', ...
                            {metDispFcn,[metric_field '.totalHits'],[metric_field  '.totalCnt'],'@2'}, ...
                            barGr{:} ...
                    }}];
%=============================
function metricTitles = add_metric_title(metricTitles , title, colspan)
    metricTitles = [metricTitles  {{'Cat' '$&nbsp&nbsp'} {'CellFormat',['$' title],colspan}}];

     
%==================    
 function this = generate_summary(this)
    if isempty(this.allModels.metricNames) && isempty(this.allModels.toMetricNames) 
        return;
    end
    allModels = order_data(this.allModels);
    allModels = computeTotal(allModels);
    testNum = allModels.testNum; 
   
    colspan = 1 + int8(this.options.barGrInMdlSumm) ;

    tmpMetricNames = setdiff(allModels.metricNames, {'sigrange', 'sigsize'});
    tmpMetricNames = union(tmpMetricNames , allModels.toMetricNames);
    [metricTitles metricData] = create_metric_data(tmpMetricNames, this.options, colspan);
    
    complexD = {};
    if this.options.complexInSumm 
        complexD = {{'Cat' '#complexity'}};
    end
    space = {'Cat' '$&nbsp&nbsp'};

    columnData = {'ForEach' '#test' space  metricData{:} } ;
    rowEntries = {'ForEach','#mdlref', ...
                {'CellFormat', ...
                    {'&in_tocentry',{'&in_href','#name','#refFileName'},'@1',1}, ...
                    1, ...
                    '$left' ...
                },...
               complexD{:} ...
                columnData,... 
                '\n' ...
             };


    if this.options.complexInSumm 
        complexMH = {space, {'CellFormat' '$Complexity',1}}; 
    else
        complexMH = {space}; 
    end
    metricHeader    = { complexMH{:} ...
                        {'ForN' testNum   space  metricTitles{:}   } ...

                        } ;
    complexTH = {};
    if this.options.complexInSumm 
        complexTH = {space}; 
    end
                  
    totalRow   = { {'CellFormat' '$TOTAL COVERAGE' 1} ...
                   complexTH{:}...
                   columnData ...    
                } ;
                   
    if testNum > 1

        testHeaderCore = {};
        testColSpan = colspan * numel(allModels.metricNames) + numel(allModels.metricNames);
        for idx = 1: testNum  
            testHeaderCore = [testHeaderCore  {space {'CellFormat' ['$' allModels.testTitle{idx}] testColSpan }} ];  %#ok<AGROW>
        end

        testHeader    = { ... 
                            {'CellFormat' '$' int8(this.options.complexInSumm)*2} ...
                            testHeaderCore{:} ...
                          } ;
        script = { ...
                        '&in_startbold' ...
                        '<THEAD>' ...    
                        testHeader{:} ...    
                        '</THEAD>' ...
                        '\n' ...
                       '<TBODY>' ...                     
                        metricHeader{:} ...
                       '</TBODY>' ...
                        '\n' };
                          
    else
        script = { ...
                '&in_startbold' ...
                '<THEAD>' ...    
                metricHeader{:} ...
                '</THEAD>' ...
                '\n' ...
              }; 
    end
    script  = [ script { ...
                       '$&nbsp' ...
                       '\n' ...
                        totalRow{:}...
                        '\n' ...
                        '&in_endbold' ...               
                        '$&nbsp' ...
                        '\n' ... 
                        rowEntries ...
                     }]; 

    systableInfo.cols.align = 'CENTER';
    systableInfo.table = 'RULES=GROUPS FRAME = ABOVE  CELLPADDING="2" CELLSPACING="1"';
    systableInfo.textSize = 2;
    systableInfo.imageDir = this.options.imageSubDirectory;
    systableInfo.twoColorBarGraphs = this.options.twoColorBarGraphs;
    systableInfo.barGraphBorder = this.options.barGraphBorder;

    tableStr = html_table(allModels,script,systableInfo);
    fprintf(this.outFile,'%s',tableStr);

%==================
function this = parse_varargin(vars)
    this.cvdgs = {};
    cvhtmlSettings = [];
    for i = 1:length(vars)
        arg = vars{i};
        switch(class(arg))
           case 'cv.cvdatagroup'
               this.cvdgs{end+1} = arg;
           case 'cvi.CvhtmlSettings'
                cvhtmlSettings = arg;
           otherwise 
                assert(false, 'Unknown Arguments: %s', arg);
        end
    end

   this.options = cvhtmlSettings.covHTMLOptions;
   this.cvhtmlSettings = cvhtmlSettings;

%==================
function this = show_report(this)
    browserLoc  =   this.baseFileName;

    hBrowser = local_browser_mgr('displayFile',browserLoc);
    if ~isempty(hBrowser)
        % Load the htmlinfo into the persistent data of the info mgr function
        htmlData = [];
        html_info_mgr('load',browserLoc,htmlData);

    else
        disp(['Unable to open coverage report in the MATLAB Help Browser. ' ...
         'Hyper-links to Simulink models will only work in the MATLAB ' ...
         'Help Browser.']);
    end
%==================
function this = get_file_handle(this)
    [path,name] = fileparts(this.fileName);
    path = cvi.ReportUtils.get_full_path(path);

    this.baseFileName = fullfile(path,[name '.html']);

    this.outFile = fopen(this.baseFileName,'w');

    
%==================
function this = report_header(this)
    outFile = this.outFile;
    fprintf(outFile,'<HTML>\n');
    fprintf(outFile,'<HEAD>\n');
    fprintf(outFile,'<TITLE> Coverage Report by Model</TITLE>\n');
    fprintf(outFile,'</HEAD>\n');
    fprintf(outFile,'\n');
    fprintf(outFile,'<BODY>\n');
    fprintf(outFile,'<H1>Coverage by Model</H1>\n');
    if ~isempty(this.modelName)
        fprintf(outFile,'<H3>Top Model: %s</H3>\n', this.modelName);
    end
    
    fprintf(outFile,'<BR>\n');
%==================
function report_test(this, testObj, nameStr)

    outFile = this.outFile;
    testId = testObj.id;
    label = '';
    startTime = testObj.startTime;
    stopTime = testObj.stopTime;
    mlSetupCmd = '';

    if (testId>0)
        [label,mlSetupCmd ] = cv('get',testId,'testdata.label','testdata.mlSetupCmd');
    end

    if this.options.cumulativeReport
        nameStr = label;
    else
        if ~isempty(label)
            nameStr = [nameStr ', ' label];
        end
    end; 

    fprintf(outFile,'<H3> %s </H3>\n',nameStr);
    fprintf(outFile,'<TABLE>\n');
    fprintf(outFile,'<TR> <TD> Started Execution: <TD> %s </TR>\n',startTime);
    fprintf(outFile,'<TR> <TD> Ended Execution: <TD> %s </TR>\n',stopTime);
    if ~isempty(mlSetupCmd)
        fprintf(outFile,'<TR> <TD> Setup Command: <TD> %s </TR>\n',mlSetupCmd);
    end
    fprintf(outFile,'</TABLE>\n');
%==================
 function  this = generate_tests_summary(this)
     if length(this.cvdgs) > 1
         fprintf(this.outFile,'<H2>Tests</H2>\n');
     end
     for idx = 1:length(this.cvdgs)-1
        cvdg = this.cvdgs{idx};      
        cvds = cvdg.getAll;
        cvd = cvds{1};              
        nameStr = ['Test ' num2str(idx)];        
        report_test(this, cvd, nameStr);
     end

    fprintf(this.outFile,'<BR>\n');
    
%==================
 function  this = report_end(this)
      fprintf(this.outFile,'</BODY>\n');
      fprintf(this.outFile,'</HTML>\n');
      fprintf(this.outFile,'\n');
      fclose(this.outFile);
      
%==================    
     
 function this = create_fake_data(this)   %#ok<DEFNU>

%    allModels.metricNames = {'decision', 'condition', 'mcdc', 'tableExec'};
    %allModels.metricNames = {'decision', 'condition' };
    allModels.metricNames = {'sigrange' };
    allModels.testNum = 2;
    for i=1:4

         mdlref.name = sprintf('bazki%d',i);
         mdlref.refFileName = 'bazki';
         mdlref.complexity = int32(rand*100);
         
         for idx = 1:allModels.testNum
             for j = 1:length(allModels.metricNames)
                mn = allModels.metricNames{j};
                 %if logical(rand < 0.5)
                 if logical(mod(j+i,allModels.testNum))
                    mdlref.test(idx).(mn).totalHits =  int32(rand*99);
                    mdlref.test(idx).(mn).totalCnt = 100;
                 else
                     mdlref.test(idx).(mn) = [];
                 end
                    
             end
         end 
         allModels.mdlref(i) = mdlref;
    end
    for idx = 1:allModels.testNum
        allModels.testTitle{idx} = sprintf('Test%d', idx);
    end
    this.allModels = allModels;

%==================


function [mdlref hasSignalRange] = reshape_data(allModels, cvstruct, emptyTestIdx)

    hasSignalRange = [];
    mn = cvstruct.model.name;
    mdlref.name = mn;
    refFileName = cvi.ReportUtils.get_report_file_name(mn, 'reproduce');
    mdlref.refFileName = cvi.ReportUtils.file_path_2_url(refFileName);

    if isfield(cvstruct, 'system') && ~isempty(cvstruct.system)
    mdlref.complexity = cvstruct.system.complexity.deep;
    else
        mdlref.complexity = 0;
    end
    hasData = false;
    allMetircNames = union(allModels.metricNames, allModels.toMetricNames);
    for j = 1:length(allMetircNames)
        mn = allMetircNames{j};
        totalHits = [];
        if isfield(cvstruct, 'system') && ~isempty(cvstruct.system)
            switch mn
                case 'decision'
                    if isfield(cvstruct.system, mn)
                        totalHits = cvstruct.system.(mn).outTotalCnts;
                        totalCnt = cvstruct.system.(mn).totalTotalCnts;
                    end
                case {'condition', 'mcdc', 'tableExec'}
                    if isfield(cvstruct.system, mn)
                       totalHits = cvstruct.system.(mn).totalHits;
                       totalCnt = cvstruct.system.(mn).totalCnt;
                    end
                case {'sigrange', 'sigsize'}
                case {'cvmetric_Sldv_test', 'cvmetric_Sldv_proof', 'cvmetric_Sldv_condition', 'cvmetric_Sldv_assumption' }
                    if isfield(cvstruct.system, mn)
                       totalHits = cvstruct.system.(mn).outTotalCnts;
                       totalCnt = cvstruct.system.(mn).totalTotalCnts;
                    end
                otherwise
                    assert(false, 'Unkwown metrics');
            end
        end

        if ~isempty(totalHits)
            c = 1;
            for i = 1:allModels.testNum
                if isfield(emptyTestIdx, mdlref.name) && ...
                  ~isempty(emptyTestIdx.(mdlref.name)) && any(emptyTestIdx.(mdlref.name) == i)
                        mdlref.test(i).(mn) = [];
                else
                    mdlref.test(i).(mn).totalHits =  totalHits(c);
                mdlref.test(i).(mn).totalCnt = totalCnt;
                    c = c + 1;
                    hasData = true;
                end

            end
        else
            for i = 1:allModels.testNum
                mdlref.test(i).(mn) = [];
            end
        end
        if  isequal(mn, 'sigrange') && ...
            ~isempty(cvstruct.allCvData{1}.modelinfo.modelVersion) %it is not external eml ...
            hasSignalRange.name = mdlref.name;
            hasSignalRange.refFileName = mdlref.refFileName;
        end
   end

   if  ~hasData 
       mdlref =  [];
    end


%==================
function metricNames = order_metric_names(metricNames)

    rightOrder = {'decision', 'condition', 'mcdc', 'tableExec','sigrange', 'sigsize', ... 
                'cvmetric_Sldv_test', 'cvmetric_Sldv_proof', 'cvmetric_Sldv_condition', 'cvmetric_Sldv_assumption' };
    [~, oI] = intersect(rightOrder, metricNames);
    metricNames = rightOrder(sort(oI));
    
%==================
function this = prepare_data(this)
    allNames = {};
    moreThanOneTestProvided = length(this.cvdgs) > 1 && this.options.allTestInMdlSumm && ~this.options.cumulativeReport;
    if moreThanOneTestProvided
        total = this.cvdgs{1};
         for cidx = 1:length(this.cvdgs)
             ccvdg = this.cvdgs{cidx};
             total = total + ccvdg;
             allNames = [allNames ccvdg.allNames']; %#ok
         end
        this.cvdgs{end+1} = total; 
        allNames = unique(allNames);
    else
    cvdg = this.cvdgs{1}; 
    allNames = cvdg.allNames;
    end
    allModels.metricNames = {};
    allModels.toMetricNames = {};
    cvstructs = {};
    for idx = 1:length(allNames)
        cmn = allNames {idx};
        allCvData = {};
        for cidx = 1:length(this.cvdgs)
            dg = this.cvdgs{cidx};
            cvd = dg.get(cmn);
            if ~isempty(cvd)
                allCvData{end+1} = cvd; %#ok<AGROW>
            end
        end
        [metricNames toMetricNames] = cvi.ReportUtils.get_all_metric_names(allCvData);
        %filter no data
        allCvData = {};
        emptyTestIdx.(cmn) =  [];
        if ~isempty(metricNames) || ~isempty(toMetricNames)
            testIds = {};
            for cidx = 1:length(this.cvdgs)
                dg = this.cvdgs{cidx};
                cvd = dg.get(cmn);
                if ~isempty(cvd) && ~cvi.ReportUtils.check_no_data(cvd, metricNames, toMetricNames);
                    allCvData{end+1} = cvd; %#ok<AGROW>
                    testIds{end+1} = cvd.id; %#ok<AGROW>
                else
                    emptyTestIdx.(cmn)(end+1) = cidx;
                end
            end
        end
        %do the individual reports
        %don't give the total, they will compute
        if ~isempty(allCvData)
            tmpMetricNames = setdiff(metricNames, {'sigrange', 'sigsize'});
            if ~this.options.cumulativeReport && numel(testIds) > 1
                testIds(end) = []; %#ok<AGROW>
            end
            cvstruct = report_create_structured_data(allCvData, testIds, tmpMetricNames ,toMetricNames,this.options,[],true); 

            allModels.metricNames = union(allModels.metricNames,  metricNames);
            allModels.toMetricNames = union(allModels.toMetricNames, toMetricNames);
            cvstructs{idx} = cvstruct;   %#ok<AGROW>
            mn = cvstruct.model.name;
            refFileName = cvi.ReportUtils.get_report_file_name(mn, 'reproduce');
            this.cvhtmlSettings.covHTMLOptions.dontShowReport = true;
            if (moreThanOneTestProvided)
                icvdg = allCvData(1 : end-1);
            else
                icvdg = allCvData;
            end
            cvhtml(refFileName, icvdg{:}, this.cvhtmlSettings);
         end
     end
    
    if ~isempty(allModels.metricNames) || ~isempty(allModels.toMetricNames)
        allModels.testNum = length(this.cvdgs);
        allModels.metricNames = order_metric_names(allModels.metricNames);
        allModels.toMetricNames = order_metric_names(allModels.toMetricNames);
        allModels.hasSignalRange = {};
        
        for idx = 1:length(cvstructs)
            if ~isempty(cvstructs{idx})
                [mdlref hasSignalRange] = reshape_data(allModels, cvstructs{idx}, emptyTestIdx);
                if ~isempty(hasSignalRange)
                   allModels.hasSignalRange{end+1} = hasSignalRange;
                end
                if ~isempty(mdlref)
                    if ~isfield(allModels, 'mdlref')
                      allModels.mdlref(1) = mdlref;
                    else
                       allModels.mdlref(end+1) = mdlref;
                    end
                end
            end
        end
        allModels.metricNames = setdiff(allModels.metricNames, {'sigrange', 'sigsize'});
        if ~isempty(allModels.metricNames) || ~isempty(allModels.toMetricNames)
        if this.options.cumulativeReport 
               allModels.testTitle = {'Current Run', 'Delta', 'Cumulative'};
        else
                if isempty(allModels.mdlref)
                    allModels.testTitle{1} = sprintf('Test');
                else
            for idx = 1:length(allModels.mdlref(1).test)
                allModels.testTitle{idx} = sprintf('Test %d', idx);
            end
                end
            if this.options.allTestInMdlSumm
                 allModels.testTitle{end} = 'Total';
            end
        end
        end
        this.allModels = allModels;
    end

