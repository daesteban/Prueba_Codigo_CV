clear all
cls
*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2016\552-Modulo1135\a2016_s11_fM"
*****************************************************************
**MANUFACTURA M 2016
 
cd "$intermedios"

import dbase "$input1\a2016_s11_fM_c00_1",clear
rename T07 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaM_2016,replace

*****************************************************************
**PRODUCCION M 2016
import dbase "$input1\a2016_s11_fM_c02M_1",clear
rename P02 produccion2016 //valor de la produccion debido a multiproducto
drop P* T* 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE
save produccionM_2016,replace //& produccion M 2016

*****************************************************************

**TRABAJADORES M 2016
import dbase "$input1\a2016_s11_fM_c06MB_1",clear
drop if CLAVE=="006"
rename P01 trabajadoresM_2016
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresM_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save trabajadoresM_2016,replace //& trabajdores M 2016
*****************************************************************

**CAPITAL M 2016

*capital
import dbase "$input1\a2016_s11_fM_c07M_1",clear

sort IRUC NROESTABLE CLAVE
keep if CLAVE != "009" | CLAVE != "010" 
rename P06 capitalM_2016
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalM_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save capitalM_2016,replace

/*
*depreciacion
import dbase "$input1\a2016_s11_fM_c08M_1",clear
sort IRUC NROESTABLE CLAVE
keep if CLAVE != "005" |  CLAVE != "003" | CLAVE != "006" | CLAVE != "001"
rename P05 depreciacionM_2016
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionM_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save depreciacionM_2016,replace
*/

*capital neto
use capitalM_2016,clear
rename capitalM_2016 capitalnetoM_2016
*merge 1:1 IRUC NROESTABLE using depreciacionM_2016,nogenerate
*gen capitalnetoM_2016 = capitalM_2016 - depreciacionM_2016
save capitalnetoM_2016,replace
 //& capital M 2016
 
*****************************************************************
**MATERIAL
*materia prima
import dbase "$input1\a2016_s11_fM_c03M_1",clear
rename P02 MaterialesTotalM_2016
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) MaterialesTotalM_2016, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MaterialesTotalM_2016,replace //& Materiales M 2016

*****************************************************************
use EmpresasManufacturaM_2016,clear
merge 1:1 IRUC  using produccionM_2016,nogenerate
merge 1:1 IRUC NROESTABLE using MaterialesTotalM_2016,nogenerate
merge 1:1 IRUC NROESTABLE using capitalnetoM_2016,nogenerate
merge 1:1 IRUC NROESTABLE using trabajadoresM_2016,nogenerate

rename MaterialesTotalM_2016 MaterialesTotal_2016
rename capitalnetoM_2016 capitalneto_2016
rename trabajadoresM_2016 trabajadores_2016
drop COD* 

save baseM_2016,replace