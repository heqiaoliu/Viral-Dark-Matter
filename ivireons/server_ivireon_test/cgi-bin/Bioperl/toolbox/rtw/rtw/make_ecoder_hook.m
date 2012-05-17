function make_ecoder_hook(hook, h, cs)
% MAKE_ECODER_HOOK: Real-Time Workshop Embedded Coder has additional
% hooks (calbacks) to the normal Real-Time Workshop build process.
%

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.5.2.11 $

% For model reference sim target, do not process the hooks
if strcmp(h.MdlRefBuildArgs.ModelReferenceTargetType, 'SIM')
  return
end

mptEnabled = ec_mpt_enabled(h.ModelName);

switch hook
    case 'entry'
        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'before_tlc'

        LocalExpandCodeTemplates(h,cs);
        LocalCopyCustomTemplates(h,cs);

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'after_tlc'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'before_make'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'after_make'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    case 'exit'

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

    otherwise

        if mptEnabled
            mpt_ecoder_hook(hook,h.ModelName);
        end

end


% Expand ERT code templates if they exist
function LocalExpandCodeTemplates(h,cs)
ert_src_template = get_param(cs,'ERTSrcFileBannerTemplate');
usList = {get_param(cs,'ERTDataHdrFileTemplate')...
          get_param(cs,'ERTDataSrcFileTemplate')...
          get_param(cs,'ERTHdrFileBannerTemplate')...
          ert_src_template};

% Sort list and remove duplicates
list = unique(usList);

for i = 1: length(list)
    cgtName = list{i};

    % if the path is not empty, then we need to strip out just the filename
    % portion for the tlcname.
    [fpath,fname,fext] = fileparts(cgtName);
    if ~isempty(fpath)
        tlcName = [fname fext];
    else
        tlcName = cgtName;
    end
    tlcName = rtw_cgt_name_conv(tlcName,'cgt2tlc');
    
    fullPathName = which(cgtName);
        
    if isempty(fullPathName)
        if exist(cgtName,'file')
            fullPathName = cgtName;
        end
    end
    
    outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,tlcName);
    if ~isempty(fullPathName)
        if isequal(fext,'.cgt')
            cgtfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,[fname '_ct.cgt']);
            % Generate function banners from ERTSrcFileBannerTemplate only
            if strcmp(cgtName, ert_src_template)
                bGenFcnBannerFile = true;
            else
                bGenFcnBannerFile = false;
            end
            
            % Cut regions out from original cgt file and save to a temp cgt file
            % Save regions into tlc files in the same directory as cgtfile, which is the tlc subdirectory
            rtwprivate('rtw_get_region_from_template', fullPathName, cgtfile, get_param(cs, 'TargetLang'), bGenFcnBannerFile);
            
            % Expand temporary cgt file for code tempalte. As rtw_expand_template doesn't recognize region,
            % rtw_get_region_from_template shall be called first.
            % Delete the file in the tlc directory to ensure the latest template.
            if exist(outfile,'file')
                rtw_delete_file(outfile);
            end    
            rtw_expand_template(cgtfile,outfile);  
            rtw_delete_file(cgtfile);
        else
            rtw_copy_file(fullPathName,outfile);
        end
    else
        if isempty(cgtName)
            % cgt file is not specified in the config set
            doclink = rtwprivate('rtw_template_helper', 'get_doc_link');
            DAStudio.error('RTW:targetSpecific:cgtFileNotSet', doclink);
        else
            % cgt file is not in Matlab path.
            DAStudio.error('RTW:targetSpecific:cgtFileNotFound', cgtName);
        end
    end
end


% Copy ERT custom template if it exist
function LocalCopyCustomTemplates(h,cs)

templateFile = strtok(get_param(cs,'ERTCustomFileTemplate'));

    % Delete the file in the tlc directory if it exists (to ensure
    % we get the latest template).
    [dirstr,fname,ext] = fileparts(templateFile);
    outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,[fname,ext]);
    if exist(outfile,'file')
        rtw_delete_file(outfile);
    end

    templateFile = which(templateFile);

    % Copy it to the tlc directory if found
    if ~isempty(templateFile)
        rtw_copy_file(templateFile,outfile);
    end

