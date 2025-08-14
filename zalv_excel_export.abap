*&---------------------------------------------------------------------*
*& Report ZALV_EXCEL_EXPORT
*&---------------------------------------------------------------------*
*& This program demonstrates how to export ALV data to Excel
*& using a custom export button
*&---------------------------------------------------------------------*
REPORT zalv_excel_export.

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
        PERFORM export_to_excel.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
* Excel Export Form
*----------------------------------------------------------------------*
FORM export_to_excel.
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

  " Export to Excel
  PERFORM export_data_to_excel USING lv_fullpath.

  " Show success message
  MESSAGE 'Data exported successfully to Excel file' TYPE 'S'.
ENDFORM.

*----------------------------------------------------------------------*
FORM export_data_to_excel USING pv_filename TYPE string.
  DATA: lo_excel     TYPE REF TO cl_excel,
        lo_worksheet TYPE REF TO cl_excel_worksheet,
        lo_writer    TYPE REF TO cl_excel_writer,
        lv_content   TYPE xstring,
        lv_row       TYPE i VALUE 1,
        lv_col       TYPE i,
        ls_data      TYPE ty_data.

  TRY.
    " Create Excel object
    CREATE OBJECT lo_excel.

    " Get active worksheet
    lo_worksheet = lo_excel->get_active_worksheet( ).

    " Set worksheet title
    lo_worksheet->set_title( 'Material Data' ).

    " Add headers
    lo_worksheet->set_cell(
      ip_column = 'A'
      ip_row    = lv_row
      ip_value  = 'Material Number' ).

    lo_worksheet->set_cell(
      ip_column = 'B'
      ip_row    = lv_row
      ip_value  = 'Material Description' ).

    lo_worksheet->set_cell(
      ip_column = 'C'
      ip_row    = lv_row
      ip_value  = 'Material Type' ).

    lo_worksheet->set_cell(
      ip_column = 'D'
      ip_row    = lv_row
      ip_value  = 'Material Group' ).

    lo_worksheet->set_cell(
      ip_column = 'E'
      ip_row    = lv_row
      ip_value  = 'Base Unit' ).

    lo_worksheet->set_cell(
      ip_column = 'F'
      ip_row    = lv_row
      ip_value  = 'Cross-Plant Status' ).

    " Style headers (make them bold)
    lo_worksheet->set_cell_style(
      ip_column = 'A'
      ip_row    = lv_row
      ip_style  = 'Bold' ).

    lo_worksheet->set_cell_style(
      ip_column = 'B'
      ip_row    = lv_row
      ip_style  = 'Bold' ).

    lo_worksheet->set_cell_style(
      ip_column = 'C'
      ip_row    = lv_row
      ip_style  = 'Bold' ).

    lo_worksheet->set_cell_style(
      ip_column = 'D'
      ip_row    = lv_row
      ip_style  = 'Bold' ).

    lo_worksheet->set_cell_style(
      ip_column = 'E'
      ip_row    = lv_row
      ip_style  = 'Bold' ).

    lo_worksheet->set_cell_style(
      ip_column = 'F'
      ip_row    = lv_row
      ip_style  = 'Bold' ).

    " Add data rows
    LOOP AT gt_data INTO ls_data.
      lv_row = lv_row + 1.

      lo_worksheet->set_cell(
        ip_column = 'A'
        ip_row    = lv_row
        ip_value  = ls_data-matnr ).

      lo_worksheet->set_cell(
        ip_column = 'B'
        ip_row    = lv_row
        ip_value  = ls_data-maktx ).

      lo_worksheet->set_cell(
        ip_column = 'C'
        ip_row    = lv_row
        ip_value  = ls_data-mtart ).

      lo_worksheet->set_cell(
        ip_column = 'D'
        ip_row    = lv_row
        ip_value  = ls_data-matkl ).

      lo_worksheet->set_cell(
        ip_column = 'E'
        ip_row    = lv_row
        ip_value  = ls_data-meins ).

      lo_worksheet->set_cell(
        ip_column = 'F'
        ip_row    = lv_row
        ip_value  = ls_data-mstae ).
    ENDLOOP.

    " Auto-fit columns
    lo_worksheet->set_column_width(
      ip_column = 'A'
      ip_width  = 15 ).

    lo_worksheet->set_column_width(
      ip_column = 'B'
      ip_width  = 30 ).

    lo_worksheet->set_column_width(
      ip_column = 'C'
      ip_width  = 12 ).

    lo_worksheet->set_column_width(
      ip_column = 'D'
      ip_width  = 12 ).

    lo_worksheet->set_column_width(
      ip_column = 'E'
      ip_width  = 10 ).

    lo_worksheet->set_column_width(
      ip_column = 'F'
      ip_width  = 15 ).

    " Create Excel writer
    CREATE OBJECT lo_writer.

    " Generate Excel file
    lv_content = lo_writer->write_file( lo_excel ).

    " Save file to application server
    PERFORM save_file_to_server
      USING
        pv_filename
        lv_content.

  CATCH cx_excel INTO DATA(lx_excel).
    MESSAGE lx_excel TYPE 'E'.
  ENDTRY.
ENDFORM.

*----------------------------------------------------------------------*
FORM save_file_to_server USING pv_filename TYPE string
                                pv_content TYPE xstring.
  DATA: lv_file TYPE string.

  " Convert to application server path
  lv_file = pv_filename.

  " Write file to application server
  OPEN DATASET lv_file FOR OUTPUT IN BINARY MODE.
  IF sy-subrc = 0.
    TRANSFER pv_content TO lv_file.
    CLOSE DATASET lv_file.
  ELSE.
    MESSAGE 'Error opening file for writing' TYPE 'E'.
  ENDIF.
ENDFORM.