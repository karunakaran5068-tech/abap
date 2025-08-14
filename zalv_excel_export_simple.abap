*&---------------------------------------------------------------------*
*& Report ZALV_EXCEL_EXPORT_SIMPLE
*&---------------------------------------------------------------------*
*& Simple version using SAP standard Excel export functionality
*&---------------------------------------------------------------------*
REPORT zalv_excel_export_simple.

*----------------------------------------------------------------------*
* Data Declarations
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_data,
         matnr TYPE matnr,
         maktx TYPE maktx,
         mtart TYPE mtart,
         matkl TYPE matkl,
         meins TYPE meins,
         mstae TYPE mstae,
       END OF ty_data.

DATA: gt_data     TYPE TABLE OF ty_data,
      gs_data     TYPE ty_data,
      go_alv      TYPE REF TO cl_salv_table,
      go_functions TYPE REF TO cl_salv_functions,
      go_columns  TYPE REF TO cl_salv_columns_table,
      go_column   TYPE REF TO cl_salv_column_table,
      go_layout   TYPE REF TO cl_salv_layout,
      go_display  TYPE REF TO cl_salv_display_settings,
      go_selections TYPE REF TO cl_salv_selections.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_matnr FOR gs_data-matnr,
                s_matkl FOR gs_data-matkl.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Main Program
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display_alv.

*----------------------------------------------------------------------*
* Forms
*----------------------------------------------------------------------*
FORM get_data.
  SELECT matnr maktx mtart matkl meins mstae
    FROM mara AS a
    INNER JOIN makt AS t ON a~matnr = t~matnr
    WHERE a~matnr IN @s_matnr
      AND a~matkl IN @s_matkl
      AND t~spras = @sy-langu
    INTO CORRESPONDING FIELDS OF TABLE @gt_data.
ENDFORM.

*----------------------------------------------------------------------*
FORM display_alv.
  TRY.
    " Create ALV instance
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = go_alv
      CHANGING
        t_table      = gt_data ).

    " Get function list
    go_functions = go_alv->get_functions( ).
    go_functions->set_all( abap_true ).

    " Add custom export button
    PERFORM add_custom_export_button.

    " Get columns
    go_columns = go_alv->get_columns( ).
    go_columns->set_optimize( abap_true ).

    " Set column properties
    PERFORM set_column_properties.

    " Get layout
    go_layout = go_alv->get_layout( ).
    go_layout->set_key( value = 'EXCEL_EXPORT' ).

    " Get display settings
    go_display = go_alv->get_display_settings( ).
    go_display->set_striped_pattern( abap_true ).

    " Get selections
    go_selections = go_alv->get_selections( ).
    go_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

    " Display ALV
    go_alv->display( ).

  CATCH cx_salv_msg INTO DATA(lx_msg).
    MESSAGE lx_msg TYPE 'E'.
  ENDTRY.
ENDFORM.

*----------------------------------------------------------------------*
FORM add_custom_export_button.
  " Add custom export button to toolbar
  go_functions->add_function(
    name     = 'EXCEL_EXPORT'
    icon     = '@2L@'
    text     = 'Export to Excel'
    tooltip  = 'Export data to Excel file'
    position = if_salv_c_function_position=>right_of_salv_functions ).

  " Set event handler for custom button
  SET HANDLER lcl_events=>on_user_command FOR go_alv.
ENDFORM.

*----------------------------------------------------------------------*
FORM set_column_properties.
  TRY.
    " Material Number
    go_column ?= go_columns->get_column( 'MATNR' ).
    go_column->set_short_text( 'Material' ).
    go_column->set_medium_text( 'Material Number' ).
    go_column->set_long_text( 'Material Number' ).

    " Material Description
    go_column ?= go_columns->get_column( 'MAKTX' ).
    go_column->set_short_text( 'Desc' ).
    go_column->set_medium_text( 'Description' ).
    go_column->set_long_text( 'Material Description' ).

    " Material Type
    go_column ?= go_columns->get_column( 'MTART' ).
    go_column->set_short_text( 'Type' ).
    go_column->set_medium_text( 'Material Type' ).
    go_column->set_long_text( 'Material Type' ).

    " Material Group
    go_column ?= go_columns->get_column( 'MATKL' ).
    go_column->set_short_text( 'Group' ).
    go_column->set_medium_text( 'Material Group' ).
    go_column->set_long_text( 'Material Group' ).

    " Base Unit
    go_column ?= go_columns->get_column( 'MEINS' ).
    go_column->set_short_text( 'Unit' ).
    go_column->set_medium_text( 'Base Unit' ).
    go_column->set_long_text( 'Base Unit of Measure' ).

    " Cross-Plant Status
    go_column ?= go_columns->get_column( 'MSTAE' ).
    go_column->set_short_text( 'Status' ).
    go_column->set_medium_text( 'Cross-Plant Status' ).
    go_column->set_long_text( 'Cross-Plant Material Status' ).

  CATCH cx_salv_not_found INTO DATA(lx_not_found).
    MESSAGE lx_not_found TYPE 'W'.
  ENDTRY.
ENDFORM.

*----------------------------------------------------------------------*
* Event Handler Class
*----------------------------------------------------------------------*
CLASS lcl_events DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.

CLASS lcl_events IMPLEMENTATION.
  METHOD on_user_command.
    CASE e_salv_function.
      WHEN 'EXCEL_EXPORT'.
        PERFORM export_to_excel_simple.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
* Simple Excel Export Form using SAP Standard Function
*----------------------------------------------------------------------*
FORM export_to_excel_simple.
  DATA: lv_filename TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string,
        lv_answer   TYPE c.

  " Get file path from user
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
    IMPORTING
      file_name     = lv_filename.

  IF lv_filename IS INITIAL.
    RETURN.
  ENDIF.

  " Add .xlsx extension if not present
  IF lv_filename CS '.xlsx' OR lv_filename CS '.xls'.
    lv_fullpath = lv_filename.
  ELSE.
    CONCATENATE lv_filename '.xlsx' INTO lv_fullpath.
  ENDIF.

  " Confirm overwrite if file exists
  CALL FUNCTION 'FILE_EXIST'
    EXPORTING
      file                = lv_fullpath
    EXCEPTIONS
      not_found           = 1
      OTHERS              = 2.

  IF sy-subrc = 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'File Exists'
        text_question         = 'File already exists. Do you want to overwrite it?'
        text_button_1         = 'Yes'
        text_button_2         = 'No'
        default_button        = '2'
        display_cancel_button = 'X'
      IMPORTING
        answer                = lv_answer.

    IF lv_answer <> '1'.
      RETURN.
    ENDIF.
  ENDIF.

  " Export to Excel using SAP standard function
  PERFORM export_data_to_excel_simple USING lv_fullpath.

  " Show success message
  MESSAGE 'Data exported successfully to Excel file' TYPE 'S'.
ENDFORM.

*----------------------------------------------------------------------*
FORM export_data_to_excel_simple USING pv_filename TYPE string.
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_fieldcat TYPE slis_fieldcat_alv,
        lv_file     TYPE string.

  " Build field catalog
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MATNR'.
  ls_fieldcat-seltext_l = 'Material Number'.
  ls_fieldcat-seltext_m = 'Material Number'.
  ls_fieldcat-seltext_s = 'Material'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAKTX'.
  ls_fieldcat-seltext_l = 'Material Description'.
  ls_fieldcat-seltext_m = 'Description'.
  ls_fieldcat-seltext_s = 'Desc'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MTART'.
  ls_fieldcat-seltext_l = 'Material Type'.
  ls_fieldcat-seltext_m = 'Material Type'.
  ls_fieldcat-seltext_s = 'Type'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MATKL'.
  ls_fieldcat-seltext_l = 'Material Group'.
  ls_fieldcat-seltext_m = 'Material Group'.
  ls_fieldcat-seltext_s = 'Group'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MEINS'.
  ls_fieldcat-seltext_l = 'Base Unit of Measure'.
  ls_fieldcat-seltext_m = 'Base Unit'.
  ls_fieldcat-seltext_s = 'Unit'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MSTAE'.
  ls_fieldcat-seltext_l = 'Cross-Plant Material Status'.
  ls_fieldcat-seltext_m = 'Cross-Plant Status'.
  ls_fieldcat-seltext_s = 'Status'.
  APPEND ls_fieldcat TO lt_fieldcat.

  " Export to Excel using SAP standard function
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_XLS'
    EXPORTING
      i_structure_name = 'ZALV_EXCEL_EXPORT_SIMPLE'
      i_filename       = pv_filename
      i_fieldcat       = lt_fieldcat
    TABLES
      t_outtab         = gt_data
    EXCEPTIONS
      file_open_error  = 1
      file_write_error = 2
      invalid_type     = 3
      no_data          = 4
      unknown_error    = 5
      OTHERS           = 6.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE 'Error opening file' TYPE 'E'.
      WHEN 2.
        MESSAGE 'Error writing to file' TYPE 'E'.
      WHEN 3.
        MESSAGE 'Invalid file type' TYPE 'E'.
      WHEN 4.
        MESSAGE 'No data to export' TYPE 'E'.
      WHEN OTHERS.
        MESSAGE 'Unknown error occurred' TYPE 'E'.
    ENDCASE.
  ENDIF.
ENDFORM.