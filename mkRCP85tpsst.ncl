    ; loading our libraries...

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

    ;load global data file
files=systemfunc("ls /Volumes/data4/atmos/hardi091/CMIP5/RCP8.5/modeloutput/tos/tos_Omon_CNRM-CM5_rcp85_r1i1p1_*.nc")
allfiles=addfiles(files, "r")
    ;loading some of the global files, converting time to annual data
glblsst=allfiles[0:4]->tos
daysince=allfiles[0:4]->time
yyyymm=cd_calendar(daysince,-1)
annfutsst=month_to_annual_weighted(yyyymm(0:599),glblsst(0:599,:,:),1)
annfutsst!1="latitude"  ;j is lat
annfutsst!2="longitude" ;i is lon
annfutsst@missing_value=9E+20
annfutsst@_FillValue=9E+20

;printVarSummary(annfutsst)     ;annfutsst has annual data for the TP from the rcp8.5. where there is no sst data, value 0 is used

    ;make a new array to fill in for just the TP with ssts
futtp=new((/50,292,362/),float,9E+20)

copy_VarMeta(annfutsst,futtp)
printVarSummary(futtp)
    ;fill in futtp with ssts
        futtp(:,132:161,118:168)=where(annfutsst(:,132:161,118:168).ne.0,annfutsst(:,132:161,118:168),annfutsst@missing_value)
if(.not.all(ismissing(futtp))) then
  futtp = futtp - 273.15            ; change values
  futtp@units = "deg C"          ; update appropriate attribute
end if
fh=addfile("/Users/orris012/Data/OISST/RCP85tpsst.nc", "c")
fh->ssts=futtp               ; overwrite
