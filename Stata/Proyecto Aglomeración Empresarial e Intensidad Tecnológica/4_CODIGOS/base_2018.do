clear all
cls

global inputs "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\1_INPUTS"
global intermedios "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\2_INTERMEDIOS"
global output "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\3_OUTPUTS"

cd "$intermedios"

use EmpresasManufacturaD2_2018,clear
merge 1:m IRUC  using produccionD2_2018,nogenerate
merge 1:m IRUC NROESTABLE using trabajadoresD2_2018,nogenerate
merge 1:m IRUC NROESTABLE using MaterialesTotalD2_2018,nogenerate
merge 1:m IRUC NROESTABLE using capitalnetoD2_2018,nogenerate

rename trabajadoresD2_2018 trabajadores_2018
rename MaterialesTotalD2_2018 MaterialesTotal_2018
rename capitalnetoD2_2018 capitalneto_2018
drop COD* produccion2018A-produccion2018C MateriaPrimaD2_2018-OtrosInsumosD2_2018 //capitalD2_2018 depreciacionD2_2018
save baseD2_2018,replace

////////////////////////////
*SEPARAR EN OTRO CODIGO
*juntar bases de datos 2018
use baseD2_2018,clear
append using baseM_2018
destring  FACTOR_EXP, replace
gen ciiu2 = real(substr(ciiu,1,2)) //codigo a 2 digitos
//drop if ciiu2<10 | ciiu2>33
joinby IRUC NROESTABLE using EmpresasManufactura_2018
joinby ubigeo ciiu2 using EmpresasManufacturaConteoDist_2018
sort IRUC NROESTABLE 
gen year=2018
order year

rename produccion2018 produccion
rename trabajadores_2018 trabajadores
rename MaterialesTotal_2018 MaterialesTotal
rename capitalneto_2018 capitalneto
*regresion provisional


/*


gen logprod2018 = log(produccion2018) 
gen logtrabaj2018 = log(trabajadores_2018)
gen logcapital2018 =log(capitalneto_2018)
gen logmaterial2018 = log(MaterialesTotal_2018)
gen logCantidadEmpresas =log(CantidadEmpresas)
egen provincia = group(CCDD CCPP)
sort provincia


reghdfe logprod2018 logtrabaj2018 logcapital2018 logmaterial2018 logCantidadEmpresas , abs(ciiu2)
reghdfe logprod2018 logtrabaj2018 logcapital2018 logmaterial2018 logCantidadEmpresas , abs(ciiu2 ubigeo)
reghdfe logprod2018 logtrabaj2018 logcapital2018 logmaterial2018 logCantidadEmpresas , abs(ciiu2 provincia)
reghdfe logprod2018 logtrabaj2018 logcapital2018 logmaterial2018 logCantidadEmpresas , abs(ciiu2 CCDD)
reghdfe logprod2018 logtrabaj2018 logcapital2018 logmaterial2018 logCantidadEmpresas , abs(ciiu2 IRUC)
reghdfe logprod2018 logtrabaj2018 logcapital2018 logmaterial2018 logCantidadEmpresas , abs(ciiu2 IRUC ubigeo)


*/
save base_2018,replace
