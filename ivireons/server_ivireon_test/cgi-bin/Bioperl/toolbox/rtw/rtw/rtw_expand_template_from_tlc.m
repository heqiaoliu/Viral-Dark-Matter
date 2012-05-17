function errMsg = rtw_expand_template_from_tlc(name, modelName)
% Expand the specified ERT code generation template.
%
% Args:
%   name - name of the code geneartion template to expand
%
% Returns:
%   'success'        - success
%   'file not found' - failure (could not find file on MATLAB path)
%   lasterr          - failure (error during template expansion)

% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $

%cgt file name in config set
cs_cgt = which(name);
  
if ~isempty(cs_cgt)
    [dirstr,fname,ext] = fileparts(cs_cgt);
    try
        h = get_param(modelName, 'MakeRTWSettingsObject');
        if isempty(h)
            DAStudio.error('RTW:buildProcess:objHandleLoadError', modelName);
        end  
        if isequal(ext,'.cgt')
            tlcName = rtw_cgt_name_conv([fname,ext],'cgt2tlc');
            outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,tlcName);
            tmp_cgt = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,[fname '_ct.cgt']);
            cs = getActiveConfigSet(modelName);
            ert_src_template = get_param(cs,'ERTSrcFileBannerTemplate');
            % Generate function banners from ERTSrcFileBannerTemplate only
            if strcmp([fname ext], ert_src_template)
                bGenFcnBannerFile = true;
            else
                bGenFcnBannerFile = false;
            end
            % Expand cgt to tlc only once for each cgt file.
            if ~(exist(outfile, 'file') == 2)
                % Cut regions out from original cgt file and save to a temp cgt file
                % Save regions into tlc files in the same directory as cgtfile, which is the tlc subdirectory
                rtwprivate('rtw_get_region_from_template', cs_cgt, tmp_cgt, get_param(modelName, 'TargetLang'), bGenFcnBannerFile);
                % Expand temporary cgt file for code tempalte. As rtw_expand_template doesn't recognize region,
                % rtw_get_region_from_template shall be called first.
                rtw_expand_template(tmp_cgt,outfile);
                rtw_delete_file(tmp_cgt);
            end
        else
            outfile = fullfile(h.BuildDirectory,h.GeneratedTLCSubDir,[fname,ext]);
            rtw_copy_file(cgt,outfile);
        end
        errMsg = 'success';
    catch exc
        errMsg = exc.message;
    end
else
    errMsg = 'file not found';
end
