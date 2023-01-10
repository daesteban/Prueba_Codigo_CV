clear all
cls
*****************************************************************
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"
global input1 "D:\STATA LIMPIO\1_INPUTS\ENCUESTA ECONOMICA ANUAL\2014\393-Modulo464\a2014_s11_fM"
*****************************************************************

**MANUFACTURA M 2014

cd "$intermedios"
import dbase "$input1\a2014_s11_fM_c00_1",clear
rename T07 ciiu
replace ciiu = substr(ciiu,1,4)
drop T* FLAGESTA* CLAVE NROESTABLE
save EmpresasManufacturaM_2014,replace

*****************************************************************
**PRODUCCION M 2014
import dbase "$input1\a2014_s11_fM_c02M_1",clear
rename P02 produccion2014 //valor de la produccion debido a multiproducto
drop P* T* 
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) produccion2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE
save produccionM_2014,replace //& produccion M 2014


*****************************************************************
**TRABAJADORES M 2014
import dbase "$input1\a2014_s11_fM_c06MB_1",clear
drop if CLAVE=="006"
rename P01 trabajadoresM_2014
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) trabajadoresM_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save trabajadoresM_2014,replace //& trabajdores M 2014

 
*****************************************************************

**CAPITAL M 2014

*capital
import dbase "$input1\a2014_s11_fM_c07M_1",clear

sort IRUC NROESTABLE CLAVE
keep if CLAVE != "009" | CLAVE != "010" 
rename P06 capitalM_2014
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) capitalM_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save capitalM_2014,replace

/*
*depreciacion
import dbase "$input1\a2014_s11_fM_c08M_1",clear
sort IRUC NROESTABLE CLAVE
keep if CLAVE != "005" |  CLAVE != "003" | CLAVE != "006" | CLAVE != "001"
rename P05 depreciacionM_2014
drop P* COD* FLAG*
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) depreciacionM_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save depreciacionM_2014,replace
*/ 
*capital neto
use capitalM_2014,clear
*merge 1:1 IRUC NROESTABLE using depreciacionM_2014,nogenerate
*gen capitalnetoM_2014 = capitalM_2014 - depreciacionM_2014
rename capitalM_2014 capitalnetoM_2014
save capitalnetoM_2014,replace
 //& capital M 2014
 
*****************************************************************
**MATERIAL
*materia prima
import dbase "$input1\a2014_s11_fM_c03M_1",clear
rename P02 MaterialesTotalM_2014
drop P* COD* FLAG* T* CLAVE
encode IRUC, gen(iruc2)
encode NROESTABLE, gen(estable)
collapse (sum) MaterialesTotalM_2014, by(iruc2 estable)
decode estable, gen(NROESTABLE) 
decode iruc2, gen(IRUC)
drop iruc2 estable
order IRUC NROESTABLE 
save MaterialesTotalM_2014,replace //& Materiales M 2014

*****************************************************************
use EmpresasManufacturaM_2014,clear
merge 1:1 IRUC  using produccionM_2014,nogenerate
merge 1:1 IRUC NROESTABLE using MaterialesTotalM_2014,nogenerate
merge 1:1 IRUC NROESTABLE using capitalnetoM_2014,nogenerate
merge 1:1 IRUC NROESTABLE using trabajadoresM_2014,nogenerate

rename MaterialesTotalM_2014 MaterialesTotal_2014
rename capitalnetoM_2014 capitalneto_2014
rename trabajadoresM_2014 trabajadores_2014
drop COD* 

save baseM_2014,replace
*****************************************************************