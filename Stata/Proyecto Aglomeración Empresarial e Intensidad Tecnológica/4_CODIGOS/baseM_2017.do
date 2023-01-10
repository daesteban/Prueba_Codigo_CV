clear all
cls
*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2017\630-Modulo1579\a2017_s11_fM"
*****************************************************************
**MANUFACTURA M 2017

cd "$intermedios"
import dbase "$input1\a2017_s11_fM_c00_1",clear
rename T07 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaM_2017,replace

*****************************************************************
**PRODUCCION M 2017
import dbase "$input1\a2017_s11_fM_c02M_1",clear
rename P02 produccion2017 //valor de la produccion debido a multiproducto
drop P* T* 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE
save produccionM_2017,replace //& produccion M 2017


*****************************************************************

**TRABAJADORES M 2017
import dbase "$input1\a2017_s11_fM_c06MB_1",clear
drop if CLAVE=="006"
rename P01 trabajadoresM_2017
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresM_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save trabajadoresM_2017,replace //& trabajdores M 2017

*****************************************************************

**CAPITAL M 2017

*capital
import dbase "$input1\a2017_s11_fM_c07M_1",clear

sort IRUC NROESTABLE CLAVE
keep if CLAVE != "009" | CLAVE != "010" 
rename P06 capitalM_2017
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalM_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save capitalM_2017,replace

/*
*depreciacion
import dbase "$input1\a2017_s11_fM_c08M_1",clear
sort IRUC NROESTABLE CLAVE
keep if CLAVE != "005" |  CLAVE != "003" | CLAVE != "006"
rename P05 depreciacionM_2017
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionM_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save depreciacionM_2017,replace
*/

*capital neto
use capitalM_2017,clear
rename capitalM_2017 capitalnetoM_2017
*merge 1:1 IRUC NROESTABLE using depreciacionM_2017,nogenerate
*gen capitalnetoM_2017 = capitalM_2017 - depreciacionM_2017
save capitalnetoM_2017,replace
 //& capital M 2017
 
*****************************************************************
**MATERIAL
*materia prima
import dbase "$input1\a2017_s11_fM_c03M_1",clear
rename P02 MaterialesTotalM_2017
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) MaterialesTotalM_2017, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MaterialesTotalM_2017,replace //& Materiales M 2017

*****************************************************************
use EmpresasManufacturaM_2017,clear
merge 1:1 IRUC  using produccionM_2017,nogenerate
merge 1:1 IRUC NROESTABLE using MaterialesTotalM_2017,nogenerate
merge 1:1 IRUC NROESTABLE using capitalnetoM_2017,nogenerate
merge 1:1 IRUC NROESTABLE using trabajadoresM_2017,nogenerate

rename MaterialesTotalM_2017 MaterialesTotal_2017
rename capitalnetoM_2017 capitalneto_2017
rename trabajadoresM_2017 trabajadores_2017
drop COD* 

save baseM_2017,replace
*****************************************************************