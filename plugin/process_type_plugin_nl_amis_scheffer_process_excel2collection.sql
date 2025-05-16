prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run the script connected to SQL*Plus as the owner (parsing schema)
-- of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2022.10.07'
,p_release=>'22.2.0'
,p_default_workspace_id=>4800407278249095
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'ASCHEFFE'
);
end;
/
 
prompt APPLICATION 100 - Demo for Excel2Collection
--
-- Application Export:
--   Application:     100
--   Name:            Demo for Excel2Collection
--   Date and Time:   00:10 Saturday May 17, 2025
--   Exported By:     ANTON
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 50580935975708604
--   Manifest End
--   Version:         22.2.0
--   Instance ID:     1600152839179180
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/process_type/nl_amis_scheffer_process_excel2collection
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(50580935975708604)
,p_plugin_type=>'PROCESS TYPE'
,p_name=>'NL.AMIS.SCHEFFER.PROCESS.EXCEL2COLLECTION'
,p_display_name=>'Excel2Collection'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_PROC'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function parse_excel',
'  ( p_process apex_plugin.t_process',
'  , p_plugin apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_process_exec_result',
'is',
'  e_no_doc exception;',
'  l_rv apex_plugin.t_process_exec_result;',
'  t_parse    varchar2(32767);',
'  l_time            date := sysdate;',
'  l_log             clob;',
'  l_src             clob;',
'  l_document        blob;',
'  l_file_id         number;',
'  l_extended        boolean;',
'  l_api             sys_refcursor;',
'  l_what            varchar2(100);',
'  l_storage_type    varchar2(100);',
'  l_apex_version    varchar2(100);',
'  l_plugin_version  varchar2(100);',
'  l_filename        varchar2(32767);',
'  p_browse_item     varchar2(32767);',
'  p_collection_name varchar2(32767);',
'  p_sheet_nrs       varchar2(32767);',
'  p_separator       varchar2(32767);',
'  p_enclosed_by     varchar2(32767);',
'  p_encoding        varchar2(32767);',
'  p_round           varchar2(1);',
'  p_50              varchar2(1);',
'  t_x dbmsoutput_linesarray;',
'  --',
'  cursor c_src( b_app_id number, p_file_name varchar2 )',
'  is',
'    select apex_util.blob_to_clob( pgf.file_content, ''AL32UTF8'' )',
'    from apex_appl_plugin_files pgf',
'    where pgf.plugin_name = p_plugin.name',
'    and   pgf.application_id = b_app_id',
'    and   pgf.file_name   = p_file_name;',
'--',
'  t_parse_bef varchar2(32767) :=',
'''H4sIAAAAAAAAC4VSzW7DIAy+8xQcWymqumxaD9X2KsgQjyI5gAzJ2rcfoelftG43''||',
'''G39/thAdGgJGkU8RZY7KIJF0STKawJ1YdZBB1eEIbA7A7eplLZqU2XmrRqDb+2u7''||',
'''e9+VmR96jVxn51I0RQXrw1SIRlPQtZ0Ksd5f3Tl8T+YZNKEMX7dAvsOj1CcZKSnn''||',
'''M1rkB1Za0qrSn6x0QMz3q3ro77Zst9ttWaZqzx73Sae7LD1nxd9dz4yZOfUmEKHJ''||',
'''LnilIeHyjgvIY7grZE7TFuRDGoh4VBAjOQOVb8ulgTajUcDcPgvZXsSqOz+V8ZNK''||',
'''xZj/MTx/g72IHAx2A6PsT4qCXUXVJ3tday1cEhqt86KKdqgHq3pMCSxuCv5Sn3lN''||',
'''VIQjkvz4lG/lGOi7/Q+Kyt//0AIAAA=='';',
'  t_parse_aft varchar2(32767) :=',
'''H4sIAAAAAAAAC+WWS2+bQBDH73yKPVQCGuyyD/Jw5EhV1WOqHnrpCeFlHSPxsHZx''||',
'''4kj+8N3dYWIcnERVj40iwX93hvnNgzXBSj1UbdDnsqtrJfuqa/NVYRRZLMnCruVt''||',
'''0ahbu18WfeEWt4U2Klps87KTib2YjVK9sXf7+DZonvO6e4hCb1Qm4eEAjnPZ7dr+''||',
'''cAgJmJO11WU48mi6x6p9IH1Hvr2ARCZ2JsVW7Ud4c6lV0au803mvd61098fdaJKJ''||',
'''jZp/uv/60z1q3WlSkaollMznZMwW1F23PS2Dy9xlPK3N4WBBc7kpdNTu6rpaR1VC''||',
'''42k2PlkSWvvKUixI6Bx90KiK5+75riQ2Z1+oV6HPZF6UZd6oZqX0O2kGyTaXaUqX''||',
'''d6ehhnXm1l+Fclutd6mCfyv4AN6zealq1fvJkXos5Iuo1qNi6O7JQCeimNyRNOg3''||',
'''yo2ldh2g0Dn9qnMvfnVhjg10tdGx9dIQDyU9F1HtK9ObSMcQzxrYkdZuOMmShL9D''||',
'''WHbB5RvBre8o/iSC2x6CyJgU9rmTfbsxd0t5/7xVLuyPELM/Y9nuXP/zx6J2lfGo''||',
'''0QeGCRUzs1uZ3pZmGNuPPMJf99/DOJlxN9XKUldruLosjyunhcnSoQnMPg3LLt0L''||',
'''82TTebcwLl8iu6JWRqoIYc9B2g37akFaiUjTNE7+Iqmb8APz0k23Ny7LWdPMnu0f''||',
'''2WyYWDTVwpgwjolNflwLPzNZurTTcr6/fjzsTGfpaJr2x3Fy71Q0pfFuMxqTL9Yz''||',
'''xvHWcCLpC3r73rDL/ecsvaCjDg0rLiLcjrrVPtZ4kDVdGcnEBkzsv738P32cTreq''||',
'''jXLloVAEV/kwPG6fNuPo/vapbaaH5ei0doFGhzSLGEruJUcpvBQoMy8zlJdeXqK8''||',
'''8vIK5bWX1yhvvLwZJE0BI0U9YCEXBS6KYBTAKJJRIKOIRgGNIhsFNopwFOAo0lGg''||',
'''o4hHAY8iHwM+hnwM+BjysaFuyMeAjyEfAz6GfAz4GPIx4GPIx4CPIR8DPoZ8DPgY''||',
'''8nHg48jHgY8jHwc+jnx8aCzyceDjyMeBjyMfBz6OfBz4OPJx4OPIx4GPI58APoF8''||',
'''AvgE8gngE8gngE8gnxgmD/kE8AnkE8AnkE8An0A+AXwC+QTwCeTLgC8Dvnb4iJF6''||',
'''UPDpIoOzP0mjTy9Vnv2OdO/7H0N8nHXvCgAA'';',
'  t_parse_csv varchar2(32767) :=',
'''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''||',
'''NvoHYPVsDAwWAAA='';',
'--',
'  t_parse_xml varchar2(32767) :=',
'''H4sIAAAAAAAAC6VWbY/TMAz+3l8R7UsT0fX2ggDtBAKBkJCADzAE36qudbewNKmS''||',
'''7F6k+/HY6cu64w7uYNLUNHbsx/bjuFF10IWXRrMmtw4i3mSlKQ41aM82ymyipMnc''||',
'''DsA7dpHbYpfbBVu9ZPqgFIngytuclZvamYNvDj5TUoPLrc2vBzURWfAHq5lH27nP''||',
'''I+kin5HxrHCyRKV6AzaoK5eRCwc+kyWP33xcLr6t37+IxTmeuKoVw7+/boBegyey''||',
'''ac2lo40AU1vWoBWpPWzB0jaKb28VRt3eusjVECBfLp4/ex58Il7IqtofZfPZTBDW''||',
'''uCyndT29xh/b7RZPV7VcORfTIX3MFV/06ohcu5cTzMPKFTuoczetZWGNM5WfFqZe''||',
'''maqSBaxcYyEvQywTFrObm6g9isYfebrFUobqUPJKU6f416YM+dPqLomSzrfSxZ/F''||',
'''y/vFG9hKHdXXmTJbHhOvpN6yH58+skvpd4wSkxceqMwhwpO667wGPqKHGGqPWezK''||',
'''PyJpMlYdswC1Z10CcDnGWud7ILB8vLkF35sEBfQ4EWu4xEevwQMg0ULT6ujAqcaa''||',
'''ApwzNnVop/DkyHGCkcRn343db4zZh0UAGidEF7RTGcskk5rNWJqyW8gU6K3fkRUl''||',
'''pvNIGdOcRjq8PJmfR7JinA1dK13bhWRfO295vAo5HxRwjVtJt+1NqAQfLIpOQbBX''||',
'''bPZQK79nA/vrAKY6Sar0UIegEimS+LVzq89Y/C4lJ25F5Heg237MeftIC3PQ/slc''||',
'''pESZu2vwaK/nA22pj1p23uG19SmGayhF6oOH/rpBLPO+if7KjfuxrfONgrMv5vKE''||',
'''JT8fwJLFiCYdIH2h+CMTtEh+dhn6oEu46lBESbAZif4mPUa7/MdoW0dvQamTSPcP''||',
'''iHQ5irQD8w+RLpP9PZGizTZSGhCP51hrGO2+Q+4MwWGH/o+dMwK6xnuwbxUcL7gP''||',
'''a4k87julwzv0swmzjAdBEtPYovFVlpP15Di+0slsNpvEIjlOPoQLeIfKaiA7D/UX''||',
'''PCRHpNQVGd3KYcx9je/Tw1sDx8CAixYjBoUF3V7kjOo56qWwuC37rSe5ECl9CrQn''||',
'''AoIj9OPJ/lsknAyC81/ltxh2BAkAAA=='';',
'--',
'  t_parse_xls varchar2(32767) :=',
'''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''||',
'''Zz4lW6vAiB+14b/8iQfI/wErDDLQpVQAAA=='';',
'--',
'  t_parse_html varchar2(32767) :=',
'''H4sIAAAAAAAAC9VXzW7jOAy++ym0e7GNOm28M9PJbJpeOpc97aEPYCi2khhQJEOS''||',
'''23QxDz+k/mLHTtEeN0Bii6Io8uMnUkl2vahNKwXpqNIsybqqkTXZcrlNiq7SB8ZM''||',
'''JRTpuK5aYdieKfL3hoiec5xnJ6MoabZHLXvT9abirWCaKkXfolqeKGZ6JYgB29TQ''||',
'''pNWJqWrGOUrwuYaxkq84hIcfaT/UOMZ1YT2OD+bISQ1O2kmmTSV3O80MGfhY4pxW''||',
'''dZiazNW6bcDF45YpHHIq9lUtQelkvBhVMbgKdrpt2I72POiZE655pUq0Yk/sx9u3''||',
'''pvsRZCjqpL4UGbqtmGguxRD0nBi0OatqYSYTalbazEl1R8WlrJZ8VnxARhjyQhW+''||',
'''/pWVy+UyXydbtm9F0u5IRhxZWu0SLdUZrD0znIm9OThC5WRDliMF3W+1UW62+FaU''||',
'''OfljQ9IvT/er71/vf94/pcAbc2AiksfnHoFpdzF9SDJw2/tatU3WG1615UrcHmkX''||',
'''5Fn6z/O/i9Xq249FmRZL2A3iiK7UilHDDDt2UlH1ljl6FUb1bKQmxQtTxkjknVfC''||',
'''MwABJEXUgu+RnnT7H0uKETVxeGZjUogXnrkgimWOk0P+4dhzK8kDoSDWViBo3sH0''||',
'''YSubtzQP7Joq+PA3qAMJc2qPZEkooOhGD8Qad1jHpIMln6AQp9W+WSUFZ1SbDL3H''||',
'''pLe7bLwlSZ1qDlEV1nTuYp3V/vNT2vD5jPrjjHa+sKLFKnGQfIQ8ERXHHCTqOHke''||',
'''u2Edmqs/o7rzQeJe7P3/oGM4o+FpqYdLgHoBrHM1AzvLte8It3jIK/PWMRSnz+k6''||',
'''4VJ2V3e0VlKfXNjw1BryChv4/bzlUGen6++sgcd5C2EZWiGXLg+GN2VoWdAjOBSS''||',
'''QVF2wb0fg3o3AAJVM6AXfbqagxDKzZdPWgP3o/eQr9HpdyYXZajSd2nIYmhVc8iq''||',
'''K7CGNdGbIBh6REYQhveI9BDo5sNAN58A2jsVauvHgUbtaM3V24G1GWixHFloR8j6''||',
'''EFzZLeP5gJVwCKsXysP9CnbncHHzrX3aAlxz35xDt6fRKp87gR0+uN2cB67Lny8H''||',
'''6Ius3LUo4+DFMVP29zIc1L5Z+TZhDRYzHQK1cizG+LJY5dgK0jQ8LKQ16/Bimlhc''||',
'''JTil4EqI7z5qhNOHPnAyToZbwgTH2XQCX5srfH03oWQ+MTPHx2c67hA9PBM4vEea''||',
'''Z0GSu2l3WXbl1If8SMpYUqeGot6iHJdlPCgjeCJDz45hRcvC0cuj2hUDg1qCRTwb''||',
'''FMj8VtCjq+hWRlLy69ewgs4vsn8Cwq56uG3wMba5nWKTCxyAPL07rn8DAB+QK/EM''||',
'''AAA='';',
'--',
'  procedure log( p_msg varchar2, p_level number := 4 )',
'  is',
'  begin',
'--    apex_debug_message.error( p_msg );',
'    apex_debug_message.log_message( p_msg, p_level => p_level );',
'  end;',
'  function dc( p varchar2 ) return varchar2',
'  is',
'  begin',
'    return utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( p ) ) ) );',
'  end;',
'--',
'begin',
'  p_browse_item     := p_process.attribute_01;',
'  p_collection_name := p_process.attribute_02;',
'  p_sheet_nrs       := p_process.attribute_03;',
'  if upper( p_process.attribute_04 ) in ( ''HT'', ''^I'', ''\T'' )',
'  then',
'    p_separator := chr(9);',
'  elsif upper( p_process.attribute_04 ) in ( ''VT'', ''^K'', ''\V'' )',
'  then',
'    p_separator := chr(11);',
'  else',
'    p_separator := substr( ltrim( p_process.attribute_04 ), 1, 1 );',
'  end if;',
'  p_enclosed_by := substr( ltrim( p_process.attribute_05 ), 1, 1 );',
'  p_encoding    := p_process.attribute_06;',
'  p_round       := substr( ltrim( p_process.attribute_07 ), 1, 1 );',
'  p_50          := substr( ltrim( p_process.attribute_08 ), 1, 1 );',
'--',
'  open l_api for ''',
'    select '' || case when wwv_flow_api.c_current > 20240531',
'                  then ''json_value( api.attributes, ''''$.storage_type'''' )''',
'                  else ''api.attribute_01''',
'                end || q''~ storage_type',
'         , rel.version_no   apex_version',
'         , aap.display_name || '' version '' || aap.version_identifier plugin_version',
'    from apex_application_page_items api',
'    cross join apex_release rel',
'    cross join apex_appl_plugins aap',
'    where api.application_id = :app_id',
'    and   api.page_id = :page_id',
'    and   api.display_as_code = ''NATIVE_FILE''',
'    and   api.item_name = :item_name',
'    and   aap.application_id = :app_id',
'    and   aap.name = :plugin_name~''',
'    using nv(''APP_ID''), nv(''APP_PAGE_ID''), upper( p_browse_item ), nv(''APP_ID''), p_plugin.name;',
'  fetch l_api into l_storage_type, l_apex_version, l_plugin_version;',
'  if l_api%found',
'  then',
'    log( ''apex '' || l_apex_version || '', '' || l_plugin_version || '', '' || nls_charset_name( nls_charset_id( ''C'' ) ) );',
'  else',
'    log( ''FILE BROWSE item '' || p_browse_item || '' not found'' );',
'  end if;',
'  close l_api;',
'  l_filename := apex_util.get_session_state(  p_browse_item );',
'  log( ''looking for uploaded file '' || l_filename || '' in '' || l_storage_type );',
'--',
'  begin',
'    if l_storage_type = ''WWV_FLOW_FILES''',
'    then',
'      select aaf.id',
'           , aaf.blob_content',
'      into l_file_id',
'         , l_document',
'      from apex_application_files aaf',
'      where aaf.name = l_filename;',
'      --',
'      delete from apex_application_files aaf',
'      where aaf.id = l_file_id;',
'      --',
'      log( ''retrieved!''  );',
'    elsif l_storage_type = ''APEX_APPLICATION_TEMP_FILES''',
'    then',
'      select aaf.blob_content',
'      into l_document',
'      from apex_application_temp_files aaf',
'      where aaf.name = l_filename;',
'      --',
'      log( ''retrieved!''  );',
'    else',
'      log( ''Storage type "'' || l_storage_type || ''" not handled'' );',
'      l_rv.success_message := ''Storage type "'' || l_storage_type || ''" not handled'';',
'      return l_rv;',
'    end if;',
'  exception',
'    when no_data_found',
'    then',
'      raise e_no_doc;',
'  end;',
'--',
'  if l_document is null or dbms_lob.getlength( l_document ) = 0',
'  then',
'    log( ''file is empty'' );',
'    l_rv.success_message := ''No file/empty file found.'';',
'    return l_rv;',
'  else',
'    log( ''file with length '' || dbms_lob.getlength( l_document ) || '' found '' );',
'  end if;',
'--',
'  if apex_collection.collection_exists( p_collection_name )',
'  then',
'    apex_collection.delete_collection( p_collection_name );',
'  end if;',
'  for i in 1 .. 10',
'  loop',
'    if apex_collection.collection_exists( p_collection_name || i )',
'    then',
'      apex_collection.delete_collection( p_collection_name || i );',
'    end if;',
'  end loop;',
'  apex_collection.create_or_truncate_collection( p_collection_name || ''_$MAP'' );',
'  begin  ',
'    apex_collection.add_member( p_collection_name || ''_$MAP'', p_c001 => rpad( ''x'', 32000, ''x'' ) );',
'    l_extended := true;',
'  exception',
'    when others then',
'      l_extended := false;',
'  end;',
'  apex_collection.create_or_truncate_collection( p_collection_name || ''_$MAP'' );',
'  --',
'  if dbms_lob.substr( l_document, 4, 1 ) = hextoraw( ''504B0304'' )',
'  then',
'    open c_src( nv(''APP_ID''), ''parse_xlsx.prc'' );',
'    fetch c_src into l_src;',
'    close c_src;',
'    log( ''parsing XLSX'' );',
'    execute immediate l_src using ',
'        p_collection_name',
'      , l_extended',
'      , l_document',
'      , p_sheet_nrs',
'      , p_50    = ''Y''',
'      , p_round = ''Y''',
'      , out l_log;   ',
'    log( rtrim( l_log, chr(10) ) || chr(10) );',
'    log( ''Loaded a XLSX-file in '' || to_char( trunc( ( sysdate - l_time ) * 24 * 60 * 60 ) ) || '' seconds'' );',
'    l_rv.success_message := ''Loaded a XLSX-file in '' || to_char( trunc( ( sysdate - l_time ) * 24 * 60 * 60 ) ) || '' seconds'';',
'    return l_rv;',
'  elsif dbms_lob.substr( l_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B11AE1'' )',
'  then',
'    log( ''parsing XLS'' );',
'    l_what := ''XLS-file'';',
'    t_parse := dc( t_parse_xls );',
'  elsif dbms_lob.substr( l_document, 5, 1 ) = hextoraw( ''3C68746D6C'' )',
'  then',
'    log( ''parsing HTML'' );',
'    l_what := ''HTML-file'';',
'    t_parse := dc( t_parse_html );',
'  elsif (  dbms_lob.substr( l_document, 1, 1 ) = hextoraw( ''3C'' )',
'        or dbms_lob.substr( l_document, 2, 1 ) = hextoraw( ''003C'' )',
'        or dbms_lob.substr( l_document, 4, 1 ) = hextoraw( ''0000003C'' )',
'        )',
'  then',
'    log( ''parsing XML'' );',
'    l_what := ''XML-file'';',
'    t_parse := dc( t_parse_xml );',
'  else',
'    log( ''parsing CSV'' );',
'    l_what := ''CSV-file'';',
'    t_x := dbmsoutput_linesarray( p_separator, p_enclosed_by, p_encoding );',
'    t_parse := dc( t_parse_csv );',
'  end if;',
'  execute immediate dc( t_parse_bef ) || t_parse || dc( t_parse_aft ) using p_collection_name, l_document,p_sheet_nrs,t_x,p_round,p_50;',
'--',
'  log( ''Loaded a '' || l_what || '' in '' || to_char( trunc( ( sysdate - l_time ) * 24 * 60 * 60 ) ) || '' seconds'' );',
'  l_rv.success_message := ''Loaded a '' || l_what || '' in '' || to_char( trunc( ( sysdate - l_time ) * 24 * 60 * 60 ) ) || '' seconds'';',
'  return l_rv;',
'exception',
'  when e_no_doc',
'  then',
'    l_rv.success_message := ''No uploaded document found'';',
'    return l_rv;',
'  when others',
'  then',
'    log( dbms_utility.format_error_stack, 1 );',
'    log( dbms_utility.format_error_backtrace, 1 );',
'    l_rv.success_message := ''Oops, something went wrong in '' || p_plugin.name ||',
'         ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||',
'       dbms_utility.format_error_backtrace || ''<br/><br/>'' ||',
'         ''This could be caused by<ul>'' ||',
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||',
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could imagine''||',
'           ''</li></ul><br/>'' ||',
'           ''try running this plugin in debug mode, and send the debug messages to me, excel2collection@gmail.com'';',
'    return l_rv;',
'end;',
''))
,p_api_version=>1
,p_execution_function=>'parse_excel'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.006'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'1.006',
'  Changed parse_xlsx.prc, fixing a bug for dates in XLSX',
'1.004',
'  Some logging changes',
'1.002',
'  check for extended size cXXX columns in APEX collections',
'1.000',
'  moved XLSX parsing to plugin files',
'0.906',
'  changed email-address',
'0.904',
'  add version information to log',
'0.902',
'  use package excel2collection when available',
'  XLS: better support for BIFF5',
'0.823',
'  XLS: fix date during MULRK',
'0.822',
'  XLS: fix empty string results for formulas',
'  more than 50 columns ',
'0.821',
'  XLSX: fixed bug for numbers without a format',
'0.820',
'  Apex 5.0: Handle APEX_APPLICATION_TEMP_FILES',
'0.818',
'  XLS: fixed bug for unicode strings starting at CONTINUE record',
'0.816',
'  XLSX: treat numbers with "text" format as string',
'0.814',
'  XLS: performance',
'0.812',
'  XLS, XLSX: option to round number values',
'  XLS: fixed bug for Asian strings',
'0.810',
'  XLSX: skip empty nodes',
'  CSV: handle 1 line file',
'0.808',
'  Use dd-mm-yyyy hh24:mi:ss for date format',
'0.806',
'  save mapping between sheet name and collection name in <Collection name>_$MAP',
'  XLSX: also strings on 10.2 databases',
'        read formulas',
'  XLS: fix empty string results for formulas',
'       added standard data formats',
'  CSV: performance in case of wrong separator',
'0.804',
'  XLSX: Fix bug for formated strings',
'  CSV: Support for HT separator',
'0.802',
'  XLSX: Support for numbers in scientific notation',
'  XLSX: Fix bug for empty strings',
''))
,p_files_version=>9
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(50625413363455632)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Browse Item'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>'The name of the File Browse Item which is used to select the uploaded Excel file.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(50626110985483361)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Collection name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The name of the Collection in which the first sheet is placed.',
'<br/>Eventually, other sheets are placed in Colections with a sequence number attached to this name: <br/>',
'<br/>&lt;Collection name&gt;2',
'<br/>&lt;Collection name&gt;3',
'<br/>&lt;Collection name&gt;4'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(50627425577515920)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Sheets'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'A colon separated list of sheets which should loaded.',
'<br/>When left empty all sheets are loaded.<br/>',
'A sheet is identified by its name or positional number.',
'<br/><br/>For instance',
'<br/>',
'&nbsp;&nbsp;1:3 will load the first and the third sheet<br/>',
'&nbsp;&nbsp;Sheet1:Sheet2 will load the sheets with the names "Sheet1" and  "Sheet2"'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(50628129779545550)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'CSV Separator'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>';'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The column separator character used for CSV-files.<br/>',
'Use \t, ^I or HT for a (horizontal) tab character.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(50628827617563804)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'CSV Enclosed By'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'"'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'A delimiter character used for CSV-files. This character is used to delineate the starting and ending boundary of a data value.',
'The default value is ".',
'The same character is used as the escape character.'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(50629521908600032)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'CSV Character set'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'The character set used for loading a CSV file.',
'<br/>When left empty the database character set is used.',
'<br/>Use the Oracle name for the character set, for instance WE8MSWIN1252 and not Windows-1252'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(48865727269914860)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Round Excel numbers'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Excel has a numerical precision of 15 digits. When this option is used numbers are rounded to 15 digits.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(43012626187837672)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Load more than 50 columns'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Load more than 50 columns. Because we can store only 50 varchar2 columns in a APEX collection, columns above 50 are loaded in a second row. Attribute N001 stores the row number, attribute N002 stores the column number of C001.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '6465636C6172650D0A20206C5F6C6F6720636C6F623B0D0A20206C5F76617263686172325F737A20706C735F696E74656765723B0D0A20206C5F636F6C6C656374696F6E5F62617365207661726368617232283332373637293B0D0A2020747970652074';
wwv_flow_imp.g_varchar2_table(2) := '705F636F6C5F6D656D206973207461626C65206F66207661726368617232283332373637293B0D0A20206C5F636F6C5F6D656D2074705F636F6C5F6D656D3B0D0A2020635F6C6F625F6475726174696F6E20636F6E7374616E7420706C735F696E746567';
wwv_flow_imp.g_varchar2_table(3) := '6572203A3D2064626D735F6C6F622E63616C6C3B0D0A2020635F4C4F43414C5F46494C455F4845414445522020202020202020636F6E7374616E7420726177283429203A3D20686578746F72617728202735303442303330342720293B202D2D204C6F63';
wwv_flow_imp.g_varchar2_table(4) := '616C2066696C6520686561646572207369676E61747572650D0A2020635F43454E5452414C5F46494C455F484541444552202020202020636F6E7374616E7420726177283429203A3D20686578746F72617728202735303442303130322720293B202D2D';
wwv_flow_imp.g_varchar2_table(5) := '2043656E7472616C206469726563746F72792066696C6520686561646572207369676E61747572650D0A2020635F454E445F4F465F43454E5452414C5F4449524543544F525920636F6E7374616E7420726177283429203A3D20686578746F7261772820';
wwv_flow_imp.g_varchar2_table(6) := '2735303442303530362720293B202D2D20456E64206F662063656E7472616C206469726563746F7279207369676E61747572650D0A20202D2D0D0A2020747970652074705F7A69705F696E666F206973207265636F72640D0A2020202028206C656E2069';
wwv_flow_imp.g_varchar2_table(7) := '6E74656765720D0A202020202C20636E7420696E74656765720D0A202020202C206C656E5F636420696E74656765720D0A202020202C206964785F636420696E74656765720D0A202020202C206964785F656F636420696E74656765720D0A2020202029';
wwv_flow_imp.g_varchar2_table(8) := '3B0D0A20202D2D0D0A2020747970652074705F636668206973207265636F72640D0A2020202028206F666673657420696E74656765720D0A202020202C20636F6D707265737365645F6C656E20696E74656765720D0A202020202C206F726967696E616C';
wwv_flow_imp.g_varchar2_table(9) := '5F6C656E20696E74656765720D0A202020202C206C656E20706C735F696E74656765720D0A202020202C206E202020706C735F696E74656765720D0A202020202C206D202020706C735F696E74656765720D0A202020202C206B202020706C735F696E74';
wwv_flow_imp.g_varchar2_table(10) := '656765720D0A202020202C207574663820626F6F6C65616E0D0A202020202C20656E6372797074656420626F6F6C65616E0D0A202020202C206372633332207261772834290D0A202020202C2065787465726E616C5F66696C655F617474722072617728';
wwv_flow_imp.g_varchar2_table(11) := '34290D0A202020202C20656E636F64696E672076617263686172322833393939290D0A202020202C20696478202020696E74656765720D0A202020202C206E616D653120726177283332373637290D0A20202020293B0D0A20202D2D0D0A202066756E63';
wwv_flow_imp.g_varchar2_table(12) := '74696F6E206C6974746C655F656E6469616E2820705F6E756D207261772C20705F706F7320706C735F696E7465676572203A3D20312C20705F627974657320706C735F696E7465676572203A3D206E756C6C20290D0A202072657475726E20696E746567';
wwv_flow_imp.g_varchar2_table(13) := '65720D0A202069730D0A2020626567696E0D0A2020202072657475726E20746F5F6E756D626572282075746C5F7261772E72657665727365282075746C5F7261772E7375627374722820705F6E756D2C20705F706F732C20705F6279746573202920292C';
wwv_flow_imp.g_varchar2_table(14) := '2027585858585858585858585858585858582720293B0D0A2020656E643B0D0A20202D2D0D0A202066756E6374696F6E206765745F656E636F64696E672820705F656E636F64696E67207661726368617232203A3D206E756C6C20290D0A202072657475';
wwv_flow_imp.g_varchar2_table(15) := '726E2076617263686172320D0A202069730D0A202020206C5F656E636F64696E67207661726368617232283332373637293B0D0A2020626567696E0D0A20202020696620705F656E636F64696E67206973206E6F74206E756C6C0D0A202020207468656E';
wwv_flow_imp.g_varchar2_table(16) := '0D0A2020202020206966206E6C735F636861727365745F69642820705F656E636F64696E672029206973206E756C6C0D0A2020202020207468656E0D0A20202020202020206C5F656E636F64696E67203A3D2075746C5F6931386E2E6D61705F63686172';
wwv_flow_imp.g_varchar2_table(17) := '7365742820705F656E636F64696E672C2075746C5F6931386E2E47454E455249435F434F4E544558542C2075746C5F6931386E2E49414E415F544F5F4F5241434C4520293B0D0A202020202020656C73650D0A20202020202020206C5F656E636F64696E';
wwv_flow_imp.g_varchar2_table(18) := '67203A3D20705F656E636F64696E673B0D0A202020202020656E642069663B0D0A20202020656E642069663B0D0A2020202072657475726E20636F616C6573636528206C5F656E636F64696E672C202755533850433433372720293B202D2D2049424D20';
wwv_flow_imp.g_varchar2_table(19) := '636F646570616765203433370D0A2020656E643B0D0A20202D2D0D0A202066756E6374696F6E2063686172327261772820705F747874207661726368617232206368617261637465722073657420616E795F63732C20705F656E636F64696E6720766172';
wwv_flow_imp.g_varchar2_table(20) := '6368617232203A3D206E756C6C20290D0A202072657475726E207261770D0A202069730D0A2020626567696E0D0A2020202069662069736E636861722820705F74787420290D0A202020207468656E202D2D206F6E206D792031322E3120646174616261';
wwv_flow_imp.g_varchar2_table(21) := '73652C207768696368206973206E6F7420414C3332555446382C0D0A2020202020202020202D2D2075746C5F6931386E2E737472696E675F746F5F7261772820705F7478742C206765745F656E636F64696E672820705F656E636F64696E67202920646F';
wwv_flow_imp.g_varchar2_table(22) := '6573206E6F7420776F726B0D0A20202020202072657475726E2075746C5F7261772E636F6E76657274282075746C5F6931386E2E737472696E675F746F5F7261772820705F74787420290D0A202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '202020202C206765745F656E636F64696E672820705F656E636F64696E6720290D0A202020202020202020202020202020202020202020202020202020202C206E6C735F636861727365745F6E616D6528206E6C735F636861727365745F69642820274E';
wwv_flow_imp.g_varchar2_table(24) := '434841525F435327202920290D0A20202020202020202020202020202020202020202020202020202020293B0D0A20202020656E642069663B0D0A2020202072657475726E2075746C5F6931386E2E737472696E675F746F5F7261772820705F7478742C';
wwv_flow_imp.g_varchar2_table(25) := '206765745F656E636F64696E672820705F656E636F64696E67202920293B0D0A2020656E643B0D0A20202D2D0D0A202070726F636564757265206765745F7A69705F696E666F2820705F7A697020626C6F622C20705F696E666F206F75742074705F7A69';
wwv_flow_imp.g_varchar2_table(26) := '705F696E666F20290D0A202069730D0A202020206C5F696E6420696E74656765723B0D0A202020206C5F6275665F737A20706C735F696E7465676572203A3D20323032343B0D0A202020206C5F73746172745F62756620696E74656765723B0D0A202020';
wwv_flow_imp.g_varchar2_table(27) := '206C5F62756620726177283332373637293B0D0A2020626567696E0D0A20202020705F696E666F2E6C656E203A3D206E766C282064626D735F6C6F622E6765746C656E6774682820705F7A697020292C203020293B0D0A20202020696620705F696E666F';
wwv_flow_imp.g_varchar2_table(28) := '2E6C656E203C2032320D0A202020207468656E202D2D206E6F20287A6970292066696C65206F7220656D707479207A69702066696C650D0A20202020202072657475726E3B0D0A20202020656E642069663B0D0A202020206C5F73746172745F62756620';
wwv_flow_imp.g_varchar2_table(29) := '3A3D2067726561746573742820705F696E666F2E6C656E202D206C5F6275665F737A202B20312C203120293B0D0A202020206C5F627566203A3D2064626D735F6C6F622E7375627374722820705F7A69702C206C5F6275665F737A2C206C5F7374617274';
wwv_flow_imp.g_varchar2_table(30) := '5F62756620293B0D0A202020206C5F696E64203A3D2075746C5F7261772E6C656E67746828206C5F6275662029202D2032313B0D0A202020206C6F6F700D0A20202020202065786974207768656E206C5F696E64203C2031206F722075746C5F7261772E';
wwv_flow_imp.g_varchar2_table(31) := '73756273747228206C5F6275662C206C5F696E642C20342029203D20635F454E445F4F465F43454E5452414C5F4449524543544F52593B0D0A2020202020206C5F696E64203A3D206C5F696E64202D20313B0D0A20202020656E64206C6F6F703B0D0A20';
wwv_flow_imp.g_varchar2_table(32) := '2020206966206C5F696E64203E20300D0A202020207468656E0D0A2020202020206C5F696E64203A3D206C5F696E64202B206C5F73746172745F627566202D20313B0D0A20202020656C73650D0A2020202020206C5F696E64203A3D20705F696E666F2E';
wwv_flow_imp.g_varchar2_table(33) := '6C656E202D2032313B0D0A2020202020206C6F6F700D0A202020202020202065786974207768656E206C5F696E64203C2031206F722064626D735F6C6F622E7375627374722820705F7A69702C20342C206C5F696E642029203D20635F454E445F4F465F';
wwv_flow_imp.g_varchar2_table(34) := '43454E5452414C5F4449524543544F52593B0D0A20202020202020206C5F696E64203A3D206C5F696E64202D20313B0D0A202020202020656E64206C6F6F703B0D0A20202020656E642069663B0D0A202020206966206C5F696E64203C3D20300D0A2020';
wwv_flow_imp.g_varchar2_table(35) := '20207468656E0D0A20202020202072616973655F6170706C69636174696F6E5F6572726F7228202D32303030312C20274572726F722070617273696E6720746865207A697066696C652720293B0D0A20202020656E642069663B0D0A202020206C5F6275';
wwv_flow_imp.g_varchar2_table(36) := '66203A3D2064626D735F6C6F622E7375627374722820705F7A69702C2032322C206C5F696E6420293B0D0A2020202069662020202075746C5F7261772E73756273747228206C5F6275662C20352C2032202920213D2075746C5F7261772E737562737472';
wwv_flow_imp.g_varchar2_table(37) := '28206C5F6275662C20372C2032202920202D2D2074686973206469736B203D206469736B2077697468207374617274206F662043656E7472616C204469720D0A202020202020206F722075746C5F7261772E73756273747228206C5F6275662C20392C20';
wwv_flow_imp.g_varchar2_table(38) := '32202920213D2075746C5F7261772E73756273747228206C5F6275662C2031312C20322029202D2D20636F6D706C657465204344206F6E2074686973206469736B0D0A202020207468656E0D0A20202020202072616973655F6170706C69636174696F6E';
wwv_flow_imp.g_varchar2_table(39) := '5F6572726F7228202D32303030332C20274572726F722070617273696E6720746865207A697066696C652720293B0D0A20202020656E642069663B0D0A20202020705F696E666F2E6964785F656F6364203A3D206C5F696E643B0D0A20202020705F696E';
wwv_flow_imp.g_varchar2_table(40) := '666F2E6964785F6364203A3D206C6974746C655F656E6469616E28206C5F6275662C2031372C20342029202B20313B0D0A20202020705F696E666F2E636E74203A3D206C6974746C655F656E6469616E28206C5F6275662C20392C203220293B0D0A2020';
wwv_flow_imp.g_varchar2_table(41) := '2020705F696E666F2E6C656E5F6364203A3D20705F696E666F2E6964785F656F6364202D20705F696E666F2E6964785F63643B0D0A2020656E643B0D0A20202D2D0D0A202066756E6374696F6E2070617273655F63656E7472616C5F66696C655F686561';
wwv_flow_imp.g_varchar2_table(42) := '6465722820705F7A697020626C6F622C20705F696E6420696E74656765722C20705F636668206F75742074705F63666820290D0A202072657475726E20626F6F6C65616E0D0A202069730D0A202020206C5F746D7020706C735F696E74656765723B0D0A';
wwv_flow_imp.g_varchar2_table(43) := '202020206C5F6C656E20706C735F696E74656765723B0D0A202020206C5F62756620726177283332373637293B0D0A2020626567696E0D0A202020206C5F627566203A3D2064626D735F6C6F622E7375627374722820705F7A69702C2034362C20705F69';
wwv_flow_imp.g_varchar2_table(44) := '6E6420293B0D0A2020202069662075746C5F7261772E73756273747228206C5F6275662C20312C2034202920213D20635F43454E5452414C5F46494C455F4845414445520D0A202020207468656E0D0A20202020202072657475726E2066616C73653B0D';
wwv_flow_imp.g_varchar2_table(45) := '0A20202020656E642069663B0D0A20202020705F6366682E6372633332203A3D2075746C5F7261772E73756273747228206C5F6275662C2031372C203420293B0D0A20202020705F6366682E6E203A3D206C6974746C655F656E6469616E28206C5F6275';
wwv_flow_imp.g_varchar2_table(46) := '662C2032392C203220293B0D0A20202020705F6366682E6D203A3D206C6974746C655F656E6469616E28206C5F6275662C2033312C203220293B0D0A20202020705F6366682E6B203A3D206C6974746C655F656E6469616E28206C5F6275662C2033332C';
wwv_flow_imp.g_varchar2_table(47) := '203220293B0D0A20202020705F6366682E6C656E203A3D203436202B20705F6366682E6E202B20705F6366682E6D202B20705F6366682E6B3B0D0A202020202D2D0D0A20202020705F6366682E75746638203A3D20626974616E642820746F5F6E756D62';
wwv_flow_imp.g_varchar2_table(48) := '6572282075746C5F7261772E73756273747228206C5F6275662C2031302C203120292C202758582720292C20382029203E20303B0D0A20202020696620705F6366682E6E203E20300D0A202020207468656E0D0A202020202020705F6366682E6E616D65';
wwv_flow_imp.g_varchar2_table(49) := '31203A3D2064626D735F6C6F622E7375627374722820705F7A69702C206C656173742820705F6366682E6E2C20333237363720292C20705F696E64202B20343620293B0D0A20202020656E642069663B0D0A202020202D2D0D0A20202020705F6366682E';
wwv_flow_imp.g_varchar2_table(50) := '636F6D707265737365645F6C656E203A3D206C6974746C655F656E6469616E28206C5F6275662C2032312C203420293B0D0A20202020705F6366682E6F726967696E616C5F6C656E203A3D206C6974746C655F656E6469616E28206C5F6275662C203235';
wwv_flow_imp.g_varchar2_table(51) := '2C203420293B0D0A20202020705F6366682E6F6666736574203A3D206C6974746C655F656E6469616E28206C5F6275662C2034332C203420293B0D0A202020202D2D0D0A2020202072657475726E20747275653B0D0A2020656E643B0D0A20202D2D0D0A';
wwv_flow_imp.g_varchar2_table(52) := '202066756E6374696F6E206765745F63656E7472616C5F66696C655F6865616465720D0A202020202820705F7A6970202020202020626C6F620D0A202020202C20705F6E616D652020202020766172636861723220636861726163746572207365742061';
wwv_flow_imp.g_varchar2_table(53) := '6E795F63730D0A202020202C20705F6964782020202020206E756D6265720D0A202020202C20705F656E636F64696E672076617263686172320D0A202020202C20705F6366682020202020206F75742074705F6366680D0A20202020290D0A2020726574';
wwv_flow_imp.g_varchar2_table(54) := '75726E20626F6F6C65616E0D0A202069730D0A202020206C5F72762020202020202020626F6F6C65616E3B0D0A202020206C5F696E6420202020202020696E74656765723B0D0A202020206C5F69647820202020202020696E74656765723B0D0A202020';
wwv_flow_imp.g_varchar2_table(55) := '206C5F696E666F20202020202074705F7A69705F696E666F3B0D0A202020206C5F6E616D65202020202020726177283332373637293B0D0A202020206C5F757466385F6E616D6520726177283332373637293B0D0A2020626567696E0D0A202020206966';
wwv_flow_imp.g_varchar2_table(56) := '20705F6E616D65206973206E756C6C20616E6420705F696478206973206E756C6C0D0A202020207468656E0D0A20202020202072657475726E2066616C73653B0D0A20202020656E642069663B0D0A202020206765745F7A69705F696E666F2820705F7A';
wwv_flow_imp.g_varchar2_table(57) := '69702C206C5F696E666F20293B0D0A202020206966206E766C28206C5F696E666F2E636E742C20302029203C20310D0A202020207468656E202D2D206E6F20287A6970292066696C65206F7220656D707479207A69702066696C650D0A20202020202072';
wwv_flow_imp.g_varchar2_table(58) := '657475726E2066616C73653B0D0A20202020656E642069663B0D0A202020202D2D0D0A20202020696620705F6E616D65206973206E6F74206E756C6C0D0A202020207468656E0D0A2020202020206C5F6E616D65203A3D2063686172327261772820705F';
wwv_flow_imp.g_varchar2_table(59) := '6E616D652C20705F656E636F64696E6720293B0D0A2020202020206C5F757466385F6E616D65203A3D2063686172327261772820705F6E616D652C2027414C3332555446382720293B0D0A20202020656E642069663B0D0A202020202D2D0D0A20202020';
wwv_flow_imp.g_varchar2_table(60) := '6C5F7276203A3D2066616C73653B0D0A202020206C5F696E64203A3D206C5F696E666F2E6964785F63643B0D0A202020206C5F696478203A3D20313B0D0A202020206C6F6F700D0A20202020202065786974207768656E206E6F742070617273655F6365';
wwv_flow_imp.g_varchar2_table(61) := '6E7472616C5F66696C655F6865616465722820705F7A69702C206C5F696E642C20705F63666820293B0D0A2020202020206966206C5F696478203D20705F6964780D0A2020202020202020206F7220705F6366682E6E616D6531203D2063617365207768';
wwv_flow_imp.g_varchar2_table(62) := '656E20705F6366682E75746638207468656E206C5F757466385F6E616D6520656C7365206C5F6E616D6520656E640D0A2020202020207468656E0D0A20202020202020206C5F7276203A3D20747275653B0D0A2020202020202020657869743B0D0A2020';
wwv_flow_imp.g_varchar2_table(63) := '20202020656E642069663B0D0A2020202020206C5F696E64203A3D206C5F696E64202B20705F6366682E6C656E3B0D0A2020202020206C5F696478203A3D206C5F696478202B20313B0D0A20202020656E64206C6F6F703B0D0A202020202D2D0D0A2020';
wwv_flow_imp.g_varchar2_table(64) := '2020705F6366682E696478203A3D206C5F6964783B0D0A20202020705F6366682E656E636F64696E67203A3D206765745F656E636F64696E672820705F656E636F64696E6720293B0D0A2020202072657475726E206C5F72763B0D0A2020656E643B0D0A';
wwv_flow_imp.g_varchar2_table(65) := '20202D2D0D0A202066756E6374696F6E2070617273655F66696C652820705F7A69707065645F626C6F6220626C6F622C20705F666820696E206F75742074705F63666820290D0A202072657475726E20626C6F620D0A202069730D0A202020206C5F7276';
wwv_flow_imp.g_varchar2_table(66) := '20626C6F623B0D0A202020206C5F627566207261772833393939293B0D0A202020206C5F636F6D7072657373696F6E5F6D6574686F642076617263686172322834293B0D0A202020206C5F6E20696E74656765723B0D0A202020206C5F6D20696E746567';
wwv_flow_imp.g_varchar2_table(67) := '65723B0D0A202020206C5F637263207261772834293B0D0A2020626567696E0D0A20202020696620705F66682E6F726967696E616C5F6C656E206973206E756C6C0D0A202020207468656E0D0A20202020202072616973655F6170706C69636174696F6E';
wwv_flow_imp.g_varchar2_table(68) := '5F6572726F7228202D32303030362C202746696C65206E6F7420666F756E642720293B0D0A20202020656E642069663B0D0A202020206966206E766C2820705F66682E6F726967696E616C5F6C656E2C20302029203D20300D0A202020207468656E0D0A';
wwv_flow_imp.g_varchar2_table(69) := '20202020202072657475726E20656D7074795F626C6F6228293B0D0A20202020656E642069663B0D0A202020206C5F627566203A3D2064626D735F6C6F622E7375627374722820705F7A69707065645F626C6F622C2033302C20705F66682E6F66667365';
wwv_flow_imp.g_varchar2_table(70) := '74202B203120293B0D0A2020202069662075746C5F7261772E73756273747228206C5F6275662C20312C2034202920213D20635F4C4F43414C5F46494C455F4845414445520D0A202020207468656E0D0A20202020202072616973655F6170706C696361';
wwv_flow_imp.g_varchar2_table(71) := '74696F6E5F6572726F7228202D32303030372C20274572726F722070617273696E6720746865207A697066696C652720293B0D0A20202020656E642069663B0D0A202020206C5F636F6D7072657373696F6E5F6D6574686F64203A3D2075746C5F726177';
wwv_flow_imp.g_varchar2_table(72) := '2E73756273747228206C5F6275662C20392C203220293B0D0A202020206C5F6E203A3D206C6974746C655F656E6469616E28206C5F6275662C2032372C203220293B0D0A202020206C5F6D203A3D206C6974746C655F656E6469616E28206C5F6275662C';
wwv_flow_imp.g_varchar2_table(73) := '2032392C203220293B0D0A202020206966206C5F636F6D7072657373696F6E5F6D6574686F64203D202730383030270D0A202020207468656E0D0A202020202020696620705F66682E6F726967696E616C5F6C656E203C20333237363720616E6420705F';
wwv_flow_imp.g_varchar2_table(74) := '66682E636F6D707265737365645F6C656E203C2033323734380D0A2020202020207468656E0D0A202020202020202072657475726E2075746C5F636F6D70726573732E6C7A5F756E636F6D7072657373282075746C5F7261772E636F6E6361740D0A2020';
wwv_flow_imp.g_varchar2_table(75) := '2020202020202020202020202020202820686578746F72617728202731463842303830303030303030303030303030332720290D0A20202020202020202020202020202020202C2064626D735F6C6F622E7375627374722820705F7A69707065645F626C';
wwv_flow_imp.g_varchar2_table(76) := '6F622C20705F66682E636F6D707265737365645F6C656E2C20705F66682E6F6666736574202B203331202B206C5F6E202B206C5F6D20290D0A20202020202020202020202020202020202C20705F66682E63726333320D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(77) := '20202020202C2075746C5F7261772E737562737472282075746C5F7261772E726576657273652820746F5F636861722820705F66682E6F726967696E616C5F6C656E2C2027666D3058585858585858585858585858585827202920292C20312C20342029';
wwv_flow_imp.g_varchar2_table(78) := '0D0A20202020202020202020202020202020202920293B0D0A202020202020656E642069663B0D0A2020202020206C5F7276203A3D20686578746F72617728202731463842303830303030303030303030303030332720293B202D2D20677A6970206865';
wwv_flow_imp.g_varchar2_table(79) := '616465720D0A20202020202064626D735F6C6F622E636F707928206C5F72760D0A202020202020202020202020202020202020202C20705F7A69707065645F626C6F620D0A202020202020202020202020202020202020202C20705F66682E636F6D7072';
wwv_flow_imp.g_varchar2_table(80) := '65737365645F6C656E0D0A202020202020202020202020202020202020202C2031310D0A202020202020202020202020202020202020202C20705F66682E6F6666736574202B203331202B206C5F6E202B206C5F6D0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(81) := '202020202020293B0D0A20202020202064626D735F6C6F622E617070656E6428206C5F72760D0A2020202020202020202020202020202020202020202C2075746C5F7261772E636F6E6361742820705F66682E63726333320D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(82) := '2020202020202020202020202020202020202020202020202020202C2075746C5F7261772E737562737472282075746C5F7261772E726576657273652820746F5F636861722820705F66682E6F726967696E616C5F6C656E2C2027666D30585858585858';
wwv_flow_imp.g_varchar2_table(83) := '58585858585858585827202920292C20312C203420290D0A20202020202020202020202020202020202020202020202020202020202020202020202020290D0A202020202020202020202020202020202020202020293B0D0A2020202020207265747572';
wwv_flow_imp.g_varchar2_table(84) := '6E2075746C5F636F6D70726573732E6C7A5F756E636F6D707265737328206C5F727620293B0D0A20202020656C736966206C5F636F6D7072657373696F6E5F6D6574686F64203D202730303030270D0A202020207468656E0D0A20202020202069662070';
wwv_flow_imp.g_varchar2_table(85) := '5F66682E6F726967696E616C5F6C656E203C20333237363720616E6420705F66682E636F6D707265737365645F6C656E203C2033323736370D0A2020202020207468656E0D0A202020202020202072657475726E2064626D735F6C6F622E737562737472';
wwv_flow_imp.g_varchar2_table(86) := '2820705F7A69707065645F626C6F620D0A2020202020202020202020202020202020202020202020202020202020202C20705F66682E636F6D707265737365645F6C656E0D0A202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(87) := '2C20705F66682E6F6666736574202B203331202B206C5F6E202B206C5F6D0D0A202020202020202020202020202020202020202020202020202020202020293B0D0A202020202020656E642069663B0D0A20202020202064626D735F6C6F622E63726561';
wwv_flow_imp.g_varchar2_table(88) := '746574656D706F7261727928206C5F72762C20747275652C20635F6C6F625F6475726174696F6E20293B0D0A20202020202064626D735F6C6F622E636F707928206C5F72760D0A202020202020202020202020202020202020202C20705F7A6970706564';
wwv_flow_imp.g_varchar2_table(89) := '5F626C6F620D0A202020202020202020202020202020202020202C20705F66682E636F6D707265737365645F6C656E0D0A202020202020202020202020202020202020202C20310D0A202020202020202020202020202020202020202C20705F66682E6F';
wwv_flow_imp.g_varchar2_table(90) := '6666736574202B203331202B206C5F6E202B206C5F6D0D0A20202020202020202020202020202020202020293B0D0A20202020202072657475726E206C5F72763B0D0A20202020656E642069663B0D0A2020202072616973655F6170706C69636174696F';
wwv_flow_imp.g_varchar2_table(91) := '6E5F6572726F7228202D32303030382C2027556E68616E646C656420636F6D7072657373696F6E206D6574686F642027207C7C206C5F636F6D7072657373696F6E5F6D6574686F6420293B0D0A2020656E642070617273655F66696C653B0D0A20202D2D';
wwv_flow_imp.g_varchar2_table(92) := '0D0A202066756E6374696F6E206765745F636F756E742820705F7A69707065645F626C6F6220626C6F6220290D0A202072657475726E20696E74656765720D0A202069730D0A202020206C5F696E666F2074705F7A69705F696E666F3B0D0A2020626567';
wwv_flow_imp.g_varchar2_table(93) := '696E0D0A202020206765745F7A69705F696E666F2820705F7A69707065645F626C6F622C206C5F696E666F20293B0D0A2020202072657475726E206E766C28206C5F696E666F2E636E742C203020293B0D0A2020656E643B0D0A20202D2D0D0A20206675';
wwv_flow_imp.g_varchar2_table(94) := '6E6374696F6E20636F6C5F616C66616E2820705F636F6C20766172636861723220290D0A202072657475726E20706C735F696E74656765720D0A202069730D0A202020206C5F636F6C207661726368617232283130303029203A3D20727472696D282070';
wwv_flow_imp.g_varchar2_table(95) := '5F636F6C2C2027303132333435363738392720293B0D0A2020626567696E0D0A2020202072657475726E206173636969282073756273747228206C5F636F6C2C202D3120292029202D2036340D0A2020202020202020202B206E766C2820282061736369';
wwv_flow_imp.g_varchar2_table(96) := '69282073756273747228206C5F636F6C2C202D322C203120292029202D2036342029202A2032362C203020290D0A2020202020202020202B206E766C282028206173636969282073756273747228206C5F636F6C2C202D332C203120292029202D203634';
wwv_flow_imp.g_varchar2_table(97) := '2029202A203637362C203020293B0D0A2020656E643B0D0A20202D2D0D0A202070726F636564757265206164645F6D656D6265722820705F6E616D652076617263686172322C20705F726F7720706C735F696E74656765722C20705F666972737420706C';
wwv_flow_imp.g_varchar2_table(98) := '735F696E746567657220290D0A202069730D0A2020626567696E0D0A2020202020617065785F636F6C6C656374696F6E2E6164645F6D656D6265720D0A202020202020202820705F6E616D650D0A202020202020202C20705F63303031203D3E206C5F63';
wwv_flow_imp.g_varchar2_table(99) := '6F6C5F6D656D2820203120290D0A202020202020202C20705F63303032203D3E206C5F636F6C5F6D656D2820203220290D0A202020202020202C20705F63303033203D3E206C5F636F6C5F6D656D2820203320290D0A202020202020202C20705F633030';
wwv_flow_imp.g_varchar2_table(100) := '34203D3E206C5F636F6C5F6D656D2820203420290D0A202020202020202C20705F63303035203D3E206C5F636F6C5F6D656D2820203520290D0A202020202020202C20705F63303036203D3E206C5F636F6C5F6D656D2820203620290D0A202020202020';
wwv_flow_imp.g_varchar2_table(101) := '202C20705F63303037203D3E206C5F636F6C5F6D656D2820203720290D0A202020202020202C20705F63303038203D3E206C5F636F6C5F6D656D2820203820290D0A202020202020202C20705F63303039203D3E206C5F636F6C5F6D656D282020392029';
wwv_flow_imp.g_varchar2_table(102) := '0D0A202020202020202C20705F63303130203D3E206C5F636F6C5F6D656D2820313020290D0A202020202020202C20705F63303131203D3E206C5F636F6C5F6D656D2820313120290D0A202020202020202C20705F63303132203D3E206C5F636F6C5F6D';
wwv_flow_imp.g_varchar2_table(103) := '656D2820313220290D0A202020202020202C20705F63303133203D3E206C5F636F6C5F6D656D2820313320290D0A202020202020202C20705F63303134203D3E206C5F636F6C5F6D656D2820313420290D0A202020202020202C20705F63303135203D3E';
wwv_flow_imp.g_varchar2_table(104) := '206C5F636F6C5F6D656D2820313520290D0A202020202020202C20705F63303136203D3E206C5F636F6C5F6D656D2820313620290D0A202020202020202C20705F63303137203D3E206C5F636F6C5F6D656D2820313720290D0A202020202020202C2070';
wwv_flow_imp.g_varchar2_table(105) := '5F63303138203D3E206C5F636F6C5F6D656D2820313820290D0A202020202020202C20705F63303139203D3E206C5F636F6C5F6D656D2820313920290D0A202020202020202C20705F63303230203D3E206C5F636F6C5F6D656D2820323020290D0A2020';
wwv_flow_imp.g_varchar2_table(106) := '20202020202C20705F63303231203D3E206C5F636F6C5F6D656D2820323120290D0A202020202020202C20705F63303232203D3E206C5F636F6C5F6D656D2820323220290D0A202020202020202C20705F63303233203D3E206C5F636F6C5F6D656D2820';
wwv_flow_imp.g_varchar2_table(107) := '323320290D0A202020202020202C20705F63303234203D3E206C5F636F6C5F6D656D2820323420290D0A202020202020202C20705F63303235203D3E206C5F636F6C5F6D656D2820323520290D0A202020202020202C20705F63303236203D3E206C5F63';
wwv_flow_imp.g_varchar2_table(108) := '6F6C5F6D656D2820323620290D0A202020202020202C20705F63303237203D3E206C5F636F6C5F6D656D2820323720290D0A202020202020202C20705F63303238203D3E206C5F636F6C5F6D656D2820323820290D0A202020202020202C20705F633032';
wwv_flow_imp.g_varchar2_table(109) := '39203D3E206C5F636F6C5F6D656D2820323920290D0A202020202020202C20705F63303330203D3E206C5F636F6C5F6D656D2820333020290D0A202020202020202C20705F63303331203D3E206C5F636F6C5F6D656D2820333120290D0A202020202020';
wwv_flow_imp.g_varchar2_table(110) := '202C20705F63303332203D3E206C5F636F6C5F6D656D2820333220290D0A202020202020202C20705F63303333203D3E206C5F636F6C5F6D656D2820333320290D0A202020202020202C20705F63303334203D3E206C5F636F6C5F6D656D282033342029';
wwv_flow_imp.g_varchar2_table(111) := '0D0A202020202020202C20705F63303335203D3E206C5F636F6C5F6D656D2820333520290D0A202020202020202C20705F63303336203D3E206C5F636F6C5F6D656D2820333620290D0A202020202020202C20705F63303337203D3E206C5F636F6C5F6D';
wwv_flow_imp.g_varchar2_table(112) := '656D2820333720290D0A202020202020202C20705F63303338203D3E206C5F636F6C5F6D656D2820333820290D0A202020202020202C20705F63303339203D3E206C5F636F6C5F6D656D2820333920290D0A202020202020202C20705F63303430203D3E';
wwv_flow_imp.g_varchar2_table(113) := '206C5F636F6C5F6D656D2820343020290D0A202020202020202C20705F63303431203D3E206C5F636F6C5F6D656D2820343120290D0A202020202020202C20705F63303432203D3E206C5F636F6C5F6D656D2820343220290D0A202020202020202C2070';
wwv_flow_imp.g_varchar2_table(114) := '5F63303433203D3E206C5F636F6C5F6D656D2820343320290D0A202020202020202C20705F63303434203D3E206C5F636F6C5F6D656D2820343420290D0A202020202020202C20705F63303435203D3E206C5F636F6C5F6D656D2820343520290D0A2020';
wwv_flow_imp.g_varchar2_table(115) := '20202020202C20705F63303436203D3E206C5F636F6C5F6D656D2820343620290D0A202020202020202C20705F63303437203D3E206C5F636F6C5F6D656D2820343720290D0A202020202020202C20705F63303438203D3E206C5F636F6C5F6D656D2820';
wwv_flow_imp.g_varchar2_table(116) := '343820290D0A202020202020202C20705F63303439203D3E206C5F636F6C5F6D656D2820343920290D0A202020202020202C20705F63303530203D3E206C5F636F6C5F6D656D2820353020290D0A202020202020202C20705F6E303031203D3E20705F72';
wwv_flow_imp.g_varchar2_table(117) := '6F770D0A202020202020202C20705F6E303032203D3E20705F66697273740D0A20202020202020293B0D0A2020656E643B0D0A20202D2D0D0A202070726F63656475726520726561640D0A202020202820705F786C7378202020626C6F620D0A20202020';
wwv_flow_imp.g_varchar2_table(118) := '2C20705F7368656574732076617263686172320D0A202020202C20705F35302020202020626F6F6C65616E0D0A202020202C20705F726F756E642020626F6F6C65616E0D0A20202020290D0A202069730D0A202020206C5F656D70747920202020202020';
wwv_flow_imp.g_varchar2_table(119) := '202020626F6F6C65616E3B0D0A202020206C5F636E74202020202020202020202020706C735F696E74656765723B0D0A202020206C5F636F6C5F636E742020202020202020706C735F696E7465676572203A3D20303B0D0A202020206C5F636F6C5F6E72';
wwv_flow_imp.g_varchar2_table(120) := '202020202020202020706C735F696E74656765723B0D0A202020206C5F636F6C5F626C6F636B202020202020706C735F696E74656765723B0D0A202020206C5F707265765F636F6C5F626C6F636B20706C735F696E74656765723B0D0A202020206C5F72';
wwv_flow_imp.g_varchar2_table(121) := '6F775F6E72202020202020202020706C735F696E74656765723B0D0A202020206C5F707265765F726F775F6E7220202020706C735F696E74656765723B0D0A202020206C5F6D61785F636F6C5F626C6F636B2020706C735F696E74656765723B0D0A2020';
wwv_flow_imp.g_varchar2_table(122) := '20206C5F6E72202020202020202020202020206E756D6265723B0D0A202020206C5F746D702020202020202020202020207661726368617232283332373637293B0D0A202020206C5F6E616D652020202020202020202020766172636861723228333237';
wwv_flow_imp.g_varchar2_table(123) := '3637293B0D0A202020206C5F64696D656E73696F6E20202020202076617263686172322833393939293B0D0A202020206C5F776F726B626F6F6B20202020202020626C6F623B0D0A202020206C5F776F726B626F6F6B5F72656C732020626C6F623B0D0A';
wwv_flow_imp.g_varchar2_table(124) := '202020206C5F7368617265645F737472696E677320626C6F623B0D0A202020206C5F66696C652020202020202020202020626C6F623B0D0A202020206C5F637369645F75746638202020202020696E7465676572203A3D206E6C735F636861727365745F';
wwv_flow_imp.g_varchar2_table(125) := '6964282027414C3332555446382720293B0D0A202020206C5F63666820202020202020202020202074705F6366683B0D0A20202020747970652074705F737472696E677320202020206973207461626C65206F6620766172636861723228333237363729';
wwv_flow_imp.g_varchar2_table(126) := '3B0D0A20202020747970652074705F737472696E675F6C656E73206973207461626C65206F66207661726368617232283332373637293B0D0A20202020747970652074705F626F6F6C65616E5F746162206973207461626C65206F6620626F6F6C65616E';
wwv_flow_imp.g_varchar2_table(127) := '20696E64657820627920706C735F696E74656765723B0D0A202020206C5F737472696E677320202020202074705F737472696E67733B0D0A202020206C5F737472696E675F6C656E73202074705F737472696E675F6C656E733B0D0A202020206C5F7175';
wwv_flow_imp.g_varchar2_table(128) := '6F74655F7072656669782074705F626F6F6C65616E5F7461623B0D0A202020206C5F646174655F7374796C6573202074705F626F6F6C65616E5F7461623B0D0A202020206C5F74696D655F7374796C6573202074705F626F6F6C65616E5F7461623B0D0A';
wwv_flow_imp.g_varchar2_table(129) := '2020626567696E0D0A202020206C5F636E74203A3D206765745F636F756E742820705F786C737820293B0D0A20202020666F72206920696E2031202E2E206C5F636E740D0A202020206C6F6F700D0A20202020202065786974207768656E206E6F742067';
wwv_flow_imp.g_varchar2_table(130) := '65745F63656E7472616C5F66696C655F6865616465722820705F786C73782C206E756C6C2C20692C206E756C6C2C206C5F63666820293B0D0A2020202020206C5F6E616D65203A3D206C6F776572282075746C5F7261772E636173745F746F5F76617263';
wwv_flow_imp.g_varchar2_table(131) := '6861723228206C5F6366682E6E616D6531202920293B0D0A2020202020206966202020206C5F6E616D65206C696B65202725776F726B626F6F6B2E786D6C272020202020207468656E0D0A20202020202020206C5F776F726B626F6F6B2020202020203A';
wwv_flow_imp.g_varchar2_table(132) := '3D2070617273655F66696C652820705F786C73782C206C5F63666820293B0D0A202020202020656C736966206C5F6E616D65206C696B65202725776F726B626F6F6B2E786D6C2E72656C7327207468656E0D0A20202020202020206C5F776F726B626F6F';
wwv_flow_imp.g_varchar2_table(133) := '6B5F72656C73203A3D2070617273655F66696C652820705F786C73782C206C5F63666820293B0D0A202020202020656C736966206C5F6E616D65206C696B65202725736861726564737472696E67732E786D6C27207468656E0D0A20202020202020206C';
wwv_flow_imp.g_varchar2_table(134) := '5F7368617265645F737472696E6773203A3D2070617273655F66696C652820705F786C73782C206C5F63666820293B0D0A202020202020202073656C656374207874312E7478740D0A202020202020202020202020202C207874312E6C656E0D0A202020';
wwv_flow_imp.g_varchar2_table(135) := '202020202062756C6B20636F6C6C65637420696E746F206C5F737472696E67732C206C5F737472696E675F6C656E730D0A202020202020202066726F6D20786D6C7461626C652820786D6C6E616D65737061636573282064656661756C74202768747470';
wwv_flow_imp.g_varchar2_table(136) := '3A2F2F736368656D61732E6F70656E786D6C666F726D6174732E6F72672F73707265616473686565746D6C2F323030362F6D61696E270D0A2020202020202020202020202020202020202020202020202020202020202020202020202C2027687474703A';
wwv_flow_imp.g_varchar2_table(137) := '2F2F7075726C2E6F636C632E6F72672F6F6F786D6C2F73707265616473686565746D6C2F6D61696E272061732022782220290D0A2020202020202020202020202020202020202020202C202728202F7373742F73692C202F783A7373742F783A73692029';
wwv_flow_imp.g_varchar2_table(138) := '270D0A202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461203D3E206C5F7368617265645F737472696E67732C20637369643D3E206C5F637369645F7574663820290D0A202020202020';
wwv_flow_imp.g_varchar2_table(139) := '2020202020202020202020202020202020636F6C756D6E7320747874207661726368617232283430303020636861722920706174682027737562737472696E672820737472696E672D6A6F696E282E2F2F2A3A742F7465787428292C20222220292C2031';
wwv_flow_imp.g_varchar2_table(140) := '2C20333930302029270D0A20202020202020202020202020202020202020202020202020202020202C206C656E20696E746567657220202020202020202020202020706174682027737472696E672D6C656E6774682820737472696E672D6A6F696E282E';
wwv_flow_imp.g_varchar2_table(141) := '2F2F2A3A742F7465787428292C20222220292029270D0A20202020202020202020202020202020202020202029207874313B0D0A202020202020656C736966206C5F6E616D65206C696B652027257374796C65732E786D6C27207468656E0D0A20202020';
wwv_flow_imp.g_varchar2_table(142) := '202020206C5F66696C65203A3D2070617273655F66696C652820705F786C73782C206C5F63666820293B0D0A2020202020202020666F7220725F6E20696E20282073656C656374207874322E736571202D2031207365710D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(143) := '2020202020202020202020202020202C207874322E69640D0A20202020202020202020202020202020202020202020202020202C207874322E71756F74657072656669780D0A20202020202020202020202020202020202020202020202020202C206C6F';
wwv_flow_imp.g_varchar2_table(144) := '77657228207874332E666F726D6174202920666F726D61740D0A20202020202020202020202020202020202020202066726F6D20786D6C7461626C652820786D6C6E616D65737061636573282064656661756C742027687474703A2F2F736368656D6173';
wwv_flow_imp.g_varchar2_table(145) := '2E6F70656E786D6C666F726D6174732E6F72672F73707265616473686565746D6C2F323030362F6D61696E270D0A202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202C20276874';
wwv_flow_imp.g_varchar2_table(146) := '74703A2F2F7075726C2E6F636C632E6F72672F6F6F786D6C2F73707265616473686565746D6C2F6D61696E272061732022782220290D0A202020202020202020202020202020202020202020202020202020202020202020202C202728202F7374796C65';
wwv_flow_imp.g_varchar2_table(147) := '53686565742C202F783A7374796C6553686565742029270D0A20202020202020202020202020202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461203D3E206C5F66696C652C20637369';
wwv_flow_imp.g_varchar2_table(148) := '643D3E206E6C735F636861727365745F6964282027414C33325554463827202920290D0A2020202020202020202020202020202020202020202020202020202020202020202020202020636F6C756D6E732063656C6C78667320786D6C74797065207061';
wwv_flow_imp.g_varchar2_table(149) := '74682027282063656C6C5866732C20783A63656C6C5866732029270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202C206E756D666D747320786D6C747970652070617468202728206E';
wwv_flow_imp.g_varchar2_table(150) := '756D466D74732C20783A6E756D466D74732029270D0A2020202020202020202020202020202020202020202020202020202020202020202029207874310D0A20202020202020202020202020202020202020202063726F7373206A6F696E0D0A20202020';
wwv_flow_imp.g_varchar2_table(151) := '20202020202020202020202020202020202020202020786D6C7461626C652820272F2A3A63656C6C5866732F2A3A7866270D0A20202020202020202020202020202020202020202020202020202020202020202020202070617373696E67207874312E63';
wwv_flow_imp.g_varchar2_table(152) := '656C6C7866730D0A2020202020202020202020202020202020202020202020202020202020202020202020202020636F6C756D6E732073657120666F72206F7264696E616C6974790D0A2020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(153) := '2020202020202020202020202020202020202C20696420202020202020202020696E74656765722020202020202020706174682027406E756D466D744964270D0A2020202020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(154) := '2020202020202020202C2071756F7465707265666978207661726368617232283430303029207061746820274071756F7465507265666978270D0A2020202020202020202020202020202020202020202020202020202020202020202029207874320D0A';
wwv_flow_imp.g_varchar2_table(155) := '2020202020202020202020202020202020202020206C656674206A6F696E0D0A2020202020202020202020202020202020202020202020202020786D6C7461626C652820272F2A3A6E756D466D74732F2A3A6E756D466D74270D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(156) := '20202020202020202020202020202020202020202020202020202070617373696E67207874312E6E756D666D74730D0A202020202020202020202020202020202020202020202020202020202020202020202020636F6C756D6E73206964202020202069';
wwv_flow_imp.g_varchar2_table(157) := '6E74656765722020202020202020706174682027406E756D466D744964270D0A2020202020202020202020202020202020202020202020202020202020202020202020202020202020202C20666F726D6174207661726368617232283430303029207061';
wwv_flow_imp.g_varchar2_table(158) := '7468202740666F726D6174436F6465270D0A2020202020202020202020202020202020202020202020202020202020202020202029207874330D0A2020202020202020202020202020202020202020206F6E207874332E6964203D207874322E69640D0A';
wwv_flow_imp.g_varchar2_table(159) := '20202020202020202020202020202020202020290D0A20202020202020206C6F6F700D0A20202020202020202020696620202020725F6E2E6964206265747765656E20313420616E642031370D0A202020202020202020202020206F7220696E73747228';
wwv_flow_imp.g_varchar2_table(160) := '20725F6E2E666F726D61742C202764272029203E20300D0A202020202020202020202020206F7220696E7374722820725F6E2E666F726D61742C202779272029203E20300D0A202020202020202020207468656E0D0A2020202020202020202020206C5F';
wwv_flow_imp.g_varchar2_table(161) := '646174655F7374796C65732820725F6E2E7365712029203A3D206E756C6C3B0D0A20202020202020202020656C73696620725F6E2E6964206265747765656E20313820616E642032320D0A202020202020202020202020206F7220725F6E2E6964206265';
wwv_flow_imp.g_varchar2_table(162) := '747765656E20343520616E642034370D0A202020202020202020202020206F7220696E7374722820725F6E2E666F726D61742C202768272029203E20300D0A202020202020202020202020206F7220696E7374722820725F6E2E666F726D61742C20276D';
wwv_flow_imp.g_varchar2_table(163) := '272029203E20300D0A202020202020202020207468656E0D0A2020202020202020202020206C5F74696D655F7374796C65732820725F6E2E7365712029203A3D206E756C6C3B0D0A20202020202020202020656C73696620725F6E2E71756F7465707265';
wwv_flow_imp.g_varchar2_table(164) := '66697820696E2028202731272C2027747275652720290D0A202020202020202020207468656E0D0A2020202020202020202020206C5F71756F74655F7072656669782820725F6E2E7365712029203A3D206E756C6C3B0D0A20202020202020202020656E';
wwv_flow_imp.g_varchar2_table(165) := '642069663B0D0A2020202020202020656E64206C6F6F703B0D0A202020202020202064626D735F6C6F622E6672656574656D706F7261727928206C5F66696C6520293B0D0A202020202020656E642069663B0D0A20202020656E64206C6F6F703B0D0A20';
wwv_flow_imp.g_varchar2_table(166) := '2020206966206C5F776F726B626F6F6B206973206E756C6C206F72206C5F776F726B626F6F6B5F72656C73206973206E756C6C0D0A202020207468656E0D0A2020202020206C5F6C6F67203A3D20274E6F20786C73782066696C6527207C7C2063687228';
wwv_flow_imp.g_varchar2_table(167) := '3130293B0D0A20202020202072657475726E3B0D0A20202020656E642069663B0D0A202020206C5F6C6F67203A3D202770617273655F786C73782E7072632076657273696F6E20312E303030273B0D0A202020202D2D0D0A20202020666F7220725F7820';
wwv_flow_imp.g_varchar2_table(168) := '696E20282073656C656374207874312E64313930340D0A202020202020202020202020202020202020202020202C207874322E7365710D0A202020202020202020202020202020202020202020202C207874322E6E616D650D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(169) := '2020202020202020202020202C207874332E7461726765740D0A202020202020202020202020202020202066726F6D20786D6C7461626C652820786D6C6E616D65737061636573282064656661756C742027687474703A2F2F736368656D61732E6F7065';
wwv_flow_imp.g_varchar2_table(170) := '6E786D6C666F726D6174732E6F72672F73707265616473686565746D6C2F323030362F6D61696E270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202C20276874';
wwv_flow_imp.g_varchar2_table(171) := '74703A2F2F7075726C2E6F636C632E6F72672F6F6F786D6C2F73707265616473686565746D6C2F6D61696E272061732022782220290D0A2020202020202020202020202020202020202020202020202020202020202C202728202F776F726B626F6F6B2C';
wwv_flow_imp.g_varchar2_table(172) := '202F783A776F726B626F6F6B2029270D0A202020202020202020202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461203D3E206C5F776F726B626F6F6B2C20637369643D3E206E6C735F';
wwv_flow_imp.g_varchar2_table(173) := '636861727365745F6964282027414C33325554463827202920290D0A2020202020202020202020202020202020202020202020202020202020202020636F6C756D6E73206431393034202076617263686172322820343030302029207061746820272A3A';
wwv_flow_imp.g_varchar2_table(174) := '776F726B626F6F6B50722F406461746531393034270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202C2073686565747320786D6C74797065207061746820272A3A736865657473270D0A2020202020';
wwv_flow_imp.g_varchar2_table(175) := '2020202020202020202020202020202020202020202020202029207874310D0A202020202020202020202020202020202063726F7373206A6F696E0D0A20202020202020202020202020202020202020202020786D6C7461626C652820272A3A73686565';
wwv_flow_imp.g_varchar2_table(176) := '74732F2A3A7368656574270D0A202020202020202020202020202020202020202020202020202020202020202070617373696E67207874312E7368656574730D0A2020202020202020202020202020202020202020202020202020202020202020636F6C';
wwv_flow_imp.g_varchar2_table(177) := '756D6E732073657120666F72206F7264696E616C6974790D0A20202020202020202020202020202020202020202020202020202020202020202020202020202C206E616D65202020207661726368617232282034303030202920706174682027406E616D';
wwv_flow_imp.g_varchar2_table(178) := '65270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202C20736865657469642076617263686172322820343030302029207061746820274073686565744964270D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(179) := '2020202020202020202020202020202020202020202020202C2072696420202020207661726368617232282034303030202920706174682027402A3A69645B206E616D6573706163652D757269282E29203D0D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(180) := '202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020282022687474703A2F2F736368656D61732E6F70656E786D6C666F726D6174732E6F72672F6F6666696365';
wwv_flow_imp.g_varchar2_table(181) := '446F63756D656E742F323030362F72656C6174696F6E7368697073220D0A20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(182) := '2020202C2022687474703A2F2F7075726C2E6F636C632E6F72672F6F6F786D6C2F6F6666696365446F63756D656E742F72656C6174696F6E7368697073220D0A202020202020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(183) := '2020202020202020202020202020202020202020202020202020202020202020202020202029205D270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202C207374617465202020766172636861723228';
wwv_flow_imp.g_varchar2_table(184) := '2034303030202920706174682027407374617465272029207874320D0A20202020202020202020202020202020206A6F696E0D0A20202020202020202020202020202020202020202020786D6C7461626C652820786D6C6E616D65737061636573282064';
wwv_flow_imp.g_varchar2_table(185) := '656661756C742027687474703A2F2F736368656D61732E6F70656E786D6C666F726D6174732E6F72672F7061636B6167652F323030362F72656C6174696F6E73686970732720290D0A202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(186) := '2020202C20272F52656C6174696F6E73686970732F52656C6174696F6E73686970270D0A202020202020202020202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461203D3E206C5F776F';
wwv_flow_imp.g_varchar2_table(187) := '726B626F6F6B5F72656C732C20637369643D3E206E6C735F636861727365745F6964282027414C33325554463827202920290D0A2020202020202020202020202020202020202020202020202020202020202020636F6C756D6E73207479706520202020';
wwv_flow_imp.g_varchar2_table(188) := '76617263686172322820343030302029207061746820274054797065270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202C207461726765742020766172636861723228203430303020292070617468';
wwv_flow_imp.g_varchar2_table(189) := '202740546172676574270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202C2069642020202020207661726368617232282034303030202920706174682027404964272029207874330D0A2020202020';
wwv_flow_imp.g_varchar2_table(190) := '2020202020202020202020206F6E207874332E6964203D207874322E7269640D0A20202020202020202020202020202020206F72646572206279207874322E736865657469640D0A202020202020202020202020202020290D0A202020206C6F6F700D0A';
wwv_flow_imp.g_varchar2_table(191) := '2020202020206C5F6C6F67203A3D206C5F6C6F67207C7C20282027666F756E642073686565743A2027207C7C20725F782E736571207C7C20272C2027207C7C20725F782E6E616D65207C7C206368722831302920293B0D0A202020202020696620282070';
wwv_flow_imp.g_varchar2_table(192) := '5F736865657473206973206E756C6C0D0A2020202020202020206F7220696E7374722820273A27207C7C20705F736865657473207C7C20273A272C20273A27207C7C20725F782E736571207C7C20273A272029203E20300D0A2020202020202020206F72';
wwv_flow_imp.g_varchar2_table(193) := '20696E7374722820273A27207C7C20705F736865657473207C7C20273A272C20273A27207C7C20725F782E6E616D65207C7C20273A272029203E20300D0A202020202020202020290D0A2020202020207468656E0D0A20202020202020206C5F6C6F6720';
wwv_flow_imp.g_varchar2_table(194) := '3A3D206C5F6C6F67207C7C202820276C6F61642073686565743A2027207C7C20725F782E736571207C7C20272C2027207C7C20725F782E6E616D65207C7C206368722831302920293B0D0A20202020202020206C5F636F6C5F636E74203A3D206C5F636F';
wwv_flow_imp.g_varchar2_table(195) := '6C5F636E74202B20313B0D0A2020202020202020617065785F636F6C6C656374696F6E2E6372656174655F636F6C6C656374696F6E28206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C696628206C5F636F6C5F636E742C203120292C20';
wwv_flow_imp.g_varchar2_table(196) := '275945532720293B0D0A2020202020202020666F72206920696E2031202E2E206C5F636E740D0A20202020202020206C6F6F700D0A2020202020202020202065786974207768656E206E6F74206765745F63656E7472616C5F66696C655F686561646572';
wwv_flow_imp.g_varchar2_table(197) := '2820705F786C73782C206E756C6C2C20692C206E756C6C2C206C5F63666820293B0D0A2020202020202020202069662075746C5F7261772E636173745F746F5F766172636861723228206C5F6366682E6E616D65312029206C696B6520272527207C7C20';
wwv_flow_imp.g_varchar2_table(198) := '725F782E7461726765740D0A202020202020202020207468656E0D0A2020202020202020202020206C5F656D707479203A3D20747275653B0D0A2020202020202020202020206C5F707265765F726F775F6E72203A3D20313B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(199) := '2020206C5F707265765F636F6C5F626C6F636B203A3D20303B200D0A2020202020202020202020206C5F636F6C5F6D656D203A3D2074705F636F6C5F6D656D28293B0D0A2020202020202020202020206C5F636F6C5F6D656D2E657874656E6428203530';
wwv_flow_imp.g_varchar2_table(200) := '20293B0D0A2020202020202020202020206C5F66696C65203A3D2070617273655F66696C652820705F786C73782C206C5F63666820293B0D0A2020202020202020202020202D2D0D0A202020202020202020202020696620705F35300D0A202020202020';
wwv_flow_imp.g_varchar2_table(201) := '2020202020207468656E0D0A202020202020202020202020202073656C65637420786D6C636173742820786D6C71756572792820272F2A3A776F726B73686565742F2A3A64696D656E73696F6E2F40726566270D0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(202) := '2020202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461203D3E206C5F66696C652C20637369643D3E206C5F637369645F7574663820292072657475726E696E6720636F6E74656E740D';
wwv_flow_imp.g_varchar2_table(203) := '0A20202020202020202020202020202020202020202020202020202020202020202020202020202920617320766172636861723228313030290D0A20202020202020202020202020202020202020202020202020202020290D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(204) := '20202020696E746F206C5F64696D656E73696F6E0D0A202020202020202020202020202066726F6D206475616C3B0D0A20202020202020202020202020206966206C5F64696D656E73696F6E206973206E6F74206E756C6C0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(205) := '20202020202020616E6420696E73747228206C5F64696D656E73696F6E2C20273A272029203E20300D0A20202020202020202020202020207468656E0D0A202020202020202020202020202020206C5F6D61785F636F6C5F626C6F636B203A3D20636F6C';
wwv_flow_imp.g_varchar2_table(206) := '5F616C66616E282073756273747228206C5F64696D656E73696F6E2C20696E73747228206C5F64696D656E73696F6E2C20273A272029202B2031202920293B200D0A202020202020202020202020202020206C5F6D61785F636F6C5F626C6F636B203A3D';
wwv_flow_imp.g_varchar2_table(207) := '207472756E63282028206C5F6D61785F636F6C5F626C6F636B202D20312029202F20353020293B0D0A2020202020202020202020202020656E642069663B0D0A202020202020202020202020656E642069663B0D0A2020202020202020202020202D2D0D';
wwv_flow_imp.g_varchar2_table(208) := '0A202020202020202020202020666F7220725F6320696E20282073656C656374202A0D0A2020202020202020202020202020202020202020202020202066726F6D20786D6C7461626C652820786D6C6E616D65737061636573282064656661756C742027';
wwv_flow_imp.g_varchar2_table(209) := '687474703A2F2F736368656D61732E6F70656E786D6C666F726D6174732E6F72672F73707265616473686565746D6C2F323030362F6D61696E270D0A20202020202020202020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(210) := '202020202020202020202020202C2027687474703A2F2F7075726C2E6F636C632E6F72672F6F6F786D6C2F73707265616473686565746D6C2F6D61696E272061732022782220290D0A202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(211) := '20202020202020202020202C202728202F776F726B73686565742F7368656574446174612F726F772F632C202F783A776F726B73686565742F783A7368656574446174612F783A726F772F783A632029270D0A2020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(212) := '202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461203D3E206C5F66696C652C20637369643D3E206C5F637369645F7574663820290D0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(213) := '202020202020202020202020202020202020202020636F6C756D6E732076207661726368617232283430303029207061746820272A3A76270D0A202020202020202020202020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(214) := '202020202C2066207661726368617232283430303029207061746820272A3A66270D0A202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202C207420766172636861723228343030302920';
wwv_flow_imp.g_varchar2_table(215) := '7061746820274074270D0A202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202C2072207661726368617232283332292020207061746820274072270D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(216) := '2020202020202020202020202020202020202020202020202020202020202020202C207320696E746567657220202020202020207061746820274073270D0A20202020202020202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(217) := '2020202020202020202C20727720696E7465676572202020202020207061746820272E2F2E2E2F4072270D0A202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202C207478742076617263';
wwv_flow_imp.g_varchar2_table(218) := '68617232283430303020636861722920706174682027737562737472696E672820737472696E672D6A6F696E282E2F2F2A3A742F7465787428292C20222220292C20312C20333930302029270D0A20202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(219) := '2020202020202020202020202020202020202020202020202C206C656E20696E746567657220202020202020202020202020706174682027737472696E672D6C656E6774682820737472696E672D6A6F696E282E2F2F2A3A742F7465787428292C202222';
wwv_flow_imp.g_varchar2_table(220) := '20292029270D0A2020202020202020202020202020202020202020202020202020202020202020202020202020290D0A2020202020202020202020202020202020202020202020290D0A2020202020202020202020206C6F6F700D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(221) := '202020202020696620725F632E72206973206E756C6C0D0A20202020202020202020202020207468656E0D0A202020202020202020202020202020206966206C5F726F775F6E72203D20725F632E72770D0A202020202020202020202020202020207468';
wwv_flow_imp.g_varchar2_table(222) := '656E0D0A2020202020202020202020202020202020206C5F636F6C5F6E72203A3D206C5F636F6C5F6E72202B20313B0D0A20202020202020202020202020202020656C73650D0A2020202020202020202020202020202020206C5F636F6C5F6E72203A3D';
wwv_flow_imp.g_varchar2_table(223) := '20313B0D0A20202020202020202020202020202020656E642069663B0D0A2020202020202020202020202020656C73650D0A202020202020202020202020202020206C5F636F6C5F6E72203A3D20636F6C5F616C66616E2820725F632E7220293B0D0A20';
wwv_flow_imp.g_varchar2_table(224) := '20202020202020202020202020656E642069663B0D0A20202020202020202020202020206C5F636F6C5F626C6F636B203A3D207472756E63282028206C5F636F6C5F6E72202D20312029202F20353020293B0D0A20202020202020202020202020206C5F';
wwv_flow_imp.g_varchar2_table(225) := '726F775F6E72203A3D20636F616C657363652820725F632E72772C206C5F726F775F6E72202B203120293B0D0A202020202020202020202020202069662020202020705F3530200D0A2020202020202020202020202020202020616E64206C5F726F775F';
wwv_flow_imp.g_varchar2_table(226) := '6E72203D206C5F707265765F726F775F6E720D0A2020202020202020202020202020202020616E64206C5F636F6C5F626C6F636B203E206C5F707265765F636F6C5F626C6F636B0D0A20202020202020202020202020207468656E0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(227) := '2020202020202020206164645F6D656D62657228206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C696628206C5F636F6C5F636E742C203120292C206C5F707265765F726F775F6E722C206C5F707265765F636F6C5F626C6F636B202A20';
wwv_flow_imp.g_varchar2_table(228) := '3530202B203120293B0D0A202020202020202020202020202020206966206E6F74206C5F656D7074790D0A202020202020202020202020202020207468656E0D0A2020202020202020202020202020202020206C5F636F6C5F6D656D203A3D2074705F63';
wwv_flow_imp.g_varchar2_table(229) := '6F6C5F6D656D28293B0D0A2020202020202020202020202020202020206C5F636F6C5F6D656D2E657874656E642820353020293B0D0A2020202020202020202020202020202020206C5F656D707479203A3D20747275653B0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(230) := '202020202020656E642069663B0D0A20202020202020202020202020202020666F72206A20696E206C5F707265765F636F6C5F626C6F636B202B2031202E2E206C5F636F6C5F626C6F636B202D20310D0A202020202020202020202020202020206C6F6F';
wwv_flow_imp.g_varchar2_table(231) := '700D0A2020202020202020202020202020202020206164645F6D656D62657228206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C696628206C5F636F6C5F636E742C203120292C206C5F707265765F726F775F6E722C206A202A20353020';
wwv_flow_imp.g_varchar2_table(232) := '2B203120293B0D0A20202020202020202020202020202020656E64206C6F6F703B0D0A2020202020202020202020202020656E642069663B0D0A20202020202020202020202020206966206C5F726F775F6E72203E206C5F707265765F726F775F6E720D';
wwv_flow_imp.g_varchar2_table(233) := '0A20202020202020202020202020207468656E0D0A202020202020202020202020202020206164645F6D656D62657228206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C696628206C5F636F6C5F636E742C203120292C206C5F70726576';
wwv_flow_imp.g_varchar2_table(234) := '5F726F775F6E722C206C5F707265765F636F6C5F626C6F636B202A203530202B203120293B0D0A202020202020202020202020202020206966206E6F74206C5F656D7074790D0A202020202020202020202020202020207468656E0D0A20202020202020';
wwv_flow_imp.g_varchar2_table(235) := '20202020202020202020206C5F636F6C5F6D656D203A3D2074705F636F6C5F6D656D28293B0D0A2020202020202020202020202020202020206C5F636F6C5F6D656D2E657874656E642820353020293B0D0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(236) := '6C5F656D707479203A3D20747275653B0D0A20202020202020202020202020202020656E642069663B0D0A202020202020202020202020202020206966206C5F6D61785F636F6C5F626C6F636B203E20300D0A2020202020202020202020202020202074';
wwv_flow_imp.g_varchar2_table(237) := '68656E0D0A202020202020202020202020202020202020666F72206A20696E206C5F707265765F636F6C5F626C6F636B202B2031202E2E206C5F6D61785F636F6C5F626C6F636B0D0A2020202020202020202020202020202020206C6F6F700D0A202020';
wwv_flow_imp.g_varchar2_table(238) := '20202020202020202020202020202020206164645F6D656D62657228206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C696628206C5F636F6C5F636E742C203120292C206C5F707265765F726F775F6E722C206A202A203530202B203120';
wwv_flow_imp.g_varchar2_table(239) := '293B0D0A202020202020202020202020202020202020656E64206C6F6F703B0D0A20202020202020202020202020202020656E642069663B0D0A20202020202020202020202020202020666F72206920696E206C5F707265765F726F775F6E72202B2031';
wwv_flow_imp.g_varchar2_table(240) := '202E2E206C5F726F775F6E72202D20310D0A202020202020202020202020202020206C6F6F700D0A2020202020202020202020202020202020206164645F6D656D62657228206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C696628206C';
wwv_flow_imp.g_varchar2_table(241) := '5F636F6C5F636E742C203120292C20692C203120293B0D0A2020202020202020202020202020202020206966206C5F6D61785F636F6C5F626C6F636B203E20300D0A2020202020202020202020202020202020207468656E0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(242) := '20202020202020202020666F72206A20696E2031202E2E206C5F6D61785F636F6C5F626C6F636B0D0A20202020202020202020202020202020202020206C6F6F700D0A202020202020202020202020202020202020202020206164645F6D656D62657228';
wwv_flow_imp.g_varchar2_table(243) := '206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C696628206C5F636F6C5F636E742C203120292C20692C206A202A203530202B203120293B0D0A2020202020202020202020202020202020202020656E64206C6F6F703B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(244) := '20202020202020202020202020656E642069663B0D0A20202020202020202020202020202020656E64206C6F6F703B0D0A2020202020202020202020202020656E642069663B0D0A20202020202020202020202020202D2D0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(245) := '20202020696620705F3530206F72206C5F636F6C5F626C6F636B203D20300D0A20202020202020202020202020207468656E0D0A202020202020202020202020202020206C5F656D707479203A3D2066616C73653B0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(246) := '202020696620725F632E74203D202773270D0A202020202020202020202020202020207468656E0D0A202020202020202020202020202020202020696620725F632E76206973206E6F74206E756C6C0D0A20202020202020202020202020202020202074';
wwv_flow_imp.g_varchar2_table(247) := '68656E0D0A20202020202020202020202020202020202020206C5F746D70203A3D206C5F737472696E67732820746F5F6E756D6265722820725F632E762029202B203120293B0D0A20202020202020202020202020202020202020206966206C5F737472';
wwv_flow_imp.g_varchar2_table(248) := '696E675F6C656E732820746F5F6E756D6265722820725F632E762029202B20312029203E20333930300D0A20202020202020202020202020202020202020207468656E0D0A2020202020202020202020202020202020202020202073656C656374207375';
wwv_flow_imp.g_varchar2_table(249) := '6273747228207874312E7478742C20312C206C5F76617263686172325F737A20290D0A20202020202020202020202020202020202020202020696E746F206C5F746D700D0A2020202020202020202020202020202020202020202066726F6D20786D6C74';
wwv_flow_imp.g_varchar2_table(250) := '61626C652820272F2A3A7373742F2A3A73695B24695D270D0A2020202020202020202020202020202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461203D3E206C5F7368617265645F73';
wwv_flow_imp.g_varchar2_table(251) := '7472696E67732C20637369643D3E206C5F637369645F7574663820290D0A202020202020202020202020202020202020202020202020202020202020202020202020202020202020202C20746F5F6E756D6265722820725F632E762029202B2031206173';
wwv_flow_imp.g_varchar2_table(252) := '202269220D0A20202020202020202020202020202020202020202020202020202020202020202020202020636F6C756D6E732074787420636C6F6220706174682027737472696E672D6A6F696E282E2F2F2A3A742F7465787428292C2022222029270D0A';
wwv_flow_imp.g_varchar2_table(253) := '202020202020202020202020202020202020202020202020202020202020202020202029207874313B0D0A2020202020202020202020202020202020202020656E642069663B0D0A20202020202020202020202020202020202020206966206C5F71756F';
wwv_flow_imp.g_varchar2_table(254) := '74655F7072656669782E6578697374732820725F632E73202920616E64206C656E67746828206C5F746D702029203C206C5F76617263686172325F737A0D0A20202020202020202020202020202020202020207468656E0D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(255) := '20202020202020202020206C5F746D70203A3D2027272727207C7C206C5F746D703B0D0A2020202020202020202020202020202020202020656E642069663B0D0A202020202020202020202020202020202020656E642069663B0D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(256) := '2020202020202020656C73696620725F632E74203D20276E27206F7220725F632E74206973206E756C6C0D0A202020202020202020202020202020207468656E0D0A2020202020202020202020202020202020206C5F6E72203A3D20746F5F6E756D6265';
wwv_flow_imp.g_varchar2_table(257) := '722820725F632E760D0A20202020202020202020202020202020202020202020202020202020202020202020202C2063617365207768656E20696E737472282075707065722820725F632E7620292C202745272029203D20300D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(258) := '2020202020202020202020202020202020202020202020202020202020207468656E207472616E736C6174652820725F632E762C20272E3031323334353637382C2D2B272C2027443939393939393939392720290D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(259) := '20202020202020202020202020202020202020202020202020656C7365207472616E736C61746528207375627374722820725F632E762C20312C20696E737472282075707065722820725F632E762029202C202745272029202D203120292C20272E3031';
wwv_flow_imp.g_varchar2_table(260) := '323334353637382C2D2B272C202744393939393939393939272029207C7C202745454545270D0A20202020202020202020202020202020202020202020202020202020202020202020202020656E640D0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(261) := '202020202020202020202020202020202C20274E4C535F4E554D455249435F434841524143544552533D2E2C270D0A2020202020202020202020202020202020202020202020202020202020202020202020293B0D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(262) := '202020206966206C5F646174655F7374796C65732E6578697374732820725F632E7320290D0A2020202020202020202020202020202020207468656E0D0A20202020202020202020202020202020202020206966206C6F7765722820725F782E64313930';
wwv_flow_imp.g_varchar2_table(263) := '34202920696E2028202774727565272C2027312720290D0A20202020202020202020202020202020202020207468656E0D0A202020202020202020202020202020202020202020206C5F746D70203A3D20746F5F63686172282064617465202731393034';
wwv_flow_imp.g_varchar2_table(264) := '2D30312D303127202B206C5F6E722C2027797979792D6D6D2D646420686832343A6D693A73732720293B0D0A2020202020202020202020202020202020202020656C73650D0A202020202020202020202020202020202020202020206C5F746D70203A3D';
wwv_flow_imp.g_varchar2_table(265) := '20746F5F636861722820646174652027313930302D30332D303127202B2028206C5F6E72202D2063617365207768656E206C5F6E72203C203631207468656E20363020656C736520363120656E6420292C2027797979792D6D6D2D646420686832343A6D';
wwv_flow_imp.g_varchar2_table(266) := '693A73732720293B0D0A2020202020202020202020202020202020202020656E642069663B0D0A202020202020202020202020202020202020656C736966206C5F74696D655F7374796C65732E6578697374732820725F632E7320290D0A202020202020';
wwv_flow_imp.g_varchar2_table(267) := '2020202020202020202020207468656E0D0A20202020202020202020202020202020202020206C5F746D70203A3D20746F5F6368617228206E756D746F6473696E74657276616C28206C5F6E722C202764617927202920293B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(268) := '202020202020202020656C73650D0A2020202020202020202020202020202020202020696620705F726F756E640D0A20202020202020202020202020202020202020207468656E0D0A202020202020202020202020202020202020202020206C5F6E7220';
wwv_flow_imp.g_varchar2_table(269) := '3A3D20726F756E6428206C5F6E722C203134202D207375627374722820746F5F6368617228206C5F6E722C2027544D452720292C202D33202920293B0D0A2020202020202020202020202020202020202020656E642069663B0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(270) := '20202020202020202020206C5F746D70203A3D206C5F6E723B0D0A202020202020202020202020202020202020656E642069663B0D0A20202020202020202020202020202020656C73696620725F632E74203D202764270D0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(271) := '20202020207468656E0D0A2020202020202020202020202020202020206C5F746D70203A3D20746F5F636861722820636173742820746F5F74696D657374616D705F747A2820725F632E762C2027797979792D6D6D2D6464225422686832343A6D693A73';
wwv_flow_imp.g_varchar2_table(272) := '732E6666545A483A545A4D272029206173206461746520292C2027797979792D6D6D2D646420686832343A6D693A73732720293B0D0A20202020202020202020202020202020656C73696620725F632E74203D2027696E6C696E65537472270D0A202020';
wwv_flow_imp.g_varchar2_table(273) := '202020202020202020202020207468656E0D0A2020202020202020202020202020202020206C5F746D70203A3D20725F632E7478743B0D0A20202020202020202020202020202020202069662020202020725F632E6C656E203E20333930300D0A202020';
wwv_flow_imp.g_varchar2_table(274) := '202020202020202020202020202020202020616E6420725F632E72206973206E6F74206E756C6C0D0A2020202020202020202020202020202020207468656E0D0A202020202020202020202020202020202020202073656C656374207375627374722820';
wwv_flow_imp.g_varchar2_table(275) := '7874312E7478742C20312C206C5F76617263686172325F737A20290D0A2020202020202020202020202020202020202020696E746F206C5F746D700D0A202020202020202020202020202020202020202066726F6D20786D6C7461626C652820272F2A3A';
wwv_flow_imp.g_varchar2_table(276) := '776F726B73686565742F2A3A7368656574446174612F2A3A726F772F2A3A635B40723D24725D270D0A202020202020202020202020202020202020202020202020202020202020202020202070617373696E6720786D6C747970652820786D6C64617461';
wwv_flow_imp.g_varchar2_table(277) := '203D3E206C5F66696C652C20637369643D3E206C5F637369645F7574663820290D0A20202020202020202020202020202020202020202020202020202020202020202020202020202020202C20725F632E72206173202272220D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(278) := '2020202020202020202020202020202020202020202020202020636F6C756D6E732074787420636C6F6220706174682027737472696E672D6A6F696E282E2F2F2A3A742F7465787428292C2022222029270D0A2020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(279) := '2020202020202020202020202020202029207874313B0D0A202020202020202020202020202020202020656E642069663B0D0A20202020202020202020202020202020656C73696620725F632E7420696E20282027737472272C2027652720290D0A2020';
wwv_flow_imp.g_varchar2_table(280) := '20202020202020202020202020207468656E0D0A2020202020202020202020202020202020206C5F746D70203A3D20725F632E763B0D0A20202020202020202020202020202020656C73696620725F632E74203D202762270D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(281) := '2020202020207468656E0D0A2020202020202020202020202020202020206C5F746D70203A3D206361736520725F632E760D0A20202020202020202020202020202020202020202020202020202020207768656E20273127207468656E20275452554527';
wwv_flow_imp.g_varchar2_table(282) := '0D0A20202020202020202020202020202020202020202020202020202020207768656E20273027207468656E202746414C5345270D0A2020202020202020202020202020202020202020202020202020202020656C736520725F632E760D0A2020202020';
wwv_flow_imp.g_varchar2_table(283) := '20202020202020202020202020202020202020202020656E643B0D0A20202020202020202020202020202020656E642069663B0D0A202020202020202020202020202020206C5F636F6C5F6D656D28206C5F636F6C5F6E72202D206C5F636F6C5F626C6F';
wwv_flow_imp.g_varchar2_table(284) := '636B202A2035302029203A3D2073756273747228206C5F746D702C20312C206C5F76617263686172325F737A20293B0D0A2020202020202020202020202020656E642069663B0D0A20202020202020202020202020202D2D0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(285) := '202020206C5F707265765F726F775F6E72203A3D206C5F726F775F6E723B0D0A20202020202020202020202020206C5F707265765F636F6C5F626C6F636B203A3D206C5F636F6C5F626C6F636B3B0D0A202020202020202020202020656E64206C6F6F70';
wwv_flow_imp.g_varchar2_table(286) := '3B0D0A2020202020202020202020206966206E6F74206C5F656D7074790D0A2020202020202020202020207468656E0D0A20202020202020202020202020206164645F6D656D62657228206C5F636F6C6C656374696F6E5F62617365207C7C206E756C6C';
wwv_flow_imp.g_varchar2_table(287) := '696628206C5F636F6C5F636E742C203120292C206C5F707265765F726F775F6E722C206C5F636F6C5F626C6F636B202A203530202B203120293B0D0A202020202020202020202020656E642069663B0D0A2020202020202020202020206C5F6C6F67203A';
wwv_flow_imp.g_varchar2_table(288) := '3D206C5F6C6F67207C7C20282027726F77733A2027207C7C2063617365207768656E206C5F656D70747920616E64206C5F707265765F726F775F6E72203D2031207468656E203020656C7365206C5F707265765F726F775F6E7220656E64207C7C206368';
wwv_flow_imp.g_varchar2_table(289) := '722831302920293B0D0A20202020202020202020202064626D735F6C6F622E6672656574656D706F7261727928206C5F66696C6520293B0D0A202020202020202020202020657869743B0D0A20202020202020202020656E642069663B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(290) := '202020656E64206C6F6F703B0D0A2020202020202020617065785F636F6C6C656374696F6E2E6164645F6D656D62657228206C5F636F6C6C656374696F6E5F62617365207C7C20275F244D4150270D0A2020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(291) := '20202020202020202020202020202C20705F63303031203D3E20725F782E6E616D650D0A202020202020202020202020202020202020202020202020202020202020202020202C20705F63303032203D3E206C5F636F6C6C656374696F6E5F6261736520';
wwv_flow_imp.g_varchar2_table(292) := '7C7C206E756C6C696628206C5F636F6C5F636E742C203120290D0A202020202020202020202020202020202020202020202020202020202020202020202C20705F63303033203D3E206C5F707265765F726F775F6E72207C7C202720726F7773270D0A20';
wwv_flow_imp.g_varchar2_table(293) := '2020202020202020202020202020202020202020202020202020202020202020202C20705F6E303031203D3E206C5F636F6C5F636E740D0A202020202020202020202020202020202020202020202020202020202020202020202C20705F6E303032203D';
wwv_flow_imp.g_varchar2_table(294) := '3E206C5F707265765F726F775F6E720D0A20202020202020202020202020202020202020202020202020202020202020202020293B0D0A202020202020656E642069663B0D0A20202020656E64206C6F6F703B0D0A202020202D2D0D0A2020202064626D';
wwv_flow_imp.g_varchar2_table(295) := '735F6C6F622E6672656574656D706F7261727928206C5F776F726B626F6F6B20293B0D0A2020202064626D735F6C6F622E6672656574656D706F7261727928206C5F776F726B626F6F6B5F72656C7320293B0D0A202020206966206C5F737472696E6773';
wwv_flow_imp.g_varchar2_table(296) := '206973206E6F74206E756C6C0D0A202020207468656E0D0A2020202020206C5F737472696E67732E64656C6574653B0D0A2020202020206C5F737472696E675F6C656E732E64656C6574653B0D0A20202020202064626D735F6C6F622E6672656574656D';
wwv_flow_imp.g_varchar2_table(297) := '706F7261727928206C5F7368617265645F737472696E677320293B0D0A20202020656E642069663B0D0A202020206C5F646174655F7374796C65732E64656C6574653B0D0A202020206C5F74696D655F7374796C65732E64656C6574653B0D0A20202020';
wwv_flow_imp.g_varchar2_table(298) := '6C5F71756F74655F7072656669782E64656C6574653B0D0A2020656E643B0D0A626567696E0D0A20206C5F636F6C6C656374696F6E5F62617365203A3D203A70313B0D0A20206C5F76617263686172325F737A203A3D2063617365207768656E203A7032';
wwv_flow_imp.g_varchar2_table(299) := '207468656E20333237363720656C7365203430303020656E643B0D0A20207265616428203A70332C203A70342C203A70352C203A703620293B0D0A20203A7037203A3D206C5F6C6F673B0D0A656E643B0D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(6400348616563186)
,p_plugin_id=>wwv_flow_imp.id(50580935975708604)
,p_file_name=>'parse_xlsx.prc'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
