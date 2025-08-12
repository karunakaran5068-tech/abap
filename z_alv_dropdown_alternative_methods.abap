*&---------------------------------------------------------------------*
*& Report Z_ALV_DROPDOWN_ALTERNATIVE_METHODS
*&---------------------------------------------------------------------*
*& This program demonstrates various alternative methods for
*& implementing dropdowns in SAP ABAP ALV Grid
*&---------------------------------------------------------------------*
REPORT z_alv_dropdown_alternative_methods.

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
      go_alv       TYPE REF TO cl_salv_table,
      go_columns   TYPE REF TO cl_salv_columns_table,
      go_column    TYPE REF TO cl_salv_column_table.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_method TYPE char1 DEFAULT '1'.
SELECTION-SCREEN COMMENT 1(50) text-002.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 1(50) text-003.
SELECTION-SCREEN COMMENT 1(50) text-004.
SELECTION-SCREEN COMMENT 1(50) text-005.
SELECTION-SCREEN COMMENT 1(50) text-006.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Main Program
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM prepare_data.
  
  CASE p_method.
    WHEN '1'.
      PERFORM method_1_salv_dropdown.
    WHEN '2'.
      PERFORM method_2_cl_gui_alv_grid.
    WHEN '3'.
      PERFORM method_3_reuse_alv_list.
    WHEN '4'.
      PERFORM method_4_dynamic_dropdown.
    WHEN '5'.
      PERFORM method_5_checkbox_dropdown.
    WHEN OTHERS.
      PERFORM method_1_salv_dropdown.
  ENDCASE.

*----------------------------------------------------------------------*
* Method 1: SALV (Simple ALV) with Dropdowns
*----------------------------------------------------------------------*
FORM method_1_salv_dropdown.
  TRY.
    " Create SALV instance
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = go_alv
      CHANGING
        t_table      = gt_data ).
    
    " Get columns
    go_columns = go_alv->get_columns( ).
    
    " Configure Status column as dropdown
    go_column ?= go_columns->get_column( 'STATUS' ).
    go_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
    go_column->set_dropdown_table( build_status_dropdown( ) ).
    
    " Configure Category column as dropdown
    go_column ?= go_columns->get_column( 'CATEGORY' ).
    go_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
    go_column->set_dropdown_table( build_category_dropdown( ) ).
    
    " Configure Priority column as dropdown
    go_column ?= go_columns->get_column( 'PRIORITY' ).
    go_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
    go_column->set_dropdown_table( build_priority_dropdown( ) ).
    
    " Set editable
    go_alv->get_display_settings( )->set_list_header( 'SALV Dropdown Example' ).
    go_alv->get_functions( )->set_all( abap_true ).
    
    " Display
    go_alv->display( ).
    
  CATCH cx_salv_msg INTO DATA(lx_salv).
    MESSAGE lx_salv TYPE 'E'.
  ENDTRY.
ENDFORM.

*----------------------------------------------------------------------*
* Method 2: CL_GUI_ALV_GRID with Dropdowns
*----------------------------------------------------------------------*
FORM method_2_cl_gui_alv_grid.
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
  
  " Build dropdown tables
  PERFORM build_lvc_dropdowns USING lt_dropdown.
  
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
ENDFORM.

*----------------------------------------------------------------------*
* Method 3: REUSE_ALV_LIST_DISPLAY with Dropdowns
*----------------------------------------------------------------------*
FORM method_3_reuse_alv_list.
  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
        gs_layout   TYPE slis_layout_alv,
        gt_dropdown TYPE slis_t_dropdown_alv.

  " Build field catalog
  PERFORM build_list_fieldcat USING gt_fieldcat.
  
  " Build dropdown tables
  PERFORM build_list_dropdowns USING gt_dropdown.
  
  " Set layout
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.

  " Display list
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = gt_fieldcat
      it_dropdown        = gt_dropdown
      is_layout          = gs_layout
    TABLES
      t_outtab           = gt_data
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
ENDFORM.

*----------------------------------------------------------------------*
* Method 4: Dynamic Dropdown with Search Help
*----------------------------------------------------------------------*
FORM method_4_dynamic_dropdown.
  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
        gs_layout   TYPE slis_layout_alv.

  " Build field catalog with search help
  PERFORM build_search_help_fieldcat USING gt_fieldcat.
  
  " Set layout
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.

  " Display ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = gt_fieldcat
      is_layout          = gs_layout
    TABLES
      t_outtab           = gt_data.
ENDFORM.

*----------------------------------------------------------------------*
* Method 5: Checkbox Dropdown (Multi-Select)
*----------------------------------------------------------------------*
FORM method_5_checkbox_dropdown.
  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
        gs_layout   TYPE slis_layout_alv.

  " Build field catalog with checkboxes
  PERFORM build_checkbox_fieldcat USING gt_fieldcat.
  
  " Set layout
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-box_fieldname = 'SEL'.

  " Display ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = gt_fieldcat
      is_layout          = gs_layout
    TABLES
      t_outtab           = gt_data.
ENDFORM.

*----------------------------------------------------------------------*
* Helper Methods for SALV
*----------------------------------------------------------------------*
FORM build_status_dropdown RETURNING VALUE(rt_dropdown) TYPE lvc_t_dral.
  DATA: ls_dropdown TYPE lvc_s_dral.
  
  ls_dropdown-handle = '1'.
  ls_dropdown-value = 'OPEN'.
  ls_dropdown-text = 'Open'.
  APPEND ls_dropdown TO rt_dropdown.
  
  ls_dropdown-value = 'IN_PROGRESS'.
  ls_dropdown-text = 'In Progress'.
  APPEND ls_dropdown TO rt_dropdown.
  
  ls_dropdown-value = 'CLOSED'.
  ls_dropdown-text = 'Closed'.
  APPEND ls_dropdown TO rt_dropdown.
ENDFORM.

FORM build_category_dropdown RETURNING VALUE(rt_dropdown) TYPE lvc_t_dral.
  DATA: ls_dropdown TYPE lvc_s_dral.
  
  ls_dropdown-handle = '2'.
  ls_dropdown-value = 'DEVELOPMENT'.
  ls_dropdown-text = 'Development'.
  APPEND ls_dropdown TO rt_dropdown.
  
  ls_dropdown-value = 'TESTING'.
  ls_dropdown-text = 'Testing'.
  APPEND ls_dropdown TO rt_dropdown.
  
  ls_dropdown-value = 'DOCUMENTATION'.
  ls_dropdown-text = 'Documentation'.
  APPEND ls_dropdown TO rt_dropdown.
ENDFORM.

FORM build_priority_dropdown RETURNING VALUE(rt_dropdown) TYPE lvc_t_dral.
  DATA: ls_dropdown TYPE lvc_s_dral.
  
  ls_dropdown-handle = '3'.
  ls_dropdown-value = 'HIGH'.
  ls_dropdown-text = 'High'.
  APPEND ls_dropdown TO rt_dropdown.
  
  ls_dropdown-value = 'MEDIUM'.
  ls_dropdown-text = 'Medium'.
  APPEND ls_dropdown TO rt_dropdown.
  
  ls_dropdown-value = 'LOW'.
  ls_dropdown-text = 'Low'.
  APPEND ls_dropdown TO rt_dropdown.
ENDFORM.

*----------------------------------------------------------------------*
* Helper Methods for CL_GUI_ALV_GRID
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

FORM build_lvc_dropdowns USING pt_dropdown TYPE lvc_t_dral.
  DATA: ls_dropdown TYPE lvc_s_dral.
  
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
* Helper Methods for REUSE_ALV_LIST
*----------------------------------------------------------------------*
FORM build_list_fieldcat USING pt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  
  " ID Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ID'.
  ls_fieldcat-seltext_l = 'ID'.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-outputlen = 5.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Name Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext_l = 'Task Name'.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-edit = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Status Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-seltext_l = 'Status'.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '1'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Category Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext_l = 'Category'.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '2'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Priority Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRIORITY'.
  ls_fieldcat-seltext_l = 'Priority'.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '3'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
ENDFORM.

FORM build_list_dropdowns USING pt_dropdown TYPE slis_t_dropdown_alv.
  DATA: ls_dropdown TYPE slis_dropdown_alv.
  
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
* Helper Methods for Search Help
*----------------------------------------------------------------------*
FORM build_search_help_fieldcat USING pt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  
  " ID Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ID'.
  ls_fieldcat-seltext_l = 'ID'.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-outputlen = 5.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Name Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext_l = 'Task Name'.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-edit = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Status Field - with Search Help
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-seltext_l = 'Status'.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-search_help = 'Z_STATUS_HELP'. " Custom search help
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Category Field - with Search Help
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext_l = 'Category'.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-search_help = 'Z_CATEGORY_HELP'. " Custom search help
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Priority Field - with Search Help
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRIORITY'.
  ls_fieldcat-seltext_l = 'Priority'.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-search_help = 'Z_PRIORITY_HELP'. " Custom search help
  APPEND ls_fieldcat TO pt_fieldcat.
ENDFORM.

*----------------------------------------------------------------------*
* Helper Methods for Checkbox Dropdown
*----------------------------------------------------------------------*
FORM build_checkbox_fieldcat USING pt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  
  " Selection checkbox
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-seltext_l = 'Select'.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-outputlen = 3.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-just = 'C'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " ID Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ID'.
  ls_fieldcat-seltext_l = 'ID'.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-just = 'C'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Name Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext_l = 'Task Name'.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-edit = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Status Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-seltext_l = 'Status'.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '1'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Category Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext_l = 'Category'.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '2'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
  
  " Priority Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRIORITY'.
  ls_fieldcat-seltext_l = 'Priority'.
  ls_fieldcat-col_pos = 6.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '3'.
  ls_fieldcat-drdn_alias = 'X'.
  APPEND ls_fieldcat TO pt_fieldcat.
ENDFORM.

*----------------------------------------------------------------------*
* Data Preparation
*----------------------------------------------------------------------*
FORM prepare_data.
  DATA: ls_data TYPE ty_data.
  
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
ENDFORM.