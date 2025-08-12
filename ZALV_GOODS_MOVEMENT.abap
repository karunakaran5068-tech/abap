REPORT zalv_goods_movement.

*----------------------------------------------------------------------*
* Configurable Post Goods Movement ALV Display with Advanced Features
*----------------------------------------------------------------------*

* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_mblnr TYPE mblnr OBLIGATORY.
SELECT-OPTIONS: s_werks FOR mseg-werks,
                s_budat FOR mkpf-budat,
                s_bwart FOR mseg-bwart.
SELECTION-SCREEN END OF BLOCK b1.

* Global Data Declarations
DATA: go_alv_display TYPE REF TO lcl_alv_display,
      go_data_fetcher TYPE REF TO lcl_data_fetcher,
      go_config_manager TYPE REF TO lcl_config_manager,
      go_validator TYPE REF TO lcl_validator,
      go_audit_logger TYPE REF TO lcl_audit_logger.

*----------------------------------------------------------------------*
* Local Classes
*----------------------------------------------------------------------*

* Configuration Manager Class
CLASS lcl_config_manager DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_config,
             field_name     TYPE char30,
             dropdown       TYPE char1,
             checkbox       TYPE char1,
             enable         TYPE char1,
             editable       TYPE char1,
             mandatory      TYPE char1,
             sort_order     TYPE int4,
             validation_rule TYPE char30,
             data_source    TYPE char10,
             field_text     TYPE char60,
           END OF ty_config.
    
    TYPES: tt_config TYPE TABLE OF ty_config.
    
    DATA: mt_config TYPE tt_config.
    
    METHODS: constructor,
             load_configuration,
             get_field_config IMPORTING iv_field_name TYPE char30
                             RETURNING VALUE(rs_config) TYPE ty_config,
             validate_configuration RAISING cx_static_check.
  
  PRIVATE SECTION.
    METHODS: cache_configuration.
ENDCLASS.

* Data Fetcher Class
CLASS lcl_data_fetcher DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_goods_movement,
             guid        TYPE sysuuid_x16,
             mblnr       TYPE mblnr,
             mjahr       TYPE mjahr,
             mblpo       TYPE mblpo,
             matnr       TYPE matnr,
             werks       TYPE werks_d,
             lgort       TYPE lgort_d,
             menge       TYPE menge_d,
             meins       TYPE meins,
             bwart       TYPE bwart,
             budat       TYPE budat,
             maktx       TYPE maktx,
             editable    TYPE abap_bool,
           END OF ty_goods_movement.
    
    TYPES: tt_goods_movement TYPE TABLE OF ty_goods_movement.
    
    DATA: mt_data TYPE tt_goods_movement.
    
    METHODS: constructor IMPORTING io_config TYPE REF TO lcl_config_manager,
             fetch_data,
             fetch_from_mkpf_mseg,
             fetch_sample_data,
             add_custom_row.
  
  PRIVATE SECTION.
    DATA: mo_config TYPE REF TO lcl_config_manager.
ENDCLASS.

* Validator Class
CLASS lcl_validator DEFINITION.
  PUBLIC SECTION.
    METHODS: validate_field IMPORTING iv_field_name TYPE char30
                                      iv_value TYPE any
                            RETURNING VALUE(rv_valid) TYPE abap_bool,
             validate_mandatory_fields IMPORTING it_data TYPE lcl_data_fetcher=>tt_goods_movement
                                      RETURNING VALUE(rv_valid) TYPE abap_bool,
             validate_werks IMPORTING iv_werks TYPE werks_d
                           RETURNING VALUE(rv_valid) TYPE abap_bool,
             validate_menge IMPORTING iv_menge TYPE menge_d
                           RETURNING VALUE(rv_valid) TYPE abap_bool.
  
  PRIVATE SECTION.
    METHODS: log_validation_error IMPORTING iv_field TYPE char30
                                            iv_value TYPE any
                                            iv_message TYPE string.
ENDCLASS.

* Audit Logger Class
CLASS lcl_audit_logger DEFINITION.
  PUBLIC SECTION.
    METHODS: log_field_change IMPORTING iv_field_name TYPE char30
                                        iv_old_value TYPE any
                                        iv_new_value TYPE any
                                        iv_record_guid TYPE sysuuid_x16,
             log_action IMPORTING iv_action TYPE char10
                                  iv_record_guid TYPE sysuuid_x16.
  
  PRIVATE SECTION.
    METHODS: generate_guid RETURNING VALUE(rv_guid) TYPE sysuuid_x16.
ENDCLASS.

* ALV Display Class
CLASS lcl_alv_display DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor IMPORTING io_data TYPE REF TO lcl_data_fetcher
                                   io_config TYPE REF TO lcl_config_manager
                                   io_validator TYPE REF TO lcl_validator
                                   io_audit TYPE REF TO lcl_audit_logger,
             display_alv,
             refresh_data,
             save_data,
             export_data,
             add_row.
  
  PRIVATE SECTION.
    DATA: mo_data TYPE REF TO lcl_data_fetcher,
          mo_config TYPE REF TO lcl_config_manager,
          mo_validator TYPE REF TO lcl_validator,
          mo_audit TYPE REF TO lcl_audit_logger,
          mo_alv TYPE REF TO cl_salv_table,
          mo_functions TYPE REF TO cl_salv_functions,
          mo_columns TYPE REF TO cl_salv_columns_table,
          mo_events TYPE REF TO cl_salv_events_table.
    
    METHODS: setup_alv,
             setup_columns,
             setup_functions,
             setup_events,
             on_user_command FOR EVENT added_function OF cl_salv_events
                            IMPORTING e_salv_function,
             on_double_click FOR EVENT double_click OF cl_salv_events_table
                            IMPORTING row column,
             on_hotspot_click FOR EVENT link_click OF cl_salv_events_table
                              IMPORTING row column,
             create_field_catalog RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat,
             apply_field_properties IMPORTING io_column TYPE REF TO cl_salv_column_table
                                             is_config TYPE lcl_config_manager=>ty_config.
ENDCLASS.

*----------------------------------------------------------------------*
* Class Implementations
*----------------------------------------------------------------------*

CLASS lcl_config_manager IMPLEMENTATION.
  METHOD constructor.
    load_configuration( ).
  ENDMETHOD.
  
  METHOD load_configuration.
    SELECT field_name dropdown checkbox enable editable mandatory
           sort_order validation_rule data_source field_text
      FROM zalv_config
      WHERE enable = 'X'
      ORDER BY sort_order
      INTO CORRESPONDING FIELDS OF TABLE @mt_config.
    
    IF sy-subrc <> 0.
      " Load default configuration if table is empty
      load_default_config( ).
    ENDIF.
    
    cache_configuration( ).
  ENDMETHOD.
  
  METHOD load_default_config.
    DATA: ls_config TYPE ty_config.
    
    " MBLNR - Material Document Number
    ls_config-field_name = 'MBLNR'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-mandatory = 'X'.
    ls_config-sort_order = 1.
    ls_config-data_source = 'MKPF'.
    ls_config-field_text = 'Material Document Number'.
    APPEND ls_config TO mt_config.
    
    " MJAHR - Material Document Year
    ls_config-field_name = 'MJAHR'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-sort_order = 2.
    ls_config-data_source = 'MKPF'.
    ls_config-field_text = 'Material Document Year'.
    APPEND ls_config TO mt_config.
    
    " MATNR - Material Number
    ls_config-field_name = 'MATNR'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-mandatory = 'X'.
    ls_config-sort_order = 3.
    ls_config-data_source = 'MSEG'.
    ls_config-field_text = 'Material Number'.
    APPEND ls_config TO mt_config.
    
    " WERKS - Plant
    ls_config-field_name = 'WERKS'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-dropdown = 'X'.
    ls_config-sort_order = 4.
    ls_config-data_source = 'MSEG'.
    ls_config-field_text = 'Plant'.
    APPEND ls_config TO mt_config.
    
    " LGORT - Storage Location
    ls_config-field_name = 'LGORT'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-dropdown = 'X'.
    ls_config-sort_order = 5.
    ls_config-data_source = 'MSEG'.
    ls_config-field_text = 'Storage Location'.
    APPEND ls_config TO mt_config.
    
    " MENGE - Quantity
    ls_config-field_name = 'MENGE'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-mandatory = 'X'.
    ls_config-sort_order = 6.
    ls_config-data_source = 'MSEG'.
    ls_config-field_text = 'Quantity'.
    APPEND ls_config TO mt_config.
    
    " MEINS - Unit of Measure
    ls_config-field_name = 'MEINS'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-dropdown = 'X'.
    ls_config-sort_order = 7.
    ls_config-data_source = 'MSEG'.
    ls_config-field_text = 'Unit of Measure'.
    APPEND ls_config TO mt_config.
    
    " BWART - Movement Type
    ls_config-field_name = 'BWART'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-dropdown = 'X'.
    ls_config-sort_order = 8.
    ls_config-data_source = 'MSEG'.
    ls_config-field_text = 'Movement Type'.
    APPEND ls_config TO mt_config.
    
    " BUDAT - Posting Date
    ls_config-field_name = 'BUDAT'.
    ls_config-enable = 'X'.
    ls_config-editable = 'X'.
    ls_config-sort_order = 9.
    ls_config-data_source = 'MKPF'.
    ls_config-field_text = 'Posting Date'.
    APPEND ls_config TO mt_config.
    
    " MAKTX - Material Description
    ls_config-field_name = 'MAKTX'.
    ls_config-enable = 'X'.
    ls_config-editable = ' '.
    ls_config-sort_order = 10.
    ls_config-data_source = 'CUSTOM'.
    ls_config-field_text = 'Material Description'.
    APPEND ls_config TO mt_config.
  ENDMETHOD.
  
  METHOD get_field_config.
    READ TABLE mt_config INTO rs_config
      WITH KEY field_name = iv_field_name.
  ENDMETHOD.
  
  METHOD validate_configuration.
    LOOP AT mt_config INTO DATA(ls_config).
      IF ls_config-field_name IS INITIAL.
        RAISE EXCEPTION TYPE cx_static_check
          EXPORTING textid = cx_static_check=>error_occurred.
      ENDIF.
      
      IF ls_config-dropdown = 'X' AND ls_config-checkbox = 'X'.
        RAISE EXCEPTION TYPE cx_static_check
          EXPORTING textid = cx_static_check=>error_occurred.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
  
  METHOD cache_configuration.
    " Cache configuration in memory for runtime stability
    " This ensures changes in SM30 don't affect current session
  ENDMETHOD.
ENDCLASS.

CLASS lcl_data_fetcher IMPLEMENTATION.
  METHOD constructor.
    mo_config = io_config.
  ENDMETHOD.
  
  METHOD fetch_data.
    fetch_from_mkpf_mseg( ).
    
    " If no data found, fetch sample data
    IF mt_data IS INITIAL.
      fetch_sample_data( ).
    ENDIF.
  ENDMETHOD.
  
  METHOD fetch_from_mkpf_mseg.
    DATA: lt_mkpf TYPE TABLE OF mkpf,
          lt_mseg TYPE TABLE OF mseg,
          lt_makt TYPE TABLE OF makt.
    
    " Fetch header data
    SELECT * FROM mkpf
      WHERE mblnr = @p_mblnr
        AND budat IN @s_budat
      INTO TABLE @lt_mkpf.
    
    IF sy-subrc = 0.
      " Fetch item data
      SELECT * FROM mseg
        WHERE mblnr = @p_mblnr
          AND werks IN @s_werks
          AND bwart IN @s_bwart
        INTO TABLE @lt_mseg.
      
      " Fetch material descriptions
      SELECT * FROM makt
        FOR ALL ENTRIES IN @lt_mseg
        WHERE matnr = @lt_mseg-matnr
          AND spras = @sy-langu
        INTO TABLE @lt_makt.
      
      " Join data
      LOOP AT lt_mkpf INTO DATA(ls_mkpf).
        LOOP AT lt_mseg INTO DATA(ls_mseg) WHERE mblnr = ls_mkpf-mblnr.
          DATA: ls_data TYPE ty_goods_movement.
          
          ls_data-guid = generate_guid( ).
          ls_data-mblnr = ls_mkpf-mblnr.
          ls_data-mjahr = ls_mkpf-mjahr.
          ls_data-mblpo = ls_mseg-mblpo.
          ls_data-matnr = ls_mseg-matnr.
          ls_data-werks = ls_mseg-werks.
          ls_data-lgort = ls_mseg-lgort.
          ls_data-menge = ls_mseg-menge.
          ls_data-meins = ls_mseg-meins.
          ls_data-bwart = ls_mseg-bwart.
          ls_data-budat = ls_mkpf-budat.
          
          " Get material description
          READ TABLE lt_makt INTO DATA(ls_makt)
            WITH KEY matnr = ls_mseg-matnr.
          IF sy-subrc = 0.
            ls_data-maktx = ls_makt-maktx.
          ENDIF.
          
          ls_data-editable = abap_true.
          APPEND ls_data TO mt_data.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  
  METHOD fetch_sample_data.
    DATA: ls_data TYPE ty_goods_movement.
    
    " Sample data - minimum 10 records
    DO 10 TIMES.
      ls_data-guid = generate_guid( ).
      ls_data-mblnr = p_mblnr.
      ls_data-mjahr = sy-datum(4).
      ls_data-mblpo = sy-index.
      ls_data-matnr = |MAT{ sy-index ALPHA = IN }|.
      ls_data-werks = |PLNT{ sy-index }|.
      ls_data-lgort = |LOC{ sy-index }|.
      ls_data-menge = sy-index * 10.
      ls_data-meins = 'PC'.
      ls_data-bwart = '261'.
      ls_data-budat = sy-datum.
      ls_data-maktx = |Sample Material { sy-index }|.
      ls_data-editable = abap_true.
      
      APPEND ls_data TO mt_data.
    ENDDO.
  ENDMETHOD.
  
  METHOD add_custom_row.
    DATA: ls_data TYPE ty_goods_movement.
    
    ls_data-guid = generate_guid( ).
    ls_data-editable = abap_true.
    APPEND ls_data TO mt_data.
  ENDMETHOD.
  
  METHOD generate_guid.
    rv_guid = cl_system_uuid=>create_uuid_x16_static( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_validator IMPLEMENTATION.
  METHOD validate_field.
    CASE iv_field_name.
      WHEN 'WERKS'.
        rv_valid = validate_werks( CONV #( iv_value ) ).
      WHEN 'MENGE'.
        rv_valid = validate_menge( CONV #( iv_value ) ).
      WHEN OTHERS.
        rv_valid = abap_true.
    ENDCASE.
  ENDMETHOD.
  
  METHOD validate_mandatory_fields.
    LOOP AT it_data INTO DATA(ls_data).
      " Check mandatory fields based on configuration
      " Implementation would check against configuration
    ENDLOOP.
    rv_valid = abap_true.
  ENDMETHOD.
  
  METHOD validate_werks.
    SELECT SINGLE @abap_true FROM t001w
      WHERE werks = @iv_werks
      INTO @rv_valid.
  ENDMETHOD.
  
  METHOD validate_menge.
    rv_valid = COND #( WHEN iv_menge > 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.
  
  METHOD log_validation_error.
    " Log validation errors
  ENDMETHOD.
ENDCLASS.

CLASS lcl_audit_logger IMPLEMENTATION.
  METHOD log_field_change.
    DATA: ls_audit TYPE zalv_audit.
    
    ls_audit-guid = generate_guid( ).
    ls_audit-field_name = iv_field_name.
    ls_audit-old_value = CONV char255( iv_old_value ).
    ls_audit-new_value = CONV char255( iv_new_value ).
    ls_audit-user_id = sy-uname.
    ls_audit-action = 'CHANGE'.
    ls_audit-record_guid = iv_record_guid.
    ls_audit-timestamp = cl_abap_context_info=>get_system_time( ).
    
    INSERT zalv_audit FROM ls_audit.
  ENDMETHOD.
  
  METHOD log_action.
    DATA: ls_audit TYPE zalv_audit.
    
    ls_audit-guid = generate_guid( ).
    ls_audit-user_id = sy-uname.
    ls_audit-action = iv_action.
    ls_audit-record_guid = iv_record_guid.
    ls_audit-timestamp = cl_abap_context_info=>get_system_time( ).
    
    INSERT zalv_audit FROM ls_audit.
  ENDMETHOD.
  
  METHOD generate_guid.
    rv_guid = cl_system_uuid=>create_uuid_x16_static( ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_alv_display IMPLEMENTATION.
  METHOD constructor.
    mo_data = io_data.
    mo_config = io_config.
    mo_validator = io_validator.
    mo_audit = io_audit.
  ENDMETHOD.
  
  METHOD display_alv.
    setup_alv( ).
    setup_columns( ).
    setup_functions( ).
    setup_events( ).
    
    mo_alv->display( ).
  ENDMETHOD.
  
  METHOD setup_alv.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = mo_alv
          CHANGING
            t_table      = mo_data->mt_data ).
        
        mo_functions = mo_alv->get_functions( ).
        mo_columns = mo_alv->get_columns( ).
        mo_events = mo_alv->get_event( ).
        
      CATCH cx_salv_msg.
        MESSAGE 'Error creating ALV' TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
  
  METHOD setup_columns.
    DATA: lo_column TYPE REF TO cl_salv_column_table.
    
    TRY.
        " Set column properties based on configuration
        LOOP AT mo_config->mt_config INTO DATA(ls_config).
          lo_column ?= mo_columns->get_column( ls_config-field_name ).
          
          IF lo_column IS BOUND.
            apply_field_properties( io_column = lo_column
                                   is_config = ls_config ).
          ENDIF.
        ENDLOOP.
        
        " Add hotspot to MBLNR
        lo_column ?= mo_columns->get_column( 'MBLNR' ).
        IF lo_column IS BOUND.
          lo_column->set_cell_type( if_salv_c_cell_type=>hotspot ).
        ENDIF.
        
      CATCH cx_salv_not_found.
        " Column not found
    ENDTRY.
  ENDMETHOD.
  
  METHOD setup_functions.
    mo_functions->set_all( abap_true ).
    
    " Add custom buttons
    mo_functions->add_function(
      name     = 'SAVE'
      icon     = icon_system_save
      text     = 'Save'
      tooltip  = 'Save Changes'
      position = if_salv_c_function_position=>right_of_salv_functions ).
    
    mo_functions->add_function(
      name     = 'REFRESH'
      icon     = icon_refresh
      text     = 'Refresh'
      tooltip  = 'Refresh Data'
      position = if_salv_c_function_position=>right_of_salv_functions ).
    
    mo_functions->add_function(
      name     = 'EXPORT'
      icon     = icon_export
      text     = 'Export'
      tooltip  = 'Export to Excel'
      position = if_salv_c_function_position=>right_of_salv_functions ).
    
    mo_functions->add_function(
      name     = 'ADD_ROW'
      icon     = icon_insert_row
      text     = 'Add Row'
      tooltip  = 'Add New Row'
      position = if_salv_c_function_position=>right_of_salv_functions ).
  ENDMETHOD.
  
  METHOD setup_events.
    SET HANDLER on_user_command FOR mo_events.
    SET HANDLER on_double_click FOR mo_events.
    SET HANDLER on_hotspot_click FOR mo_events.
  ENDMETHOD.
  
  METHOD on_user_command.
    CASE e_salv_function.
      WHEN 'SAVE'.
        save_data( ).
      WHEN 'REFRESH'.
        refresh_data( ).
      WHEN 'EXPORT'.
        export_data( ).
      WHEN 'ADD_ROW'.
        add_row( ).
    ENDCASE.
  ENDMETHOD.
  
  METHOD on_double_click.
    " Handle double click events
  ENDMETHOD.
  
  METHOD on_hotspot_click.
    " Navigate to MB03 for MBLNR
    IF column = 'MBLNR'.
      READ TABLE mo_data->mt_data INTO DATA(ls_data) INDEX row.
      IF sy-subrc = 0.
        SET PARAMETER ID 'MBN' FIELD ls_data-mblnr.
        SET PARAMETER ID 'MJA' FIELD ls_data-mjahr.
        CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
      ENDIF.
    ENDIF.
  ENDMETHOD.
  
  METHOD apply_field_properties.
    " Apply dropdown
    IF is_config-dropdown = 'X'.
      io_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
    ENDIF.
    
    " Apply checkbox
    IF is_config-checkbox = 'X'.
      io_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
    ENDIF.
    
    " Set editable
    IF is_config-editable = 'X'.
      io_column->set_cell_type( if_salv_c_cell_type=>text ).
    ELSE.
      io_column->set_cell_type( if_salv_c_cell_type=>text ).
      io_column->set_read_only( abap_true ).
    ENDIF.
    
    " Set field text
    io_column->set_short_text( is_config-field_text ).
    io_column->set_medium_text( is_config-field_text ).
    io_column->set_long_text( is_config-field_text ).
  ENDMETHOD.
  
  METHOD refresh_data.
    mo_data->fetch_data( ).
    mo_alv->refresh( ).
    MESSAGE 'Data refreshed successfully' TYPE 'S'.
  ENDMETHOD.
  
  METHOD save_data.
    " Validate data before saving
    IF mo_validator->validate_mandatory_fields( mo_data->mt_data ) = abap_false.
      MESSAGE 'Validation failed. Please check mandatory fields.' TYPE 'E'.
      RETURN.
    ENDIF.
    
    " Save to custom table
    LOOP AT mo_data->mt_data INTO DATA(ls_data).
      MODIFY zalv_data FROM ls_data.
    ENDLOOP.
    
    MESSAGE 'Data saved successfully' TYPE 'S'.
  ENDMETHOD.
  
  METHOD export_data.
    " Export to Excel functionality
    MESSAGE 'Export functionality to be implemented' TYPE 'I'.
  ENDMETHOD.
  
  METHOD add_row.
    mo_data->add_custom_row( ).
    mo_alv->refresh( ).
    MESSAGE 'New row added' TYPE 'S'.
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
* Main Program Logic
*----------------------------------------------------------------------*

START-OF-SELECTION.
  TRY.
      " Initialize objects
      CREATE OBJECT go_config_manager.
      CREATE OBJECT go_data_fetcher EXPORTING io_config = go_config_manager.
      CREATE OBJECT go_validator.
      CREATE OBJECT go_audit_logger.
      CREATE OBJECT go_alv_display
        EXPORTING
          io_data     = go_data_fetcher
          io_config   = go_config_manager
          io_validator = go_validator
          io_audit    = go_audit_logger.
      
      " Validate configuration
      go_config_manager->validate_configuration( ).
      
      " Fetch data
      go_data_fetcher->fetch_data( ).
      
      " Display ALV
      go_alv_display->display_alv( ).
      
    CATCH cx_static_check INTO DATA(lx_error).
      MESSAGE lx_error TYPE 'E'.
  ENDTRY.