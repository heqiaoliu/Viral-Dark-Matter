/*var anca_plate={A1:['PropionicAcid','0.3'],B1:['Glycine','0.3'],C1:['Citrate','0.3'],D1:['L-Alanine','0.3'],E1:['Thymidine','0.3'],F1:['Xylitol','0.3'],G1:['NegativeControl','0'],H1:['L-Histidine','0.3'],A2:['L-Glutamate','0.3'],B2:['NegativeControl','0'],C2:['D-Mannose','0.3'],D2:['L-Arabinose','0.3'],E2:['Sucrose','0.3'],F2:['L-Glutamine','0.3'],G2:['Tyramine','0.2'],H2:['Thymine','0.2'],A3:['D-Glucose','0.3'],B3:['QuinicAcid','0.3'],C3:['L-Serine','0.3'],D3:['L-Threonine','0.3'],E3:['D-Xylose','0.3'],F3:['L-Rhamnose','0.3'],G3:['Uridine','0.3'],H3:['L-Glutathione','0.2'],A4:['PotasiumSorbate','0.3'],B4:['SodiumSuccinate','0.3'],C4:['D-Salicin','0.3'],D4:['4Hydroxy-Phenylacetate','0.3'],E4:['L-Cysteine','0.3'],F4:['Putrescine','0.3'],G4:['Inosine','0.3'],H4:['Allantoin','0.2'],A5:['Lactulose','0.3'],B5:['Dulcitol','0.3'],C5:['D-Cellubiose','0.3'],D5:['D-Ribose','0.3'],E5:['Alpha-D-Lactose','0.3'],F5:['2-Deoxy-D-Ribose','0.3'],G5:['Histamine','0.3'],H5:['Adenine','0.2'],A6:['Glycerol','0.3'],B6:['Alpha-D-Glucose','0.3'],C6:['Adonitol','0.3'],D6:['Alpha-D-Melebiose','0.3'],E6:['D-Raffinose','0.3'],F6:['L-Arabitol','0.3'],G6:['L-Pyro-Glutamate','0.3'],H6:['Glycine','0.3'],A7:['Myo-Inositol','0.3'],B7:['L-Xylose','0.3'],C7:['D-Glucose-6-phosphate','0.3'],D7:['D-Alanine','0.3'],E7:['D-Asparagine','0.3'],F7:['D-Glucosamine','0.3'],G7:['Cytidine','0.3'],H7:['Beta-Phenylethylamine','0.3'],A8:['D-Serine','0.3'],B8:['L-Aspartate','0.2'],C8:['L-Sorbose','0.3'],D8:['L-Fucose','0.3'],E8:['i-Erythritol','0.3'],F8:['L-Phenylalanine','0.3'],G8:['Adenosine','0.2'],H8:['L-Proline','0.2'],A9:['D-Galactose','0.3'],B9:['D-Fructose','0.3'],C9:['D-Arabitol','0.3'],D9:['L-Asparagine','0.2'],E9:['D-Cysteine','0.3'],F9:['D-Glutamate','0.2'],G9:['L-Arginine','0.2'],H9:['D-Methionine','0.2'],A10:['Oxalate','0.2'],B10:['L-Valine','0.2'],C10:['L-Lysine','0.3'],D10:['L-Leucine','0.3'],E10:['L-Isoleucine','0.2'],F10:['D-Arabinose','0.3'],G10:['Thiourea','0.3'],H10:['Cytosine','0.2'],A11:['Malate','0.3'],B11:['SodiumPyruvate','0.3'],C11:['D-Trehalose','0.3'],D11:['D-Aspartate','0.2'],E11:['L-Cysteate','0.3'],F11:['L-Tryptophan','0.2'],G11:['Biuret','0.2'],H11:['D-Valine','0.2'],A12:['L-Methionine','0.2'],B12:['Lactate','0.3'],C12:['Acetate','0.3'],D12:['Inosine','0.3'],E12:['Adenosine','0.2'],F12:['L-Pyro-Glutamate','0.3'],G12:['Guanidine','0.3'],H12:['N-Acetyl-D-Glucosamine','0.2']};*/
function getWell(wellId){
    var bacteria_id="";
    var plate_id="";
    var info=""
    $("p.beid.focus").each(function(){
	bacteria_id=(this).getAttribute("bacteria_id");
    });
    $("td.plate.focus").each(function(){
	plate_id=(this).getAttribute("plate_id");
    });  
    var askingInfo="&type=wellinfo;&bacteria_id="+bacteria_id+";&plate_id="+plate_id+"; &well="+wellId+";";
    console.log(askingInfo);
    $.ajax({
        type:"POST",
        url:"viewsite/infoTrans.php",
        data: askingInfo,
        dataType: "json",
        success:function(dataObj,info){
    		htmlChange("p#infoBox",wellId+" is "+dataObj);
        }
    });
	return info;
}
