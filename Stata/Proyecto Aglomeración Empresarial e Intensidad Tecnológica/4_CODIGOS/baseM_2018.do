clear all
cls
*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2018\733-Modulo1611\a2018_s11fM"
*****************************************************************

**MANUFACTURA M 2018
*local  str1 "$inputs\ENCUESTA ECONOMICA ANUAL\2019\733-Modulo1611\a2018_s11_fM" 
cd "$intermedios"
import dbase "$input1\a2018_s11_fM_c00_1",clear
rename T08 ciiu
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaM_2018,replace

*****************************************************************
**PRODUCCION M 2018
import dbase "$input1\a2018_s11_fM_c02M_1",clear
rename P02 produccion2018 //valor de la produccion debido a multiproducto
drop P* T* 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE
save produccionM_2018,replace //& produccion M 2018
*****************************************************************

**TRABAJADORES M 2018
import dbase "$input1\a2018_s11_fM_c06MB_1",clear
drop if CLAVE=="006"
rename P01 trabajadoresM_2018
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresM_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save trabajadoresM_2018,replace //& trabajdores M 2018
*****************************************************************
**CAPITAL M 2018

*capital
import dbase "$input1\a2018_s11_fM_c07M_1",clear

sort IRUC NROESTABLE CLAVE
keep if CLAVE != "009" | CLAVE != "010" 
rename P06 capitalM_2018
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalM_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save capitalM_2018,replace

/*
*depreciacion
import dbase "$input1\a2018_s11_fM_c08M_1",clear
sort IRUC NROESTABLE CLAVE
keep if CLAVE != "005" |  CLAVE != "003" | CLAVE != "006"
rename P05 depreciacionM_2018
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionM_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save depreciacionM_2018,replace
*/


*capital neto
use capitalM_2018,clear
rename capitalM_2018 capitalnetoM_2018
*merge 1:1 IRUC NROESTABLE using depreciacionM_2018,nogenerate
*gen capitalnetoM_2018 = capitalM_2018 - depreciacionM_2018
save capitalnetoM_2018,replace
 //& capital M 2018

*****************************************************************
**MATERIAL
*materia prima
import dbase "$input1\a2018_s11_fM_c03M_1",clear
rename P02 MaterialesTotalM_2018
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) MaterialesTotalM_2018, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MaterialesTotalM_2018,replace //& Materiales M 2018

*****************************************************************
use EmpresasManufacturaM_2018,clear
merge 1:1 IRUC  using produccionM_2018,nogenerate
merge 1:1 IRUC NROESTABLE using MaterialesTotalM_2018,nogenerate
merge 1:1 IRUC NROESTABLE using capitalnetoM_2018,nogenerate
merge 1:1 IRUC NROESTABLE using trabajadoresM_2018,nogenerate

rename MaterialesTotalM_2018 MaterialesTotal_2018
rename capitalnetoM_2018 capitalneto_2018
rename trabajadoresM_2018 trabajadores_2018
drop COD* 

save baseM_2018,replace

*****************************************************************