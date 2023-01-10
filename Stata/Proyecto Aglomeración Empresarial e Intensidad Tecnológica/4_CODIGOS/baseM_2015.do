clear all
cls

*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2015\552-Modulo1113\a2015_s11_fM"
*****************************************************************

**MANUFACTURA M 2015

cd "$intermedios"

import dbase "$input1\a2015_s11_fM_c00_1",clear
rename T07 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaM_2015,replace

*****************************************************************
**PRODUCCION M 2015
import dbase "$input1\a2015_s11_fM_c02M_1",clear
rename P02 produccion2015 //valor de la produccion debido a multiproducto
drop P* T* 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE
save produccionM_2015,replace //& produccion M 2015


*****************************************************************

**TRABAJADORES M 2015
import dbase "$input1\a2015_s11_fM_c06MB_1",clear
drop if CLAVE=="006"
rename P01 trabajadoresM_2015
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresM_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save trabajadoresM_2015,replace //& trabajdores M 2015
 
*****************************************************************
**CAPITAL M 2015

*capital
import dbase "$input1\a2015_s11_fM_c07M_1",clear

sort IRUC NROESTABLE CLAVE
keep if CLAVE != "009" | CLAVE != "010" 
rename P06 capitalM_2015
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalM_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save capitalM_2015,replace

*depreciacion
/*
import dbase "$input1\a2015_s11_fM_c08M_1",clear
sort IRUC NROESTABLE CLAVE
keep if CLAVE != "005" |  CLAVE != "003" | CLAVE != "006" | CLAVE != "001"
rename P05 depreciacionM_2015
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionM_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save depreciacionM_2015,replace
*/

*capital neto
use capitalM_2015,clear
*merge 1:1 IRUC NROESTABLE using depreciacionM_2015,nogenerate
*gen capitalnetoM_2015 = capitalM_2015 - depreciacionM_2015
rename capitalM_2015 capitalnetoM_2015
save capitalnetoM_2015,replace
 //& capital M 2015
 
*****************************************************************
**MATERIAL
*materia prima
import dbase "$input1\a2015_s11_fM_c03M_1",clear
rename P02 MaterialesTotalM_2015
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) MaterialesTotalM_2015, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MaterialesTotalM_2015,replace //& Materiales M 2015

*****************************************************************
use EmpresasManufacturaM_2015,clear
merge 1:1 IRUC  using produccionM_2015,nogenerate
merge 1:1 IRUC NROESTABLE using MaterialesTotalM_2015,nogenerate
merge 1:1 IRUC NROESTABLE using capitalnetoM_2015,nogenerate
merge 1:1 IRUC NROESTABLE using trabajadoresM_2015,nogenerate

rename MaterialesTotalM_2015 MaterialesTotal_2015
rename capitalnetoM_2015 capitalneto_2015
rename trabajadoresM_2015 trabajadores_2015
drop COD* 

save baseM_2015,replace