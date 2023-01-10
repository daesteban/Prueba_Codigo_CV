clear all
cls

global inputs "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\1_INPUTS"
global intermedios "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\2_INTERMEDIOS"
global output "G:\Mi unidad\1_CURSOS\1_PUCP\2022-0\TEMAS DE ECONOMIA 1 (ECONOMIA URBANA)\PROYECTO FINAL - ECONOMIA URBANA\AVANCES\PARTE EMPIRICA\2_DATA\3_OUTPUTS"

cd "$intermedios"

use EmpresasManufacturaD2_2014,clear
merge 1:m IRUC  using produccionD2_2014,nogenerate
merge 1:m IRUC NROESTABLE using trabajadoresD2_2014,nogenerate
merge 1:m IRUC NROESTABLE using MaterialesTotalD2_2014,nogenerate
merge 1:m IRUC NROESTABLE using capitalnetoD2_2014,nogenerate

rename trabajadoresD2_2014 trabajadores_2014
rename MaterialesTotalD2_2014 MaterialesTotal_2014
rename capitalnetoD2_2014 capitalneto_2014
drop COD* produccion2014A-produccion2014C MateriaPrimaD2_2014-OtrosInsumosD2_2014 //capitalD2_2014 depreciacionD2_2014
*rename FACTOR FACTOR_EXP
save baseD2_2014,replace

////////////////////////////
*SEPARAR EN OTRO CODIGO
*juntar bases de datos 2014
use baseD2_2014,clear
append using baseM_2014
*destring  FACTOR_EXP, replace
gen ciiu2 = real(substr(ciiu,1,2)) //codigo a 2 digitos
//drop if ciiu2<10 | ciiu2>33
joinby IRUC NROESTABLE using EmpresasManufactura_2014
joinby ubigeo ciiu2 using EmpresasManufacturaConteoDist_2014
sort IRUC NROESTABLE 
gen year=2014
order year

rename produccion2014 produccion
rename trabajadores_2014 trabajadores
rename MaterialesTotal_2014 MaterialesTotal
rename capitalneto_2014 capitalneto
rename FACTOR FACTOR_EXP
*regresion provisional


/*


gen logprod2014 = log(produccion2014) 
gen logtrabaj2014 = log(trabajadores_2014)
gen logcapital2014 =log(capitalneto_2014)
gen logmaterial2014 = log(MaterialesTotal_2014)
gen logCantidadEmpresas =log(CantidadEmpresas)
egen provincia = group(CCDD CCPP)
sort provincia


reghdfe logprod2014 logtrabaj2014 logcapital2014 logmaterial2014 logCantidadEmpresas , abs(ciiu2)
reghdfe logprod2014 logtrabaj2014 logcapital2014 logmaterial2014 logCantidadEmpresas , abs(ciiu2 ubigeo)
reghdfe logprod2014 logtrabaj2014 logcapital2014 logmaterial2014 logCantidadEmpresas , abs(ciiu2 provincia)
reghdfe logprod2014 logtrabaj2014 logcapital2014 logmaterial2014 logCantidadEmpresas , abs(ciiu2 CCDD)
reghdfe logprod2014 logtrabaj2014 logcapital2014 logmaterial2014 logCantidadEmpresas , abs(ciiu2 IRUC)
reghdfe logprod2014 logtrabaj2014 logcapital2014 logmaterial2014 logCantidadEmpresas , abs(ciiu2 IRUC ubigeo)

*/

save base_2014,replace
