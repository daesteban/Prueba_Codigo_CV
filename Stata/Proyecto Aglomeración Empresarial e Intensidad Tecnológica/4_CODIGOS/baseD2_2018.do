clear all
cls

*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2018\733-Modulo1592\a2018_CAP_01"
global input2 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2018\733-Modulo1602\a2018_s11_fD2"
*****************************************************************
**LOS DATOS ESTAN A NIVEL DE ESTABLECIMIENTOS
**LA EMPRESA ES LA QUE TIENE VALORES DE 
** FORMA JURIDICA Y REGIMEN DE PROPIEDAD

*****************************************************************

cd "$intermedios"
import dbase "$input1\a2018_CAP_01",clear
gen ubigeo2 = CCDD + CCPP + CCDI
encode ubigeo2, gen(ubigeo) //encodificar el ubigeo
destring  FACTOR_EXP, replace //convertir el factor a numerico
drop COD* ubigeo2
gen ciiu2 = real(substr(CIIU,1,2)) //codigo a 2 digitos
**drop if ciiu2<10 | ciiu2>33 //solo manufactura
save EmpresasManufactura_2018,replace
sort IRUC NROESTABLE


//numero de empresas por industria 
egen id=group(IRUC NROESTABLE)
collapse (count) id [pw=FACTOR_EXP], by(ciiu2 ubigeo)
rename id CantidadEmpresas
save EmpresasManufacturaConteoDist_2018,replace 
*****************************************************************

**MANUFACTURA D2 2018
import dbase "$input2\a2018_s11_fD2_c00_1",clear
rename T08 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaD2_2018,replace

*****************************************************************
**PRODUCCION D2 2018
import dbase "$input2\a2018_s11_fD2_c10AE_2",clear
rename P03 produccion2018A //valor de la produccion debido a multiproducto
keep if CLAVE=="001"
sort IRUC
drop P* T* 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2018A, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2018A,replace


import dbase "$input2\a2018_s11_fD2_c10BE_2",clear
rename P03 produccion2018B //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001" 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2018B, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2018B,replace

import dbase "$input2\a2018_s11_fD2_c10CE_2",clear
rename P03 produccion2018C //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2018C, by(iruc2 estable) 
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2018C,replace

use produccionD2_2018A,clear
merge 1:1 IRUC NROESTABLE using produccionD2_2018B, nogenerate
merge 1:1 IRUC NROESTABLE using produccionD2_2018C, nogenerate
egen produccion2018 = rowtotal(produccion2018A produccion2018B produccion2018C)
sum produccion2018
sort produccion2018
save produccionD2_2018,replace //& produccion D2 2018
*****************************************************************

**TRABAJADORES D2 2018
import dbase "$input2\a2018_s11_fD2_c11_1",clear
save trabajadoresD2_2018,replace

import dbase "$input2\a2018_s11_fD2_c08BE_2",clear
append using trabajadoresD2_2018 
drop if CLAVE=="006"
rename P01 trabajadoresD2_2018
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable 
order IRUC  NROESTABLE
drop if NROESTABLE=="000"
save trabajadoresD2_2018,replace 

*****************************************************************
**CAPITAL D2 2018

*capital
import dbase "$input2\a2018_s11_fD2_c05_1",clear
save capitalD2_2018,replace

import dbase "$input2\a2018_s11_fD2_c05E_2",clear
append using capitalD2_2018 
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "014" 
rename P07 capitalD2_2018
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save capitalD2_2018,replace



/*
*depreciacion
import dbase "$input2\a2018_s11_fD2_c06_1",clear
save depreciacionD2_2018,replace


import dbase "$input2\a2018_s11_fD2_c06E_2",clear
append using depreciacionD2_2018 
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "009" | CLAVE == "016" | CLAVE == "017" | CLAVE == "020"
rename P07 depreciacionD2_2018
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save depreciacionD2_2018,replace
*/

*capital neto
use capitalD2_2018,clear
rename capitalD2_2018 capitalnetoD2_2018
*merge 1:1 IRUC NROESTABLE using depreciacionD2_2018,nogenerate
*gen capitalnetoD2_2018 = capitalD2_2018 - depreciacionD2_2018 
drop if NROESTABLE=="000"
order IRUC  
save capitalnetoD2_2018,replace //& capital D2 2018

*****************************************************************
**MATERIAL
*materia prima
import dbase "$input2\a2018_s11_fD2_c09AE_2",clear
keep if CLAVE == "001" 
rename P11 MateriaPrimaD2_2018
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) MateriaPrimaD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MateriaPrimaD2_2018,replace

*envases
import dbase "$input2\a2018_s11_fD2_c09BE_2",clear
keep if CLAVE == "001" 
rename P11 EnvasesD2_2018
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) EnvasesD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save EnvasesD2_2018,replace

*combustibles
import dbase "$input2\a2018_s11_fD2_c09CE_2",clear
keep if CLAVE == "001" 
rename P11 CombustiblesD2_2018
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) CombustiblesD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save CombustiblesD2_2018,replace

*repuestos
import dbase "$input2\a2018_s11_fD2_c09DE_2",clear
keep if CLAVE == "001" 
rename P11 RepuestosD2_2018
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) RepuestosD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save RepuestosD2_2018,replace

*otros
import dbase "$input2\a2018_s11_fD2_c09EE_2",clear
keep if CLAVE == "001" 
rename P11 OtrosInsumosD2_2018
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) OtrosInsumosD2_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save OtrosInsumosD2_2018,replace


use MateriaPrimaD2_2018,clear
merge 1:1 IRUC NROESTABLE using EnvasesD2_2018,nogenerate
merge 1:1 IRUC NROESTABLE using CombustiblesD2_2018,nogenerate
merge 1:1 IRUC NROESTABLE using RepuestosD2_2018,nogenerate
merge 1:1 IRUC NROESTABLE using OtrosInsumosD2_2018,nogenerate
egen MaterialesTotalD2_2018 = rowtotal(MateriaPrimaD2_2018 EnvasesD2_2018 CombustiblesD2_2018 RepuestosD2_2018 OtrosInsumosD2_2018)
save MaterialesTotalD2_2018, replace //& Materiales D2 2018

*****************************************************************
//FIN 