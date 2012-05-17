function highCtx = chart_simctx_raw2high(hSFcn, rawCtx, ctxInfo)

chart = get_param(hSFcn, 'parent');
highCtx = Stateflow.SimState.BlockSimState.computeSimStateInfo(chart, rawCtx, ctxInfo);
