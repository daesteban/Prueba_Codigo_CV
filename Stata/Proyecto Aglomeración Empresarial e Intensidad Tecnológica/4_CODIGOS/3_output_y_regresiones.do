**OUTPUT Y REGRESIONES
clear all
cls
**************************************************************
global inputs "D:\STATA LIMPIO\1_INPUTS"
global intermedios "D:\STATA LIMPIO\2_INTERMEDIOS"
global output "D:\STATA LIMPIO\3_OUTPUT"

cd "$output"
///////////////////////////////////////
**TABLAS
use basefinal,clear

drop if ciiu2==59 | ciiu2==58
summarize produccion, detail
keep if inrange(produccion, r(p1), r(p99))
summarize produccion, detail
gen IntensidadTecnologica = 1
replace IntensidadTecnologica = 2 if MediaAltaTec==1
replace IntensidadTecnologica = 3 if MediaBajaTec==1
replace IntensidadTecnologica = 4 if BajaTec==1
*tabla 2
tab2xl IntensidadTecnologica year using "tabla2",row(1) col(1) replace

tab CCDD year if ciiu2==31 //fabricacion muebles

*tabla 1
gen id = 1
tab2xl id year  using "tabla1",row(1) col(1) replace

preserve
*tabla 3
collapse (mean) produccion (mean) trabajadores (mean) capitalneto, by(year )
 export excel using "$intermedios/tabla3.xls", sheetmodify firstrow(variables)
 restore

*tabla 4
preserve
 collapse (sd) produccion (sd) trabajadores (sd) capitalneto, by(year )
 export excel using "$intermedios/tabla4.xls", sheetmodify firstrow(variables)
restore

///////////////////////////
**REGRESIONES
sort year ciiu2 IRUC
*ratio capital neto per capita
gen ratio1= capitalneto/trabajadores

sum ratio1
sum capitalneto

*variables en logs
gen logprod = log(produccion) 
gen logtrabaj = log(trabajadores)
gen logcapital =log(capitalneto)
gen logmaterial = log(MaterialesTotal)
gen logCantidadEmpresas =log(CantidadEmpresas)

*efecto fijo industria tendencia
egen IndustriaTiempo1 = group(CIIU year)
egen IndustriaTiempo2 = group(ciiu2 year)


////////////////////////////
cls
log using "D:\STATA LIMPIO\3_OUTPUT\regresiones.smcl"

**REGRESIONES PRINCIPALES
**a nivel de CIUU 4 digitos
*regresiones de todas las empresas
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas , abs(IndustriaTiempo1 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas , abs(IndustriaTiempo1 ubigeo) vce(robust)

*regresiones de todas las empresas de alta intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if AltaTec==1 , abs(IndustriaTiempo1 IRUC)  vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if AltaTec==1 , abs(IndustriaTiempo1 ubigeo) vce(robust)

*regresiones de todas las empresas de media alta intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaAltaTec==1 , abs(IndustriaTiempo1 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaAltaTec==1 , abs(IndustriaTiempo1 ubigeo) vce(robust)

*regresiones de todas las empresas de media baja intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaBajaTec==1 , abs(IndustriaTiempo1 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaBajaTec==1 , abs(IndustriaTiempo1 ubigeo) vce(robust)

*regresiones de todas las empresas de  baja intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==1 , abs(IndustriaTiempo1 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==1 , abs(IndustriaTiempo1 ubigeo) vce(robust)


*regresiones de todas las empresas de alta, media alta y media baja intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==0 , abs(IndustriaTiempo1 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==0 , abs(IndustriaTiempo1 ubigeo) vce(robust)
**************************************************************
**OTRAS REGRESIONES
**a nivel de CIUU 2 digitos
*regresiones de todas las empresas
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas , abs(IndustriaTiempo2 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas , abs(IndustriaTiempo2 ubigeo) vce(robust)

*regresiones de todas las empresas de alta intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if AltaTec==1 , abs(IndustriaTiempo2 IRUC)  vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if AltaTec==1 , abs(IndustriaTiempo2 ubigeo) vce(robust)

*regresiones de todas las empresas de media alta intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaAltaTec==1 , abs(IndustriaTiempo2 ) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaAltaTec==1 , abs(IndustriaTiempo2 ubigeo) vce(robust)

*regresiones de todas las empresas de media baja intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaBajaTec==1 , abs(IndustriaTiempo2 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if MediaBajaTec==1 , abs(IndustriaTiempo2 ubigeo) vce(robust)

*regresiones de todas las empresas de  baja intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==1 , abs(IndustriaTiempo2 IRUC) vce(robust)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==1 , abs(IndustriaTiempo2 ubigeo) vce(robust)


*regresiones de todas las empresas de alta, media alta y media baja intensidad tecnologica
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==0  , abs(IndustriaTiempo2  IRUC) vce(robust)
 
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==0 , abs(IndustriaTiempo2 ubigeo) vce(robust)
////////////////////////////////////////////
**EXPORTAR REGRESIONES
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas , abs(IndustriaTiempo2  ubigeo) vce(robust)
outreg2 using regresion.doc, replace ctitle(Model 1)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==0  , abs(IndustriaTiempo2  ubigeo) vce(robust)
outreg2 using regresion.doc, append ctitle(Model 2)
reghdfe logprod logtrabaj logcapital logmaterial logCantidadEmpresas if BajaTec==1 , abs(IndustriaTiempo2 ubigeo) vce(robust)
outreg2 using regresion.doc, append ctitle(Model 3)


log close
