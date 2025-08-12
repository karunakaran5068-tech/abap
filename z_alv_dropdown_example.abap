*&---------------------------------------------------------------------*
*& Report Z_ALV_DROPDOWN_EXAMPLE
*&---------------------------------------------------------------------*
*& This program demonstrates how to implement dropdowns (combo boxes)
*& in ALV Grid using REUSE_ALV_GRID_DISPLAY
*&---------------------------------------------------------------------*
REPORT z_alv_dropdown_example.

*----------------------------------------------------------------------*
* Data Declarations
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_data,
         id         TYPE i,
         name       TYPE string,
         status     TYPE string,
         category   TYPE string,
         priority   TYPE string,
       END OF ty_data.

DATA: gt_data      TYPE TABLE OF ty_data,
      gt_fieldcat  TYPE slis_t_fieldcat_alv,
      gs_layout    TYPE slis_layout_alv,
      gs_variant   TYPE disvariant.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* Main Program
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM prepare_data.
  PERFORM display_alv.

*----------------------------------------------------------------------*
* Forms
*----------------------------------------------------------------------*
FORM prepare_data.
  " Sample data with different values for dropdowns
  DATA: ls_data TYPE ty_data.
  
  ls_data-id = 1.
  ls_data-name = 'Task 1'.
  ls_data-status = 'OPEN'.
  ls_data-category = 'DEVELOPMENT'.
  ls_data-priority = 'HIGH'.
  APPEND ls_data TO gt_data.
  
  ls_data-id = 2.
  ls_data-name = 'Task 2'.
  ls_data-status = 'IN_PROGRESS'.
  ls_data-category = 'TESTING'.
  ls_data-priority = 'MEDIUM'.
  APPEND ls_data TO gt_data.
  
  ls_data-id = 3.
  ls_data-name = 'Task 3'.
  ls_data-status = 'CLOSED'.
  ls_data-category = 'DOCUMENTATION'.
  ls_data-priority = 'LOW'.
  APPEND ls_data TO gt_data.
  
  ls_data-id = 4.
  ls_data-name = 'Task 4'.
  ls_data-status = 'OPEN'.
  ls_data-category = 'DEVELOPMENT'.
  ls_data-priority = 'HIGH'.
  APPEND ls_data TO gt_data.
ENDFORM.

*----------------------------------------------------------------------*
FORM display_alv.
  PERFORM build_fieldcat.
  PERFORM set_layout.
  PERFORM set_variant.
  
  " Display ALV Grid with dropdowns
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
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
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

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
  ls_fieldcat-drdn_hndl = '1'.  " Dropdown handle
  ls_fieldcat-drdn_alias = 'X'. " Use alias for dropdown
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Category Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext_l = 'Category'.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '2'.  " Dropdown handle
  ls_fieldcat-drdn_alias = 'X'. " Use alias for dropdown
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Priority Field - Dropdown
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRIORITY'.
  ls_fieldcat-seltext_l = 'Priority'.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '3'.  " Dropdown handle
  ls_fieldcat-drdn_alias = 'X'. " Use alias for dropdown
  APPEND ls_fieldcat TO gt_fieldcat.
ENDFORM.

*----------------------------------------------------------------------*
FORM set_layout.
  " Set layout parameters
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-box_fieldname = 'SEL'.
  gs_layout-box_tabname = 'GT_DATA'.
ENDFORM.

*----------------------------------------------------------------------*
FORM set_variant.
  " Set variant
  gs_variant-report = sy-repid.
  gs_variant-handle = 'GRID'.
ENDFORM.

*----------------------------------------------------------------------*
* Callback Forms
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.
ENDFORM.

*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     TYPE syucomm
                        rs_selfield  TYPE slis_selfield.
  
  CASE r_ucomm.
    WHEN 'SAVE'.
      PERFORM save_changes.
    WHEN 'REFRESH'.
      PERFORM refresh_data.
    WHEN OTHERS.
      " Handle other commands
  ENDCASE.
  
  rs_selfield-refresh = 'X'.
ENDFORM.

*----------------------------------------------------------------------*
* Additional Forms for Dropdown Handling
*----------------------------------------------------------------------*
FORM save_changes.
  " Save changes to database or perform other actions
  MESSAGE 'Changes saved successfully!' TYPE 'S'.
ENDFORM.

*----------------------------------------------------------------------*
FORM refresh_data.
  " Refresh data from database
  PERFORM prepare_data.
  MESSAGE 'Data refreshed!' TYPE 'S'.
ENDFORM.

*----------------------------------------------------------------------*
* Alternative Method: Using Dropdown Tables
*----------------------------------------------------------------------*
* If you want to define dropdown values explicitly, you can use this approach:

FORM build_dropdown_tables.
  DATA: lt_dropdown TYPE TABLE OF vrm_value,
        ls_dropdown TYPE vrm_value.
  
  " Status dropdown values
  CLEAR lt_dropdown.
  ls_dropdown-key = 'OPEN'.
  ls_dropdown-text = 'Open'.
  APPEND ls_dropdown TO lt_dropdown.
  
  ls_dropdown-key = 'IN_PROGRESS'.
  ls_dropdown-text = 'In Progress'.
  APPEND ls_dropdown TO lt_dropdown.
  
  ls_dropdown-key = 'CLOSED'.
  ls_dropdown-text = 'Closed'.
  APPEND ls_dropdown TO lt_dropdown.
  
  " Set dropdown values for status field
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'STATUS'
      values = lt_dropdown.
  
  " Category dropdown values
  CLEAR lt_dropdown.
  ls_dropdown-key = 'DEVELOPMENT'.
  ls_dropdown-text = 'Development'.
  APPEND ls_dropdown TO lt_dropdown.
  
  ls_dropdown-key = 'TESTING'.
  ls_dropdown-text = 'Testing'.
  APPEND ls_dropdown TO lt_dropdown.
  
  ls_dropdown-key = 'DOCUMENTATION'.
  ls_dropdown-text = 'Documentation'.
  APPEND ls_dropdown TO lt_dropdown.
  
  " Set dropdown values for category field
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'CATEGORY'
      values = lt_dropdown.
  
  " Priority dropdown values
  CLEAR lt_dropdown.
  ls_dropdown-key = 'HIGH'.
  ls_dropdown-text = 'High'.
  APPEND ls_dropdown TO lt_dropdown.
  
  ls_dropdown-key = 'MEDIUM'.
  ls_dropdown-text = 'Medium'.
  APPEND ls_dropdown TO lt_dropdown.
  
  ls_dropdown-key = 'LOW'.
  ls_dropdown-text = 'Low'.
  APPEND ls_dropdown TO lt_dropdown.
  
  " Set dropdown values for priority field
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'PRIORITY'
      values = lt_dropdown.
ENDFORM.