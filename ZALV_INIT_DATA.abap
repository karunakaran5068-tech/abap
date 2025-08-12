*&---------------------------------------------------------------------*
*& Program: ZALV_INIT_DATA
*& Purpose: Initialize configuration table with sample data
*&---------------------------------------------------------------------*

REPORT zalv_init_data.

*----------------------------------------------------------------------*
* Data Declarations
*----------------------------------------------------------------------*

DATA: lt_config TYPE TABLE OF zalv_config,
      ls_config TYPE zalv_config.

*----------------------------------------------------------------------*
* Main Processing
*----------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM initialize_configuration.
  PERFORM display_results.

*----------------------------------------------------------------------*
* Forms
*----------------------------------------------------------------------*

FORM initialize_configuration.
  " Clear existing data
  DELETE FROM zalv_config.
  
  " MBLNR - Material Document Number
  ls_config-field_name = 'MBLNR'.
  ls_config-dropdown = ' '.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = 'X'.
  ls_config-sort_order = 1.
  ls_config-validation_rule = 'VALIDATE_MBLNR'.
  ls_config-data_source = 'MKPF'.
  ls_config-field_text = 'Material Document Number'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " MJAHR - Material Document Year
  ls_config-field_name = 'MJAHR'.
  ls_config-dropdown = ' '.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = ' '.
  ls_config-sort_order = 2.
  ls_config-validation_rule = 'VALIDATE_MJAHR'.
  ls_config-data_source = 'MKPF'.
  ls_config-field_text = 'Material Document Year'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " MBLPO - Material Document Item
  ls_config-field_name = 'MBLPO'.
  ls_config-dropdown = ' '.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = ' '.
  ls_config-sort_order = 3.
  ls_config-validation_rule = 'VALIDATE_MBLPO'.
  ls_config-data_source = 'MSEG'.
  ls_config-field_text = 'Material Document Item'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " MATNR - Material Number
  ls_config-field_name = 'MATNR'.
  ls_config-dropdown = ' '.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = 'X'.
  ls_config-sort_order = 4.
  ls_config-validation_rule = 'VALIDATE_MATNR'.
  ls_config-data_source = 'MSEG'.
  ls_config-field_text = 'Material Number'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " WERKS - Plant
  ls_config-field_name = 'WERKS'.
  ls_config-dropdown = 'X'.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = 'X'.
  ls_config-sort_order = 5.
  ls_config-validation_rule = 'VALIDATE_WERKS'.
  ls_config-data_source = 'MSEG'.
  ls_config-field_text = 'Plant'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " LGORT - Storage Location
  ls_config-field_name = 'LGORT'.
  ls_config-dropdown = 'X'.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = 'X'.
  ls_config-sort_order = 6.
  ls_config-validation_rule = 'VALIDATE_LGORT'.
  ls_config-data_source = 'MSEG'.
  ls_config-field_text = 'Storage Location'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " MENGE - Quantity
  ls_config-field_name = 'MENGE'.
  ls_config-dropdown = ' '.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = 'X'.
  ls_config-sort_order = 7.
  ls_config-validation_rule = 'VALIDATE_MENGE'.
  ls_config-data_source = 'MSEG'.
  ls_config-field_text = 'Quantity'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " MEINS - Unit of Measure
  ls_config-field_name = 'MEINS'.
  ls_config-dropdown = 'X'.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = 'X'.
  ls_config-sort_order = 8.
  ls_config-validation_rule = 'VALIDATE_MEINS'.
  ls_config-data_source = 'MSEG'.
  ls_config-field_text = 'Unit of Measure'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " BWART - Movement Type
  ls_config-field_name = 'BWART'.
  ls_config-dropdown = 'X'.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = 'X'.
  ls_config-sort_order = 9.
  ls_config-validation_rule = 'VALIDATE_BWART'.
  ls_config-data_source = 'MSEG'.
  ls_config-field_text = 'Movement Type'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " BUDAT - Posting Date
  ls_config-field_name = 'BUDAT'.
  ls_config-dropdown = ' '.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = 'X'.
  ls_config-mandatory = ' '.
  ls_config-sort_order = 10.
  ls_config-validation_rule = 'VALIDATE_BUDAT'.
  ls_config-data_source = 'MKPF'.
  ls_config-field_text = 'Posting Date'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " MAKTX - Material Description
  ls_config-field_name = 'MAKTX'.
  ls_config-dropdown = ' '.
  ls_config-checkbox = ' '.
  ls_config-enable = 'X'.
  ls_config-editable = ' '.
  ls_config-mandatory = ' '.
  ls_config-sort_order = 11.
  ls_config-validation_rule = ' '.
  ls_config-data_source = 'CUSTOM'.
  ls_config-field_text = 'Material Description'.
  ls_config-created_by = sy-uname.
  ls_config-created_date = sy-datum.
  ls_config-created_time = sy-uzeit.
  APPEND ls_config TO lt_config.
  
  " Insert all configuration records
  INSERT zalv_config FROM TABLE lt_config.
  
  IF sy-subrc = 0.
    MESSAGE 'Configuration data initialized successfully' TYPE 'S'.
  ELSE.
    MESSAGE 'Error initializing configuration data' TYPE 'E'.
  ENDIF.
ENDFORM.

FORM display_results.
  DATA: lv_count TYPE i.
  
  SELECT COUNT(*) FROM zalv_config INTO lv_count.
  
  WRITE: / 'Configuration Table Status:'.
  WRITE: / 'Total records:', lv_count.
  WRITE: /.
  WRITE: / 'Sample Configuration Records:'.
  WRITE: /.
  
  " Display sample records
  SELECT * FROM zalv_config
    ORDER BY sort_order
    INTO TABLE @DATA(lt_display)
    UP TO 5 ROWS.
  
  LOOP AT lt_display INTO DATA(ls_display).
    WRITE: / ls_display-field_name, 
             ls_display-field_text,
             ls_display-data_source,
             ls_display-sort_order.
  ENDLOOP.
  
  WRITE: /.
  WRITE: / 'To view all configuration records:'.
  WRITE: / '1. Execute transaction SM30'.
  WRITE: / '2. Enter table name: ZALV_CONFIG'.
  WRITE: / '3. Click Display or Change'.
ENDFORM.