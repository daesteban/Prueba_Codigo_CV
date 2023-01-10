clear all
cls

global inputs "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\1_INPUTS"
global intermedios "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\2_INTERMEDIOS"
global output "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\3_OUTPUTS"

cd "$intermedios"

use EmpresasManufacturaD2_2017,clear
merge 1:m IRUC  using produccionD2_2017,nogenerate
merge 1:m IRUC NROESTABLE using trabajadoresD2_2017,nogenerate
merge 1:m IRUC NROESTABLE using MaterialesTotalD2_2017,nogenerate
merge 1:m IRUC NROESTABLE using capitalnetoD2_2017,nogenerate

rename trabajadoresD2_2017 trabajadores_2017
rename MaterialesTotalD2_2017 MaterialesTotal_2017
rename capitalnetoD2_2017 capitalneto_2017
drop COD* produccion2017A-produccion2017C MateriaPrimaD2_2017-OtrosInsumosD2_2017 //capitalD2_2017 depreciacionD2_2017
save baseD2_2017,replace

////////////////////////////
*SEPARAR EN OTRO CODIGO
*juntar bases de datos 2017
use baseD2_2017,clear
append using baseM_2017
destring  FACTOR_EXP, replace
gen ciiu2 = real(substr(ciiu,1,2)) //codigo a 2 digitos
//drop if ciiu2<10 | ciiu2>33
joinby IRUC NROESTABLE using EmpresasManufactura_2017
joinby ubigeo ciiu2 using EmpresasManufacturaConteoDist_2017
sort IRUC NROESTABLE 
gen year=2017
order year

rename produccion2017 produccion
rename trabajadores_2017 trabajadores
rename MaterialesTotal_2017 MaterialesTotal
rename capitalneto_2017 capitalneto

*regresion provisional


/*


gen logprod2017 = log(produccion2017) 
gen logtrabaj2017 = log(trabajadores_2017)
gen logcapital2017 =log(capitalneto_2017)
gen logmaterial2017 = log(MaterialesTotal_2017)
gen logCantidadEmpresas =log(CantidadEmpresas)
egen provincia = group(CCDD CCPP)
sort provincia


reghdfe logprod2017 logtrabaj2017 logcapital2017 logmaterial2017 logCantidadEmpresas , abs(ciiu2)
reghdfe logprod2017 logtrabaj2017 logcapital2017 logmaterial2017 logCantidadEmpresas , abs(ciiu2 ubigeo)
reghdfe logprod2017 logtrabaj2017 logcapital2017 logmaterial2017 logCantidadEmpresas , abs(ciiu2 provincia)
reghdfe logprod2017 logtrabaj2017 logcapital2017 logmaterial2017 logCantidadEmpresas , abs(ciiu2 CCDD)
reghdfe logprod2017 logtrabaj2017 logcapital2017 logmaterial2017 logCantidadEmpresas , abs(ciiu2 IRUC)
reghdfe logprod2017 logtrabaj2017 logcapital2017 logmaterial2017 logCantidadEmpresas , abs(ciiu2 IRUC ubigeo)

*/

save base_2017,replace
