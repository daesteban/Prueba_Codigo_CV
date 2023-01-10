clear all
cls

*****************************************************************
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2017\630-Modulo1560\a2017_CAP_01"
global input2 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2017\630-Modulo1570\a2017_s11_fD2"
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
*****************************************************************

cd "$intermedios"
import dbase "$input1\a2017_CAP_01",clear
gen ubigeo2 = CCDD + CCPP + CCDI
encode ubigeo2, gen(ubigeo) //encodificar el ubigeo
destring  FACTOR_EXP, replace //convertir el factor a numerico
drop COD* ubigeo2
gen ciiu2 = real(substr(CIIU,1,2)) //codigo a 2 digitos
**drop if ciiu2<10 | ciiu2>33 //solo manufactura
save EmpresasManufactura_2017,replace
sort IRUC NROESTABLE


//numero de empresas por industria 
egen id=group(IRUC NROESTABLE)
collapse (count) id [pw=FACTOR_EXP], by(ciiu2 ubigeo)
rename id CantidadEmpresas
save EmpresasManufacturaConteoDist_2017,replace 
*****************************************************************

**MANUFACTURA D2 2017
import dbase "$input2\a2017_s11_fD2_c00_1",clear
rename T07 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaD2_2017,replace

*****************************************************************
**PRODUCCION D2 2017
import dbase "$input2\a2017_s11_fD2_c10AE_2",clear
rename P03 produccion2017A //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2017A, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2017A,replace


import dbase "$input2\a2017_s11_fD2_c10BE_2",clear
rename P03 produccion2017B //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001" 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2017B, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2017B,replace


import dbase "$input2\a2017_s11_fD2_c10CE_2",clear
rename P03 produccion2017C //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2017C, by(iruc2 estable) 
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2017C,replace

use produccionD2_2017A,clear
merge 1:1 IRUC NROESTABLE using produccionD2_2017B, nogenerate
merge 1:1 IRUC NROESTABLE using produccionD2_2017C, nogenerate
egen produccion2017 = rowtotal(produccion2017A produccion2017B produccion2017C)
save produccionD2_2017,replace

*****************************************************************
**TRABAJADORES D2 2017
import dbase "$input2\a2017_s11_fD2_c11_1",clear
save trabajadoresD2_2017,replace


import dbase "$input2\a2017_s11_fD2_c08BE_2",clear
append using trabajadoresD2_2017 
drop if CLAVE=="006"
rename P01 trabajadoresD2_2017
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable 
order IRUC  NROESTABLE
drop if NROESTABLE=="000"
save trabajadoresD2_2017,replace

*****************************************************************
**CAPITAL D2 2017

*capital
import dbase "$input2\a2017_s11_fD2_c05_1",clear
save capitalD2_2017,replace

import dbase "$input2\a2017_s11_fD2_c05E_2",clear
append using capitalD2_2017 
sort IRUC NROESTABLE CLAVE
keep if  CLAVE == "014" 
rename P07 capitalD2_2017
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save capitalD2_2017,replace


/*
*depreciacion
import dbase "$input2\a2017_s11_fD2_c06_1",clear
save depreciacionD2_2017,replace

import dbase "$inputs\ENCUESTA ECONOMICA ANUAL\2019\630-Modulo1570\a2017_s11_fD2\a2017_s11_fD2_c06E_2",clear
append using depreciacionD2_2017
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "009" | CLAVE == "016" | CLAVE == "017" | CLAVE == "020"
rename P07 depreciacionD2_2017
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save depreciacionD2_2017,replace
*/

*capital neto
use capitalD2_2017,clear
rename capitalD2_2017 capitalnetoD2_2017
*merge 1:1 IRUC NROESTABLE using depreciacionD2_2017,nogenerate
*gen capitalnetoD2_2017 = capitalD2_2017 - depreciacionD2_2017 
drop if NROESTABLE=="000"
order IRUC  
save capitalnetoD2_2017,replace

*****************************************************************
**MATERIAL
*materia prima
import dbase "$input2\a2017_s11_fD2_c09AE_2",clear
keep if CLAVE == "001" 
rename P11 MateriaPrimaD2_2017
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
destring MateriaPrimaD2_2017,replace
collapse (sum) MateriaPrimaD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MateriaPrimaD2_2017,replace

*envases
import dbase "$input2\a2017_s11_fD2_c09BE_2",clear
keep if CLAVE == "001" 
rename P11 EnvasesD2_2017
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) EnvasesD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save EnvasesD2_2017,replace

*combustibles
import dbase "$input2\a2017_s11_fD2_c09CE_2",clear
keep if CLAVE == "001" 
rename P11 CombustiblesD2_2017
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) CombustiblesD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save CombustiblesD2_2017,replace

*repuestos
import dbase "$input2\a2017_s11_fD2_c09DE_2",clear
keep if CLAVE == "001" 
rename P11 RepuestosD2_2017
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) RepuestosD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save RepuestosD2_2017,replace

*otros
import dbase "$input2\a2017_s11_fD2_c09EE_2",clear
keep if CLAVE == "001" 
rename P11 OtrosInsumosD2_2017
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) OtrosInsumosD2_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save OtrosInsumosD2_2017,replace


use MateriaPrimaD2_2017,clear
merge 1:1 IRUC NROESTABLE using EnvasesD2_2017,nogenerate
merge 1:1 IRUC NROESTABLE using CombustiblesD2_2017,nogenerate
merge 1:1 IRUC NROESTABLE using RepuestosD2_2017,nogenerate
merge 1:1 IRUC NROESTABLE using OtrosInsumosD2_2017,nogenerate
egen MaterialesTotalD2_2017 = rowtotal(MateriaPrimaD2_2017 EnvasesD2_2017 CombustiblesD2_2017 RepuestosD2_2017 OtrosInsumosD2_2017)
save MaterialesTotalD2_2017, replace

*****************************************************************
//FIN 