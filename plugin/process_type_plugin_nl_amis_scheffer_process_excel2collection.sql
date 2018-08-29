set define off
set verify off
set serveroutput on size 1000000
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end; 
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040000 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,1240203129055874));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2010.05.13');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,101);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/process_type/nl_amis_scheffer_process_excel2collection
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'PROCESS TYPE'
 ,p_name => 'NL.AMIS.SCHEFFER.PROCESS.EXCEL2COLLECTION'
 ,p_display_name => 'Excel2Collection'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'function parse_excel'||chr(10)||
'  ( p_process apex_plugin.t_process'||chr(10)||
'  , p_plugin apex_plugin.t_plugin'||chr(10)||
'  )'||chr(10)||
'return apex_plugin.t_process_exec_result'||chr(10)||
'is'||chr(10)||
'  e_no_doc exception;'||chr(10)||
'  t_rv apex_plugin.t_process_exec_result;'||chr(10)||
'  t_time date := sysdate;'||chr(10)||
'  t_what varchar2(100);'||chr(10)||
'  t_file_id number;'||chr(10)||
'  t_document blob;'||chr(10)||
'  t_filename varchar2(32767);'||chr(10)||
'  t_parse varchar2(32767);'||chr(10)||
'  p_browse_item varchar2(32767);'||chr(10)||
'  p_collection_nam'||
'e varchar2(32767);'||chr(10)||
'  p_sheet_nrs varchar2(32767);'||chr(10)||
'  p_separator varchar2(32767);'||chr(10)||
'  p_enclosed_by varchar2(32767);'||chr(10)||
'  p_encoding varchar2(32767);'||chr(10)||
'  p_round varchar2(1);'||chr(10)||
'  p_50 varchar2(1);'||chr(10)||
'  t_x dbmsoutput_linesarray;'||chr(10)||
'--'||chr(10)||
'  t_parse_bef varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC4VSzW7DIAy+8xQcWymqumxaD9X2KsgQjyI5gAzJ2rcfoelftG43''||'||chr(10)||
'''G39/thAdGgJGkU8RZY7KIJF0STKawJ1YdZBB1eEIbA7A7eplLZqU2XmrRqDb+2u7''||'||chr(10)||
'''e9+VmR96j'||
'Vxn51I0RQXrw1SIRlPQtZ0Ksd5f3Tl8T+YZNKEMX7dAvsOj1CcZKSnn''||'||chr(10)||
'''M1rkB1Za0qrSn6x0QMz3q3ro77Zst9ttWaZqzx73Sae7LD1nxd9dz4yZOfUmEKHJ''||'||chr(10)||
'''LnilIeHyjgvIY7grZE7TFuRDGoh4VBAjOQOVb8ulgTajUcDcPgvZXsSqOz+V8ZNK''||'||chr(10)||
'''xZj/MTx/g72IHAx2A6PsT4qCXUXVJ3tday1cEhqt86KKdqgHq3pMCSxuCv5Sn3lN''||'||chr(10)||
'''VIQjkvz4lG/lGOi7/Q+Kyt//0AIAAA=='';'||chr(10)||
'  t_parse_aft varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+WWS2+bQBDH73yKPVQCGuyyD/Jw5EhV1WOqHnrpCeFlHSPxsHZx'||
'''||'||chr(10)||
'''4kj+8N3dYWIcnERVj40iwX93hvnNgzXBSj1UbdDnsqtrJfuqa/NVYRRZLMnCruVt''||'||chr(10)||
'''0ahbu18WfeEWt4U2Klps87KTib2YjVK9sXf7+DZonvO6e4hCb1Qm4eEAjnPZ7dr+''||'||chr(10)||
'''cAgJmJO11WU48mi6x6p9IH1Hvr2ARCZ2JsVW7Ud4c6lV0au803mvd61098fdaJKJ''||'||chr(10)||
'''jZp/uv/60z1q3WlSkaollMznZMwW1F23PS2Dy9xlPK3N4WBBc7kpdNTu6rpaR1VC''||'||chr(10)||
'''42k2PlkSWvvKUixI6Bx90KiK5+75riQ2Z1+oV6HPZF6UZd6oZqX0O2kGyTaXaUqX''||'||chr(10)||
'''d6ehhnXm1l+Fclutd6mCfyv4AN6zealq1fvJkXos5Iuo1qNi6O'||
'7JQCeimNyRNOg3''||'||chr(10)||
'''yo2ldh2g0Dn9qnMvfnVhjg10tdGx9dIQDyU9F1HtK9ObSMcQzxrYkdZuOMmShL9D''||'||chr(10)||
'''WHbB5RvBre8o/iSC2x6CyJgU9rmTfbsxd0t5/7xVLuyPELM/Y9nuXP/zx6J2lfGo''||'||chr(10)||
'''0QeGCRUzs1uZ3pZmGNuPPMJf99/DOJlxN9XKUldruLosjyunhcnSoQnMPg3LLt0L''||'||chr(10)||
'''82TTebcwLl8iu6JWRqoIYc9B2g37akFaiUjTNE7+Iqmb8APz0k23Ny7LWdPMnu0f''||'||chr(10)||
'''2WyYWDTVwpgwjolNflwLPzNZurTTcr6/fjzsTGfpaJr2x3Fy71Q0pfFuMxqTL9Yz''||'||chr(10)||
'''xvHWcCLpC3r73rDL/ecsvaCjDg0rLiLcjrrV'||
'PtZ4kDVdGcnEBkzsv738P32cTreq''||'||chr(10)||
'''jXLloVAEV/kwPG6fNuPo/vapbaaH5ei0doFGhzSLGEruJUcpvBQoMy8zlJdeXqK8''||'||chr(10)||
'''8vIK5bWX1yhvvLwZJE0BI0U9YCEXBS6KYBTAKJJRIKOIRgGNIhsFNopwFOAo0lGg''||'||chr(10)||
'''o4hHAY8iHwM+hnwM+BjysaFuyMeAjyEfAz6GfAz4GPIx4GPIx4CPIR8DPoZ8DPgY''||'||chr(10)||
'''8nHg48jHgY8jHwc+jnx8aCzyceDjyMeBjyMfBz6OfBz4OPJx4OPIx4GPI58APoF8''||'||chr(10)||
'''AvgE8gngE8gngE8gnxgmD/kE8AnkE8AnkE8An0A+AXwC+QTwCeTLgC8Dvnb4iJF6''||'||chr(10)||
'''UPDpIoOzP0mjTy9Vnv2OdO'||
'/7H0N8nHXvCgAA'';'||chr(10)||
'  t_parse_csv varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+1Y227jNhB911cQfZGEKEFk7yVddxdIXLsbNEiAJE37UFSgZdoW''||'||chr(10)||
'''IEsCSSdOsR/fGV5ESZadLJq+NcCuzdvMmZkzw6G9xaZIZVYWpKJcMC+oknmZklle''||'||chr(10)||
'''zryoSsSKMSnII+XpivIB+fSZFJs8xyW2lZyS+Wwtyo2sNjLJs4IJyjl9rreFHmdy''||'||chr(10)||
'''wwsiQSyV1MuEJ5OU5TnO4OcIxrx8wiF8mJEwQ4FjPGfP4zgVjyQFeGqNCZmUi4Vg''||'||chr(10)||
'''kpCskGzJOCqPcVHwtF7bWZyVa8LpU3AWapnZHBCvZ4zjMKfFMklLOLKVZhoPoq0J''||'||chr(10)||
'''aD6Z'||
'swXd5Haf3OKZJ8qLrFgS9We04Twr89p9wYDgp1IpWOXmYzfPCjBOsHnvYs4g''||'||chr(10)||
'''TrlIGvKrUnSnhKRc9uxTWDrTGLQkLXa2LzKWz2Fi3l5g6P5kAREnbJuyCpmj3LlZ''||'||chr(10)||
'''OMDDwccPH0Mz3YdmxpZZ4WULosmWCcUWUnLn4iWTYOxSrjQhQ/KZnHpyxYqaUYYQ''||'||chr(10)||
'''DCBmi5bnkH2PeSA2MyF5YJgaDMIojuIw8n/wQ8sA2LmReQJEOIFwp1QGNYD6NGiP''||'||chr(10)||
'''3uHBFcgpkTP+ufnzw9D5WzMLjLISjQSlCVQP0AYnYzqZTv1Qm9QQMazpiFaA09Cl''||'||chr(10)||
'''QOEkm4Peq/jDb/fT+ANawHLxemXT6cQq23do2D10Cn89CN+PPIyWAsC+H/r'||
'VRIE3''||'||chr(10)||
'''UTtoxLtdPE1D9mDaL2/YljeZXlxc9MXg/WFDhgMw5KxphdudljRnImWBnvKiznFL''||'||chr(10)||
'''xmEY7qwh6iw+K07WtLLzjQNRvf7L5HpyezlOxjfX95M/7t3C5fn1eXJ/k9zcno+v''||'||chr(10)||
'''Jj0q/PHX89tkfAdGh5qrVcVcisRhCKWLBP7Xez/y/7qE//68bzgIShbauOLBj46A''||'||chr(10)||
'''/RIelIRfUcJDr4Q47ogwwcolz9ZNeSpwGDkAf+trSbqAsC1LN5KRbL1m84zCN18t''||'||chr(10)||
'''kE9b1OKTb9+IE4Qjf0QgZiOfbATWaixjChQgsdXMewIFpAQ1HK6hFmx/5KuYO+rr''||'||chr(10)||
'''+Uax6UOPNWfUpEtdY1LOALVk6woYyZ8VaR4jyTcsbO4qi'||
'0fGpSzx1tN78P6FuuRF''||'||chr(10)||
'''9Sb4t6Zbkf3NvKh1L+LQ3YQ40sRs33I4NjeYYUZW6NRBRBivU4jBl7oG00ywhFZV''||'||chr(10)||
'''nkHRBK8ljPOSB8cDyNE48q9LSSgZ3z0cL7Kc+dYk64Ae8fFQBUh9banSN6glTWuX''||'||chr(10)||
'''5c+OrFO3a7hfVmvXAVkHBOw9dUCt09VMzoKubdFQXP99cja5GP98OX4PRbhHzMCk''||'||chr(10)||
'''D+vDZNy8fgZqLAMfOzukO8SDPGVypfoJmkqGmnWa7IWCSRPpbMGNXn1dUmCYLPF7''||'||chr(10)||
'''oBJBbyVUEBiAeCiy0YET9rJ2x/QMKqrhEQqWHBJS5u785ObK98JmqwM+aQZG71fs''||'||chr(10)||
'''c3u+ENWtvILWg8i/gmaJ6LaEyLIkOeX'||
'LXXbrNg2UmwZGaQ9bzZbtQl2XZWewJz7B''||'||chr(10)||
'''ziaRzxVTVefO38FcEwv7LthTX3TaTnWTRfWBYzNjGaOEIca3NF5T0eBRQBq3fO0Z''||'||chr(10)||
'''1xCqXerrMRiel2UFNTiTRJVfexl/0UCV/b02xpgsjk3WLcqLsBvYlDxSxQTfb7Vq''||'||chr(10)||
'''5uuR1a0b6V3GGMGRc6ENRaMjRc8R1xq3Cl0HNhw8ir8D9u4k8H1/uI9ru8KOuah4''||'||chr(10)||
'''UMfp7TSF5s0WNNgcOnkv+gCqxU4DVqPtZEhjiIHTVbRXeJ16mPLG2WVuFeHTMnDp''||'||chr(10)||
'''aOC69yc88HK4lns8GB+1JHeT2o2O9uT3odrUQ7Jm+r5xurZKyudXlZSdPH993Xmx''||'||chr(10)||
'''AjQQkZ902u/NLo3hY'||
'BS7cWsUI6gy7dKEBaBZGrGtM29S6xRTHE5r5Z1qAVZF6qD1''||'||chr(10)||
'''wnHD0mbRaNRuI0IDbGzfrZvNkqPuxN7A9eS0ewBpfD3IDifvQS8bT6rABbV5DqCK''||'||chr(10)||
'''owEa4uv+rWB/ZwXqY8OLlWVPlXwdtA77/4WPu9hR8v816L+qQZ28c8WhfmctOOs+''||'||chr(10)||
'''2EL7KyW8906weVbtRv34aa6q3zZtcMVo57es9iPU1TztlxdAHIzG0D7KgMfZvPdp''||'||chr(10)||
'''NvoHYPVsDAwWAAA='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xml varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC6VWbY/TMAz+3l8R7UsT0fX2ggDtBAKBkJCADzAE36qudbewNKmS''||'||chr(10)||
'''7F6k+/HY6cu64w7u'||
'YNLUNHbsx/bjuFF10IWXRrMmtw4i3mSlKQ41aM82ymyipMnc''||'||chr(10)||
'''DsA7dpHbYpfbBVu9ZPqgFIngytuclZvamYNvDj5TUoPLrc2vBzURWfAHq5lH27nP''||'||chr(10)||
'''I+kin5HxrHCyRKV6AzaoK5eRCwc+kyWP33xcLr6t37+IxTmeuKoVw7+/boBegyey''||'||chr(10)||
'''ac2lo40AU1vWoBWpPWzB0jaKb28VRt3eusjVECBfLp4/ex58Il7IqtofZfPZTBDW''||'||chr(10)||
'''uCyndT29xh/b7RZPV7VcORfTIX3MFV/06ohcu5cTzMPKFTuoczetZWGNM5WfFqZe''||'||chr(10)||
'''maqSBaxcYyEvQywTFrObm6g9isYfebrFUobqUPJKU6f416YM+dPqLomSzrfSxZ/F''||'||chr(10)||
'''y/'||
'vFG9hKHdXXmTJbHhOvpN6yH58+skvpd4wSkxceqMwhwpO667wGPqKHGGqPWezK''||'||chr(10)||
'''PyJpMlYdswC1Z10CcDnGWud7ILB8vLkF35sEBfQ4EWu4xEevwQMg0ULT6ujAqcaa''||'||chr(10)||
'''ApwzNnVop/DkyHGCkcRn343db4zZh0UAGidEF7RTGcskk5rNWJqyW8gU6K3fkRUl''||'||chr(10)||
'''pvNIGdOcRjq8PJmfR7JinA1dK13bhWRfO295vAo5HxRwjVtJt+1NqAQfLIpOQbBX''||'||chr(10)||
'''bPZQK79nA/vrAKY6Sar0UIegEimS+LVzq89Y/C4lJ25F5Heg237MeftIC3PQ/slc''||'||chr(10)||
'''pESZu2vwaK/nA22pj1p23uG19SmGayhF6oOH/rpBLPO+if7KjfuxrfONg'||
'rMv5vKE''||'||chr(10)||
'''JT8fwJLFiCYdIH2h+CMTtEh+dhn6oEu46lBESbAZif4mPUa7/MdoW0dvQamTSPcP''||'||chr(10)||
'''iHQ5irQD8w+RLpP9PZGizTZSGhCP51hrGO2+Q+4MwWGH/o+dMwK6xnuwbxUcL7gP''||'||chr(10)||
'''a4k87julwzv0swmzjAdBEtPYovFVlpP15Di+0slsNpvEIjlOPoQLeIfKaiA7D/UX''||'||chr(10)||
'''PCRHpNQVGd3KYcx9je/Tw1sDx8CAixYjBoUF3V7kjOo56qWwuC37rSe5ECl9CrQn''||'||chr(10)||
'''AoIj9OPJ/lsknAyC81/ltxh2BAkAAA=='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xlsx varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC70aa4/TuPZ7fkXEl8Q7mbZJS+e'||
'1s2KXAS0SoBUDElfcVZWmbidL''||'||chr(10)||
'''HpXtznTQ/vh7ju04zqOdzgC3AtrYx+f9dHCWmyIRaVm486ycR0W5oP56hr/lAnEY''||'||chr(10)||
'''FRtWuIt5zmfbPFuU+QD+IpyTcmdOV2nhpEtXn0m5W2yyzC2ZOgFrgxUVGS1W4kYj''||'||chr(10)||
'''Ju6lO3LEDS0q5HjkwqHFwk2XF30U8/grlazZi4B3USabnBaCZhS/GtsFvYOvCsKH''||'||chr(10)||
'''VXG/roQLiozPkpuYcSpm6cL3fn87jj59fH3qEfwAM9uErlEvzh0w6pbALuOK6QVN''||'||chr(10)||
'''sphRR8yA4R69XMBOgsqoPviAiwvKxaxcLoGm66bA9YoyXOcsMcv2ehYXq1lSwsJW''||'||chr(10)||
'''gI7yOWXu+WWt2AVdxpusghNbP'||
'HMXsyItVoqwwaXMZA4mjMaCCpqvSxaze1/xGwi2''||'||chr(10)||
'''oaTNKBAM20yqtRpdWdxSJkSJWDQyJ1CKdgIDBn/zeMvTb9QJGjTwsUbv7LENQtpa''||'||chr(10)||
'''wWctsSM5B4tUGvpxrqMkkm5hhFky2lEgMb6LjEiH1v+0gmyT2zEGmoL4qIwFT+uS''||'||chr(10)||
'''V0+kDhE0fx1yenkjshmL7wZJDNoU5WyeFsDPTJ/2Dbt8M+eCVc4vCSpCJKhQZKmA''||'||chr(10)||
'''OJ0Bv2lckDbjjV3Ek640T2joe0G5uwazacJohInhHbDvZFwz1pBjycq8LYmkuIPX''||'||chr(10)||
'''IKx46LCdlNkszpaSZfjt3sYMPSsyvFlMd3iMeZKmvlEdnA+OQ0KOpxPnqLjNfL8P''||'||chr(10)||
'''IAoUCPklmgY'||
'jsgdybCCnJwja5h2cdLZMM+rAgW/pek0Xtc9geOHerIhzaqRyjFgS''||'||chr(10)||
'''BuQBp8jX8gmjI8UMW+eXm0V7ZZm1V2iRlAtMKBUNPxzJSLNctsovioCdoezUb4lA''||'||chr(10)||
'''jiPIH1lZriHPpsKVKVad/tUNG8XDqMw6HkwCCYyF5AayAMTgne89H03+GD0fTT1y''||'||chr(10)||
'''UXMifxyHqrggwQssVprU/jJk9ANorLDt4eMonJIjoLEExlNQCogwGOw6E+kzp0Qp''||'||chr(10)||
'''ANipvHqeillcLHqi1kYQBhVnR2ckqOUfYe1qaARXlICWHUGaOqGCtBmn7e1P16d/''||'||chr(10)||
'''vZyMT7xaGbLC1w53KXlOw9NiAJQw8aBvOPs5d4I9KtESRacyx+unydSRjxV3jhEH''|'||
'|'||chr(10)||
'''vW+/XSqEE6JNjkeMxWHFsGjEwuhG8/ne0Au8/2rluS33QIXpFcj/4l6S9EmtK0tn''||'||chr(10)||
'''+y1pyQ1B1TLdaFQbT4flQQJPIun/GPbnNsbw9ekfiNX6jD3SqOJrLGRwEJPLIXaz''||'||chr(10)||
'''1QyZLghDNJZi9mgcOkd77K2hohNyENgZcWxeY4CCQJHcmqIAPUESiweix+IZotYJ''||'||chr(10)||
'''mnVNegmQcupSjtiTMl8zyvkg+zaD7KyfFHnygww++i6D72ntUEW6szvE1lIFYMuf''||'||chr(10)||
'''bErTKAEP3dCxc6+dDfbhrzOIewjceHQgXETs6tEuFVa9XmPHisUaGkdTpPkN9Inc''||'||chr(10)||
'''VE8UCM/iFtiexdJjyo1Yb0DxaUF5zFh8b8BMQReANhaxqumsvOO4'||
'gt+yX4edCkI/''||'||chr(10)||
'''0/BsNHHnZZnRuIA1GH00BMUhTcTzjLrlsoKAtLegW3d+bzdEiGq7VGf0Wdljb/Jl''||'||chr(10)||
'''LnYty2GlXtZ0IRYgf/MGadNRjKOT6QnZyYJUIQwC3EJUr2Pi7uxoas1V1qYoQfsW''||'||chr(10)||
'''Rd/ibZz1LRdM98FSWx31dVaSjnidFcbaK4XFZjQCz8UyDcNKwS+f3QixPh8OeXJD''||'||chr(10)||
'''85gPSsiMsAO9SB4LeGSrIYd0FS+kuvJsCOenwzxOi2fexd4ZtlhEu7fGu7Zo1t7R''||'||chr(10)||
'''E5Y819nEY1nK9W4vwXq7l2i1LV2t7lKlcWDebCtctar5PeTBle9hzGLb8/nt9WfP''||'||chr(10)||
'''miDry5CqC1dxHXjbbHhXsq8QN18HwIhHSCPi4G'||
'xW3lWj15Zna1YmUCxKNgAH2tBy''||'||chr(10)||
'''6SONwDNYzI+/2PBFhccL0OhEtyOYvqEjCTWHWT3j2vg5KDoRyDTv0FBpSH1p3Fa/''||'||chr(10)||
'''OsJ+tTUf674dyZHjUPWqViz66VFI+vmo5LQRplCRJK4gJYH3gp2nCxBIevA5O8SH''||'||chr(10)||
'''y+UyTeiVHsmVEzOaxZh5+U265s+Ucqyk8H0sIgqvkfptYBz/zf1AS3PlXUGZdXkA''||'||chr(10)||
'''g8qhnsXFfUa55VePsLU8e43iDyEhvc7B3Or7e+yNSe+pGlTmewk8eqoH94E2NkUS''||'||chr(10)||
'''beAtFh5xf4OOHNmyN/J8x8b9vd4wjZJVi/ZE3D4zSxW9WeDshM0GRFqzHVG2b1IK''||'||chr(10)||
'''JxZwa+v57q3p7q2TnVtR1Nx6'||
'kkMkNMs+L/lwuxzWEv8otzCwSF2qfKfCidVS+KkS''||'||chr(10)||
'''zJZ2QLeQzbmyN2l1FeYAUof6Nznz/t/hCaWFLq5VS2GiFDy7KEVDGSnH7k0hr1x1''||'||chr(10)||
'''i+hHuinAG1Rs+S8qjT7GrlwMefplXfIUs59Pfrt85rn//uvqMRzgtr8gFUx/sOw9''||'||chr(10)||
'''c2MQrob/tQWPBwBWntEn/jbeUV/Q7PEMt5JMGWjbuA15RHVJ1HndtMGYslF9g17w''||'||chr(10)||
'''EYQc4HldDWKVz7oXwc1sIIbSz0hl1jZh/XbDJJ8sethou6mxYU1PqeufA9QV2fpq''||'||chr(10)||
'''q6W9BLZ8XIxGwT+kUfS6qbC79/2RFzVDz+2JvRlUe95ovQa4Ik3VvHizuhTlQeai''||'||chr(10)||
'''zTfzWGVJU2'||
'G8cxkSBgCj4BxalPNGpKREb7Tq0wOnm11JE4fJD6pXrXIEjnYDaG6p''||'||chr(10)||
'''Gq5wsvPVl5IJ4nUgr+KU1Rv4L0x7i32/28uDGWn2VndpG0g5H+xOq/H05cWbRZVO''||'||chr(10)||
'''7O6wyiPDFx9jtsKm8/B5ZR0nX+MV3dXk1Xd3qi0IgwkmIG8IXuJV2tSiNQCfE/uG''||'||chr(10)||
'''4YB8r8XCWkQuDkjh40c15lJbqiW/ArsOweQ/O6kfmM/HOxM6OyBDja0M9fQUOQ4Y''||'||chr(10)||
'''5Mjky+3fT82OOKS2SkUjz+lpted9YfVOUOIg6u6gW3RiAbl2voFOBvFAPlcTCJOw''||'||chr(10)||
'''GewhKRYw88sbhdF48nx6cnqm23sZ7/U7qn2gJj2s5A0fR+7kGhTqpBvNTyuNUuDA'''||
'||'||chr(10)||
'''u7XrIF6HPCy88KqSKTAWuWfu2RVjmHBL0SifmOJQWEbw/SkZYHJTUzzeblx7Fz0w''||'||chr(10)||
'''qrxVolrlrpypWxjfhKupXBnXfMlZGk5ALkoLvGy7lr9pde/6s5mFHw22qLo+wr0m''||'||chr(10)||
'''+06QxJyqKG0MQK+8+j9PwEgQFzyLpQnk7sA4TXB8BIJdnVUfkBDpWUdaGbRN5Tgk''||'||chr(10)||
'''+/HJjPIKPh5K5ATe+7fXs/ef3r368Obl7OWfv3/4/eXHVx+uLweB5+iLtoediBsn''||'||chr(10)||
'''4rYNZKYzc4OZESyd4U1JA6i9e5gZrzxNvrqG2XOMGruWiiKE7DH8Ubc33tXV8bt3''||'||chr(10)||
'''x/+Bj0eO0MzG4gfjGiOuURsXxig7noak5Uo71WZNUPtVZ49aT1L'||
'fY6Jgpy4sfO97''||'||chr(10)||
'''8Sm+anxSta33Bw91rT9iYpQKl22abMhkM6fVpMeYinOEyWIuyGCZMuuysh+opQmr''||'||chr(10)||
'''7uru1oBWpU4PoHpH25g1jdarYaEpdNXVFS5U6JCZxGJGlqCq4lZ41dsRw3fU4ttw''||'||chr(10)||
'''bXirmE4M0y0FAftNpWAbs5NxebgxrNXEwoeJhR1iylsbjt52tZ1W6rFRr8R9cu43''||'||chr(10)||
'''kvULGdxjmib1PhX0Cd4ra3csVO10Z0IhA/mayqi1D83TIzAi9ktE9eILX8f9D/7t''||'||chr(10)||
'''OCnQKAAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xls varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+0cXW/jRu7dv0J9OEhayz5JVmyn6RZINwmwwO72sGnRuy'||
'dDtseJ''||'||chr(10)||
'''urZkSHKTHPrjj5wvzYwl2bGdbHHbIICt0QzJ4ZAcDslxZ7FJZ2WSpdY6zgvScdaT''||'||chr(10)||
'''eTbbrEhaWtNlNu1460lxT0hZWH/E+ew+zkPr+7dWulku8RV5LPPYmk9XRbYp15ty''||'||chr(10)||
'''skxSUsR5Hj/Jbm4nJ+UmT60SYMdl3EmKTjmZkeUSW/DzAp7z7KHAZ/zEZ+wpRuDz''||'||chr(10)||
'''Q5Z/mWbZF0oVNiTp3ErSktyRHB8L43lJUvVxFT+aTTOYovJ4l0+T0srjBydw8Xma''||'||chr(10)||
'''LBZnFqBckjilGMpc8sAZhKPhiPZL5lVrZOEnbb4n8ZzkFF5EG8rVmj5VI3MyM1pg''||'||chr(10)||
'''siQ49yMF7dOaIBuKAogFBsXTJbGyhUkITGROHq3pk7Ve'||
'FhOVLTCODa9gIRYNGMfW''||'||chr(10)||
'''CORxwcbwsdi0WJVmG4cOneGlBl8B14YDh0kAHEkdx/F5UhDlXeD7Lsqb/dv1+OPt''||'||chr(10)||
'''b+8/BeFZaCvcQwmm/Aay4CPL5x0njVfEBN/xFDHquAaEQpuVDreJ/2ychCDbtOF0''||'||chr(10)||
'''VuZQirqaoivE2Oi4zrMZmW9yAhOL55NNmsyyOUFpTdI7pmvQpgnalNwlKZdorqUX''||'||chr(10)||
'''nYf7BObF1OJHy+8ss2zdSRbWplxOYHAftGMSp3OHa4p3D7qfIVTbD2zXtd5aekun''||'||chr(10)||
'''vCcpAnAsi6lnlwJ/EwJ4ARRU8q68dygT3G7QAQTUmkxAyfvFZgoUOpXue6FH9b5L''||'||chr(10)||
'''1bsb6UgH73wf0HLEcnbsy59/UpxJME'||
'770HtSZlSMHEGIxAWEeIxc17MvPwTDX3+5''||'||chr(10)||
'''CYYfrm1X2AwKE770jEm0gXKtf1qhsFoUgDINYa6gXcCYxUWJNE6TNM6fxGI7e7Am''||'||chr(10)||
'''dD1JV1KWSzIh6TyJU7eycYCnBVDAAUXSRrX3p7T35KguE9SCTzS46JAl7CvHL4fH''||'||chr(10)||
'''paduWQrJVlXOlAXzgQxU7AUnZ1ssX0UoAS0n9oe39eiE8OJuochDnUwdJY9yWTgi''||'||chr(10)||
'''ZgMEj75lOd3NeSaJjYJXL3Z06RE2bCFpVjLXSAiFQAbOVFosYTt1aF/JoUdovyOO''||'||chr(10)||
'''fXNje/boxgYdgK8uhSXh7KliDLL96+3o8vbd+/d2JQq4TUhRWGSwV8O2ZgVWv78t''||'||chr(10)||
'''qwDDZVuEHCdlIktn'||
'cenQdm+LjYg88QJX3T9AQ1zGKYR4sf9MEINpDaSe13wy8PAN''||'||chr(10)||
'''5if83vxLmG5WU5BacD6/4D4pHVbWjnso2zF5Mwg9wX5lBnNwzP3RmDECBVmFCdv+''||'||chr(10)||
'''AOYJ+yyokO2HtoWrtkuTTOgUnH3z7ob+2U1KBNtNJDANXhyT7wtcfjuuebYB58kx''||'||chr(10)||
'''JAWGsT/bQ6RNmASO4EgcuybaMlPwM5n06CIEchKiEwyg4CsXGylF+KaSIWoHhJ/P''||'||chr(10)||
'''FFccjzLajt5TD/7xPWj71VXv48fef+DPdrsUfiXSdQMHONA3BzLKesPA5bQbXuNs''||'||chr(10)||
'''MYUuswU9XbnMa1ROMGdByM5ETyWZgPMMzYazSlLwOsHhtCzFpfaZjSz+C63aAIs2''||'||chr(10)||
'''s/'||
'a6V2RWvp9vvWLGWbwV3f6BfrLiqJNZMjccdbVno6e+KuKyAkAJhwajZbsPQM4Y''||'||chr(10)||
'''k0I/GrMJ32c5bAFZWsZwGs7liRXMAYlX8hG3UoMG80gijpOzyU1OyOSWzN5fUbYA''||'||chr(10)||
'''8KKMYZNRj1bfv+0F2Pc6nU9+Xkze3QN6Pqapf4j9by9/UUA39h1g349656a+Efa9''||'||chr(10)||
'''ev95cr1al09aT3bCRuuu7wBixC223ZFdIwJ1BOXrrhFhNeJDNvti7aZqUI34V56t''||'||chr(10)||
'''SQ5TaR8RVSM+Z7DL78ZxZisHMq5yNY4MKqcHauihBlPvVfYWTgCI4dY2zbq41g8W''||'||chr(10)||
'''jFV7yP2Y9YAdauxa36mUXfnvboLg2r8MfgqCy+ug8mKZ2VG9RcUuAO10f'||
'3xQTbSJ''||'||chr(10)||
'''LTz3Qt1PvrmmDo1m2DXza6GTohxG72Q7mjNqVRUq3tYDEY6StFYYM1D9B+kL1few''||'||chr(10)||
'''1UlT+wWv19kDbJ+ht+f+avJiEAAvPJV6l5tNgH8C8IM68NK789G7C/zzXiC8OW5e''||'||chr(10)||
'''dzv5TRhHo27yJvIiAyuw7hGceioXEgsIi2LahBl2Epd7f7SX4RoeS9/wvIY2Ef3g''||'||chr(10)||
'''0L9DwrbtqMqjrFlPqWygtnbptzcCLD1z6KxnYgQ+VC8UwCkH2Ad4L5u0dFz3kOky''||'||chr(10)||
'''Ij1Yi25Qtxon4SlH0qtdb4kB5/y7Mmd1brrkPYurlFO/u61sraBTrr4aU08rsnW4''||'||chr(10)||
'''vr7IVrzlzP0qIiuXlracTLI566O/orUIwnHF/P1CMs2'||
'8BmDd4dnWLsE3VYT+oxWK''||'||chr(10)||
'''nZN6qBzb7uidhiPgIRiKSOyvyoGdug07yByB/8POgarrx4iTzJ1BW0lKslqDb5E/''||'||chr(10)||
'''OcLz9sp8Q1zjGHEs54JgVCMgp1mVIKzTgmpZDhbqs22aGQ+FYCsMahVuyfN4vSY0''||'||chr(10)||
'''OcBZvaekV3hA2muWRuh21aobWXTWXozmrZOcx7wy/rEf+e30c9GXmMs8WSnyisss''||'||chr(10)||
'''VpxqHqa4eEDTFiopM6MiYAZDjbijGPvT/uMUJcOTzG4VM1n1arp2gvU3aH9F4a3i''||'||chr(10)||
'''7mj+DtjiYH0luUnRsiJ43gqMZVyA6902RBOjJjRUcPaCznpqIVlx9l09wZA7x8Yq''||'||chr(10)||
'''BDx2/fvDLR6MleCUKEsQ+iDFl59/L'||
'dgpJeo7UsozsOiIJPqMRIHtU2ZJMAuUogU4''||'||chr(10)||
'''L3OKOE4KMgEJWSazGIN8E5LnWe70Qt/3Bx6MLK3Y+iNeJnOktYejbSH0W2mUQC1B''||'||chr(10)||
'''UP2AWjr5AX+PnJORdT33x3CGhr99U1YRFg5YjhqIwYBERwvO+0N69N8T5NCg6UxP''||'||chr(10)||
'''yrKqivZMjUKdHiRiwZLXSkLVp8CoCVFPstjtR+zG11cp/mifZsTXkBeRQOetnMJ2''||'||chr(10)||
'''lCZ0jYN0godo278ENh/hdohggdfCEap1DN0NZjW5tpPZMs4xZJJvtPIaWLfqsQo3''||'||chr(10)||
'''x/M5NTCg0UYA1DWC5DSjxno1ZUu7QVNE6jkrIDO3z18JhSeDiifHpk8PX569css8''||'||chr(10)||
'''V2pkSForIXblVaX'||
'GVtnEPTOyShZXCa0ZWVk9O61sG1rX/bPAY46VpjVkcELLdD7f''||'||chr(10)||
'''qAhpGjcmsKjtkAowUDP4z5UIJRvdasSMBHWoZdfboAZ1w4OLPSuCxlsVQWNRESTn''||'||chr(10)||
'''z1JKaDVedf5CPBlePUO/x8yirZlFWzNjlgQN4HEzi3ZoO2L4Qfg0EiH90o3C8+h8''||'||chr(10)||
'''OArPh3WKxdkRVfHuR7NgoaaajBcU0kiPHuihzt1FxQHK3zdRlwKur5RQOmwl54Eo''||'||chr(10)||
'''xbKOzxTL+nyzwnID6HcIGEfoHAYgWsStrXhkrNaNYOVfvzWYwkolqmrHyrIeSb67''||'||chr(10)||
'''2waMRZrpuOI/WcdRi+RcVnSZNWLM3Ldz81xy8xmVKgY5slIF2g+rVFE0a58VRTxN''||'||chr(10)||
'''9'||
'SoCBNeTQ1Y3aLMYHH7hiC+mAmOjqXphqKierE4+zH0PWJZXRxBcg/38i+j24HDd''||'||chr(10)||
'''jhTdxqrlV1XqVrdwl6qfvYaqD49S9eFfTNXbF7hdx0XdvHOYfjcutNsBihxgDesN''||'||chr(10)||
'''aDx7PrddWsqNXFNfrFYNL56e+IstPb32j9qDRX2/I74clSbaKfQ67VF4rP/gVAdC''||'||chr(10)||
'''dpSiYRM78MOR7YGojDHGgQGSFI6zKAeg2oDcofcRLt99/vnj5acxr9cUtZ9SceR1''||'||chr(10)||
'''BnGBQQ7YLmJsOlmqYUMpYkHETHu+IXr7WUP7sKF9VN8ehkq7majSl7nKVvG7JDLF''||'||chr(10)||
'''L6D1yWNS0N2JS0oCsoEsVRCq7+pUE2ko1GSZss9VFFSOKNsPC7dfnW1e'||
'K+xmBLaG''||'||chr(10)||
'''9qEBtsD3hfA5lnpPRdQEMQW3v7exjlZ2gO/Q5PFmYb2KbuDyV4aB2DFe4SV1gVQY''||'||chr(10)||
'''SvSPXV9h5wx25as/J0vCrhThTS+HfbAlA2KkQ2ViuJAxXDynWLVU/B0rbI8V0it4''||'||chr(10)||
'''yh78OrHD0bUfHuvxCSNyyMZx1raJCpMMnOmjILJLWGiYryTL8AWZ/BFz3vHS36qM''||'||chr(10)||
'''vOHgFblKcKwGwacKAQMkUOwDWd0hZi+wpXZlBoNCv6PpPxoJoG3ooLlCpU/t2oAZ''||'||chr(10)||
'''cBA+UzB2X1Tf4P3B/6VINZBiFLgbwtAYfTxM+E5LwzcupsMT+qHN4R3qYlL/lN4D''||'||chr(10)||
'''gDOah8XP7P5JbQ0wnRmyVa8AZtchtLtrf2vJ31ryEl'||
'pCOvWXqral27gFVL9Qt9VC''||'||chr(10)||
'''sci1WKg9sJxTHTLuM9k3lx9ur23LuIJk//L5V2ilMetvY63022sdcXVcZZZWK/LM''||'||chr(10)||
'''67L+CK9pbGWWswfjgsmB4dEdbJ5ly1Pg2bGcInP5da/YHhLDOSJG2cJ7NTsUXTQr''||'||chr(10)||
'''9Hasty1oOFAisjWG4JnR2ZYLyWx2A7cxY1aDnafLKjPfquDZslJx+kHVElo1I8qv''||'||chr(10)||
'''JVZ33J9nGW37WzFherEdZ5fqpkXHnyb0lETjMhyTyNt12kbgb6vkcM2S86qK3dfe''||'||chr(10)||
'''z0+kS9+WV1MrXFdHnwFOmctutcnPkog9rcy+ovIti8jN1ZGpluYF+Yo8rd8Fi/Ig''||'||chr(10)||
'''Po+aE91f8Xz/09EL90I5YJmbOTHk'||
'zu56uVqQvbAFJs/StFmfs+7wjZP0mAnyhseG''||'||chr(10)||
'''8ND6tKZWXyQqjFgHLxIVlpD38zAT/lM4L6U0CN+0emZKfVdWk64vzRfRzBDNK4lV''||'||chr(10)||
'''YQMr77joL4F4t79Icvqrd5KZNZ2oRlcsZ6qSywoDpavIHwIlGF/jb3jSMq9qaxFD''||'||chr(10)||
'''bsJl2BkGNaXbNDle1ozEzBRi6HpJBeFwq5/roXSHBt2SakmbIFr5sSmdQUC+zhTM''||'||chr(10)||
'''ITUSzn5Uo9B/0IhDCnYjC7aQcX9U3brMNHjjKtWsUe2M6+bZvkjGvZ2WpdGx17Gg''||'||chr(10)||
'''buK1c9XVpFKXrVSp26e/nynZWgdG/FoM/0lNPDD+DzoaiNz+UwAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_html varchar2(3'||
'2767) :='||chr(10)||
'''H4sIAAAAAAAAC9VXzW7jOAy++ym0e7GNOm28M9PJbJpeOpc97aEPYCi2khhQJEOS''||'||chr(10)||
'''23QxDz+k/mLHTtEeN0Bii6Io8uMnUkl2vahNKwXpqNIsybqqkTXZcrlNiq7SB8ZM''||'||chr(10)||
'''JRTpuK5aYdieKfL3hoiec5xnJ6MoabZHLXvT9abirWCaKkXfolqeKGZ6JYgB29TQ''||'||chr(10)||
'''pNWJqWrGOUrwuYaxkq84hIcfaT/UOMZ1YT2OD+bISQ1O2kmmTSV3O80MGfhY4pxW''||'||chr(10)||
'''dZiazNW6bcDF45YpHHIq9lUtQelkvBhVMbgKdrpt2I72POiZE655pUq0Yk/sx9u3''||'||chr(10)||
'''pvsRZCjqpL4UGbqtmGguxRD0nBi0OatqYSYTalbazEl1R'||
'8WlrJZ8VnxARhjyQhW+''||'||chr(10)||
'''/pWVy+UyXydbtm9F0u5IRhxZWu0SLdUZrD0znIm9OThC5WRDliMF3W+1UW62+FaU''||'||chr(10)||
'''OfljQ9IvT/er71/vf94/pcAbc2AiksfnHoFpdzF9SDJw2/tatU3WG1615UrcHmkX''||'||chr(10)||
'''5Fn6z/O/i9Xq249FmRZL2A3iiK7UilHDDDt2UlH1ljl6FUb1bKQmxQtTxkjknVfC''||'||chr(10)||
'''MwABJEXUgu+RnnT7H0uKETVxeGZjUogXnrkgimWOk0P+4dhzK8kDoSDWViBo3sH0''||'||chr(10)||
'''YSubtzQP7Joq+PA3qAMJc2qPZEkooOhGD8Qad1jHpIMln6AQp9W+WSUFZ1SbDL3H''||'||chr(10)||
'''pLe7bLwlSZ1qDlEV1nTuYp3V/vNT2vD'||
'5jPrjjHa+sKLFKnGQfIQ8ERXHHCTqOHke''||'||chr(10)||
'''u2Edmqs/o7rzQeJe7P3/oGM4o+FpqYdLgHoBrHM1AzvLte8It3jIK/PWMRSnz+k6''||'||chr(10)||
'''4VJ2V3e0VlKfXNjw1BryChv4/bzlUGen6++sgcd5C2EZWiGXLg+GN2VoWdAjOBSS''||'||chr(10)||
'''QVF2wb0fg3o3AAJVM6AXfbqagxDKzZdPWgP3o/eQr9HpdyYXZajSd2nIYmhVc8iq''||'||chr(10)||
'''K7CGNdGbIBh6REYQhveI9BDo5sNAN58A2jsVauvHgUbtaM3V24G1GWixHFloR8j6''||'||chr(10)||
'''EFzZLeP5gJVwCKsXysP9CnbncHHzrX3aAlxz35xDt6fRKp87gR0+uN2cB67Lny8H''||'||chr(10)||
'''6Ius3LUo4+DFMVP29'||
'zIc1L5Z+TZhDRYzHQK1cizG+LJY5dgK0jQ8LKQ16/Bimlhc''||'||chr(10)||
'''JTil4EqI7z5qhNOHPnAyToZbwgTH2XQCX5srfH03oWQ+MTPHx2c67hA9PBM4vEea''||'||chr(10)||
'''Z0GSu2l3WXbl1If8SMpYUqeGot6iHJdlPCgjeCJDz45hRcvC0cuj2hUDg1qCRTwb''||'||chr(10)||
'''FMj8VtCjq+hWRlLy69ewgs4vsn8Cwq56uG3wMba5nWKTCxyAPL07rn8DAB+QK/EM''||'||chr(10)||
'''AAA='';'||chr(10)||
'--'||chr(10)||
'  cursor c_api( b_app_id number, b_page_id number, b_item_name varchar2 )'||chr(10)||
'  is'||chr(10)||
'    select api.attribute_01 '||chr(10)||
'    from apex_applicati'||
'on_page_items api'||chr(10)||
'    where api.application_id = b_app_id'||chr(10)||
'    and   api.page_id = b_page_id'||chr(10)||
'    and   api.display_as_code = ''NATIVE_FILE'''||chr(10)||
'    and   api.item_name = b_item_name;'||chr(10)||
'  r_api c_api%rowtype;'||chr(10)||
'--'||chr(10)||
'  procedure log( p_msg varchar2 )'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'--    apex_debug_message.error( p_msg );'||chr(10)||
'    apex_debug_message.log_message( p_msg, p_level => 4 );'||chr(10)||
'  end;'||chr(10)||
'  function dc( p varchar2 ) return varchar2'||
''||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'    return utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( p ) ) ) );'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'begin'||chr(10)||
'  p_browse_item     := p_process.attribute_01;'||chr(10)||
'  p_collection_name := p_process.attribute_02;'||chr(10)||
'  p_sheet_nrs       := p_process.attribute_03;'||chr(10)||
'  if upper( p_process.attribute_04 ) in ( ''HT'', ''^I'', ''\T'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(9);'||chr(10)||
'  elsif upp'||
'er( p_process.attribute_04 ) in ( ''VT'', ''^K'', ''\V'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(11);'||chr(10)||
'  else'||chr(10)||
'    p_separator := substr( ltrim( p_process.attribute_04 ), 1, 1 );'||chr(10)||
'  end if;'||chr(10)||
'  p_enclosed_by     := substr( ltrim( p_process.attribute_05 ), 1, 1 );'||chr(10)||
'  p_encoding        := p_process.attribute_06;'||chr(10)||
'  p_round := substr( ltrim( p_process.attribute_07 ), 1, 1 );'||chr(10)||
'  p_50 := substr( ltrim( p_process.attribute_0'||
'8 ), 1, 1 );'||chr(10)||
'--'||chr(10)||
'  open c_api( nv(''APP_ID''), nv(''APP_PAGE_ID''), upper( p_browse_item ) );'||chr(10)||
'  fetch c_api into r_api;'||chr(10)||
'  if c_api%notfound'||chr(10)||
'  then'||chr(10)||
'    log( ''FILE BROWSE item '' || p_browse_item || '' not found'' );'||chr(10)||
'  end if;'||chr(10)||
'  close c_api;'||chr(10)||
'  t_filename := apex_util.get_session_state(  p_browse_item );'||chr(10)||
'  log( ''looking for uploaded file '' || t_filename || '' in '' || r_api.attribute_01 );'||chr(10)||
'--'||chr(10)||
'  begin'||chr(10)||
'    if r_'||
'api.attribute_01 = ''WWV_FLOW_FILES'''||chr(10)||
'    then'||chr(10)||
'      select aaf.id'||chr(10)||
'           , aaf.blob_content'||chr(10)||
'      into t_file_id'||chr(10)||
'         , t_document'||chr(10)||
'      from apex_application_files aaf'||chr(10)||
'      where aaf.name = t_filename;'||chr(10)||
'--'||chr(10)||
'      delete from apex_application_files aaf'||chr(10)||
'      where aaf.id = t_file_id;'||chr(10)||
'--'||chr(10)||
'      log( ''retrieved!''  );'||chr(10)||
'    elsif r_api.attribute_01 = ''APEX_APPLICATION_TEMP_FILES'''||chr(10)||
'    then'||chr(10)||
'      ex'||
'ecute immediate ''select aaf.blob_content'||chr(10)||
'                         from apex_application_temp_files aaf'||chr(10)||
'                         where aaf.name = :fn'''||chr(10)||
'      into t_document using t_filename;'||chr(10)||
'--'||chr(10)||
'      log( ''retrieved!''  );'||chr(10)||
'    end if;'||chr(10)||
'  exception'||chr(10)||
'    when no_data_found'||chr(10)||
'    then'||chr(10)||
'      raise e_no_doc;'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'  if t_document is null or dbms_lob.getlength( t_document ) = 0'||chr(10)||
'  then'||chr(10)||
'    log( ''file is em'||
'pty'' );'||chr(10)||
'    return null;'||chr(10)||
'  else'||chr(10)||
'    log( ''file with length '' || dbms_lob.getlength( t_document ) || '' found '' );'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'  if apex_collection.collection_exists( p_collection_name )'||chr(10)||
'  then'||chr(10)||
'    apex_collection.delete_collection( p_collection_name );'||chr(10)||
'  end if;'||chr(10)||
'  for i in 1 .. 10'||chr(10)||
'  loop'||chr(10)||
'    if apex_collection.collection_exists( p_collection_name || i )'||chr(10)||
'    then'||chr(10)||
'      apex_collection.delete_collec'||
'tion( p_collection_name || i );'||chr(10)||
'    end if;'||chr(10)||
'  end loop;'||chr(10)||
'--'||chr(10)||
'  if dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''504B0304'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLSX'' );'||chr(10)||
'    t_what := ''XLSX-file'';'||chr(10)||
'    t_parse := dc( t_parse_xlsx );'||chr(10)||
'  elsif dbms_lob.substr( t_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B11AE1'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLS'' );'||chr(10)||
'    t_what := ''XLS-file'';'||chr(10)||
'    t_parse := dc( t_parse_xls );'||chr(10)||
'  elsif d'||
'bms_lob.substr( t_document, 5, 1 ) = hextoraw( ''3C68746D6C'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing HTML'' );'||chr(10)||
'    t_what := ''HTML-file'';'||chr(10)||
'    t_parse := dc( t_parse_html );'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = hextoraw( ''003C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'        )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing X'||
'ML'' );'||chr(10)||
'    t_what := ''XML-file'';'||chr(10)||
'    t_parse := dc( t_parse_xml );'||chr(10)||
'  else'||chr(10)||
'    log( ''parsing CSV'' );'||chr(10)||
'    t_what := ''CSV-file'';'||chr(10)||
'    t_x := dbmsoutput_linesarray(p_separator, p_enclosed_by, p_encoding);'||chr(10)||
'    t_parse := dc( t_parse_csv );'||chr(10)||
'  end if;'||chr(10)||
'  execute immediate dc( t_parse_bef ) || t_parse || dc( t_parse_aft ) using p_collection_name,t_document,p_sheet_nrs,t_x,p_round,p_50;'||chr(10)||
'--'||chr(10)||
'    t_rv.success_m'||
'essage := ''Loaded a '' || t_what || '' in '' || to_char( trunc( ( sysdate - t_time ) * 24 * 60 * 60 ) ) || '' seconds'';'||chr(10)||
'    return t_rv;'||chr(10)||
'exception'||chr(10)||
'  when e_no_doc'||chr(10)||
'  then'||chr(10)||
'    t_rv.success_message := ''No uploaded document found'';'||chr(10)||
'    return t_rv;'||chr(10)||
'  when others'||chr(10)||
'  then'||chr(10)||
'    log( dbms_utility.format_error_stack );'||chr(10)||
'    log( dbms_utility.format_error_backtrace );'||chr(10)||
'    t_rv.success_message := ''Oops, something w'||
'ent wrong in '' || p_plugin.name ||'||chr(10)||
'         ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||'||chr(10)||
'       dbms_utility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could imagine''||'||chr(10)||
'           ''</li></ul><'||
'br/>'' ||'||chr(10)||
'           ''try running this plugin in debug mode, and send the debug messages to me, scheffer@amis.nl'';'||chr(10)||
'    return t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.822'
 ,p_plugin_comment => '0.822'||chr(10)||
'  XLS: fix empty string results for formulas'||chr(10)||
'  more than 50 columns '||chr(10)||
'0.821'||chr(10)||
'  XLSX: fixed bug for numbers without a format'||chr(10)||
'0.820'||chr(10)||
'  Apex 5.0: Handle APEX_APPLICATION_TEMP_FILES'||chr(10)||
'0.818'||chr(10)||
'  XLS: fixed bug for unicode strings starting at CONTINUE record'||chr(10)||
'0.816'||chr(10)||
'  XLSX: treat numbers with "text" format as string'||chr(10)||
'0.814'||chr(10)||
'  XLS: performance'||chr(10)||
'0.812'||chr(10)||
'  XLS, XLSX: option to round number values'||chr(10)||
'  XLS: fixed bug for Asian strings'||chr(10)||
'0.810'||chr(10)||
'  XLSX: skip empty nodes'||chr(10)||
'  CSV: handle 1 line file'||chr(10)||
'0.808'||chr(10)||
'  Use dd-mm-yyyy hh24:mi:ss for date format'||chr(10)||
'0.806'||chr(10)||
'  save mapping between sheet name and collection name in <Collection name>_$MAP'||chr(10)||
'  XLSX: also strings on 10.2 databases'||chr(10)||
'        read formulas'||chr(10)||
'  XLS: fix empty string results for formulas'||chr(10)||
'       added standard data formats'||chr(10)||
'  CSV: performance in case of wrong separator'||chr(10)||
'0.804'||chr(10)||
'  XLSX: Fix bug for formated strings'||chr(10)||
'  CSV: Support for HT separator'||chr(10)||
'0.802'||chr(10)||
'  XLSX: Support for numbers in scientific notation'||chr(10)||
'  XLSX: Fix bug for empty strings'||chr(10)||
''
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 12508510925690599 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Browse Item'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_is_translatable => false
 ,p_help_text => 'The name of the File Browse Item which is used to select the uploaded Excel file.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 12509208547718328 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Collection name'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_is_translatable => false
 ,p_help_text => 'The name of the Collection in which the first sheet is placed.'||chr(10)||
'<br/>Eventually, other sheets are placed in Colections with a sequence number attached to this name: <br/>'||chr(10)||
'<br/>&lt;Collection name&gt;2'||chr(10)||
'<br/>&lt;Collection name&gt;3'||chr(10)||
'<br/>&lt;Collection name&gt;4'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 12510523139750887 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Sheets'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'A colon separated list of sheets which should loaded.'||chr(10)||
'<br/>When left empty all sheets are loaded.<br/>'||chr(10)||
'A sheet is identified by its name or positional number.'||chr(10)||
'<br/><br/>For instance'||chr(10)||
'<br/>'||chr(10)||
'&nbsp;&nbsp;1:3 will load the first and the third sheet<br/>'||chr(10)||
'&nbsp;&nbsp;Sheet1:Sheet2 will load the sheets with the names "Sheet1" and  "Sheet2"'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 12511227341780517 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'CSV Separator'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_default_value => ';'
 ,p_is_translatable => false
 ,p_help_text => 'The column separator character used for CSV-files.<br/>'||chr(10)||
'Use \t, ^I or HT for a (horizontal) tab character.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 12511925179798771 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'CSV Enclosed By'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_default_value => '"'
 ,p_is_translatable => false
 ,p_help_text => 'A delimiter character used for CSV-files. This character is used to delineate the starting and ending boundary of a data value.'||chr(10)||
'The default value is ".'||chr(10)||
'The same character is used as the escape character.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 12512619470834999 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 60
 ,p_prompt => 'CSV Character set'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'The character set used for loading a CSV file.'||chr(10)||
'<br/>When left empty the database character set is used.'||chr(10)||
'<br/>Use the Oracle name for the character set, for instance WE8MSWIN1252 and not Windows-1252'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 10748824832149827 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 7
 ,p_display_sequence => 70
 ,p_prompt => 'Round Excel numbers'
 ,p_attribute_type => 'CHECKBOX'
 ,p_is_required => false
 ,p_default_value => 'Y'
 ,p_is_translatable => false
 ,p_help_text => 'Excel has a numerical precision of 15 digits. When this option is used numbers are rounded to 15 digits.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 4895723750072639 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 12464033537943571 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 8
 ,p_display_sequence => 80
 ,p_prompt => 'Load more than 50 columns'
 ,p_attribute_type => 'CHECKBOX'
 ,p_is_required => false
 ,p_default_value => 'N'
 ,p_is_translatable => false
 ,p_help_text => 'Load more than 50 columns. Because we can store only 50 varchar2 columns in a APEX collection, columns above 50 are loaded in a second row. Attribute N001 stores the row number, attribute N002 stores the column number of C001.'
  );
null;
 
end;
/

commit;
begin 
execute immediate 'begin dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
prompt  ...done
