*&---------------------------------------------------------------------*
*& Report Z_ALV_DROPDOWN_ENHANCED
*&---------------------------------------------------------------------*
*& Enhanced version showing proper dropdown implementation
*& in ALV Grid using REUSE_ALV_GRID_DISPLAY
*&---------------------------------------------------------------------*
REPORT z_alv_dropdown_enhanced.

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
      gs_variant   TYPE disvariant.

* Dropdown value tables
DATA: gt_status_values   TYPE TABLE OF vrm_value,
      gt_category_values TYPE TABLE OF vrm_value,
      gt_priority_values TYPE TABLE OF vrm_value.

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
  PERFORM build_dropdown_values.
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
FORM build_dropdown_values.
  DATA: ls_value TYPE vrm_value.
  
  " Status dropdown values
  CLEAR gt_status_values.
  ls_value-key = 'OPEN'.
  ls_value-text = 'Open'.
  APPEND ls_value TO gt_status_values.
  
  ls_value-key = 'IN_PROGRESS'.
  ls_value-text = 'In Progress'.
  APPEND ls_value TO gt_status_values.
  
  ls_value-key = 'CLOSED'.
  ls_value-text = 'Closed'.
  APPEND ls_value TO gt_status_values.
  
  ls_value-key = 'ON_HOLD'.
  ls_value-text = 'On Hold'.
  APPEND ls_value TO gt_status_values.
  
  " Category dropdown values
  CLEAR gt_category_values.
  ls_value-key = 'DEVELOPMENT'.
  ls_value-text = 'Development'.
  APPEND ls_value TO gt_category_values.
  
  ls_value-key = 'TESTING'.
  ls_value-text = 'Testing'.
  APPEND ls_value TO gt_category_values.
  
  ls_value-key = 'DOCUMENTATION'.
  ls_value-text = 'Documentation'.
  APPEND ls_value TO gt_category_values.
  
  ls_value-key = 'ANALYSIS'.
  ls_value-text = 'Analysis'.
  APPEND ls_value TO gt_category_values.
  
  " Priority dropdown values
  CLEAR gt_priority_values.
  ls_value-key = 'HIGH'.
  ls_value-text = 'High'.
  APPEND ls_value TO gt_priority_values.
  
  ls_value-key = 'MEDIUM'.
  ls_value-text = 'Medium'.
  APPEND ls_value TO gt_priority_values.
  
  ls_value-key = 'LOW'.
  ls_value-text = 'Low'.
  APPEND ls_value TO gt_priority_values.
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
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
FORM build_fieldcat.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  
  " Clear field catalog
  CLEAR gt_fieldcat.
  
  " Selection checkbox
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SEL'.
  ls_fieldcat-seltext_l = 'Select'.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-outputlen = 3.
  ls_fieldcat-checkbox = 'X'.
  ls_fieldcat-just = 'C'.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " ID Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ID'.
  ls_fieldcat-seltext_l = 'ID'.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-outputlen = 5.
  ls_fieldcat-just = 'C'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Name Field
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-seltext_l = 'Task Name'.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-outputlen = 20.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-hotspot = 'X'.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Status Field - Dropdown with value table
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STATUS'.
  ls_fieldcat-seltext_l = 'Status'.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '1'.
  ls_fieldcat-drdn_alias = 'X'.
  ls_fieldcat-value_otab = gt_status_values.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Category Field - Dropdown with value table
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CATEGORY'.
  ls_fieldcat-seltext_l = 'Category'.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-outputlen = 15.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '2'.
  ls_fieldcat-drdn_alias = 'X'.
  ls_fieldcat-value_otab = gt_category_values.
  APPEND ls_fieldcat TO gt_fieldcat.
  
  " Priority Field - Dropdown with value table
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRIORITY'.
  ls_fieldcat-seltext_l = 'Priority'.
  ls_fieldcat-col_pos = 6.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-edit = 'X'.
  ls_fieldcat-drdn_hndl = '3'.
  ls_fieldcat-drdn_alias = 'X'.
  ls_fieldcat-value_otab = gt_priority_values.
  APPEND ls_fieldcat TO gt_fieldcat.
ENDFORM.

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
  " Define custom status with buttons
  DATA: lt_exclude TYPE TABLE OF syucomm.
  
  " Exclude standard buttons if needed
  APPEND '&LOCAL' TO lt_exclude.
  APPEND '&GRAPH' TO lt_exclude.
  
  SET PF-STATUS 'STANDARD' EXCLUDING lt_exclude.
ENDFORM.

*----------------------------------------------------------------------*
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

*----------------------------------------------------------------------*
FORM top_of_page.
  " Header for ALV
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.
  
  " Title
  ls_header-typ = 'H'.
  ls_header-info = 'Task Management System'.
  APPEND ls_header TO lt_header.
  
  " Subtitle
  ls_header-typ = 'S'.
  ls_header-info = 'Dropdown Example with REUSE_ALV_GRID_DISPLAY'.
  APPEND ls_header TO lt_header.
  
  " Display header
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.

*----------------------------------------------------------------------*
* Additional Forms for Dropdown Handling
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

*----------------------------------------------------------------------*
FORM refresh_data.
  " Refresh data from database
  CLEAR gt_data.
  PERFORM prepare_data.
  MESSAGE 'Data refreshed!' TYPE 'S'.
ENDFORM.

*----------------------------------------------------------------------*
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

*----------------------------------------------------------------------*
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

*----------------------------------------------------------------------*
* Alternative Method: Using Domain-based Dropdowns
*----------------------------------------------------------------------*
* If you have domains defined in your system, you can use them:

FORM build_domain_dropdowns.
  DATA: lt_domain_values TYPE TABLE OF dd07v.
  
  " Get domain values for status (assuming domain exists)
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname        = 'Z_STATUS_DOMAIN'  " Replace with your domain
      text           = 'X'
      langu          = sy-langu
    TABLES
      dd07v_tab      = lt_domain_values
    EXCEPTIONS
      wrong_textflag = 1
      OTHERS         = 2.
  
  IF sy-subrc = 0.
    " Convert domain values to dropdown format
    LOOP AT lt_domain_values INTO DATA(ls_domain).
      DATA: ls_value TYPE vrm_value.
      ls_value-key = ls_domain-domvalue_l.
      ls_value-text = ls_domain-ddtext.
      APPEND ls_value TO gt_status_values.
    ENDLOOP.
  ENDIF.
ENDFORM.