*&---------------------------------------------------------------------*
*& Report Z_ALV_DROPDOWN_NO_CLASSES
*&---------------------------------------------------------------------*
*& This program demonstrates how to implement dropdowns in ALV
*& using only forms and function modules - NO CLASSES at all
*&---------------------------------------------------------------------*
REPORT z_alv_dropdown_no_classes.

*----------------------------------------------------------------------*
* Data Declarations
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_data,
         id         TYPE i,
         name       TYPE string,
         status     TYPE char10,
         category   TYPE char15,
         priority   TYPE char5,
         sel        TYPE char1,
       END OF ty_data.

DATA: gt_data      TYPE TABLE OF ty_data,
      gt_fieldcat  TYPE slis_t_fieldcat_alv,
      gs_layout    TYPE slis_layout_alv,
      gs_variant   TYPE disvariant,
      gt_dropdown  TYPE lvc_t_dral.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_method TYPE char1 DEFAULT '1'.
SELECTION-SCREEN COMMENT 1(50) text-002.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 1(50) text-003.
SELECTION-SCREEN COMMENT 1(50) text-004.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Main Program
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM prepare_data.
  
  CASE p_method.
    WHEN '1'.
      PERFORM display_salv_dropdown.
    WHEN '2'.
      PERFORM display_grid_dropdown.
    WHEN '3'.
      PERFORM display_function_dropdown.
    WHEN OTHERS.
      PERFORM display_function_dropdown.
  ENDCASE.

*----------------------------------------------------------------------*
* Forms
*----------------------------------------------------------------------*
FORM prepare_data.
  DATA: ls_data TYPE ty_data.
  
  " Sample data
  ls_data-id = 1.
  ls_data-name = 'Task 1'.
  ls_data-status = 'OPEN'.
  ls_data-category = 'DEVELOPMENT'.
  ls_data-priority = 'HIGH'.
  ls_data-sel = ''.
  APPEND ls_data TO gt_data.
  
  ls_data-id = 2.
  ls_data-name = 'Task 2'.
  ls_data-status = 'IN_PROGRESS'.
  ls_data-category = 'TESTING'.
  ls_data-priority = 'MEDIUM'.
  ls_data-sel = ''.
  APPEND ls_data TO gt_data.
  
  ls_data-id = 3.
  ls_data-name = 'Task 3'.
  ls_data-status = 'CLOSED'.
  ls_data-category = 'DOCUMENTATION'.
  ls_data-priority = 'LOW'.
  ls_data-sel = ''.
  APPEND ls_data TO gt_data.
  
  ls_data-id = 4.
  ls_data-name = 'Task 4'.
  ls_data-status = 'OPEN'.
  ls_data-category = 'DEVELOPMENT'.
  ls_data-priority = 'HIGH'.
  ls_data-sel = ''.
  APPEND ls_data TO gt_data.
ENDFORM.

*----------------------------------------------------------------------*
* Method 1: SALV Dropdown using Forms Only
*----------------------------------------------------------------------*
FORM display_salv_dropdown.
  DATA: lo_alv       TYPE REF TO cl_salv_table,
        lo_columns   TYPE REF TO cl_salv_columns_table,
        lo_column    TYPE REF TO cl_salv_column_table,
        lo_events    TYPE REF TO cl_salv_events_table,
        lt_dropdown  TYPE lvc_t_dral.
  
  TRY.
    " Create SALV instance
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = gt_data ).
    
    " Get columns
    lo_columns = lo_alv->get_columns( ).
    
    " Build dropdown values
    PERFORM build_dropdown_values USING lt_dropdown.
    
    " Configure Status column as dropdown
    lo_column ?= lo_columns->get_column( 'STATUS' ).
    lo_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
    lo_column->set_dropdown_table( lt_dropdown ).
    
    " Configure Category column as dropdown
    lo_column ?= lo_columns->get_column( 'CATEGORY' ).
    lo_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
    lo_column->set_dropdown_table( lt_dropdown ).
    
    " Configure Priority column as dropdown
    lo_column ?= lo_columns->get_column( 'PRIORITY' ).
    lo_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
    lo_column->set_dropdown_table( lt_dropdown ).
    
    " Set editable and functions
    lo_alv->get_display_settings( )->set_list_header( 'SALV Dropdown - No Classes' ).
    lo_alv->get_functions( )->set_all( abap_true ).
    
    " Set events
    lo_events = lo_alv->get_event( ).
    SET HANDLER handle_salv_user_command FOR lo_events.
    SET HANDLER handle_salv_double_click FOR lo_events.
    
    " Display
    lo_alv->display( ).
    
  CATCH cx_salv_msg INTO DATA(lx_salv).
    MESSAGE lx_salv TYPE 'E'.
  ENDTRY.
ENDFORM.

*----------------------------------------------------------------------*
* Method 2: CL_GUI_ALV_GRID Dropdown using Forms Only
*----------------------------------------------------------------------*
FORM display_grid_dropdown.
  DATA: lo_container TYPE REF TO cl_gui_custom_container,
        lo_grid      TYPE REF TO cl_gui_alv_grid,
        lt_fieldcat  TYPE lvc_t_fcat,
        ls_layout    TYPE lvc_s_layo,
        lt_dropdown  TYPE lvc_t_dral.
  
  " Create container
  CREATE OBJECT lo_container
    EXPORTING
      container_name = 'CONTAINER'.
  
  " Create grid
  CREATE OBJECT lo_grid
    EXPORTING
      i_parent = lo_container.
  
  " Build field catalog
  PERFORM build_lvc_fieldcat USING lt_fieldcat.
  
  " Build dropdown values
  PERFORM build_dropdown_values USING lt_dropdown.
  
  " Set layout
  ls_layout-zebra = 'X'.
  ls_layout-cwidth_opt = 'X'.
  ls_layout-edit = 'X'.
  
  " Display grid
  lo_grid->set_table_for_first_display(
    EXPORTING
      is_layout                     = ls_layout
      it_dropdown                   = lt_dropdown
    CHANGING
      it_outtab                     = gt_data
      it_fieldcatalog               = lt_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines               = 3
      OTHERS                       = 4 ).
      
  IF sy-subrc <> 0.
    MESSAGE 'Error displaying grid' TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* Method 3: REUSE_ALV_GRID_DISPLAY Dropdown using Forms Only
*----------------------------------------------------------------------*
FORM display_function_dropdown.
  " Build field catalog
  PERFORM build_fieldcat.
  
  " Build dropdown values
  PERFORM build_dropdown_values USING gt_dropdown.
  
  " Set layout
  PERFORM set_layout.
  
  " Set variant
  PERFORM set_variant.
  
  " Display ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat
      i_save                  = 'A'
      is_variant              = gs_variant
    TABLES
      t_outtab                = gt_data
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
      
  IF sy-subrc <> 0.
    MESSAGE 'Error displaying ALV' TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
* Helper Forms for Field Catalog
*----------------------------------------------------------------------*
FORM build_fieldcat.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  
  " Clear field catalog
  CLEAR gt_fieldcat.
  
  " ID Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ID'.
  ls_fieldcat-seltext_l = 'ID'.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-just = 'C'.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Name Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext_l = 'Task Name'.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-edit = 'X'.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Status Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-seltext_l = 'Status'.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '1'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Category Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext_l = 'Category'.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '2'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Priority Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRIORITY'.
  ls_fieldcat-seltext_l = 'Priority'.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '3'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO gt_fieldcat.
ENDFORM.

*----------------------------------------------------------------------*
* Helper Form for LVC Field Catalog
*----------------------------------------------------------------------*
FORM build_lvc_fieldcat USING pt_fieldcat TYPE lvc_t_fcat.
  DATA: ls_fieldcat TYPE lvc_s_fcat.
  
  " ID Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ID'.
  ls_fieldcat-seltext = 'ID'.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-outputlen = 5.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Name Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext = 'Task Name'.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-edit = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Status Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-seltext = 'Status'.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '1'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Category Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext = 'Category'.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '2'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Priority Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRIORITY'.
  ls_fieldcat-seltext = 'Priority'.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '3'.
  APPEND ls_fieldcat TO pt_fieldcat.
ENDFORM.

*----------------------------------------------------------------------*
* Helper Form for Dropdown Values
*----------------------------------------------------------------------*
FORM build_dropdown_values USING pt_dropdown TYPE lvc_t_dral.
  DATA: ls_dropdown TYPE lvc_s_dral.
  
  " Clear dropdown table
  CLEAR pt_dropdown.
  
  " Status dropdown values
  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'OPEN'.
  ls_dropdown-text = 'Open'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'IN_PROGRESS'.
  ls_dropdown-text = 'In Progress'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'CLOSED'.
  ls_dropdown-text = 'Closed'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'ON_HOLD'.
  ls_dropdown-text = 'On Hold'.
  APPEND ls_dropdown TO pt_dropdown.
  
  " Category dropdown values
  ls_dropdown-handle = '2'.
  ls_dropdown-value = 'DEVELOPMENT'.
  ls_dropdown-text = 'Development'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'TESTING'.
  ls_dropdown-text = 'Testing'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'DOCUMENTATION'.
  ls_dropdown-text = 'Documentation'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'ANALYSIS'.
  ls_dropdown-text = 'Analysis'.
  APPEND ls_dropdown TO pt_dropdown.
  
  " Priority dropdown values
  ls_dropdown-handle = '3'.
  ls_dropdown-value = 'HIGH'.
  ls_dropdown-text = 'High'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'MEDIUM'.
  ls_dropdown-text = 'Medium'.
  APPEND ls_dropdown TO pt_dropdown.
  
  ls_dropdown-value = 'LOW'.
  ls_dropdown-text = 'Low'.
  APPEND ls_dropdown TO pt_dropdown.
ENDFORM.

*----------------------------------------------------------------------*
* Helper Forms for Layout and Variant
*----------------------------------------------------------------------*
FORM set_layout.
  " Set layout parameters
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-box_fieldname = 'SEL'.
  gs_layout-box_tabname = 'GT_DATA'.
  gs_layout-totals_before_items = 'X'.
  gs_layout-key_hotspot = 'X'.
ENDFORM.

FORM set_variant.
  " Set variant
  gs_variant-report = sy-repid.
  gs_variant-handle = 'GRID'.
ENDFORM.

*----------------------------------------------------------------------*
* Event Handlers for SALV (Forms Only)
*----------------------------------------------------------------------*
FORM handle_salv_user_command USING e_ucomm TYPE syucomm.
  " Handle user commands
  CASE e_ucomm.
    WHEN 'SAVE'.
      PERFORM save_changes.
    WHEN 'REFRESH'.
      PERFORM refresh_data.
    WHEN OTHERS.
      " Handle other commands
  ENDCASE.
ENDFORM.

FORM handle_salv_double_click USING row TYPE i column TYPE lvc_fname.
  " Handle double click events
  MESSAGE |Double clicked on row { row } column { column }| TYPE 'I'.
ENDFORM.

*----------------------------------------------------------------------*
* Callback Forms for Function Module Approach
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  " Define custom status with buttons
  DATA: lt_exclude TYPE TABLE OF syucomm.
  
  " Exclude standard buttons if needed
  APPEND '&LOCAL' TO lt_exclude.
  APPEND '&GRAPH' TO lt_exclude.
  
  SET PF-STATUS 'STANDARD' EXCLUDING lt_exclude.
ENDFORM.

FORM user_command USING r_ucomm     TYPE syucomm
                        rs_selfield  TYPE slis_selfield.
  
  CASE r_ucomm.
    WHEN 'SAVE'.
      PERFORM save_changes.
    WHEN 'REFRESH'.
      PERFORM refresh_data.
    WHEN 'DELETE'.
      PERFORM delete_selected.
    WHEN 'ADD'.
      PERFORM add_new_record.
    WHEN OTHERS.
      " Handle other commands
  ENDCASE.
  
  rs_selfield-refresh = 'X'.
ENDFORM.

FORM top_of_page.
  " Header for ALV
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.
  
  " Title
  ls_header-typ = 'H'.
  ls_header-info = 'Task Management System - No Classes'.
  APPEND ls_header TO lt_header.
  
  " Subtitle
  ls_header-typ = 'S'.
  ls_header-info = 'Dropdown Example using Forms and Function Modules Only'.
  APPEND ls_header TO lt_header.
  
  " Display header
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.

*----------------------------------------------------------------------*
* Business Logic Forms
*----------------------------------------------------------------------*
FORM save_changes.
  " Save changes to database or perform other actions
  DATA: lv_count TYPE i.
  
  " Count selected records
  LOOP AT gt_data INTO DATA(ls_data) WHERE sel = 'X'.
    lv_count = lv_count + 1.
    " Here you would save to database
  ENDLOOP.
  
  IF lv_count > 0.
    MESSAGE |{ lv_count } record(s) saved successfully!| TYPE 'S'.
  ELSE.
    MESSAGE 'No records selected for saving!' TYPE 'W'.
  ENDIF.
ENDFORM.

FORM refresh_data.
  " Refresh data from database
  CLEAR gt_data.
  PERFORM prepare_data.
  MESSAGE 'Data refreshed!' TYPE 'S'.
ENDFORM.

FORM delete_selected.
  " Delete selected records
  DATA: lv_count TYPE i.
  
  " Count selected records
  LOOP AT gt_data INTO DATA(ls_data) WHERE sel = 'X'.
    lv_count = lv_count + 1.
  ENDLOOP.
  
  IF lv_count > 0.
    " Delete selected records
    DELETE gt_data WHERE sel = 'X'.
    MESSAGE |{ lv_count } record(s) deleted!| TYPE 'S'.
  ELSE.
    MESSAGE 'No records selected for deletion!' TYPE 'W'.
  ENDIF.
ENDFORM.

FORM add_new_record.
  " Add new record
  DATA: ls_data TYPE ty_data,
        lv_max_id TYPE i.
  
  " Find maximum ID
  LOOP AT gt_data INTO DATA(ls_existing).
    IF ls_existing-id > lv_max_id.
      lv_max_id = ls_existing-id.
    ENDIF.
  ENDLOOP.
  
  " Create new record
  ls_data-id = lv_max_id + 1.
  ls_data-name = |New Task { ls_data-id }|.
  ls_data-status = 'OPEN'.
  ls_data-category = 'DEVELOPMENT'.
  ls_data-priority = 'MEDIUM'.
  ls_data-sel = ''.
  
  APPEND ls_data TO gt_data.
  MESSAGE 'New record added!' TYPE 'S'.
ENDFORM.