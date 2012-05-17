function helpStr = mdlFile(fullPath)
    helpStr = char(com.mathworks.jmi.MLFileUtils.getMdlDesc(fullPath, true));
end