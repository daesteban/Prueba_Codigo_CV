clear all
cls
**************************************************************
global inputs "D:\STATA LIMPIO\1_INPUTS"
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"

cd "$intermedios"
**************************************************************
//Juntando las bases de datos por año. Luego se junta todo en un solo año.
***************2014-2015
forvalues i = 2014(1)2015 {
use EmpresasManufacturaD2_`i',clear
merge 1:m IRUC  using produccionD2_`i',nogenerate
merge 1:m IRUC NROESTABLE using trabajadoresD2_`i',nogenerate
merge 1:m IRUC NROESTABLE using MaterialesTotalD2_`i',nogenerate
merge 1:m IRUC NROESTABLE using capitalnetoD2_`i',nogenerate

rename trabajadoresD2_`i' trabajadores_`i'
rename MaterialesTotalD2_`i' MaterialesTotal_`i'
rename capitalnetoD2_`i' capitalneto_`i'
drop COD* produccion`i'A-produccion`i'C MateriaPrimaD2_`i'-OtrosInsumosD2_`i' //capitalD2_`i' depreciacionD2_`i'
drop FACTO*
save baseD2_`i',replace

////////////////////////////
*SEPARAR EN OTRA BASE
*juntar bases de datos del año
use baseD2_`i',clear
append using baseM_`i'
*destring  FACTOR_EXP, replace
gen ciiu2 = real(substr(ciiu,1,2)) //codigo a 2 digitos
//drop if ciiu2<10 | ciiu2>33
joinby IRUC NROESTABLE using EmpresasManufactura_`i'
joinby ubigeo ciiu2 using EmpresasManufacturaConteoDist_`i'
sort IRUC NROESTABLE 
gen year=`i'
order year

rename produccion`i' produccion
rename trabajadores_`i' trabajadores
rename MaterialesTotal_`i' MaterialesTotal
rename capitalneto_`i' capitalneto
*rename FACTOR FACTOR_EXP

save base_`i',replace

}
*************2016-2018

forvalues i = 2016(1)2018 {
use EmpresasManufacturaD2_`i',clear
merge 1:m IRUC  using produccionD2_`i',nogenerate
merge 1:m IRUC NROESTABLE using trabajadoresD2_`i',nogenerate
merge 1:m IRUC NROESTABLE using MaterialesTotalD2_`i',nogenerate
merge 1:m IRUC NROESTABLE using capitalnetoD2_`i',nogenerate

rename trabajadoresD2_`i' trabajadores_`i'
rename MaterialesTotalD2_`i' MaterialesTotal_`i'
rename capitalnetoD2_`i' capitalneto_`i'
drop COD* produccion`i'A-produccion`i'C MateriaPrimaD2_`i'-OtrosInsumosD2_`i' //capitalD2_`i' depreciacionD2_`i'
*drop FACTO*
save baseD2_`i',replace

////////////////////////////
*SEPARAR EN OTRA BASE
*juntar bases de datos del año
use baseD2_`i',clear
append using baseM_`i'
*destring  FACTOR_EXP, replace
gen ciiu2 = real(substr(ciiu,1,2)) //codigo a 2 digitos
//drop if ciiu2<10 | ciiu2>33
joinby IRUC NROESTABLE using EmpresasManufactura_`i'
joinby ubigeo ciiu2 using EmpresasManufacturaConteoDist_`i'
sort IRUC NROESTABLE 
gen year=`i'
order year

rename produccion`i' produccion
rename trabajadores_`i' trabajadores
rename MaterialesTotal_`i' MaterialesTotal
rename capitalneto_`i' capitalneto
*rename FACTOR FACTOR_EXP

save base_`i',replace

}

*****************************************************************
//Juntamos todos las bases de datos intermedios.
cd "$intermedios"

use base_2014,clear
drop FACTO*
save base_2014,replace

use base_2015,clear
drop FACTO*
save base_2015,replace

use base_2016,clear
drop FACTO*
save base_2016,replace

use base_2017,clear
drop FACTO*
save base_2017,replace

use base_2018,clear
drop FACTO*
save base_2018,replace


use base_2014,clear
append using base_2015
append using base_2018
append using base_2016
append using base_2017

drop ciiu

cd "$output"
save basefinal,replace

/////////////////////////////////////////////
import excel "$inputs\ciiu4IntensidadTecnologica.xlsx", sheet("Hoja2") firstrow clear
merge 1:m ciiu2 using basefinal,nogenerate
sort year ciiu2 IRUC
drop if IRUC==""
order year IRUC NROESTABLE CCDD CCPP CCDI CIIU FECANIVERS ubigeo  produccion trabajadores MaterialesTotal capitalneto CantidadEmpresas
/////////////////////////////////////////////
**AGREGAMOS LABELS
label variable year "year"
label variable IRUC "RUC - codigo identificador de empresa"
label variable NROESTABLE "numero de establecimiento de la empresa"
label variable ubigeo "codigo de ubigeo - codigo identificador por distrito"
label variable produccion "produccion total durante un año medida en soles"
label variable trabajadores "numero de trabajadores por establecimiento"
label variable MaterialesTotal "Materiales consumido en la produccion de un establecimiento en un año, medido en unidades monetarias"
label variable capitalneto "Capital descontado de depreciacion de una empresa en un año, medido en unidades monetarias"
label variable CantidadEmpresas "numero de empresa de la misma industria (CIIU 2 DIGITOS) en cada distrito"
label variable AltaTec "dummy de establecimiento del sector con alta intensidad tecnologica"
label variable MediaAltaTec "dummy de establecimiento del sector con media alta intensidad tecnologica"
label variable MediaBajaTec "dummy de establecimiento del sector con media baja intensidad tecnologica"
label variable BajaTec "dummy de establecimiento del sector con baja intensidad tecnologica"
label variable CIIU "codigo CIIU a 4 digitos"
label variable ciiu2 "codigo CIIU a 2 digitos"
/////////////////////////////////////////////

save basefinal,replace