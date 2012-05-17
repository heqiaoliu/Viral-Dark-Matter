function chksum = exported_fcn_checksum(exportedFcnInfo)
%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2005/06/24 11:29:26 $

chksum = [0 0 0 0];

for i=1:length(exportedFcnInfo)
    chksum = md5(chksum,exportedFcnInfo(i).name);
    for j=1:length(exportedFcnInfo(i).inputDataInfo)
        dataInfo = exportedFcnInfo(i).inputDataInfo(j);
        chksum = add_data_info_to_checksum(chksum,dataInfo);
    end
    for j=1:length(exportedFcnInfo(i).outputDataInfo)
        dataInfo = exportedFcnInfo(i).outputDataInfo(j);
        chksum = add_data_info_to_checksum(chksum,dataInfo);
    end
end

    
function chksum = add_data_info_to_checksum(chksum,dataInfo)
    chksum = md5(chksum...
                 ,dataInfo.type...
                 ,dataInfo.size...
                 ,dataInfo.bias...
                 ,dataInfo.slope...
                 ,dataInfo.exponent...
                 ,dataInfo.isSigned...
                 ,dataInfo.wordLength);
