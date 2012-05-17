function genHTMLreport(h)
%   GENHTMLREPORT - Generate HTML report if necessary

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.22 $  $Date: 2010/05/20 02:54:07 $

rptContentsFile = rtwprivate('rtwattic', 'getContentsFileName');
rptFileName     = rtwprivate('rtwattic', 'getReportFileName');
tInfoFile = fullfile(pwd,'html','traceInfo.mat');
if exist(tInfoFile,'file') == 2
    delete(tInfoFile);
end
hTrace = RTW.TraceInfo.instance(h.ModelName);

% cleanup XML files from previous session
htmlDir = fullfile(h.BuildDirectory,'html');
delete(fullfile(htmlDir,'*.xml'));
if isempty(rptContentsFile)
  % cleanup previous report
  delete(fullfile(htmlDir,'*.html'));
else
  % get submodels htmlrpt links
  infoStruct = rtwprivate('rtwinfomatman','load', ...
                          'binfo', h.ModelName, ...
                          h.MdlRefBuildArgs.ModelReferenceTargetType);
  % add links to submodels html report.
  if isfield(infoStruct, 'htmlrptLinks')
    insert_link_to_submodels_htmlrpt(infoStruct.htmlrptLinks, ...
                                     rptContentsFile,infoStruct);
  end
  % save current htmlrpt link into rtwinfomat.
  rtwprivate('rtwinfomatman', ...
             'updatehtmlrptLinks','binfo', ...
             h.ModelName, ...
             h.MdlRefBuildArgs.ModelReferenceTargetType, ...
             rptFileName);
  bMdlRef = ~strcmp(h.MdlRefBuildArgs.ModelReferenceTargetType,'NONE');
  rtwprivate('rtwreport', 'convertC2HTML', rptContentsFile, h.ModelName, bMdlRef);
  codeCoverageClass = rtw.pil.CodeCoverage.getActiveCodeCoverageClass...
      (h.MdlRefBuildArgs.BuildHooks,h.MdlRefBuildArgs.TopModelPILBuild);
  hasCodeCovData = ~isempty(codeCoverageClass);
  if ~bMdlRef || ...
          h.MdlRefBuildArgs.UpdateTopModelReferenceTarget 
      if ~strcmp(get_param(h.ModelName,'LaunchReport'),'off') && ~hasCodeCovData
          disableWidget = false;
          if isa(hTrace,'RTW.TraceInfo') && ~hTrace.UseWidget
              disableWidget = true;
          end
          dasRoot = DAStudio.Root;
          if dasRoot.hasWebBrowser && ~disableWidget            
              rtwprivate('rtwshowhtml', rptFileName, 'UseWebBrowserWidget');
          else
              rtwprivate('rtwshowhtml', rptFileName);
        end
      end
  end
end

function insert_link_to_submodels_htmlrpt(htmlrptLinks,rptContentsFile,infoStruct)
allsubmodel=infoStruct.modelRefsAll; % all submodels list
if ~isempty(allsubmodel)
    rptBuffer = fileread(rptContentsFile);
    insertLinks = '<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="4" WIDTH="100%" BGCOLOR="#ffffff">';
    insertLinks = [insertLinks '<TR><TD><B>Referenced Models</B></TD></TR>'];
    htmlsubmodel={}; % submodels with html report
    for i=1:length(htmlrptLinks)
        [~, submodelName] = fileparts(htmlrptLinks{i});
        submodelName = submodelName(1:end-12); % remove '_codegen_rpt'
        htmlsubmodel = [htmlsubmodel,{submodelName}]; %#ok<AGROW>
        % html relative link always use '/' on all platforms.
        relativeLink = strrep(fullfile(infoStruct.relativePathToAnchor, '..', htmlrptLinks{i}),'\','/');
        insertLinks = [insertLinks '<TR><TD><A HREF="' relativeLink '" TARGET=_top>' submodelName '</A></TD><TR>']; %#ok<AGROW>
    end    
    
    leftsubmodel = setdiff(allsubmodel,htmlsubmodel);
    for i=1:length(leftsubmodel)
        insertLinks = [insertLinks '<TR><TD>' leftsubmodel{i} '</TD><TR>']; %#ok<AGROW>
    end    
    rptBuffer = strrep(rptBuffer, '</BODY>', [insertLinks, '</TABLE> </BODY>']);
    fid = fopen(rptContentsFile,'w');
    fprintf(fid, '%s', rptBuffer);
    fclose(fid);
end
