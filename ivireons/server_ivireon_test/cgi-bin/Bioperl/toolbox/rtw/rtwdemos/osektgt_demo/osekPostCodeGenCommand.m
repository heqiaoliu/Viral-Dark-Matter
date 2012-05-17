function osekPostCodeGenCommand
    %
    % Add to generated HTML the filename provided. Normally, all .c and .h
    % file in RTW build directory are added. This function would be used to
    % add other files in builddir with different extensions such as .oil.
    % This function leverages RTW private functions, specifically rtwctags
    % is used which presumes file contains C like syntax.
    %
    if strcmp(get_param('rtwdemo_osek','GenerateReport'),'off')
        return
    end
    fileName = 'rtwdemo_osek.oil';
    savedBuildDir = pwd;
    try
        
      lasterr('');
      cd('html');
      fileToTag = {fullfile(savedBuildDir,fileName)};
      rtwprivate('rtwctags',fileToTag);
      fid = fopen('contents_file.tmp','r');
      fileContents = fread(fid, '*char')';
      fclose(fid);
      [s,f,t] = regexp(fileContents, '<A HREF[^\n]*');
      insertTxt = ['</TD></TR><TR></TR><TR><TD>', sprintf('\n'), fileContents(s:f)];
      rptContentsFile = rtwprivate('rtwattic', 'getContentsFileName');
      fid = fopen(rptContentsFile, 'r');
      fileContents = fread(fid, '*char')';
      fclose(fid);
      [s,f,t] = regexp(fileContents, '</A>\s*');
      fileContents = [fileContents(1:f(end)), insertTxt, fileContents(f(end)+1:end)];
      fid = fopen(rptContentsFile, 'w');
      fwrite(fid, fileContents, 'char');
      fclose(fid);
      rptFileName = rtwprivate('rtwattic', 'getReportFileName');
      rtwprivate('rtwshowhtml', rptFileName,'UseWebBrowserWidget');
    end
    cd(savedBuildDir);
    error(lasterr);
