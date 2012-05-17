function rawCtx = chart_simctx_high2raw(hSFcn, highCtx, ctxInfo)

parent = get_param(hSFcn, 'parent');
rawCtx = Stateflow.SimState.BlockSimState.getRawCtxFromSimStateInfo(highCtx, ctxInfo);
