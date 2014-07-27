    ; loading our libraries...

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

a=addfile("/Users/orris012/Data/CNRM-CM5/RCP8.5/RCP85tpsst.nc", "r")
tpsst=(a->ssts)

    ; weighted area avgs
rad    = 4.0*atan(1.0)/180.0
lat=a->latitude
clat   = cos(lat*rad)
clat!0="latitude"
clat&latitude=lat

avrcp85tp=wgt_areaave_Wrap(tpsst,clat,1.0,0)  ; weighted averages for the region


sdrcp85tp=dim_stddev_n_Wrap(avrcp85tp,0)
;data
    x=ispan(2006,2055,1)
    data=new((/4,dimsizes(x)/),float)
    data(0,:)=avrcp85tp
rcp85tpreg=regline(x,avrcp85tp)
    data(1,:)=rcp85tpreg*x+rcp85tpreg@yintercept
    data(2,:)=data(1,:)+sdrcp85tp
    data(3,:)=data(1,:)-sdrcp85tp
print(rcp85tpreg)
;plotting

wks=gsn_open_wks("pdf", "TimSerRCP85TPsst")
res=True
res@gsnFrame    = False
res@gsnDraw     = False

    res@gsnPaperOrientation = "auto"
    res@gsnMaximize=True
    res@tiMainString="Average Annual ENSO Sea Surface Temperature 2006-2055, CNRM-CM5"
    res@tiMainFontHeightF = 0.015
    res@tmXTOn=False
    res@tmYROn=False
    res@xyLineColors =(/"black","red","blue","blue"/)
    res@tiYAxisString="Degrees (C)"
    res@tiXAxisString="Year"
    res@trYMaxF=29.0
    res@trYMinF=24.0
    res@vpWidthF=1.0
    res@xyDashPatterns    = 0                         ; choose dash patterns

;Set up resources for a customized legend.

  lgres                    = True
  lgres@lgLineColors       = (/"blue","red","black"/)
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .6            ; legend label font thickness
  lgres@vpWidthF           = 0.18           ; width of legend (NDC)
  lgres@vpHeightF          = 0.12           ; height of legend (NDC)
  lgres@lgPerimOn          = False
  lgres@lgMonoDashIndex    = True
  lgres@lgMonoMarkerThickness = True
  lgres@legMarkerThicknessF = 1.5
  lgres@lgDashIndex        = 0

labels =(/"   One std. dev. from Mean","   Annual SST Regression","   Average Annual SST"/)
nitems = dimsizes(labels)                

amres                  = True
    amres@amJust           = "TopRight"    ; Use bottom right corner of box
; for determining its location, where (0,0) is center of plot
  amres@amParallelPosF   = -0.24              ; Move legend to right
  amres@amOrthogonalPosF = -0.5              ; Move legend down

; Create legend
    lbid = gsn_create_legend(wks,nitems,labels,lgres)
;make plot
    plot=gsn_csm_xy(wks,x,data,res)
;add legend to plot
   annoid = gsn_add_annotation(plot,lbid,amres)
       
tres  =  True
tres@txFontHeightF = 0.02
gsn_text(wks,plot,"y=0.02x-14.24",2040,25.,tres)


    pdfres=True
    maximize_output(wks,pdfres)
