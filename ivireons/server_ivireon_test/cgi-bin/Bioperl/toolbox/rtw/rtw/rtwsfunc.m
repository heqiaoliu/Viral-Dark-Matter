function displist = rtwsfunc(rtw_sf_name,block)
%RTWSFUNC: Used by the RTW S-Function code format to create a
%          block with the proper sfunctionmodules parameter set and
%          the text for display in the icon
% 
%  rtw_sf_name = String containing the name of the RTW generated
%                S-Function
%  block       = the handle to the RTW s-function block(gcb)
%
  
% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.12.2.12 $
    
    sfmodules = ''; sflibs = ''; usermodules = '';
    if exist(rtw_sf_name,'file') == 3
        mkpath = which(rtw_sf_name);
        modelname = rtw_sf_name(1:end-3);
        sfcn_sizes = feval(rtw_sf_name, [], [], [], 0);
        if sfcn_sizes(31) == 1 % rtwsfunc
            mkfile = strrep(mkpath,[rtw_sf_name,'.',mexext], ...
                            [modelname,'_sfcn_rtw',filesep,modelname,'.mk']);
        else
            mkfile = strrep(mkpath,[rtw_sf_name,'.',mexext], ...
                            [modelname,'_ert_rtw',filesep,modelname,'.mk']);
        end
        fid = fopen(mkfile,'rt');
        if fid == -1
            DAStudio.error('RTW:targetSpecific:sFunctionMakefileNotFound',...
                           mkfile,rtw_sf_name,modelname);
        else
            got_sfmodules =0; got_sflibs =0; got_usermodules =0;
            while (1)
                line = fgetl(fid); if ~ischar(line), break; end
                sfmodulesIdx = regexp(line, 'S_FUNCTIONS\s*=\s*','end');
                sflibsIdx = regexp(line, 'S_FUNCTIONS_LIB\s*=\s*','end');
                usermodulesIdx = regexp(line, 'USERMODULES\s*=\s*','end');
                if ~isempty(sfmodulesIdx)
                    sfmodules = line(sfmodulesIdx+1:end);
                    got_sfmodules =1;
                end
                if ~isempty(sflibsIdx)
                    sflibs = line(sflibsIdx+1:end);
                    got_sflibs = 1;
                end
                if ~isempty(usermodulesIdx)
                    usermodules = line(usermodulesIdx+1:end);
                    got_usermodules =1;
                end
                if got_sfmodules && got_sflibs && got_usermodules
                    break;
                end
            end
            fclose(fid);
        end
    end
    % Create the list for the sfunctionmodules parameter.
    sflist   = strrep(sfmodules,'.cpp','');
    sflist   = strrep(sflist,'.c','');
    sflist   = strrep(sflist,'.obj','');
    userlist = strrep(usermodules,'.cpp','');
    userlist = strrep(userlist,'.c','');
    userlist = strrep(userlist,'.obj','');
    list     = [sflist, ' ', userlist, ' ', sflibs];

    % remove anything that is a full path.
    list     = regexprep(list,' ([^ ]*[\\/])[^ ]*','');
    
    %
    % Set up the module list for code generation.  Note that this is
    % a "read only if compiled" parameter, so it can only be set
    % at initialization time (which includes code generation).
    %
    if strcmp(get_param(bdroot(block),'SimulationStatus'),'initializing') && ...
            strcmp(get_param(block,'LinkStatus'),'none')
        set_param(block,'sfunctionmodules', list);
    end
    
    % Create the list for the display inside the block.
    sflist = strrep(sfmodules,'.c','.c\n');
    sflist = strrep(sflist,'.obj','.c\n');
    userlist = strrep(usermodules,'.c','.c\n');
    userlist = strrep(userlist,'.obj','.c\n');
    sflibs = strrep(sflibs,'.lib','.lib\n');
    sflibs = strrep(sflibs,'.a','.a\n');
    displist = [sflist, userlist, sflibs];

    if isempty(deblank(displist))
        displist = 'none';
    end

