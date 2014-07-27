load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"                    ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

a=addfiles("", "r")
    ;loading some of the global files, converting K to C, time to annual data
glblsst=a[:]->sst
printVarSummary(glblsst)
exit
glblsst=glblsst-273.15
glblsst@units="deg C"

daysince=allfiles[0:9]->time
yyyymm=cd_calendar(daysince,-1)
annfutsst=month_to_annual_weighted(yyyymm(0:1139),glblsst(0:1139,:,:),1)
annfutsst!1="latitude"  ;j is lat
annfutsst!2="longitude" ;i is lon

    ;make a new array to fill in for just the TP with ssts
futrcp45=new((/95,292,362/),float,1e+20)
copy_VarMeta(annfutsst,futrcp45)

    ;fill in longrcp45 with ssts
        futrcp45(:,132:161,118:168)=where(annfutsst(:,132:161,118:168).ne.0,annfutsst(:,132:161,118:168),annfutsst@_FillValue)
        
        
    ;Weighted area avgs
rad= 4.0*atan(1.0)/180.0
lat=fspan(0,179,292)
clat= cos(lat*rad)
clat!0="latitude"
clat&latitude=lat
    
avgannfutsst=wgt_areaave_Wrap(futrcp45,clat,1.0,0)
printVarSummary(avgannfutsst)
fh=addfile("/Users/orris012/Data/CNRM-CM5/RCP4.5/tpSST2006_2100.nc", "c")
fh->sst=avgannfutsst