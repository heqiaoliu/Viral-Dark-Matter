function [hiddenneurons, countation, ANNname, datastring] = GetCountationNameAndData(totalcount)
    if totalcount < 61
        hiddenneurons = 40
    end
    if totalcount >= 61
        hiddenneurons = 10
    end


    
    if totalcount/111 >= 1
        derpcount = totalcount - 110;
        if derpcount/10 <= 1
            ANNname = 'ANN_LambdaRatio_TAIL_United';
            datastring = 'LambdaRatio_tail_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/101 >= 1
        derpcount = totalcount - 100;
        if derpcount/10 <= 1
            ANNname = 'ANN_SevenToOneRatio_TAIL_United';
            datastring = 'SevenToOneRatio_tail_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/91 >= 1
        derpcount = totalcount - 90;
        if derpcount/10 <= 1
            ANNname = 'ANN_FourToOneRatio_TAIL_United';
            datastring = 'FourToOneRatio_tail_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/81 >= 1
        derpcount = totalcount - 80;
        if derpcount/10 <= 1
            ANNname = 'ANN_ThreeToOneRatio_TAIL_United';
            datastring = 'ThreeToOneRatio_tail_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/71 >= 1
        derpcount = totalcount - 70;
        if derpcount/10 <= 1
            ANNname = 'ANN_TwoToOneRatio_TAIL_United';
            datastring = 'TwoToOneRatio_tail_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/61 >= 1
        derpcount = totalcount - 60;
        if derpcount/10 <= 1
            ANNname = 'ANN_OneToOneRatio_TAIL_United';
            datastring = 'OneToOneRatio_tail_pct';
            countation = derpcount;
        end
    end
    

    
    if totalcount/51 >= 1
        derpcount = totalcount - 50;
        if derpcount/10 <= 1
            ANNname = 'ANN_LambdaRatio_MCP_United';
            datastring = 'LambdaRatio_mcp_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/41 >= 1
        derpcount = totalcount - 40;
        if derpcount/10 <= 1
            ANNname = 'ANN_SevenToOneRatio_MCP_United';
            datastring = 'SevenToOneRatio_mcp_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/31 >= 1
        derpcount = totalcount - 30;
        if derpcount/10 <= 1
            ANNname = 'ANN_FourToOneRatio_MCP_United';
            datastring = 'FourToOneRatio_mcp_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/21 >= 1
        derpcount = totalcount - 20;
        if derpcount/10 <= 1
            ANNname = 'ANN_ThreeToOneRatio_MCP_United';
            datastring = 'ThreeToOneRatio_mcp_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/11 >= 1
        derpcount = totalcount - 10;
        if derpcount/10 <= 1
            ANNname = 'ANN_TwoToOneRatio_MCP_United';
            datastring = 'TwoToOneRatio_mcp_pct';
            countation = derpcount;
        end
    end
    
    if totalcount/1 >= 1
        derpcount = totalcount - 0;
        if derpcount/10 <= 1
            ANNname = 'ANN_OneToOneRatio_MCP_United';
            datastring = 'OneToOneRatio_mcp_pct';
            countation = derpcount;
        end
    end
    
    
    
    
    
    
    
    
    
    
    
end



