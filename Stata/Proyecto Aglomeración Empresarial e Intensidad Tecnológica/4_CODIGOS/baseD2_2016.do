clear all
cls
*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"

global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2016\552-Modulo1116\a2016_CAP_01"
global input2 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2016\552-Modulo1126\a2016_s11_fD2"
*****************************************************************
cd "$intermedios"
import dbase "$input1\a2016_CAP_01",clear
gen ubigeo2 = CCDD + CCPP + CCDI
encode ubigeo2, gen(ubigeo) //encodificar el ubigeo
destring  FACTOR_EXP, replace //convertir el factor a numerico
drop COD* ubigeo2
gen ciiu2 = real(substr(CIIU,1,2)) //codigo a 2 digitos
**drop if ciiu2<10 | ciiu2>33 //solo manufactura
save EmpresasManufactura_2016,replace
sort IRUC NROESTABLE


//numero de empresas por industria 
egen id=group(IRUC NROESTABLE)
collapse (count) id [pw=FACTOR_EXP], by(ciiu2 ubigeo)
rename id CantidadEmpresas
save EmpresasManufacturaConteoDist_2016,replace 

*****************************************************************

**MANUFACTURA D2 2016
import dbase "$input2\a2016_s11_fD2_c00_1",clear
rename T07 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaD2_2016,replace

*****************************************************************
**PRODUCCION D2 2016
import dbase "$input2\a2016_s11_fD2_c10AE_2",clear
rename P03 produccion2016A //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2016A, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2016A,replace


import dbase "$input2\a2016_s11_fD2_c10BE_2",clear
rename P03 produccion2016B //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001" 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
destring produccion2016B,replace
collapse (sum) produccion2016B, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2016B,replace


import dbase "$input2\a2016_s11_fD2_c10CE_2",clear
rename P03 produccion2016C //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2016C, by(iruc2 estable) 
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2016C,replace

use produccionD2_2016A,clear
merge 1:1 IRUC NROESTABLE using produccionD2_2016B, nogenerate
merge 1:1 IRUC NROESTABLE using produccionD2_2016C, nogenerate
egen produccion2016 = rowtotal(produccion2016A produccion2016B produccion2016C)
save produccionD2_2016,replace

*****************************************************************
**TRABAJADORES D2 2016
import dbase "$input2\a2016_s11_fD2_c11_1",clear
save trabajadoresD2_2016,replace


import dbase "$input2\a2016_s11_fD2_c08BE_2",clear
append using trabajadoresD2_2016 
drop if CLAVE=="006"
rename P01 trabajadoresD2_2016
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable 
order IRUC  NROESTABLE
drop if NROESTABLE=="000"
save trabajadoresD2_2016,replace


*****************************************************************
**CAPITAL D2 2016

*capital
import dbase "$input2\a2016_s11_fD2_c05_1",clear
save capitalD2_2016,replace

import dbase "$input2\a2016_s11_fD2_c05E_2",clear
append using capitalD2_2016 
sort IRUC NROESTABLE CLAVE
keep if  CLAVE == "014" 
rename P07 capitalD2_2016
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save capitalD2_2016,replace

/*
*depreciacion
import dbase "$input2\a2016_s11_fD2_c06_1",clear
save depreciacionD2_2016,replace

import dbase "$input2\a2016_s11_fD2_c06E_2",clear
append using depreciacionD2_2016
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "010" | CLAVE == "011" | CLAVE == "012" | CLAVE == "013" | CLAVE == "014" | CLAVE == "015"| CLAVE == "019"
rename P07 depreciacionD2_2016
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save depreciacionD2_2016,replace
*/

*capital neto
use capitalD2_2016,clear
rename capitalD2_2016 capitalnetoD2_2016
*merge 1:1 IRUC NROESTABLE using depreciacionD2_2016,nogenerate
*gen capitalnetoD2_2016 = capitalD2_2016 - depreciacionD2_2016 
drop if NROESTABLE=="000"
order IRUC  
save capitalnetoD2_2016,replace

*****************************************************************
**MATERIAL
*materia prima
import dbase "$input2\a2016_s11_fD2_c09AE_2",clear
keep if CLAVE == "001" 
rename P11 MateriaPrimaD2_2016
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
destring MateriaPrimaD2_2016,replace
collapse (sum) MateriaPrimaD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MateriaPrimaD2_2016,replace

*envases
import dbase "$input2\a2016_s11_fD2_c09BE_2",clear
keep if CLAVE == "001" 
rename P11 EnvasesD2_2016
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) EnvasesD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save EnvasesD2_2016,replace

*combustibles
import dbase "$input2\a2016_s11_fD2_c09CE_2",clear
keep if CLAVE == "001" 
rename P11 CombustiblesD2_2016
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) CombustiblesD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save CombustiblesD2_2016,replace

*repuestos
import dbase "$input2\a2016_s11_fD2_c09DE_2",clear
keep if CLAVE == "001" 
rename P11 RepuestosD2_2016
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) RepuestosD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save RepuestosD2_2016,replace

*otros
import dbase "$input2\a2016_s11_fD2_c09EE_2",clear
keep if CLAVE == "001" 
rename P11 OtrosInsumosD2_2016
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) OtrosInsumosD2_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save OtrosInsumosD2_2016,replace


use MateriaPrimaD2_2016,clear
merge 1:1 IRUC NROESTABLE using EnvasesD2_2016,nogenerate
merge 1:1 IRUC NROESTABLE using CombustiblesD2_2016,nogenerate
merge 1:1 IRUC NROESTABLE using RepuestosD2_2016,nogenerate
merge 1:1 IRUC NROESTABLE using OtrosInsumosD2_2016,nogenerate
egen MaterialesTotalD2_2016 = rowtotal(MateriaPrimaD2_2016 EnvasesD2_2016 CombustiblesD2_2016 RepuestosD2_2016 OtrosInsumosD2_2016)
save MaterialesTotalD2_2016, replace

*****************************************************************
//FIN 