    ; loading our libraries...

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

a=addfile("/Users/orris012/Data/OISST/sst.mnmean.nc", "r")
b=addfile("/Users/orris012/Data/OISST/awpsstbinary.nc", "r")

ssts=short2flt(a->sst)
ssts@_FillValue=0.
ssts = ssts(:,::-1,:)
ocean=b->ocean
copy_VarMeta(ssts,ocean)
printVarSummary(ssts)
printVarSummary(ocean)



awpssts=where(ocean.ne.0,ssts,ssts@_FillValue)
copy_VarMeta(ssts,awpssts)
printVarSummary(awpssts)

c=addfile("/Users/orris012/Data/OISST/awpsst.nc", "c")
c->atlantmp = awpssts
