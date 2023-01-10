clear all
cls

global inputs "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\1_INPUTS"
global intermedios "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\2_INTERMEDIOS"
global output "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\3_OUTPUTS"

cd "$intermedios"

use EmpresasManufacturaD2_2016,clear
merge 1:m IRUC  using produccionD2_2016,nogenerate
merge 1:m IRUC NROESTABLE using trabajadoresD2_2016,nogenerate
merge 1:m IRUC NROESTABLE using MaterialesTotalD2_2016,nogenerate
merge 1:m IRUC NROESTABLE using capitalnetoD2_2016,nogenerate

rename trabajadoresD2_2016 trabajadores_2016
rename MaterialesTotalD2_2016 MaterialesTotal_2016
rename capitalnetoD2_2016 capitalneto_2016
drop COD* produccion2016A-produccion2016C MateriaPrimaD2_2016-OtrosInsumosD2_2016 //capitalD2_2016 depreciacionD2_2016
save baseD2_2016,replace

////////////////////////////
*SEPARAR EN OTRO CODIGO
*juntar bases de datos 2016
use baseD2_2016,clear
append using baseM_2016
*destring  FACTOR_EXP, replace
gen ciiu2 = real(substr(ciiu,1,2)) //codigo a 2 digitos
//drop if ciiu2<10 | ciiu2>33
joinby IRUC NROESTABLE using EmpresasManufactura_2016
joinby ubigeo ciiu2 using EmpresasManufacturaConteoDist_2016
sort IRUC NROESTABLE 
gen year=2016
order year

rename produccion2016 produccion
rename trabajadores_2016 trabajadores
rename MaterialesTotal_2016 MaterialesTotal
rename capitalneto_2016 capitalneto

*regresion provisional


/*


gen logprod2016 = log(produccion2016) 
gen logtrabaj2016 = log(trabajadores_2016)
gen logcapital2016 =log(capitalneto_2016)
gen logmaterial2016 = log(MaterialesTotal_2016)
gen logCantidadEmpresas =log(CantidadEmpresas)
egen provincia = group(CCDD CCPP)
sort provincia


reghdfe logprod2016 logtrabaj2016 logcapital2016 logmaterial2016 logCantidadEmpresas , abs(ciiu2)
reghdfe logprod2016 logtrabaj2016 logcapital2016 logmaterial2016 logCantidadEmpresas , abs(ciiu2 ubigeo)
reghdfe logprod2016 logtrabaj2016 logcapital2016 logmaterial2016 logCantidadEmpresas , abs(ciiu2 provincia)
reghdfe logprod2016 logtrabaj2016 logcapital2016 logmaterial2016 logCantidadEmpresas , abs(ciiu2 CCDD)
reghdfe logprod2016 logtrabaj2016 logcapital2016 logmaterial2016 logCantidadEmpresas , abs(ciiu2 IRUC)
reghdfe logprod2016 logtrabaj2016 logcapital2016 logmaterial2016 logCantidadEmpresas , abs(ciiu2 IRUC ubigeo)

*/

save base_2016,replace
