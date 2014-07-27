load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"                    ; loading our libraries...
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
; --------------------------------------------------------------------------

;This script will make a plot with six panels: 1) historical data from obsv. 2) historical model output 3) RCP4.5 from all of the 21st century, 4) RCP4.5 from half the 21st century, 3) RCP8.5 from all of the 21st century, 4) RCP8.5 from half the 21st century.

;Historical observed data
    a=addfile("/Users/orris012/Data/OISST/awpsst.nc", "r")
    sst=(a->atlantmp)
    time=a->time
    yyyymm=cd_calendar(time,-1)
    annobsv=month_to_annual_weighted(yyyymm(1:288),sst(1:288,:,:),1)
;Weighted area avg
    rad    = 4.0*atan(1.0)/180.0
    lat=a->lat
    clat   = cos(lat*rad)
    clat!0="latitude"
    clat&latitude=lat

    histobsv=wgt_areaave_Wrap(annobsv,clat(:),1.0,0)

;Historical CNRM-CM5 model output
    b=addfile("/Users/orris012/Data/CNRM-CM5/historical/awpSST.nc", "r")
    histmod=b->sst(2:25)

;RCP4.5 long model output

;RCP4.5 short model output

;RCP8.5 long model output
    e=addfile("/Users/orris012/Data/CNRM-CM5/RCP8.5/awpSST2006_2100.nc","r")
    longrcp85=e->sst

;RCP8.5 short model output
    shortrcp85=longrcp85({2050:2100})


;printVarSummary(histobsvsst)
;printVarSummary(longrcp85)
;printVarSummary(shortrcp85)

;-----------------------------
;Data
;-----------------------------

;0, historic obsv
stddev0=dim_stddev_n_Wrap(histobsv,0)
    x0=ispan(1982,2005,1)
    data0=new((/4,dimsizes(x0)/),float)
    data0(0,:)=histobsv
reg0=regline(x0,histobsv)
    data0(1,:)=reg0*x0+reg0@yintercept
    data0(2,:)=data0(1,:)+stddev0
    data0(3,:)=data0(1,:)-stddev0

;1, historic model output
stddev1=dim_stddev_n_Wrap(histmod,0)
    x1=ispan(1982,2005,1)
    data1=new((/4,dimsizes(x1)/),float)
    data1(0,:)=histmod
reg1=regline(x1,histmod)
    data1(1,:)=reg1*x1+reg1@yintercept
    data1(2,:)=data1(1,:)+stddev1
    data1(3,:)=data1(1,:)-stddev1
;2, longrcp4.5
;3, shortrcp4.5
;4, longrcp8.5
stddev4=dim_stddev_n_Wrap(longrcp85,0)
    x4=ispan(2006,2100,1)
    data4=new((/4,dimsizes(x4)/),float)
    data4(0,:)=longrcp85
reg4=regline(x4,longrcp85)
    data4(1,:)=reg4*x4+reg4@yintercept
    data4(2,:)=data4(1,:)+stddev4
    data4(3,:)=data4(1,:)-stddev4

;5, shortrcp8.5
stddev5=dim_stddev_n_Wrap(shortrcp85,0)
    x5=ispan(2050,2100,1)
    data5=new((/4,dimsizes(x5)/),float)
    data5(0,:)=shortrcp85
reg5=regline(x5,shortrcp85)
    data5(1,:)=reg5*x5+reg5@yintercept
    data5(2,:)=data5(1,:)+stddev5
    data5(3,:)=data5(1,:)-stddev5

;-----------------------------
;Plotting
;-----------------------------

wks=gsn_open_wks("pdf","CNRMawpsst")
res=True

res@gsnDraw=False
res@gsnFrame=False

pnlres=True
pnlres@txString="Time Series of Atlantic Warming Pool SST"
plots=new(6,graphic)

;Plot 1
    res@gsnPaperOrientation = "auto"
    res@gsnMaximize=True
    res@tiMainString="Average Annual AWP Sea Surface Temperature 1982-2013, OISST"
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

labels =(/"   One std. dev. from Mean","   Annual SST Regression","   Average Annual Sea Surface Temperature"/)
nitems = dimsizes(labels)                

amres                  = True
    amres@amJust           = "TopRight"    ; Use bottom right corner of box
; for determining its location, where (0,0) is center of plot
  amres@amParallelPosF   = -0.09              ; Move legend to right
  amres@amOrthogonalPosF = -0.5              ; Move legend down

; Create legend
    lbid = gsn_create_legend(wks,nitems,labels,lgres)
;make plot
    plots(0)=gsn_csm_xy(wks,x0,data0,res)
;add legend to plot
   annoid = gsn_add_annotation(plots(0),lbid,amres)
       
tres  =  True
tres@txFontHeightF = 0.01
gsn_text(wks,plots(0),"y=0.017x-7.36",2002,25.5,tres)

;pdfres=True
;maximize_output(wks,pdfres)



;Plot 2
    res@gsnPaperOrientation = "auto"
    res@gsnMaximize=True
    res@tiMainString="Average Annual AWP Sea Surface Temperature 1982-2013, CNRM-CM5"
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

labels =(/"   One std. dev. from Mean","   Annual SST Regression","   Average Annual Sea Surface Temperature"/)
nitems = dimsizes(labels)                

amres                  = True
    amres@amJust           = "TopRight"    ; Use bottom right corner of box
; for determining its location, where (0,0) is center of plot
  amres@amParallelPosF   = -0.09              ; Move legend to right
  amres@amOrthogonalPosF = -0.5              ; Move legend down

; Create legend
    lbid = gsn_create_legend(wks,nitems,labels,lgres)
;make plot
    plots(1)=gsn_csm_xy(wks,x1,data1,res)
;add legend to plot
   annoid = gsn_add_annotation(plots(1),lbid,amres)
       
tres  =  True
tres@txFontHeightF = 0.01
gsn_text(wks,plots(1),"y=0.017x-7.36",2002,25.5,tres)

;pdfres=True
;maximize_output(wks,pdfres)


;Plot 3
;Plot 4


;Plot 5
    res@gsnPaperOrientation = "auto"
    res@gsnMaximize=True
    res@tiMainString="Average Annual AWP Sea Surface Temperature 2006-2100, CNRM-CM5, RCP8.5"
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

labels =(/"   One std. dev. from Mean","   Annual SST Regression","   Average Annual Sea Surface Temperature"/)
nitems = dimsizes(labels)                

amres                  = True
    amres@amJust           = "TopRight"    ; Use bottom right corner of box
; for determining its location, where (0,0) is center of plot
  amres@amParallelPosF   = -0.09              ; Move legend to right
  amres@amOrthogonalPosF = -0.5              ; Move legend down

; Create legend
    lbid = gsn_create_legend(wks,nitems,labels,lgres)
;make plot
    plots(4)=gsn_csm_xy(wks,x4,data4,res)
;add legend to plot
   annoid = gsn_add_annotation(plots(4),lbid,amres)
       
tres  =  True
tres@txFontHeightF = 0.01
gsn_text(wks,plots(4),"y=0.017x-7.36",2002,25.5,tres)

;pdfres=True
;maximize_output(wks,pdfres)




;Plot 6
    res@gsnPaperOrientation = "auto"
    res@gsnMaximize=True
    res@tiMainString="Average Annual AWP Sea Surface Temperature 2050-2100, CNRM-CM5, RCP8.5"
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

labels =(/"   One std. dev. from Mean","   Annual SST Regression","   Average Annual Sea Surface Temperature"/)
nitems = dimsizes(labels)                

amres                  = True
    amres@amJust           = "TopRight"    ; Use bottom right corner of box
; for determining its location, where (0,0) is center of plot
  amres@amParallelPosF   = -0.09              ; Move legend to right
  amres@amOrthogonalPosF = -0.5              ; Move legend down

; Create legend
    lbid = gsn_create_legend(wks,nitems,labels,lgres)
;make plot
    plots(5)=gsn_csm_xy(wks,x5,data5,res)
;add legend to plot
   annoid = gsn_add_annotation(plots(5),lbid,amres)
       
tres  =  True
tres@txFontHeightF = 0.01
gsn_text(wks,plots(5),"y=0.017x-7.36",2002,25.5,tres)

;pdfres=True
;maximize_output(wks,pdfres)



gsn_panel(wks,(/plots/),(/2,3/),pnlres)     ; the command that puts the panels on the page together (/rows,columns/)

