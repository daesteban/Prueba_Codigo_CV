clear all
cls
*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2014\393-Modulo445"
global input2 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2014\393-Modulo455\a2014_s11_fD2"
*****************************************************************

cd "$intermedios"
import dbase "$input1\a2014_CAP_01",clear
gen ubigeo2 = CCDD + CCPP + CCDI
encode ubigeo2, gen(ubigeo) //encodificar el ubigeo
destring  FACTOR, replace //convertir el factor a numerico
drop COD* ubigeo2
gen ciiu2 = real(substr(CIIU,1,2)) //codigo a 2 digitos
**drop if ciiu2<10 | ciiu2>33 //solo manufactura
save EmpresasManufactura_2014,replace
sort IRUC NROESTABLE


//numero de empresas por industria 
egen id=group(IRUC NROESTABLE)
collapse (count) id [pw=FACTOR], by(ciiu2 ubigeo)
rename id CantidadEmpresas
save EmpresasManufacturaConteoDist_2014,replace 

*****************************************************************

**MANUFACTURA D2 2014
import dbase "$input2\a2014_s11_fD2_c00_1",clear
rename T07 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
replace ciiu = substr(ciiu,1,2)
save EmpresasManufacturaD2_2014,replace

*****************************************************************
**PRODUCCION D2 2014
import dbase "$input2\a2014_s11_fD2_c10AE_2",clear
rename P03 produccion2014A //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2014A, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2014A,replace


import dbase "$input2\a2014_s11_fD2_c10BE_2",clear
rename P03 produccion2014B //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001" 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
destring produccion2014B,replace
collapse (sum) produccion2014B, by(iruc2 estable)
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2014B,replace


import dbase "$input2\a2014_s11_fD2_c10CE_2",clear
rename P03 produccion2014C //valor de la produccion debido a multiproducto
drop P* T* 
keep if CLAVE=="001"
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2014C, by(iruc2 estable) 
decode iruc2, gen(IRUC)
decode estable, gen(NROESTABLE) 
drop iruc2  estable
order IRUC NROESTABLE
save produccionD2_2014C,replace

//Juntar bases de datos de produccion D2 2014
use produccionD2_2014A,clear
merge 1:1 IRUC NROESTABLE using produccionD2_2014B, nogenerate
merge 1:1 IRUC NROESTABLE using produccionD2_2014C, nogenerate
egen produccion2014 = rowtotal(produccion2014A produccion2014B produccion2014C) //suma del valor total de produccion
save produccionD2_2014,replace

*****************************************************************
**TRABAJADORES D2 2014
import dbase "$input2\a2014_s11_fD2_c11_1",clear
save trabajadoresD2_2014,replace


import dbase "$input2\a2014_s11_fD2_c08BE_2",clear
append using trabajadoresD2_2014 

drop if CLAVE=="006"
rename P01 trabajadoresD2_2014
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable 
order IRUC  NROESTABLE
drop if NROESTABLE=="000"
save trabajadoresD2_2014,replace


*****************************************************************
**CAPITAL D2 2014

*capital
import dbase "$input2\a2014_s11_fD2_c05_1",clear
save capitalD2_2014,replace

import dbase "$input2\a2014_s11_fD2_c05E_2",clear
append using capitalD2_2014 
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "003" | CLAVE == "004" | CLAVE == "005" | CLAVE == "006" | CLAVE == "007" | CLAVE == "008" | CLAVE == "009" | CLAVE == "010" | CLAVE == "002"
rename P07 capitalD2_2014
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save capitalD2_2014,replace

/*
*depreciacion
import dbase "$lugar\a2014_s11_fD2_c06_1",clear
save depreciacionD2_2014,replace

import dbase "$lugar\a2014_s11_fD2_c06E_2",clear
append using depreciacionD2_2014
sort IRUC NROESTABLE CLAVE
keep if CLAVE == "007" | CLAVE == "002" | CLAVE == "003" | CLAVE == "004" 
rename P05 depreciacionD2_2014
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
drop if NROESTABLE=="000"
save depreciacionD2_2014,replace
*/


*capital neto
use capitalD2_2014,clear
rename capitalD2_2014 capitalnetoD2_2014
*merge 1:1 IRUC NROESTABLE using depreciacionD2_2014,nogenerate
*gen capitalnetoD2_2014 = capitalD2_2014 - depreciacionD2_2014 
drop if NROESTABLE=="000"
order IRUC  
save capitalnetoD2_2014,replace

*****************************************************************
**MATERIAL
*materia prima
import dbase "$input2\a2014_s11_fD2_c09AE_2",clear
keep if CLAVE == "001" 
rename P11 MateriaPrimaD2_2014
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
destring MateriaPrimaD2_2014,replace
collapse (sum) MateriaPrimaD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MateriaPrimaD2_2014,replace

*envases
import dbase "$input2\a2014_s11_fD2_c09BE_2",clear
keep if CLAVE == "001" 
rename P11 EnvasesD2_2014
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) EnvasesD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save EnvasesD2_2014,replace

*combustibles
import dbase "$input2\a2014_s11_fD2_c09CE_2",clear
keep if CLAVE == "001" 
rename P11 CombustiblesD2_2014
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) CombustiblesD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save CombustiblesD2_2014,replace

*repuestos
import dbase "$input2\a2014_s11_fD2_c09DE_2",clear
keep if CLAVE == "001" 
rename P11 RepuestosD2_2014
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) RepuestosD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save RepuestosD2_2014,replace

*otros
import dbase "$input2\a2014_s11_fD2_c09EE_2",clear
keep if CLAVE == "001" 
rename P11 OtrosInsumosD2_2014
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) OtrosInsumosD2_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save OtrosInsumosD2_2014,replace

*Juntamos los datos de MATERIAL D2 2014
use MateriaPrimaD2_2014,clear
merge 1:1 IRUC NROESTABLE using EnvasesD2_2014,nogenerate
merge 1:1 IRUC NROESTABLE using CombustiblesD2_2014,nogenerate
merge 1:1 IRUC NROESTABLE using RepuestosD2_2014,nogenerate
merge 1:1 IRUC NROESTABLE using OtrosInsumosD2_2014,nogenerate
egen MaterialesTotalD2_2014 = rowtotal(MateriaPrimaD2_2014 EnvasesD2_2014 CombustiblesD2_2014 RepuestosD2_2014 OtrosInsumosD2_2014) //suma de todos los materiales
save MaterialesTotalD2_2014, replace

*****************************************************************
//FIN 