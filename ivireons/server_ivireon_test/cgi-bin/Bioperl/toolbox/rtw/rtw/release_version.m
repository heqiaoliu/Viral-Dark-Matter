function releaseVersion = release_version
%RELEASE_VERSION - Return a version string of the form R14, R14SP2, R14SP2plus etc.
%
%  The release version is parsed by looking at the output of the ver('rtw')
%  string. This function is expecting a struct with 'Version ' and
%  'Release' fields containing one of the following:
%
%    Version  Release
%    M.m      (R#)
%    M.m      (R#SPm)
%    M.m.p    (R#SP#+)
%
%  where M = major release num, m = minor release num, p = patch num
%

    
%   Copyright 1994-2006 The MathWorks, Inc.
%   $Revision: 1.9.2.5 $  $Date: 2006/11/19 21:24:57 $

    
    v = ver('rtw');
    if isempty(v)
        releaseVersion = 'RTWNotAvailable';
        return;
    end
    
  
    % break the Version number into it's parts.  the regexp call will put all
    % of the numbers in separate elements in the vnum vector.
    [vnum mat] = regexp(v.Version,'(\d+)','tokens','match'); %#ok<NASGU>
    shownum = false;
    switch length(vnum)
      case 2
        dacore = '';
      case {3}
        dacore = char(vnum{3});
        num3 = sscanf(char(vnum{3}),'%d');
        shownum = (num3 > 0);
      case {4}
        num3 = sscanf(char(vnum{3}),'%d');
        num4 = sscanf(char(vnum{4}),'%d');
        if ((num3 > 0) || (num4 > 0))
            dacore = char(vnum{3});
            if (num4 > 0)
                dacore = [dacore '.' char(vnum{4})];
            end
            shownum = true;
        end
      otherwise
        DAStudio.error('RTW:utility:unknownReleaseVersion');
    end
    
    % get the release string without the '(' ')'
    rel = regexprep(v.Release,'[\(\)]','');
    
    % replace spaces with '_'
    rel = regexprep(rel,' ','_');
    
    % now replace any '+' with the word plus
    rel = regexprep(rel,'\+','plus');
    
    % finally, if the dacore version is greater than 1, add it to the end of
    % the rel string.  This results in the following output (arbitrary
    % relase values shown):
    %
    % Version     Release              output       
    % 6.0         (R14)                R14          
    % 6.2.1       (R14SP2+)            R14SP2plus1  
    % 6.2.2       (R14SP2+)            R14SP2plus2  
    % 6.2.3.4     (R14SP2+)            R14SP2plus3.4  
    % 6.6.0.1     (R2007a Prerelease)  R2007a_Prerelease0.1
    % 6.6.100.12  (R2007a Prerelease)  R2007a_Prerelease100.12
    
    if shownum
        rel = sprintf('%s%s', rel, dacore);
    end
   
  releaseVersion = rel;

%endfunction release_version
