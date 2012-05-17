classdef (Hidden = true) Bullseye < rtw.pil.CodeCoverage
%BULLSEYE provides code coverage utilities
%   BULLSEYE
%
%   See also 
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2009-2010 The MathWorks, Inc.

    properties (GetAccess=private, Constant=true)
        BuildZone = ['MATLAB_' num2str(system_dependent('getpid'))];
        MaxCmdLength=8000; % Less than winxp limit of 8192
    end

    properties (Access=private)
        CovFilePath;
        TotalCovFilePath;
        CovSrcDir;
        SkipModelBuild;
        CodeGenFolder;
    end
    

    methods (Access=public, Static=true)
        
        
        function [probes,fn_cov,cd_cov,fn_total,cd_total] = ...
                mergeProbes(oldProbes, probes)
            %MERGEPROBES returns merged coverage data for probes 
            %relating to the same section of source code

            fn_cov=0;
            cd_cov=0;
            fn_total=0;
            cd_total=0;
            for i=1:length(probes)
                probe=probes(i);
                oldProbe=oldProbes(i);
                assert(strcmp(oldProbe.line,probe.line));
                assert(strcmp(oldProbe.kind,probe.kind));
                assert(strcmp(oldProbe.column,probe.column));
                assert(strcmp(oldProbe.col_seq,probe.col_seq));
                events={oldProbe.event, probe.event};
                eventsLogical=false(2, length(events));
                for j=1:length(events)
                    event=events{j};
                    switch event
                      case 'none'
                        eventsLogical(j,:)=[0 0];
                      case 'true'
                        eventsLogical(j,:)=[1 0];
                      case 'false'
                        eventsLogical(j,:)=[0 1];
                      otherwise
                        assert(strcmp(event,'full')==1);
                        eventsLogical(j,:)=[1 1];
                    end
                end
                eventMerged=eventsLogical(1,:) | eventsLogical(2,:);
                kind = probe.kind;
                if all(eventMerged==[0 0])
                    event = 'none';
                elseif all(eventMerged==[1 0])
                    event = 'true';
                    cd_cov=cd_cov + 1;
                elseif all(eventMerged==[0 1])
                    event = 'false';
                    cd_cov = cd_cov + 1;
                else
                    assert(all(eventMerged==[1 1]))
                    event = 'full';
                    if strcmp(kind,'function')
                        fn_cov = fn_cov+1;
                    elseif any(strcmp(kind,{'catch', 'switch-label', 'try'}))
                        cd_cov = cd_cov+1;
                    elseif any(strcmp(kind,{'condition','decision'}))
                        cd_cov = cd_cov+2;
                    else
                        assert(strcmp(kind,'constant'))
                    end
                end
                if strcmp(kind,'function')
                    fn_total = fn_total+1;
                elseif any(strcmp(kind,{'catch', 'switch-label', 'try'}))
                    cd_total = cd_total+1;
                elseif any(strcmp(kind,{'condition','decision'}))
                    cd_total = cd_total+2;
                else
                    assert(strcmp(kind,'constant'))
                end
                probes(i).event = event;
            end
        end
        
        
        function componentCovData = getCovDataForComponent...
                (covData, componentDir)
            %GETCOVDATAFORCOMPONENT extracts coverage data relating
            %to the specified component
            covDataSrcFolders = cell(size(covData.srcs));
            [covDataSrcFolders{:}]=deal(covData.srcs.srcFolder);
            keepIdx= strcmp(componentDir,covDataSrcFolders);
            componentCovData.srcs = covData.srcs(keepIdx);
        end            


        function componentCovData = mergeComponentCovData...
                (componentCovData, componentDir, ...
                 covFilePath, codeGenFolder)      
            %MERGECOMPONENTCOVDATA merges new coverage data into an existing
            %.mat file with previous coverage data for the same component
            %build directory
            
            rootFolder=codeGenFolder;
            buildDir = fullfile(rootFolder,componentDir);            
            covResultsFile = cov.CoverageResultsFile(buildDir);
            srcPaths=cell(size(componentCovData.srcs));
            [srcPaths{:}]=deal(componentCovData.srcs.srcPath);
            srcTimestamps=cell(size(componentCovData.srcs));
            [srcTimestamps{:}]=deal(componentCovData.srcs.srcTimestamp);
            assert(all(strcmp(srcPaths,sort(srcPaths))),'paths must in sorted');
            isOldDataValid=false;
            if covResultsFile.exists;
                
                % First we check timestamps saved in the covData.mat file against
                % the source file timestamps from the time when they were most
                % recently compiled with coverage instrumentation switched on
                covResultsFile.load;
                oldCovData = covResultsFile.getCovData;
                oldSrcPaths=cell(size(oldCovData.srcs));
                [oldSrcPaths{:}]=deal(oldCovData.srcs.srcPath);
                oldTimestamps=cell(size(oldCovData.srcs));
                [oldTimestamps{:}]=deal(oldCovData.srcs.srcTimestamp);
                isOldDataValid=true;
                for i=1:length(oldSrcPaths)
                    oldSrcPath=oldSrcPaths{i};
                    newSrcIdx = find(strcmp(oldSrcPath,srcPaths), 1 );
                    if isempty(newSrcIdx)
                        isOldDataValid=false;
                        break;
                    else
                        oldTimestamp=oldTimestamps{i};
                        srcTimestamp=srcTimestamps{newSrcIdx};
                        if ~isequal(oldTimestamp,srcTimestamp)
                            isOldDataValid=false;
                            break;
                        end
                    end
                end
            end
            
            if isOldDataValid
                for i=1:length(componentCovData.srcs);
                    probes=componentCovData.srcs(i).probes;
                    srcPath=srcPaths{i};
                    oldSrcIdx = find(strcmp(srcPath,oldSrcPaths), 1 );
                    if ~isempty(oldSrcIdx)
                        oldProbes=oldCovData.srcs(oldSrcIdx).probes;
                        [componentCovData.srcs(i).probes, ...
                            componentCovData.srcs(i).fn_cov, ...
                            componentCovData.srcs(i).cd_cov, ...
                            fn_total,cd_total] =  ...
                            rtw.pil.Bullseye.mergeProbes...
                            (probes,oldProbes);
                        assert(fn_total==componentCovData.srcs(i).fn_total,...
                            'Total function coverage must be consistent');
                        assert(cd_total==componentCovData.srcs(i).cd_total,...
                            'Total function coverage must be consistent');
                    end
                end
            else
                covResultsFile.clearCovFilePaths;
            end
            
            % Store the path to the .cov file so that it can be deleted
            % when coverage data is cleared
            covResultsFile.addCovFilePath(covFilePath);
            
            covResultsFile.setCovData(componentCovData);
            covResultsFile.save;
            
        end
        
        
        function fragments = getMarginAnnotation(kinds, events)
        %GETMARGINANNOTATION returns html fragments to provide source code 
        %annotations for the code coverage measurements

            fragments = cell(size(kinds));
            for i=1:length(kinds)
                kind = kinds{i};
                event = events{i};
                switch kind
                  case {'decision'}
                    switch event
                      case 'none'
                        text='Decision not covered';
                        fragment=['<A CLASS="VF" TITLE="' text '">&nbsp;&nbsp;=&gt;</A>'];
                      case 'full'
                        text='Decision covered true and false';
                        fragment=['<A CLASS="VT" TITLE="' text '">TF&nbsp;&nbsp;</A>'];
                      case 'true'
                        text='Decision covered true, but not false';
                        fragment=['<SPAN TITLE="' text '"><A CLASS="VF">&nbsp;=&gt;</A><A CLASS="VT">T</A></SPAN>'];
                      case 'false'
                        text='Decision covered false, but not true';
                        fragment=['<SPAN TITLE="' text '"><A CLASS="VF">&nbsp;=&gt;</A><A CLASS="VT">F</A></SPAN>'];
                    end
                  case {'function'}
                    switch event
                      case 'none'
                        text='Function not called';
                        fragment=['<A CLASS="VF" TITLE=" ' text '">=&gt;&nbsp;&nbsp;</A>'];
                      case 'full'
                        text='Function called';
                        fragment=['<A CLASS="VT" TITLE=" ' text '">Fcn&nbsp;</A>'];
                    end
                  case {'switch-label'}
                    switch event
                      case 'none'
                        text='Switch label not covered';
                        fragment=['<A CLASS="VF" TITLE=" ' text '">=&gt;&nbsp;&nbsp;</A>'];
                      case 'full'
                        text='Switch label covered';
                        fragment=['<A CLASS="VT" TITLE=" ' text '">Sw&nbsp;&nbsp;</A>'];
                    end
                  case {'constant'}
                    assert(strcmp(event,'none'));
                    text='Constant not measured';
                    fragment=['<A CLASS="VN" TITLE=" ' text '">&nbsp;&nbsp;&nbsp;k</A>'];
                  otherwise
                    assert(strcmp(kind,'condition'))
                    switch event
                      case 'none'
                        text='Condition not covered';
                        fragment=['<A CLASS="VF" TITLE= "' text '">&nbsp;&nbsp;=&gt;</A>'];
                      case 'full'
                        text='Condition covered true and false';
                        fragment=['<A CLASS="VT" TITLE= "' text '">tf&nbsp;&nbsp;</A>'];
                      case 'true'
                        text='Condition covered true, but not false';
                        fragment=sprintf(['<SPAN  TITLE= "%s">'...
                                          '<A CLASS="VF">&nbsp;=&gt;</A>'...
                                          '<A CLASS="VT">t</A></SPAN>'], text);
                      case 'false'
                        text='Condition covered false, but not true';
                        fragment=sprintf(['<SPAN  TITLE= "%s">'...
                                          '<A CLASS="VF">&nbsp;=&gt;</A>'...
                                          '<A CLASS="VT">f</A></SPAN>'], text);
                    end
                end        
                fragments{i} = fragment;
            end
        end            
        
        function fragment = getHtmlSummaryBar(cov,total,type,typeInitCap,typePlural)
        %GETHTMLSUMMARYBAR returns an html percentage complete bar
            
            % Create the file summary annotation
            space = '&nbsp;';
            covBarEmpty  = sprintf('<a CLASS="VNB">%s',...
                                repmat(space,1,10));

            covStr = sprintf('%d',cov);
            totalStr = sprintf('%d',total);

            if total==0
                covBar=covBarEmpty;
                covText = sprintf('<A>%s coverage:</A>',typeInitCap);
                covTitle= sprintf('No %s coverage to measure', type);
            else
                cov_percent=floor(100*cov/total);
                if cov_percent>50
                    % Round down for visual indicator
                    cov_perdec=floor(10*cov/total);
                else
                    % Round up for visual indicator
                    cov_perdec=ceil(10*cov/total);
                end
                covTitle=sprintf('%s out of %s %s covered',...
                    covStr, totalStr, typePlural);
                covBar  = sprintf(['<a CLASS="VTB">%s'...
                    '</a><a CLASS="VFB">%s</a>'],...
                    repmat(space,1,cov_perdec),...
                    repmat(space,1,10-cov_perdec));
                covText = sprintf('<A>%s coverage: %d%s</A>',...
                    typeInitCap, cov_percent, '%');
            end
                fragment = sprintf('<SPAN TITLE="%s">%s %s</SPAN>', ...
                    covTitle, covText, covBar);
            end
        
        function summary = getSummaryHtml...
                (fn_cov, fn_total, cd_cov, cd_total)
            %GETSUMMARYHTML returns an html fragment providing summary information
            %of coverage results
            
            fnCovHtml = rtw.pil.Bullseye.getHtmlSummaryBar...
                (fn_cov,fn_total,'function','Function','functions');
            
            cdCovHtml = rtw.pil.Bullseye.getHtmlSummaryBar...
                (cd_cov,cd_total,'condition/decision','Condition/decision',...
                'conditions/decisions');
            
            summary = sprintf('%s    %s\n<p>',fnCovHtml,cdCovHtml);
                       
        end        
        
        
        function annotations = getAnnotations(covData, file)
        %GETANNOTATIONS returns a data structure containing html annotations
        %for a model component associated with the specified .mat file.
            probes = '';
            for i=1:length(covData.srcs)
                if strcmp(covData.srcs(i).srcPath, file);
                    probes = covData.srcs(i).probes;
                    fn_cov = covData.srcs(i).fn_cov;
                    fn_total = covData.srcs(i).fn_total;
                    cd_cov = covData.srcs(i).cd_cov;
                    cd_total = covData.srcs(i).cd_total;
                    srcPath = covData.srcs(i).srcPath;
                    break
                end
            end
            
            lines = cell(size(probes));
            kinds = cell(size(probes));
            events = cell(size(probes));
            columns = cell(size(probes));
            [lines{:}]=deal(probes.line);
            [kinds{:}]=deal(probes.kind);
            [events{:}]=deal(probes.event);
            [columns{:}]=deal(probes.column);

            % Get html fragments for margin annotations
            marginText=rtw.pil.Bullseye.getMarginAnnotation(kinds,events);
            
            [linesUnique, ~, linesJ] = unique(lines);
            preAlloc = cell(size(linesUnique));
            lineAnnotations=struct('line',linesUnique,...
                                   'columns',preAlloc,...
                                   'marginText', preAlloc,...
                                   'columnPointer',preAlloc);
            lineAnnotationsLocal=struct('columns',preAlloc);
            for i=1:length(linesUnique)
                idxI = find(linesJ==i);
                linesI=lines(idxI);
                assert(all(strcmp(linesI,lineAnnotations(i).line)));
                columnsI=columns(idxI);
                marginTextI=marginText(idxI);
                assert(length(columnsI)>=1);
                columnZeroIdx = find(strcmp(columnsI,''));
                assert(length(columnZeroIdx)==1,...
                       'There must be exactly one probe with empty column number');
                columnsI{columnZeroIdx}='0'; % Replace '' with '0' to enable sorting
                [~, idxII] = sort(str2double(columnsI));
                lineAnnotations(i).marginText    = marginTextI  (idxII);
                columnsForLine=str2double(columnsI(idxII));
                assert(columnsForLine(1)==0);
                lineAnnotationsLocal(i).columns = columnsForLine;
            end
            
            % The column number returned by BullseyeCoverage indicates the
            % code measured by the probe, not counting whitespace. We need
            % to transform this to a column number that includes
            % whitespace. To achieve this we first read the source file.
            srcContents = fileread(srcPath);
            srcLines = regexp(srcContents,'([^\n]*)\n','tokens');
            
            % Now do the transform and create an html fragment pointing to
            % the required column
            spaceChar='&nbsp;';
            lineChar='.';
            for i=1:length(linesUnique)
                lineNum=str2double(lineAnnotations(i).line);
                srcLine = srcLines{lineNum}{1};
                columns = lineAnnotationsLocal(i).columns;
                columnPointer = cell(size(columns));
                if length(columns)>1
                    nonSpaceChars=find(srcLine~=' ');
                    for j=2:length(columns)
                        if mod(j,2)==0
                            fillChar=spaceChar;
                        else
                            fillChar=lineChar;
                        end
                        column=nonSpaceChars(columns(j)+1);
                        columnPointer{j} = [repmat(fillChar,1,column) '^'];
                    end
                end
                lineAnnotations(i).columnPointer=columnPointer;
            end
            
            % Sort by line number
            [~, sortIdx] = sort(str2double(linesUnique));
            lineAnnotations = lineAnnotations(sortIdx);
            
            annotations.lines = lineAnnotations;
            annotations.summary = rtw.pil.Bullseye.getSummaryHtml...
                (fn_cov, fn_total, cd_cov, cd_total);            
        end
        
        function xmlTxt = getAnnotationsXml(annotations)
            nl = sprintf('\n');
            spaces = repmat('&nbsp;',1,7); % filler for line number area
            xmlbegin = '<?xml version="1.0" encoding="UTF-8"?>';
            css = [ ...          
                '  <style><![CDATA[.VF { font-style: italic; color: #FF0000 }]]></style>' nl ...
                '  <style><![CDATA[.VT { font-style: bold; color: #000080 }]]></style>' nl ...
                '  <style><![CDATA[.VN { font-style: italic; color: #888888 }]]></style>' nl ...
                '  <style><![CDATA[.VTB { background-color: #000080 }]]></style>' nl ...
                '  <style><![CDATA[.VFB { background-color: #FF0000 }]]></style>' nl ...
                '  <style><![CDATA[.VNB { background-color: #888888 }]]></style>'];
            root = ModelAdvisor.Element;
            root.setTag('root');
            summary = ModelAdvisor.Element;
            summary.setTag('summary');
            annotation = ModelAdvisor.Element;
            annotation.setTag('annotation');
            annotation.setContent(['<![CDATA[' annotations.summary ']]>']);
            summary.setContent(annotation.emitHTML);
            linedefault = ModelAdvisor.Element;
            linedefault.setTag('line');
            linedefault.setAttribute('id','default');
            annotation.setContent('<![CDATA[&nbsp;&nbsp;&nbsp;&nbsp;]]>');
            linedefault.setContent(annotation.emitHTML);
            lines = cell(length(annotations.lines),1);
            for k=1:length(annotations.lines)
                line = ModelAdvisor.Element;
                line.setTag('line');
                line.setAttribute('id',annotations.lines(k).line);
                inner = cell(length(annotations.lines(k).marginText),1);
                for n=1:length(annotations.lines(k).marginText)
                    a = ModelAdvisor.Element;
                    a.setTag('annotation');
                    if ~isempty(annotations.lines(k).columnPointer{n})
                        assert(n > 1);
                        columnPointer = [spaces annotations.lines(k).columnPointer{n}];
                    else
                        columnPointer = '';
                    end
                    a.setContent(['<![CDATA[' annotations.lines(k).marginText{n} ...
                                   columnPointer ']]>']);
                    inner{n} = a.emitHTML;
                end
                line.setContent(sprintf('%s\n',inner{:}));
                lines{k} = line.emitHTML;
            end
            root.setContent([css nl summary.emitHTML nl linedefault.emitHTML nl sprintf('%s',lines{:})]);
            xmlTxt = [xmlbegin root.emitHTML];
        end
        
        function cleanupCovXmlFiles(componentDir)
            htmlFolder = fullfile(componentDir,'html');
            if exist(htmlFolder,'dir')
                % cleanup
                delete(fullfile(htmlFolder,'*_cov.xml'));
            end
        end
        
        function out = isRtwReportGenerated(componentDir)
            htmlFolder = fullfile(componentDir,'html');
            out = false;
            if exist(htmlFolder, 'dir')
                % does this folder contain an HTML report
                if ~isempty(dir(fullfile(htmlFolder,'*_codegen_rpt.html')))
                    out = true;
                end
            end
        end
        
        
        function generateCovXmlFiles(componentCovData, componentDir)  
            
            htmlFolder = fullfile(componentDir,'html');
            
            for k=1:length(componentCovData.srcs)
                src = componentCovData.srcs(k).srcPath;
                if ~exist(src,'file'), continue, end
                annotations = rtw.pil.Bullseye.getAnnotations(componentCovData,src);
                [~, file, ext] = fileparts(src);
                xml = rtw.pil.Bullseye.getAnnotationsXml(annotations);
                % XML file name model.c -> model_c_cov.xml
                fid = fopen(fullfile(htmlFolder,[file '_' ext(2:end) '_cov.xml']),'w');
                fprintf(fid,'%s',xml);
                fclose(fid);
            end
        end
        
        function xformedPath = transformPath(input, newAnchor)
        %TRANSFORMPATH returns transforms the specified path and makes
        %it relative to the anchor directory
            delimChar=filesep;
            if strcmp(delimChar,'\'); delimChar='\\'; end
            if ~strcmp(input,'')
                
                inputCa=textscan(input,'%s','delimiter',delimChar);
                inputCa=inputCa{1};
            else
                inputCa={};
            end
            newAnchorCa = textscan(newAnchor,'%s','delimiter',delimChar);
            newAnchorCa=newAnchorCa{1};
            pwdCa = textscan(pwd,'%s','delimiter',delimChar);
            pwdCa=pwdCa{1};
            assert(all(strcmp(newAnchorCa,'..')),...
                'must be a path like .. or ../../..');
            assert(length(pwdCa)>=length(newAnchorCa));
            xformedPath = pwdCa((end-length(newAnchorCa)+1):end);
            for i=1:length(inputCa)
                folder=inputCa(i);
                if strcmp(folder,'..') && ~isempty(xformedPath)>0
                    xformedPath=xformedPath(1:end-1); 
                else
                    xformedPath(end+1)=folder; %#ok<AGROW> 
                end
            end
            if ~isempty(xformedPath)>0
                xformedPath=fullfile(xformedPath{:});
            else
                xformedPath='';
            end
        end
                
        
        function isAbs = isAbsPath(filePath)
        %GETABSPATH returns true if the path is absolute
            isAbs=false(size(filePath));
            expr='^(([A-Za-z]:(\\|\/))|(/)|(\\\\[A-Za-z]))';
            for i=1:length(isAbs)
                match=regexp(filePath{i},expr,...
                    'once','lineanchors');
                if ~isempty(match)
                    isAbs(i)=true;
                else 
                    isAbs(i)=false;
                end
            end
        end
                    
        
        function timestamps = getCovSrcTimestamps...
                (relativePathToAnchor, covSrcs)
            isAbsPath = rtw.pil.Bullseye.isAbsPath(covSrcs);
            timestamps = cell(size(covSrcs));
            for i=1:length(covSrcs)
                if ~isAbsPath(i)
                    srcFile=fullfile(relativePathToAnchor,covSrcs{i});
                else
                    srcFile=covSrcs{i};
                end
                d = dir(srcFile);
                assert(~isempty(d));
                timestamps{i}= d.datenum;
            end
        end
            
        function allSrcs = parseSrcFileList(w)
            sep = '(\\|\/)';
            dirName = '(([\w-.]+)|(\.\.))';
            dirPrefix = '(([A-Za-z][:])?(\/))';
            fileName = '([\w-]+[.]((c)|(cpp)|(h)|(hpp)))';
            expr = ['^(' dirPrefix '?(' dirName sep ')*(' fileName '))\n'];
            allSrcs_cca = regexp(w,expr,'tokens','lineanchors');
            len = length(allSrcs_cca);
            allSrcs = cell(len,1);
            for i=1:len
                srcFile=allSrcs_cca{i};
                srcFile=srcFile{1};
                allSrcs{i}=srcFile;
            end
        end
        
        function result = systemCommand(cmd)
            [status, result] = system(cmd);

            if status ~= 0
                DAStudio.error('RTW:codeCoverage:SystemCommand',...
                    cmd, result);
            end
        end

    end
    

    methods (Access=public)
        
        function this = Bullseye(name, value)
            coverageForTopModel=[];
            if nargin>0
                assert(strcmpi(name,'coveragefortopmodel'),...
                       sprintf('Unrecognized argument %s.', name))
                % This argument is only present when the current model is the top model (either
                % standalone or at the top of a model reference hierarchy). It
                % is set to 'on' if coverage is enabled for the top model, or
                % 'off' otherwise. If coverage is off for the top model, this
                % build hook is still responsible for ensuring that the SIL/PIL
                % application is linked and launched such that coverage
                % measurements can be collected for any referenced models.
                coverageForTopModel=value;
            end
            
            if ~isempty(coverageForTopModel) && strcmp(coverageForTopModel,'off')
                this.SkipModelBuild = true;
            else
                this.SkipModelBuild = false;
            end
            
            % Specify a file that can be used to validate the Bullseye installation
            % including path relative to the installation root folder
            if ispc
                markerFile='cov01.exe';
            else
                markerFile='cov01';
            end
            markerFile = fullfile('bin',markerFile);
            this.setValidateToolInstallationFile(markerFile);
            
            % Specify the code coverage tool name
            this.setToolName('Bullseye');
            
        end
        
        
        function covData = importCovData(this, covFilePath, srcFoldersMap, ...
                                         srcTimestampsMap)

            tmpxml=tempname;
            covCmd=fullfile(this.getToolAltPath,'bin','covxml');
            covCmdOpts=['--file ' covFilePath ' > ' tmpxml];
            
            rtw.pil.Bullseye.systemCommand([covCmd ' ' covCmdOpts]);
            
            xDoc = xmlread(tmpxml); % read in the XML file
            delete(tmpxml); % delete the XML file
            
            % Convert the DOM tree to a MATLAB data structure
            srcEls = xDoc.getElementsByTagName('src');

            numSrcs = srcEls.getLength;
            preAlloc=cell(numSrcs,1);
            srcs = struct('srcPath',preAlloc,'probes',preAlloc,...
                          'srcFolder',preAlloc,'srcTimestamp', preAlloc);
            for i=1:numSrcs
                src = srcEls.item(i-1);
                srcPath = getXmlSrcPath(this, src);
                probeEls  = src.getElementsByTagName('probe');
                numProbes = probeEls.getLength;
                preAlloc=cell(numProbes,1);
                probes = struct('line',preAlloc,'kind',preAlloc,'column',preAlloc,...
                                'event',preAlloc);
                for j=1:numProbes
                    probe=probeEls.item(j-1);
                    probes(j).line = char(probe.getAttribute('line'));
                    probes(j).kind = char(probe.getAttribute('kind'));
                    probes(j).column = char(probe.getAttribute('column'));
                    probes(j).col_seq = char(probe.getAttribute('col_seq'));
                    probes(j).event = char(probe.getAttribute('event'));
                    
                end
                srcs(i).srcPath=srcPath;
                srcs(i).srcFolder=srcFoldersMap(srcPath);
                srcs(i).srcTimestamp=srcTimestampsMap(srcPath);
                srcs(i).probes=probes;
                srcs(i).fn_cov=str2double(char(src.getAttribute('fn_cov')));
                srcs(i).fn_total=str2double(char(src.getAttribute('fn_total')));
                srcs(i).cd_cov=str2double(char(src.getAttribute('cd_cov')));
                srcs(i).cd_total=str2double(char(src.getAttribute('cd_total')));
            end
            
            % Ensure srcs are sorted by srcPath
            srcPaths=cell(size(srcs));
            [srcPaths{:}]=deal(srcs.srcPath);
            [~,i]=sort(srcPaths);
            srcs=srcs(i);
            
            covData.srcs = srcs;

        end
        
        
        function entry(this, modelName, rtwroot, templateMakefile, ...
                       buildOpts, buildArgs, mdlRefTargetType) %#ok
            
            % If no coverage file location was specified in the 
            % constructor we use the model's build directory as the 
            % default location
            bDirInfo = RTW.getBuildDir(modelName);
            rootFolder = bDirInfo.CodeGenFolder;
            this.CodeGenFolder=rootFolder;
            
            if strcmp(mdlRefTargetType, 'NONE')
                buildDir = bDirInfo.BuildDirectory;
            else
                buildDir = fullfile(rootFolder, ...
                    bDirInfo.ModelRefRelativeBuildDir);
            end
            if isempty(this.CovFilePath)
                this.CovFilePath = fullfile(buildDir, [modelName '.cov']);
            end
            
            if any(strfind(rootFolder,' '))
                DAStudio.error('RTW:codeCoverage:spacesInPwd', modelName,...
                               rootFolder)
            end

            
            % All .cov files should have source file paths relative to this
            % dir
            this.CovSrcDir = RTW.transformPaths(rootFolder,...
                                              'pathType','alternate');
            
            % The coverage file that is opened in the coverage browser must
            % be in the same folder used to compute relative paths of the
            % source files
            this.TotalCovFilePath = fullfile(this.CovSrcDir, [modelName '.cov']);
           
            % Set the environment variables for when the target application
            % is launched
            envVarNames={'COVBUILDZONE','COVFILE'};
            envVarValues={rtw.pil.Bullseye.BuildZone, this.TotalCovFilePath};
            this.setLaunchEnvironmentVariables(envVarNames, envVarValues); 
            
            % Set the PATH prepends for coverage build
            this.setBuildPathPrepends({fullfile(this.getToolAltPath,'bin')});
        end
        
        function error(this, varargin)
            
            this.setCoverageBuildOff;
        end
        
        function before_make(this, varargin) 
            
            
            % Check for specific unsupported compilers
            tmf = varargin{3};
            this.checkForUnsupportedCompiler(tmf);
            
            % Set environment variable values
            envVarNames={'COVBUILDZONE','COVFILE','COVSRCDIR'};
            envVarValues={rtw.pil.Bullseye.BuildZone, this.CovFilePath,...
                this.CovSrcDir};
            this.setBuildEnvironmentVariables(envVarNames, envVarValues);
            
            % If build we are building for the top model and coverage for
            % the top model is checked off then don't switch on coverage
            % at this stage
            if this.SkipModelBuild==false
                this.setCoverageBuildOn;
            else
                this.setCoverageBuildOff;
            end
        end
        
        function after_make(this, varargin) 
            if this.SkipModelBuild==false
                this.setCoverageBuildOff;
            end
        end
        
        function before_target_make(this, varargin)
            % Switch on coverage build for the target (SIL or PIL) application; note that if
            % the model build was up to date, the before_make and after_make will not have
            % been called so it is necessary to independently switch on coverage build at
            % this point.
            
            % We must switch on code coverage for building the PIL test
            % harness so that the Bullseye library is linked; since we are 
            % not interested in coverage results for the harness this file 
            % need not be used
            testHarnessCovFile = 'pil_harness.cov';

            envVarNames={'COVBUILDZONE','COVFILE','COVSRCDIR'};
            envVarValues={rtw.pil.Bullseye.BuildZone, testHarnessCovFile,...
                this.CovSrcDir};
            this.setBuildEnvironmentVariables(envVarNames, envVarValues);
            this.setCoverageBuildOn('pilApp',testHarnessCovFile);
        end
        
        function after_target_make(this, varargin) 
            
            this.setCoverageBuildOff;
            buildInfo = varargin{2};
            
            % We need to merge coverage files for any referenced models
            this.mergeCoverageFiles(buildInfo);
            
        end
        
        
        function after_on_target_execution(this, varargin) % e.g. PIL simulation
            
            % Protect against spaces in the paths
            covBrowser = fullfile(this.getToolAltPath,'bin');
            covBrowser = fullfile(covBrowser,'CoverageBrowser');
            covFile=this.TotalCovFilePath;
            [covFilePath,covFileName,covFileExt] = fileparts(covFile);
            covFilePath=RTW.transformPaths(covFilePath,'pathType','alternate');
            covFilePath=fullfile(covFilePath,[covFileName covFileExt]);
            modelName = varargin{1};

            if exist(covFilePath,'file')
                
                disp(['### '...
                      DAStudio.message('RTW:codeCoverage:processingCodeCoverageData')]);
                
                % Push coverage data back to build directories for use by html report
                rptFullPath = this.covForHtml(covFilePath);

                link1 = targets_hyperlink_manager ...
                       ('new', ...
                        DAStudio.message('RTW:codeCoverage:openBullseyeBrowser2'), ...
                        ['!' covBrowser ' ' covFilePath ' &']);
                
                
                if ~isempty(rptFullPath)
                    
                    disp([...
                        DAStudio.message('RTW:codeCoverage:openBullseyeBrowser1') ...
                        ' ' link1 ' ' ...
                        DAStudio.message('RTW:codeCoverage:openBullseyeBrowser3') ...
                         ]);
                    
                    % Auto-launch RTW report using default web browser
                    auto_launch_cmd = ['rtwprivate rtwshowhtml ''' ...
                               rptFullPath ...
                               ''' UseWebBrowserWidget'];
                    % Auto-launch the report if the option is on
                    if ~strcmp(get_param(modelName,'LaunchReport'),'off')
                        evalin('base', auto_launch_cmd);
                    end
                    
                    % Display hyperlinks based web browser type
                    dasRoot = DAStudio.Root;
                    if dasRoot.hasWebBrowser
                        cmd = auto_launch_cmd;
                    else
                        cmd = ['rtwprivate rtwshowhtml ''' ...
                               rptFullPath ...
                               ''' UseExternalWebBrowser'];
                    end
                    link2 = targets_hyperlink_manager ...
                       ('new', ...
                        DAStudio.message('RTW:codeCoverage:openRtwReportForCoverage2'), ...
                        cmd);
                    if dasRoot.hasWebBrowser
                        disp([...
                            DAStudio.message('RTW:codeCoverage:openRtwReportForCoverage1') ...
                            ' ' link2 ' '...
                            DAStudio.message('RTW:codeCoverage:openRtwReportForCoverageWithoutNote') ...
                             ]);
                    else
                        disp([...
                            DAStudio.message('RTW:codeCoverage:openRtwReportForCoverage1') ...
                            ' ' link2 ' '...
                            DAStudio.message('RTW:codeCoverage:openRtwReportForCoverageWithNote');
                             ]);
                    end                    
                else
                    
                    disp([...
                        DAStudio.message('RTW:codeCoverage:openBullseyeBrowser1') ...
                        ' ' link1 ' ' ...
                        DAStudio.message('RTW:codeCoverage:openBullseyeBrowser3') ...
                        ' ' ...
                        DAStudio.message('RTW:codeCoverage:noRtwReportForCoverage') ...
                         ]);
                    
                end
                
            else
                DAStudio.warning('RTW:codeCoverage:bullseyeNoCoverageFile',...
                                 this.TotalCovFilePath);
            end
        end
    end
    
    methods (Access=private)
        
        function srcPath = getXmlSrcPath(~,src)
            srcPath = char(src.getAttribute('name'));
            ancestorNode = src.getParentNode;
            nodeName = char(ancestorNode.getNodeName);
            while strcmp(nodeName,'folder')
                srcPath = sprintf('%s/%s',...
                                  char(ancestorNode.getAttribute('name')),...
                                  srcPath);
                ancestorNode = ancestorNode.getParentNode;
                nodeName = char(ancestorNode.getNodeName);
            end
        end

        function relPath = getPathFromBuildDirToCovFile(~,covFilePath,buildDir)
            [~,covName,ext]=fileparts(covFilePath);

            buildDir = strrep(buildDir,'\','/');
            delimChar='/';
            buildDirCa=textscan(buildDir,'%s','delimiter',delimChar);
            buildDirCa=buildDirCa{1};
            buildDirDepth=length(buildDirCa);
            reversePath=repmat('../',1,buildDirDepth);
            relPath=[reversePath covName ext];

            assert(exist(fullfile(buildDir,relPath),'file')==2,...
                   'path from build folder to cov file must be valid');
                 
        end
        
        function rptFullPath = covForHtml(this, covFilePath)          
            
            % Locate and load the covInfo.mat file
            pilDir = fileparts(this.CovFilePath);
            covInfoFile = fullfile(pilDir,'pil','covinfo.mat');
            covInfo = load(covInfoFile);
            srcFoldersMap = covInfo.srcFoldersMap;
            srcTimestampsMap = covInfo.srcTimestampsMap;

            % Import the coverage data for this simulation run
            covData = this.importCovData(covFilePath, srcFoldersMap,...
                                         srcTimestampsMap);
            
            componentDirs = unique(srcFoldersMap.values);
            rtwReportGenerated = false(size(componentDirs));
            for i=1:length(componentDirs)
                componentDir=componentDirs{i};
                covFileRelPath=this.getPathFromBuildDirToCovFile...
                    (covFilePath,componentDir);
                % Extract coverage data for this component
                componentCovData = rtw.pil.Bullseye.getCovDataForComponent...
                    (covData, componentDir);
                % Merge coverage data into the component covData.mat
                componentCovData = rtw.pil.Bullseye.mergeComponentCovData...
                    (componentCovData, componentDir, covFileRelPath,...
                     this.CodeGenFolder);
                rtw.pil.Bullseye.cleanupCovXmlFiles(componentDir);
                rtwReportGenerated(i) = rtw.pil.Bullseye.isRtwReportGenerated...
                    (componentDir);
                % Generate coverage data xml files if report folder exists
                if exist(fullfile(componentDir,'html'), 'dir')
                    rtw.pil.Bullseye.generateCovXmlFiles(componentCovData,...
                                                         componentDir);
                end
            end
            
            % Identify the build dir for the top-most SIL/PIL component
            rootBuildDir=this.CodeGenFolder;
            topComponentDir=fileparts(this.CovFilePath);
            assert(all(strmatch(rootBuildDir,topComponentDir)),...
                'Must be a path starting with rootBuildDir');
            topComponentDir=topComponentDir(length(rootBuildDir)+2:end);
            topDirIdx=find(strcmp(componentDirs,topComponentDir));
            
            if isempty(topDirIdx)
                topModelSilOrPilWithNoCoverage=true;
                % We are running a top-model SIL or PIL simulation but code
                % coverage for the top model is switched off
                topModelRtwReportGenerated = rtw.pil.Bullseye.isRtwReportGenerated...
                    (topComponentDir);
            else
                topModelSilOrPilWithNoCoverage=false;
            end
            
            % create hyperlink to RTW report on desktop
            if (topModelSilOrPilWithNoCoverage && topModelRtwReportGenerated) ...
                    || (~isempty(topDirIdx) && rtwReportGenerated(topDirIdx))
                htmlFolder = fullfile(topComponentDir,'html');
                rpt = dir(fullfile(htmlFolder,'*_codegen_rpt.html'));
                rptFullPath = fullfile(pwd,htmlFolder,rpt.name);
            else
                rptFullPath = '';
                
            end
        end
        
        
        function checkForUnsupportedCompiler(~, tmf)

            unsupportedCompiler='';
            if any(findstr('_lcc.tmf',tmf))
                unsupportedCompiler='LCC';
            elseif any(findstr('_watc.tmf',tmf))
                unsupportedCompiler='Open Watcom';
            end
            
            if ~isempty(unsupportedCompiler)
                DAStudio.error('RTW:codeCoverage:unsupportedCompiler',...
                               unsupportedCompiler)
            end
        end
        
        
        function setCoverageBuildOn(this, mode, covFile)
            if nargin < 2
                mode = 'on';
            end
            
            % Switch on coverage for this Build Zone
            covCmd=fullfile(this.getToolAltPath,'bin','cov01');
            switch mode
                case 'on'
                    covCmd = sprintf('%s %s', covCmd, '-01');
                case 'off'
                    covCmd = sprintf('%s %s', covCmd, '-00');
                otherwise
                    assert(strcmp(mode,'pilApp'))
                    covCmd = sprintf('%s %s', covCmd, '-01');
                    % Command to switch off coverage for PIL harness files
                    covSelectCmd=sprintf('%s %s %s %s %s',...
                        fullfile(this.getToolAltPath,'bin','covselect'), ...
                        '--create',...
                        '--file', covFile,...
                        '--add _coverage_for_this_nonexistent_file_only.c');
            end
            % We use COVBUILDZONE to enable/disable coverage independently of 
            % any other processes (e.g. other sessions of MATLAB) that may be 
            % building an application
            setenv('COVBUILDZONE',rtw.pil.Bullseye.BuildZone);
            c = onCleanup(@() setenv('COVBUILDZONE',''));
            
            rtw.pil.Bullseye.systemCommand(covCmd);

            if strcmp(mode,'pilApp')
                rtw.pil.Bullseye.systemCommand(covSelectCmd);
            end
        end
        
        function setCoverageBuildOff(this)
            setCoverageBuildOn(this, 'off');
        end
        
        function mergeFiles(this,resultCovFile,covFiles,create)
            if create
                createArg = '--create';
            else
                createArg = '';
            end
            if ~iscell(covFiles)
                covFiles={covFiles};
            end
            
            done = zeros(size(covFiles));
            while ~all(done)            
            
                cmd = fullfile(this.getToolAltPath,'bin','covmerge');
                cmd = sprintf('%s --no-banner %s --file %s', cmd, ...
                              createArg, resultCovFile);
                i=find(~done,1,'first');
                covFile=covFiles{i};
                
                while(~all(done) && ...
                      (length(cmd)+length(covFile)) < ...
                      rtw.pil.Bullseye.MaxCmdLength)
                    cmd = sprintf('%s %s', cmd, covFile);
                    done(i)=1;           
                end
                rtw.pil.Bullseye.systemCommand(cmd);
            end
        end

        function removeSrcsFromCovFile(this, covFile, srcFiles)
            [covFilePath,covFileName,ext] = fileparts(covFile);
            covFileName=[covFileName ext];
            
            done = zeros(size(srcFiles));
            while ~all(done) 
                cmd = fullfile(this.getToolAltPath,'bin','covmgr');
                cmd = sprintf(...
                    '%s --no-banner --file %s --remove', ...
                    cmd, covFileName);
                i=find(~done,1,'first');
                srcFile=srcFiles{i};
                
                while(~all(done) && ...
                      (length(cmd)+length(srcFile)) < ...
                      rtw.pil.Bullseye.MaxCmdLength)
                    cmd = sprintf('%s %s',cmd,srcFile);
                    done(i)=1;
                end
                saveDir = cd(covFilePath);
                c = onCleanup(@() cd(saveDir));
                rtw.pil.Bullseye.systemCommand(cmd);
                clear c;
            end
        end
        
        
        function allSrcs = listSrcFiles(this,covFile)
            cmd = fullfile(this.getToolAltPath,'bin','covmgr');
            cmd = sprintf('%s --list --file "%s"', cmd, covFile);

            cmdResult = rtw.pil.Bullseye.systemCommand(cmd);
            
            allSrcs = rtw.pil.Bullseye.parseSrcFileList(cmdResult);
        end
        
        
        function [sharedUtilCovFile, sharedUtilSrcs, nonSharedUtilSrcs] = ...
                extractSharedUtilSrcs...
                (this, covFile, relativePathToAnchor, ...
                 srcFoldersMap, srcTimestampsMap)
            
            sharedUtilFolder=fullfile('slprj','ert','_sharedutils');
            
            sharedUtilCovFile = fullfile(sharedUtilFolder,...
                'sharedutils.zcov');   % Files *.c* may be mistaken for
                                       % source files
            
            sharedUtilCovFile = ...
                fullfile(relativePathToAnchor,sharedUtilCovFile);
            
            % Identify any sharedutil source files in the .cov file
            allSrcs = this.listSrcFiles(covFile);
            
            sharedUtilFolderBullseyeFormat=strrep(sharedUtilFolder,filesep,'/');
            sharedUtilIdx = strmatch(sharedUtilFolderBullseyeFormat,allSrcs);
            sharedUtilSrcs = unique(allSrcs(sharedUtilIdx));
            nonSharedUtilIdx = setdiff(1:length(allSrcs), sharedUtilIdx);
            nonSharedUtilSrcs = unique(allSrcs(nonSharedUtilIdx));
            
            if exist(sharedUtilCovFile, 'file')
                % Identify all source files in the shared utils .cov file
                existingSharedSrcs = this.listSrcFiles(sharedUtilCovFile);
            else
                existingSharedSrcs = {};
            end
                    
            % Populate the hash table that maps source files to .cov file folder
            timestamps=rtw.pil.Bullseye.getCovSrcTimestamps...
                (relativePathToAnchor, sharedUtilSrcs);
            for i=1:length(sharedUtilSrcs)
                srcFoldersMap(sharedUtilSrcs{i})=sharedUtilFolder;
                srcTimestampsMap(sharedUtilSrcs{i})=timestamps{i};
            end
            timestamps=rtw.pil.Bullseye.getCovSrcTimestamps...
                (relativePathToAnchor, existingSharedSrcs);
            for i=1:length(existingSharedSrcs)
                srcFoldersMap(existingSharedSrcs{i})=sharedUtilFolder;
                srcTimestampsMap(existingSharedSrcs{i})=timestamps{i};
            end
            covFileFolder=fileparts(covFile);
            covFileFolder=rtw.pil.Bullseye.transformPath(covFileFolder,...
                relativePathToAnchor);
            timestamps=rtw.pil.Bullseye.getCovSrcTimestamps...
                (relativePathToAnchor, nonSharedUtilSrcs);
            for i=1:length(nonSharedUtilSrcs)
                srcFoldersMap(nonSharedUtilSrcs{i})=covFileFolder;
                srcTimestampsMap(nonSharedUtilSrcs{i})=timestamps{i};
            end
            
            if ~isempty(sharedUtilSrcs)
                
                % make a copy of the model .cov file in the shared utils
                % folder
                [~,dstFile] = fileparts(covFile);
                dstFile = [dstFile '.cov'];
                dstFile = fullfile(relativePathToAnchor,sharedUtilFolder,...
                    dstFile);
                createDstFile=true;
                this.mergeFiles(dstFile,covFile,createDstFile);
                
                % We must remove non-shared util sources from .cov file 
                % in the shared utils folder
                this.removeSrcsFromCovFile(dstFile, nonSharedUtilSrcs);
                
                % Remove shared util sources from .cov file 
                % in the model build folder
                this.removeSrcsFromCovFile(covFile, sharedUtilSrcs);
                
                % If the sharedutils.cov already exists we must remove
                % any existing coverage info for any new files we will add
                if ~isempty(existingSharedSrcs)
                    
                    srcsToRemove=intersect(existingSharedSrcs,sharedUtilSrcs);
                    if ~isempty(srcsToRemove)
                        this.removeSrcsFromCovFile(sharedUtilCovFile, ...
                            srcsToRemove);
                    end
                end                    

                
                % Now merge the coverage data into the shared utils .cov file
                createCovFile = ~exist(sharedUtilCovFile, 'file');
                this.mergeFiles(sharedUtilCovFile, dstFile, createCovFile);
                
                % Clean up temporary file
                delete(dstFile);
            end
        end
        
        
        function mergeCoverageFiles(this, buildInfo)
            % A separate .cov file is created for each model reference
            % component; this is necessary to support parallel builds.
            % The coverage files for each component must be merged into a
            % single file to collect coverage date
           
            mdlRefs = buildInfo.ModelRefs;
            covFiles = cell(length(mdlRefs),1);
            [~,relativePathToAnchor]=buildInfo.findBuildArg...
                ('RELATIVE_PATH_TO_ANCHOR');
            timestampFiles = cell(length(mdlRefs),1);
            for i=1:length(mdlRefs)
                [~,refName]=fileparts(mdlRefs(i).Path);
                refPath=mdlRefs(i).Path;
                % Strip the leading '..' from refPath to get a path
                % relative to the anchor
                assert(logical(strmatch('..',refPath)));
                refPath=refPath(3:end);
                refPath=fullfile(relativePathToAnchor,refPath);
                covFiles{i} = fullfile(refPath, [refName '.cov']);
                timestampFiles{i} = fullfile(refPath,'modelsources.txt');
            end
            timestampFiles{end+1} = fullfile('..', 'modelsources.txt');
            covFiles{end+1} = fullfile('..',[buildInfo.ModelName '.cov']);
            
            % We must filter out .cov files that are stale or do not exist
            validCovFiles = zeros(length(covFiles),1);
            covFileMaxDate = 0;
            for i=1:length(covFiles)
                covFile = covFiles{i};
                timeFile = timestampFiles{i};
                if exist(covFile,'file') 
                   dirCovFile = dir(covFile);
                   covFileDate = dirCovFile.datenum;
                   dirTimeFile = dir(timeFile);
                   if covFileDate > dirTimeFile.datenum
                       validCovFiles(i) = 1;
                       % Identify the most recent .cov file so we can determine 
                       % if the combined .cov file must be updated
                       if covFileMaxDate < covFileDate
                           covFileMaxDate = covFileDate;
                       end
                   end
                end
            end
            covFiles = covFiles(logical(validCovFiles));
            
            covFileExists = exist(this.TotalCovFilePath,'file');

            % We delete the total coverage result file if it exists
            if covFileExists 
                delete(this.TotalCovFilePath);
            end
            
            % Load the covinfo.mat file if it exists
            covInfoFile = fullfile(pwd,'covinfo.mat');
            
            if isempty(covFiles)
                if exist(covInfoFile,'file')
                    delete(covInfoFile);
                end
            else
                % There is coverage data to collect
                
                % Make sure covInfo.mat is deleted
                if exist(covInfoFile,'file')
                    delete(covInfoFile);
                end     
                
                % Hash table that maps source files to .cov file folder
                srcFoldersMap = containers.Map;
                
                % Hash table that maps source files to timestamps
                srcTimestampsMap = containers.Map;
                
                for i=1:length(covFiles)
                    % Data for any shared utility sources is placed
                    % in a separate .cov file in the sharedutils
                    % folder
                    [sharedUtilCovFile, sharedUtilSrcs, nonSharedUtilSrcs] = ...
                        this.extractSharedUtilSrcs...
                        (covFiles{i}, ...
                        relativePathToAnchor, ...
                        srcFoldersMap, srcTimestampsMap);
                    
                    % Check that no source file has a more recent timestamp
                    % than the .cov file
                    dCovFileNonSharedUtils=dir(covFiles{i});
                    timestampCovFile = dCovFileNonSharedUtils.datenum;
                    for ii2=1:length(nonSharedUtilSrcs)
                        srcFileName = nonSharedUtilSrcs{ii2};
                        timestampSrc=srcTimestampsMap(srcFileName);
                        if timestampSrc>timestampCovFile
                            DAStudio.error('RTW:codeCoverage:SrcFileModified', ...
                                srcFileName);
                        end
                    end
                    % Check that no shared utility source file has a more
                    % recent timestamp than the shared utility .cov file
                    dCovFileSharedUtils=dir(sharedUtilCovFile);
                    if ~isempty(dCovFileSharedUtils)
                        timestampCovFile = dCovFileSharedUtils.datenum;
                        for ii2=1:length(sharedUtilSrcs)
                            srcFileName = sharedUtilSrcs{ii2};
                            timestampSrc=srcTimestampsMap(srcFileName);
                            if timestampSrc>timestampCovFile
                                DAStudio.error('RTW:codeCoverage:SrcFileModified', ...
                                               srcFileName);
                            end
                        end
                    end
                end
                
                % Copy the first .cov file
                [filePath,fileName,fileExt]=fileparts(this.TotalCovFilePath);
                filePath=RTW.transformPaths(filePath,'pathType','full');
                totalCovFileFullPath=fullfile(filePath,[fileName fileExt]);
                copyfile(covFiles{1}, totalCovFileFullPath);
                
                covFiles=covFiles(2:end);
                
                % Merge the remaining .cov files 
                for i=1:length(covFiles)
                    covFile = covFiles{i};
                    if ~isempty(covFile)
                        this.mergeFiles(this.TotalCovFilePath, ...
                                        covFile, false);
                    end
                end
                
                % Merge the shared utils .cov file
                if exist(sharedUtilCovFile,'file')
                    % If the shared utils .cov file exists we merge it
                    % irrespective of whether the SIL/PIL simulation
                    % needs to link against shared sources; a potential
                    % enhancement is to merge this .cov file only if 
                    % shared utility functions are truly needed
                    this.mergeFiles(this.TotalCovFilePath, ...
                                    sharedUtilCovFile, false);
                end
                
                % Save the mapping of source files to component/sharedutils dirs
                srcFiles=this.listSrcFiles(this.TotalCovFilePath); %#ok<NASGU>
                save(covInfoFile,'covFiles','srcFoldersMap',...
                     'srcTimestampsMap','srcFiles')
            end
        end
    end
end
