function deploylog(level,msg)  
    import com.mathworks.toolbox.javabuilder.logging.*;
    existsVal = exist('MWLogger','class');
    if(existsVal == 8)
        logger = MWLogger.getLogger('com.mathworks.toolbox.javabuilder.webfigures');

        if(strcmp(level,'finer'))
            logger.finer(msg);
        elseif(strcmp(level,'finest'))
            logger.finest(msg);
        end
    end
end