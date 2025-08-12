@EndUserText.label : 'ALV Data Storage Table'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zalv_data {
  key client      : abap.clnt not null;
  key guid        : abap.raw(16) not null;
  mblnr           : abap.char(10);
  mjahr           : abap.numc(4);
  mblpo           : abap.numc(4);
  matnr           : abap.char(18);
  werks           : abap.char(4);
  lgort           : abap.char(4);
  menge           : abap.quan(13,3);
  meins           : abap.unit(3);
  bwart           : abap.char(3);
  budat           : abap.date;
  maktx           : abap.char(40);
  created_by      : abap.uname;
  created_date    : abap.date;
  created_time    : abap.time;
  changed_by      : abap.uname;
  changed_date    : abap.date;
  changed_time    : abap.time;

}