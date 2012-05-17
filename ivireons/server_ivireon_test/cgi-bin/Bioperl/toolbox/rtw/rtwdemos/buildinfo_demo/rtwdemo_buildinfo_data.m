function rtwdemo_buildinfo_data(buildInfo)
% BUILDINFO_DEMO - Demonstrates the Build Info API executed
% during the RTW build process.  This function is invoked as a result of
% set_param(model,'PostCodeGenCommand','rtwdemo_buildinfo_data(buildInfo)'
    
%   Copyright 1994-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $

disp([char(10) '*** Running rtwdemo_buildinfo_data in Post ', ...
               'Code Generation phase']);

% Save BuildInfo.html one level above the build directories.
fileName = 'BuildInfo.html';
htmlFile = ['..' filesep fileName];

% Open HTML file
fid = fopen(htmlFile,'wt');

% Write basic HTML header tags
fprintf(fid, '<html>\n'); 
fprintf(fid, '<head>\n'); 
fprintf(fid, '<title>Using the Build Info Object</title> <br>\n'); 
fprintf(fid, '</head>\n'); 

fprintf(fid,'<body>\n');

fprintf(fid, '<h1>Build Information Object Demonstration</h1> <br>');
% Write the current date and time
fprintf(fid, '%s <br> <br>\n',datestr(datenum(clock)));

% By default, the path and extension to source files are 
% not be included. This can be updated with the following API call
updateFilePathsAndExtensions(buildInfo, '.c');

% Update the file separator to use '/' so that the hyperlinks in the
% HTML report will work correctly.

updateFileSeparator(buildInfo, '/');

% Get the source and lib files
bInfo = {};

% Get all the files in the buildInfo object
bInfo.allSrcFileList = getFiles(buildInfo, 'all', false, false);
% Write all the files obtained from the buildInfo object
fprintf(fid, '<h4>Source and header files</h4> <br>\n');
fprintf(fid, ['<h4>These include generated model files as well as ' ...
              'custom files</h4> <br>\n']);
for i = 1:length(bInfo.allSrcFileList)
    
    fprintf(fid, '%s <br>\n', bInfo.allSrcFileList{i});
    
end
fprintf(fid, '<br>\n');

% Regular expression patterns to replace drive letters with HTML
% standards for hyperlinks to files 
% Example  replace c:\ with file:///C:/
strPattern = '([A-Za-z]):\/';
htmlPattern = 'file:\/\/\/$1\:/';

% Get the source files from all groups with path and expanded matlabroot 
bInfo.srcFilesWPathMLRoot = getSourceFiles(buildInfo, true, true, {});

% Replace drive letter string pattern with HTML standard 
srcFilesWPathMLRoot_hyperlink = regexprep(bInfo.srcFilesWPathMLRoot, ...
                    strPattern, htmlPattern);

% Write all the source files with path and expanded matlabroot
fprintf(fid, '<h4>Source files with path and expanded matlabroot</h4> <br>\n');
for i = 1:length(bInfo.srcFilesWPathMLRoot)

    fprintf(fid, '<a href="%s">%s</a> <br>\n', srcFilesWPathMLRoot_hyperlink{i},...
            bInfo.srcFilesWPathMLRoot{i});    
end
fprintf(fid, '<br>\n');


% Get the source files from all groups with path
bInfo.srcFilesWPath = getSourceFiles(buildInfo, true, false, {});
% Write the source files with path (all groups)
fprintf(fid, '<h4>Source files with path </h4> <br>\n');
for i = 1:length(bInfo.srcFilesWPath)

    fprintf(fid, '<a href="%s">%s</a> <br>\n', srcFilesWPathMLRoot_hyperlink{i},...
            bInfo.srcFilesWPath{i});  
end
fprintf(fid, '<br>\n');

% Get the source files from all groups without path
bInfo.srcFilesWOPath = getSourceFiles(buildInfo, false, false, {});
% Write  all the source files without path (all groups)
fprintf(fid, '<h4>Source files without path</h4> <br>\n');
for i = 1:length(bInfo.srcFilesWOPath)
  
    fprintf(fid, '<a href="%s">%s</a> <br>\n', srcFilesWPathMLRoot_hyperlink{i},...
            bInfo.srcFilesWOPath{i});
         
end
fprintf(fid, '<br>\n');


% Get the source files associated with S-Functions, exclude everything else
bInfo.srcFilesSfcn = getSourceFiles(buildInfo, true, true, 'Sfcn', {});
% Write all the S-Function source files
fprintf(fid, '<h4>S-Function source files</h4> <br>\n');
for i = 1:length(bInfo.srcFilesSfcn)

      % Replace drive letter string pattern with HTML standard 
     srcFilesSfcn_hyperlink = regexprep(bInfo.srcFilesSfcn{i}, ...
                    strPattern, htmlPattern);
                
     fprintf(fid, '<a href="%s">%s</a> <br>\n', srcFilesSfcn_hyperlink,...
             bInfo.srcFilesSfcn{i});   
end
fprintf(fid, '<br>\n');

% Get the source files associated with custom code, exclude everything else
bInfo.srcFilesCustomCode = getSourceFiles(buildInfo, true, true, 'CustomCode', {});
% Write the CustomCode source files
fprintf(fid, '<h4>Custom code files</h4> <br>\n');
for i = 1:length(bInfo.srcFilesCustomCode)

      % Replace drive letter string pattern with HTML standard 
      srcFilesCustomCode_hyperlink = regexprep(bInfo.srcFilesCustomCode{i}, ...
                    strPattern, htmlPattern);

      fprintf(fid, '<a href="%s">%s</a> <br>\n', srcFilesCustomCode_hyperlink,...
          bInfo.srcFilesCustomCode{i});
end
fprintf(fid, '<br>\n');

% In order to get access to the rtwmakecfg source file, we have to first
% access the link object buildinfo_rtwmake_lib.
% This provides a handle to the link object buildInfo_rtwmakecfg_lib
lib = findLinkObject(buildInfo, 'buildinfo_rtwmakecfg_lib');

if ~isempty(lib)
	% Get the source files associated with library buildinfo_rtwmakecfg_lib
	bInfo.srcFilesRtwMakeCfg = getSourceFiles(lib, true, true);
 
   
	% Get the library source files with the paths and extensions
	bInfo.srcFilesRtwMakeCfg = getSourceFiles(lib, true, true);

	% Write all the rtwmakecfg source files
	fprintf(fid, '<h4>rtwmakecfg files</h4> <br>\n');
	for i = 1:length(bInfo.srcFilesRtwMakeCfg)

            % Replace drive letter string pattern with HTML standard 
            srcFilesRtwMakeCfg_hyperlink = regexprep(bInfo.srcFilesRtwMakeCfg{i}, ...
                                                     strPattern, htmlPattern);
                
            fprintf(fid, '<a href="%s">%s</a> <br>\n', srcFilesRtwMakeCfg_hyperlink,...
                    bInfo.srcFilesRtwMakeCfg{i});            
            
	end
	fprintf(fid, '<br>\n');

end

% Restore the fileseparator to the platform specific one. 
updateFileSeparator(buildInfo, filesep);

% General HTML tags
fprintf(fid, '</body>\n');

fprintf(fid, '</html>\n');

disp(['*** Generated report ' fileName]);

% Pack all the files used in the buidl process into a zip file
% using the packNGo feature.

packNGoFile = gcs; % model name : rtwdemo_buildinfo
packType = 'flat';
packNGo(buildInfo, {'fileName' packNGoFile, 'packType' packType});

disp(['*** Created Zip file ' packNGoFile '.zip using packNgo']);

% Close HTML file
fclose(fid);

disp(char(10));