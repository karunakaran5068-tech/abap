*&---------------------------------------------------------------------*
*& Table Maintenance Generator for ZALV_CONFIG
*&---------------------------------------------------------------------*

FUNCTION-POOL zalv_config_maint.

*----------------------------------------------------------------------*
* Table Maintenance Generator
*----------------------------------------------------------------------*

TABLES: zalv_config.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_field_name FOR zalv_config-field_name,
                s_data_source FOR zalv_config-data_source,
                s_enable FOR zalv_config-enable.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Global Data
*----------------------------------------------------------------------*

DATA: gt_config TYPE TABLE OF zalv_config,
      go_alv TYPE REF TO cl_salv_table.

*----------------------------------------------------------------------*
* Main Processing
*----------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM load_data.
  PERFORM display_alv.

*----------------------------------------------------------------------*
* Forms
*----------------------------------------------------------------------*

FORM load_data.
  SELECT * FROM zalv_config
    WHERE field_name IN @s_field_name
      AND data_source IN @s_data_source
      AND enable IN @s_enable
    ORDER BY sort_order
    INTO TABLE @gt_config.
  
  IF sy-subrc <> 0.
    MESSAGE 'No configuration data found' TYPE 'I'.
  ENDIF.
ENDFORM.

FORM display_alv.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_config ).
      
      " Setup display
      go_alv->get_functions( )->set_all( abap_true ).
      go_alv->get_display_settings( )->set_striped_pattern( abap_true ).
      
      " Setup columns
      PERFORM setup_columns.
      
      " Display
      go_alv->display( ).
      
    CATCH cx_salv_msg.
      MESSAGE 'Error creating ALV display' TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM setup_columns.
  DATA: lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column TYPE REF TO cl_salv_column_table.
  
  lo_columns = go_alv->get_columns( ).
  
  " Field Name
  lo_column ?= lo_columns->get_column( 'FIELD_NAME' ).
  lo_column->set_short_text( 'Field' ).
  lo_column->set_medium_text( 'Field Name' ).
  lo_column->set_long_text( 'Field Name' ).
  
  " Dropdown
  lo_column ?= lo_columns->get_column( 'DROPDOWN' ).
  lo_column->set_short_text( 'DD' ).
  lo_column->set_medium_text( 'Dropdown' ).
  lo_column->set_long_text( 'Dropdown Field' ).
  
  " Checkbox
  lo_column ?= lo_columns->get_column( 'CHECKBOX' ).
  lo_column->set_short_text( 'CB' ).
  lo_column->set_medium_text( 'Checkbox' ).
  lo_column->set_long_text( 'Checkbox Field' ).
  
  " Enable
  lo_column ?= lo_columns->get_column( 'ENABLE' ).
  lo_column->set_short_text( 'En' ).
  lo_column->set_medium_text( 'Enable' ).
  lo_column->set_long_text( 'Enable Field' ).
  
  " Editable
  lo_column ?= lo_columns->get_column( 'EDITABLE' ).
  lo_column->set_short_text( 'Ed' ).
  lo_column->set_medium_text( 'Editable' ).
  lo_column->set_long_text( 'Editable Field' ).
  
  " Mandatory
  lo_column ?= lo_columns->get_column( 'MANDATORY' ).
  lo_column->set_short_text( 'Man' ).
  lo_column->set_medium_text( 'Mandatory' ).
  lo_column->set_long_text( 'Mandatory Field' ).
  
  " Sort Order
  lo_column ?= lo_columns->get_column( 'SORT_ORDER' ).
  lo_column->set_short_text( 'Sort' ).
  lo_column->set_medium_text( 'Sort Order' ).
  lo_column->set_long_text( 'Sort Order' ).
  
  " Data Source
  lo_column ?= lo_columns->get_column( 'DATA_SOURCE' ).
  lo_column->set_short_text( 'Source' ).
  lo_column->set_medium_text( 'Data Source' ).
  lo_column->set_long_text( 'Data Source' ).
  
  " Field Text
  lo_column ?= lo_columns->get_column( 'FIELD_TEXT' ).
  lo_column->set_short_text( 'Text' ).
  lo_column->set_medium_text( 'Field Text' ).
  lo_column->set_long_text( 'Field Text' ).
ENDFORM.