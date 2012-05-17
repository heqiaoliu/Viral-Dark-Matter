function out = dataVersionLessThanR2008b(sldvData)
    out = Sldv.DataUtils.dataVersionLessThan(sldvData,'1.3');
end