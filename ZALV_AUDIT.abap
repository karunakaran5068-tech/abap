@EndUserText.label : 'ALV Audit Log Table'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zalv_audit {
  key client      : abap.clnt not null;
  key guid        : abap.raw(16) not null;
  key field_name  : abap.char(30) not null;
  key timestamp   : abap.timestampl not null;
  old_value       : abap.char(255);
  new_value       : abap.char(255);
  user_id         : abap.uname;
  action          : abap.char(10);
  record_guid     : abap.raw(16);

}