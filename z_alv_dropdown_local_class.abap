*&---------------------------------------------------------------------*
*& Report Z_ALV_DROPDOWN_LOCAL_CLASS
*&---------------------------------------------------------------------*
*& This program demonstrates how to implement dropdowns in ALV
*& using local classes instead of global classes
*&---------------------------------------------------------------------*
REPORT z_alv_dropdown_local_class.

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
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Local Class for ALV Handling
*----------------------------------------------------------------------*
CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor,
      prepare_data,
      display_salv_dropdown,
      display_grid_dropdown,
      display_function_dropdown.
  
  PRIVATE SECTION.
    DATA: mt_data      TYPE TABLE OF ty_data,
          mt_fieldcat  TYPE slis_t_fieldcat_alv,
          ms_layout    TYPE slis_layout_alv,
          mt_dropdown  TYPE lvc_t_dral.
    
    METHODS:
      build_fieldcat,
      build_dropdown_values,
      build_salv_dropdown_values RETURNING VALUE(rt_dropdown) TYPE lvc_t_dral,
      handle_user_command FOR EVENT user_command OF cl_salv_events
        IMPORTING e_ucomm,
      handle_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.

*----------------------------------------------------------------------*
* Local Class Implementation
*----------------------------------------------------------------------*
CLASS lcl_alv_handler IMPLEMENTATION.
  
  METHOD constructor.
    " Initialize data
    prepare_data( ).
  ENDMETHOD.
  
  METHOD prepare_data.
    DATA: ls_data TYPE ty_data.
    
    " Sample data
    ls_data-id = 1.
    ls_data-name = 'Task 1'.
    ls_data-status = 'OPEN'.
    ls_data-category = 'DEVELOPMENT'.
    ls_data-priority = 'HIGH'.
    ls_data-sel = ''.
    APPEND ls_data TO mt_data.
    
    ls_data-id = 2.
    ls_data-name = 'Task 2'.
    ls_data-status = 'IN_PROGRESS'.
    ls_data-category = 'TESTING'.
    ls_data-priority = 'MEDIUM'.
    ls_data-sel = ''.
    APPEND ls_data TO mt_data.
    
    ls_data-id = 3.
    ls_data-name = 'Task 3'.
    ls_data-status = 'CLOSED'.
    ls_data-category = 'DOCUMENTATION'.
    ls_data-priority = 'LOW'.
    ls_data-sel = ''.
    APPEND ls_data TO mt_data.
    
    " Copy to global table
    gt_data = mt_data.
  ENDMETHOD.
  
  METHOD display_salv_dropdown.
    DATA: lo_events TYPE REF TO cl_salv_events_table.
    
    TRY.
      " Create SALV instance using local class
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = mt_data ).
      
      " Get columns
      go_columns = go_alv->get_columns( ).
      
      " Configure Status column as dropdown
      go_column ?= go_columns->get_column( 'STATUS' ).
      go_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
      go_column->set_dropdown_table( build_salv_dropdown_values( ) ).
      
      " Configure Category column as dropdown
      go_column ?= go_columns->get_column( 'CATEGORY' ).
      go_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
      go_column->set_dropdown_table( build_salv_dropdown_values( ) ).
      
      " Configure Priority column as dropdown
      go_column ?= go_columns->get_column( 'PRIORITY' ).
      go_column->set_cell_type( if_salv_c_cell_type=>dropdown ).
      go_column->set_dropdown_table( build_salv_dropdown_values( ) ).
      
      " Set editable
      go_alv->get_display_settings( )->set_list_header( 'Local Class SALV Dropdown' ).
      go_alv->get_functions( )->set_all( abap_true ).
      
      " Set events
      lo_events = go_alv->get_event( ).
      SET HANDLER handle_user_command FOR lo_events.
      SET HANDLER handle_double_click FOR lo_events.
      
      " Display
      go_alv->display( ).
      
    CATCH cx_salv_msg INTO DATA(lx_salv).
      MESSAGE lx_salv TYPE 'E'.
    ENDTRY.
  ENDMETHOD.
  
  METHOD display_grid_dropdown.
    DATA: lo_container TYPE REF TO cl_gui_custom_container,
          lo_grid      TYPE REF TO cl_gui_alv_grid,
          lt_fieldcat  TYPE lvc_t_fcat,
          ls_layout    TYPE lvc_s_layo.
    
    " Create container (using local class approach)
    CREATE OBJECT lo_container
      EXPORTING
        container_name = 'CONTAINER'.
    
    " Create grid
    CREATE OBJECT lo_grid
      EXPORTING
        i_parent = lo_container.
    
    " Build field catalog using local method
    build_fieldcat( ).
    
    " Build dropdown values
    build_dropdown_values( ).
    
    " Set layout
    ls_layout-zebra = 'X'.
    ls_layout-cwidth_opt = 'X'.
    ls_layout-edit = 'X'.
    
    " Display grid
    lo_grid->set_table_for_first_display(
      EXPORTING
        is_layout                     = ls_layout
        it_dropdown                   = mt_dropdown
      CHANGING
        it_outtab                     = mt_data
        it_fieldcatalog               = lt_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines               = 3
        OTHERS                       = 4 ).
        
    IF sy-subrc <> 0.
      MESSAGE 'Error displaying grid' TYPE 'E'.
    ENDIF.
  ENDMETHOD.
  
  METHOD display_function_dropdown.
    " Build field catalog
    build_fieldcat( ).
    
    " Set layout
    ms_layout-zebra = 'X'.
    ms_layout-colwidth_optimize = 'X'.
    ms_layout-edit = 'X'.
    
    " Display using function module (no global class needed)
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = sy-repid
        i_callback_pf_status_set = 'SET_PF_STATUS'
        i_callback_user_command  = 'USER_COMMAND'
        is_layout               = ms_layout
        it_fieldcat             = mt_fieldcat
        i_save                  = 'A'
      TABLES
        t_outtab                = mt_data
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.
        
    IF sy-subrc <> 0.
      MESSAGE 'Error displaying ALV' TYPE 'E'.
    ENDIF.
  ENDMETHOD.
  
  METHOD build_fieldcat.
    DATA: ls_fieldcat TYPE slis_fieldcat_alv.
    
    " Clear field catalog
    CLEAR mt_fieldcat.
    
    " ID Field
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'ID'.
    ls_fieldcat-seltext_l = 'ID'.
    ls_fieldcat-col_pos = 1.
    ls_fieldcat-outputlen = 5.
    ls_fieldcat-just = 'C'.
    APPEND ls_fieldcat TO mt_fieldcat.
    
    " Name Field
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'NAME'.
    ls_fieldcat-seltext_l = 'Task Name'.
    ls_fieldcat-col_pos = 2.
    ls_fieldcat-outputlen = 20.
    ls_fieldcat-edit = 'X'.
    APPEND ls_fieldcat TO mt_fieldcat.
    
    " Status Field - Dropdown
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'STATUS'.
    ls_fieldcat-seltext_l = 'Status'.
    ls_fieldcat-col_pos = 3.
    ls_fieldcat-outputlen = 15.
    ls_fieldcat-edit = 'X'.
    ls_fieldcat-drdn_hndl = '1'.
    ls_fieldcat-drdn_alias = 'X'.
    APPEND ls_fieldcat TO mt_fieldcat.
    
    " Category Field - Dropdown
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'CATEGORY'.
    ls_fieldcat-seltext_l = 'Category'.
    ls_fieldcat-col_pos = 4.
    ls_fieldcat-outputlen = 15.
    ls_fieldcat-edit = 'X'.
    ls_fieldcat-drdn_hndl = '2'.
    ls_fieldcat-drdn_alias = 'X'.
    APPEND ls_fieldcat TO mt_fieldcat.
    
    " Priority Field - Dropdown
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'PRIORITY'.
    ls_fieldcat-seltext_l = 'Priority'.
    ls_fieldcat-col_pos = 5.
    ls_fieldcat-outputlen = 10.
    ls_fieldcat-edit = 'X'.
    ls_fieldcat-drdn_hndl = '3'.
    ls_fieldcat-drdn_alias = 'X'.
    APPEND ls_fieldcat TO mt_fieldcat.
  ENDMETHOD.
  
  METHOD build_dropdown_values.
    DATA: ls_dropdown TYPE lvc_s_dral.
    
    " Clear dropdown table
    CLEAR mt_dropdown.
    
    " Status dropdown values
    ls_dropdown-handle = '1'.
    ls_dropdown-value = 'OPEN'.
    ls_dropdown-text = 'Open'.
    APPEND ls_dropdown TO mt_dropdown.
    
    ls_dropdown-value = 'IN_PROGRESS'.
    ls_dropdown-text = 'In Progress'.
    APPEND ls_dropdown TO mt_dropdown.
    
    ls_dropdown-value = 'CLOSED'.
    ls_dropdown-text = 'Closed'.
    APPEND ls_dropdown TO mt_dropdown.
    
    " Category dropdown values
    ls_dropdown-handle = '2'.
    ls_dropdown-value = 'DEVELOPMENT'.
    ls_dropdown-text = 'Development'.
    APPEND ls_dropdown TO mt_dropdown.
    
    ls_dropdown-value = 'TESTING'.
    ls_dropdown-text = 'Testing'.
    APPEND ls_dropdown TO mt_dropdown.
    
    ls_dropdown-value = 'DOCUMENTATION'.
    ls_dropdown-text = 'Documentation'.
    APPEND ls_dropdown TO mt_dropdown.
    
    " Priority dropdown values
    ls_dropdown-handle = '3'.
    ls_dropdown-value = 'HIGH'.
    ls_dropdown-text = 'High'.
    APPEND ls_dropdown TO mt_dropdown.
    
    ls_dropdown-value = 'MEDIUM'.
    ls_dropdown-text = 'Medium'.
    APPEND ls_dropdown TO mt_dropdown.
    
    ls_dropdown-value = 'LOW'.
    ls_dropdown-text = 'Low'.
    APPEND ls_dropdown TO mt_dropdown.
  ENDMETHOD.
  
  METHOD build_salv_dropdown_values.
    DATA: ls_dropdown TYPE lvc_s_dral.
    
    " Status dropdown values
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
    
    " Category dropdown values
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
    
    " Priority dropdown values
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
  ENDMETHOD.
  
  METHOD handle_user_command.
    " Handle user commands
    CASE e_ucomm.
      WHEN 'SAVE'.
        MESSAGE 'Save functionality - implement your logic here' TYPE 'S'.
      WHEN 'REFRESH'.
        MESSAGE 'Refresh functionality - implement your logic here' TYPE 'S'.
      WHEN OTHERS.
        " Handle other commands
    ENDCASE.
  ENDMETHOD.
  
  METHOD handle_double_click.
    " Handle double click events
    MESSAGE |Double clicked on row { row } column { column }| TYPE 'I'.
  ENDMETHOD.
  
ENDCLASS.

*----------------------------------------------------------------------*
* Main Program
*----------------------------------------------------------------------*
START-OF-SELECTION.
  DATA: lo_handler TYPE REF TO lcl_alv_handler.
  
  " Create local class instance
  CREATE OBJECT lo_handler.
  
  " Display based on method selection
  CASE p_method.
    WHEN '1'.
      lo_handler->display_salv_dropdown( ).
    WHEN '2'.
      lo_handler->display_grid_dropdown( ).
    WHEN '3'.
      lo_handler->display_function_dropdown( ).
    WHEN OTHERS.
      lo_handler->display_salv_dropdown( ).
  ENDCASE.

*----------------------------------------------------------------------*
* Callback Forms (for function module approach)
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.
ENDFORM.

FORM user_command USING r_ucomm     TYPE syucomm
                        rs_selfield  TYPE slis_selfield.
  
  CASE r_ucomm.
    WHEN 'SAVE'.
      MESSAGE 'Save functionality - implement your logic here' TYPE 'S'.
    WHEN 'REFRESH'.
      MESSAGE 'Refresh functionality - implement your logic here' TYPE 'S'.
    WHEN OTHERS.
      " Handle other commands
  ENDCASE.
  
  rs_selfield-refresh = 'X'.
ENDFORM.