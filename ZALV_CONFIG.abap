@EndUserText.label : 'ALV Configuration Table'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zalv_config {
  key client      : abap.clnt not null;
  key field_name  : abap.char(30) not null;
  dropdown        : abap.char(1);
  checkbox        : abap.char(1);
  enable          : abap.char(1);
  editable        : abap.char(1);
  mandatory       : abap.char(1);
  sort_order      : abap.int4;
  validation_rule : abap.char(30);
  data_source     : abap.char(10);
  field_text      : abap.char(60);
  created_by      : abap.uname;
  created_date    : abap.date;
  created_time    : abap.time;
  changed_by      : abap.uname;
  changed_date    : abap.date;
  changed_time    : abap.time;

}