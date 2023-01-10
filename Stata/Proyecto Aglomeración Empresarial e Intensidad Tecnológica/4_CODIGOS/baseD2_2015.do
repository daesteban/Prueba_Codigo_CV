clear all
cls
*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"

global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2015\552-Modulo1094"
global input2 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2015\552-Modulo1104\a2015_s11_fD2"
*****************************************************************

cd "$intermedios"
import dbase "$input1\a2015_CAP_01",clear
gen ubigeo2 = CCDD + CCPP + CCDI
encode ubigeo2, gen(ubigeo) //encodificar el ubigeo
destring  FACTOR_EXP, replace //convertir el factor a numerico
drop COD* ubigeo2
gen ciiu2 = real(substr(CIIU,1,2)) //codigo a 2 digitos
**drop if ciiu2<10 | ciiu2>33 //solo manufactura
save EmpresasManufactura_2015,replace
sort IRUC NROESTABLE


//numero de empresas por industria 
egen id=group(IRUC NROESTABLE)
collapse (count) id [pw=FACTOR_EXP], by(ciiu2 ubigeo)
rename id CantidadEmpresas
save EmpresasManufacturaConteoDist_2015,replace 

*****************************************************************

**MANUFACTURA D2 2015

import dbase "$input2\a2015_s11_fD2_c00_1",clear
rename T07 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaD2_2015,replace

*****************************************************************

**PRODUCCION D2 2015
import dbase "$input2\a2015_s11_fD2_c10AE_2",clear
rename P03 produccion2015A //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2015A, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2015A,replace


import dbase "$input2\a2015_s11_fD2_c10BE_2",clear
rename P03 produccion2015B //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001" 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
destring produccion2015B,replace
collapse (sum) produccion2015B, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2015B,replace


import dbase "$input2\a2015_s11_fD2_c10CE_2",clear
rename P03 produccion2015C //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2015C, by(iruc2 estable) 
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2015C,replace

//Juntar bases de datos de produccion D2 2015
use produccionD2_2015A,clear
merge 1:1 IRUC NROESTABLE using produccionD2_2015B, nogenerate
merge 1:1 IRUC NROESTABLE using produccionD2_2015C, nogenerate
egen produccion2015 = rowtotal(produccion2015A produccion2015B produccion2015C) //suma del valor total de produccion
save produccionD2_2015,replace

*****************************************************************
**TRABAJADORES D2 2015
import dbase "$input2\a2015_s11_fD2_c11_1",clear
save trabajadoresD2_2015,replace


import dbase "$input2\a2015_s11_fD2_c08BE_2",clear
append using trabajadoresD2_2015 
drop if CLAVE=="006"
rename P01 trabajadoresD2_2015
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable 
order IRUC  NROESTABLE
drop if NROESTABLE=="000"
save trabajadoresD2_2015,replace


*****************************************************************
**CAPITAL D2 2015

*capital
import dbase "$input2\a2015_s11_fD2_c05_1",clear
save capitalD2_2015,replace

import dbase "$input2\a2015_s11_fD2_c05E_2",clear
append using capitalD2_2015 
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "003" | CLAVE == "004" | CLAVE == "005" | CLAVE == "006" | CLAVE == "007" | CLAVE == "008" | CLAVE == "009" | CLAVE == "010" | CLAVE == "002"
rename P07 capitalD2_2015
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save capitalD2_2015,replace

/*
*depreciacion
import dbase "$input2\a2015_s11_fD2_c06_1",clear
save depreciacionD2_2015,replace

import dbase "$input2\a2015_s11_fD2_c06E_2",clear
append using depreciacionD2_2015
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "007" | CLAVE == "002" | CLAVE == "003" | CLAVE == "004" 
rename P05 depreciacionD2_2015
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save depreciacionD2_2015,replace
*/

*capital neto
use capitalD2_2015,clear
rename capitalD2_2015 capitalnetoD2_2015
*merge 1:1 IRUC NROESTABLE using depreciacionD2_2015,nogenerate
*gen capitalnetoD2_2015 = capitalD2_2015 - depreciacionD2_2015 
drop if NROESTABLE=="000"
order IRUC  
save capitalnetoD2_2015,replace

*****************************************************************
**MATERIAL
*materia prima
import dbase "$input2\a2015_s11_fD2_c09AE_2",clear
keep if CLAVE == "001" 
rename P11 MateriaPrimaD2_2015
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
destring MateriaPrimaD2_2015,replace
collapse (sum) MateriaPrimaD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MateriaPrimaD2_2015,replace

*envases
import dbase "$input2\a2015_s11_fD2_c09BE_2",clear
keep if CLAVE == "001" 
rename P11 EnvasesD2_2015
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) EnvasesD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save EnvasesD2_2015,replace

*combustibles
import dbase "$input2\a2015_s11_fD2_c09CE_2",clear
keep if CLAVE == "001" 
rename P11 CombustiblesD2_2015
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) CombustiblesD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save CombustiblesD2_2015,replace

*repuestos
import dbase "$input2\a2015_s11_fD2_c09DE_2",clear
keep if CLAVE == "001" 
rename P11 RepuestosD2_2015
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) RepuestosD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save RepuestosD2_2015,replace

*otros
import dbase "$input2\a2015_s11_fD2_c09EE_2",clear
keep if CLAVE == "001" 
rename P11 OtrosInsumosD2_2015
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) OtrosInsumosD2_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save OtrosInsumosD2_2015,replace


use MateriaPrimaD2_2015,clear
merge 1:1 IRUC NROESTABLE using EnvasesD2_2015,nogenerate
merge 1:1 IRUC NROESTABLE using CombustiblesD2_2015,nogenerate
merge 1:1 IRUC NROESTABLE using RepuestosD2_2015,nogenerate
merge 1:1 IRUC NROESTABLE using OtrosInsumosD2_2015,nogenerate
egen MaterialesTotalD2_2015 = rowtotal(MateriaPrimaD2_2015 EnvasesD2_2015 CombustiblesD2_2015 RepuestosD2_2015 OtrosInsumosD2_2015) //suma de todos los materiales
save MaterialesTotalD2_2015, replace

*****************************************************************
//FIN 