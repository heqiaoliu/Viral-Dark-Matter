function errorsOccurred = construct_chart_ir_for_rtw(chart, hChart)

    display_chart_codegen_message(chart);
    try
        compute_chart_information(chart);
        errorsOccurred = construct_module(chart, hChart);
    catch ME
        construct_coder_error(chart,ME.message,1);
        errorsOccurred = true;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_chart_codegen_message(chart)
   chartFullName = sf('FullNameOf',chart,'/');
   chartShortName = chartFullName(find(chartFullName=='/', 1, 'last' )+1:end);
   msgString = sprintf('\nConstruct IR for Chart "%s" (#%d):\n',chartShortName,chart);
   sf('Private','sf_display','Coder',msgString);
