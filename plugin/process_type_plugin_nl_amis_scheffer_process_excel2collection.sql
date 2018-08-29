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
'''H4sIAAAAAAAAC+0ca2/bSO67f4X2w0FSLfskWbGdpi2QNglQbB+HZovefT'||
'Jke5xo''||'||chr(10)||
'''a0uGJG+Sw/74I+el0VgPx3bSxXWDALZGMySHQ3I4JMedxSae5VESG+swzUjHWk/m''||'||chr(10)||
'''yWyzInFuTJfJtOOsJ9ktIXlm/BGms9sw9Y2Xr414s1ziK3Kfp6Exn66yZJOvN/lk''||'||chr(10)||
'''GcUkC9M0fJDd7E5K8k0aGznADvOwE2WdfDIjyyW24OcZPKfJXYbP+InP2FOMwOe7''||'||chr(10)||
'''JP0+TZLvlCpsiOK5EcU5uSEpPmba85LE6uMqvNebZjBF5fEmnUa5kYZ3lmfj8zRa''||'||chr(10)||
'''LE4MQLkkYUwx5KnkgTXwR8MR7RfNi9bAwE/afEvCOUkpvIA25Ks1fSpGpmSmtcBk''||'||chr(10)||
'''iXfqBgrahzVBNmQZEAsMCqdLYiQLnRCYyJzcG9MHY73M'||
'JipbYBwbXsBCLCVgHFst''||'||chr(10)||
'''kPsFG8PHYtNilettHDp0hpcl+Aq4Jhw4TALgSKo4js+TjCjvPNe1Ud7Mb5fjj9ff''||'||chr(10)||
'''3n/y/BPfVLiHEkz5DWTBR5LOO1YcrogOvuMoYtSxNQhZaVZluHX8Z+MkBNlWGk5n''||'||chr(10)||
'''pQ+lqIsp2kKMtY7rNJmR+SYlMLFwPtnE0SyZE5TWKL5hugZtJUGbkpso5hLNtfSs''||'||chr(10)||
'''c3cbwbyYWrwx3M4ySdadaGFs8uUEBvdBOyZhPLe4pji3oPsJQjVdz7Rt47VRbunk''||'||chr(10)||
'''tyRGAJZhMPXsUuAvfAAvgIJK3uS3FmWC3fU6gIBakwkoeT/bTIFCq9B9x3eo3nep''||'||chr(10)||
'''eneDMtLBO9cFtByxnB378uefFGfkje'||
'M+9J7kCRUjSxAicQEhDiPXdszzD97w629X''||'||chr(10)||
'''3vDDpWkLm0FhwpeeNokmULbxT8MXVosCUKYhzBW0CxizMMuRxmkUh+mDWGxrB9b4''||'||chr(10)||
'''tiPpivJ8SSYknkdhbBc2DvA0API4oEDaqOb+lPaeHNVlgprxiXpnHbKEfeXw5XC4''||'||chr(10)||
'''9FQtSybZqsqZsmAukIGKveDkbIvlswgloOXEvnpdjU4IL+4WijxUydRB8iiXhSNi''||'||chr(10)||
'''NkDw6GeW03bOM0msFbxqsaNLj7BhC4mTnLlGQigEMnCm4mwJ26lF+0oO3UP7DbHM''||'||chr(10)||
'''qyvTMUdXJugAfLUpLAlnRxVjkM2v16Pz63fv35uFKOA2IUVhkcBeDdua4Rn9/ras''||'||chr(10)||
'''AgybbRFynJSJJJ6F'||
'uUXbnS02IvLI8Wx1/wANsRmnEOLZ7jNBDLo1kHpe8cnAwzeY''||'||chr(10)||
'''n/B70+9+vFlNQWrB+fyO+6R0WFk77qFsx+TNIPQE++UJzMHS90dtxggUZBUmbLoD''||'||chr(10)||
'''mCfss6BCpuubBq5amybp0Ck48+rdFf0z65QItptAYBo8OSbXFbjcZlzzZAPOk6VJ''||'||chr(10)||
'''Cgxjf6aDSOswCRzegTjaJtowU/AzmfSURQjkxEcnGEDBVy42UorwTSFD1A4IP58p''||'||chr(10)||
'''rjgeJbQdvace/ON70PaLi97Hj73/wJ9pdyn8QqSrBg5woKsPZJT1hp7Nade8xtli''||'||chr(10)||
'''Cl1mC3q6spnXqJxgTjyfnYkecjIB5xmaNWeVxOB1gsNpGIpL7TIbmf0XWksDDNrM''||'||chr(10)||
'''2q'||
'tekVn+fr71ihln8VZ0+wf6yYqjTmbRXHPU1Z61nvoqC/MCACUcGrSW7T4AOWFM''||'||chr(10)||
'''8t1gzCZ8m6SwBSRxHsJpOJUnVjAHJFzJR9xKNRr0I4k4Ts4mVykhk2sye39B2QLA''||'||chr(10)||
'''szyETUY9Wr183fOw72U8n3xeTN7dAno+pq6/j/2vz39TQNf2HWDfj+XOdX0D7Hvx''||'||chr(10)||
'''/svkcrXOH0o92QkbrXt5BxAjrrHthrSN8NQRlK9tI/xixIdk9t1op2pQjPhXmqxJ''||'||chr(10)||
'''ClNpHhEUI74ksMu34zgxlQMZV7kKRwaV0wE1dFCDqfcqewsnAMRwa5tmXWzjlQFj''||'||chr(10)||
'''1R5yP2Y9YIca28YvKmUX7rsrz7t0z723nnd+6RVeLDM7qreo2AWgne6Pd'||
'6qJ1rH5''||'||chr(10)||
'''p45f9pOvLqlDUzLsJfNroJOiHEZvZDuaM2pVFSpeVwMRjpK0VhgzUP0H6QtV9zDV''||'||chr(10)||
'''SVP7Ba/XyR1sn76z4/6q82LgAS8clXqbm02AfwTwgyrw0rtz0bvz3NOeJ7w5bl7b''||'||chr(10)||
'''nfw6jKNRN3oROIGGFVh3D049lQuJBYRFMW3CDFuRzb0/2ktzDQ+lb3haQZuIfnDo''||'||chr(10)||
'''vyBh23ZU5VFSr6dUNlBbu/TbCwGWnjnKrGdiBD5UzxfAKQfYB3gvmzi3bHuf6TIi''||'||chr(10)||
'''HViLrle1GkfhKUfSq1xviQHn/LsyZ3VuZcl7FFcpp363G9laQKdcfTamHldkq3D9''||'||chr(10)||
'''eJEteMuZ+0NEVi4tbTmaZHPWB39Fa+H544L5u4Vk6nk'||
'NwLrDk61dgm+qCP2N4Yud''||'||chr(10)||
'''k3qoHFt79K6Ew+MhGIpI7K/KgZ26DS1kjsD/YedA1fVjxEnmzqAtJzlZrcG3SB8s''||'||chr(10)||
'''4Xk7ebohtnaMOJRznjeqEJDjrIrnV2lBsSx7C/XJNs2Mh0KwFQY1CrfkebheE5oc''||'||chr(10)||
'''4KzeUdILPCDtFUsjdLtoLRtZdNaejOatk5zDvDL+sRv5zfRz0ZeY8zRaKfKKyyxW''||'||chr(10)||
'''nGoeGALL/MZDmnDIf8s+vn3+8uvbz59/NWX8WKZLRRQN4BX4FA3CY0q7/uh8eDZF''||'||chr(10)||
'''OsLiarQ/o2QWQXW0bXvsX7Dwktwoa1gRPEx52jIuwK9uGlKKTdehoYKzE3TWsxRv''||'||chr(10)||
'''FQfb1QMMubFMLDHAM9W/P1zjqVeJP'||
'ImaAyHsUnz54daAbVCiviG5POCKjkiiy0gU''||'||chr(10)||
'''2D4lhgSzQClagGcyp4jDKCMTkJBlNAsxgjchaZqkVs93XXfgwMjcCI0/wmU0R1p7''||'||chr(10)||
'''ONoUQr+VI/HU+gJ1k6+kk5/ed0goaSnVU3cMB2T42zUfFdjUXKhRFow2dEqRd3dI''||'||chr(10)||
'''z/U7ghxqNJ2UM66sZKI5DaNQV44AsUjIc2WYqvNb1ISox1Ts9ga78fVVKjuapxnw''||'||chr(10)||
'''NeQVItB5K2GwHYLxbe2UHOEJ2XTPgc0H+BQiEuA0cIRqHUN3hSlLru1ktgxTjIek''||'||chr(10)||
'''m1LtDKxb8VjEksP5nBoY0GgtumlrEXCaLmO96lKhXa8u3PSYFZBp2cevhMKTQcGT''||'||chr(10)||
'''Q3Oj+y/PToljngj'||
'V0h+NZQ5tSVOpsUWqcMd0q5KiVeJmWsq1nHpWto1S191TvGOO''||'||chr(10)||
'''leYsZOShlMZ8vFER0jSuzU5R2yEVYKCm5x8rEUqqudGIadlnv5Q6b4LqVQ33znYs''||'||chr(10)||
'''9xlvlfuMheMp58/yRWg1nnX+QjwZ3nL6fYeZBVszC7ZmxiwJGsDDZha0aDtieCV8''||'||chr(10)||
'''GomQfukG/mlwOhz5p8MqxeLsCIpg9r1ejVBRKsarBWkYpxzFoc7dWcEByt8XQZcC''||'||chr(10)||
'''ri6DUDpsZd6BKMWyjk8Uy/p4s8IC/+h3CBgH6BxGFxrErakyZKwWhWBZX78xUsLq''||'||chr(10)||
'''IIpSxsKyHki+3W4DxiKHdFhlnyzSqERyKsu19AIwZu6buXkqufmIMhSNHFmGAu37''||'||chr(10)||
'''l'||
'aEomrXLiiKeumIUAYLryT6r6zVZDA4/s8QXXYGxUVc931dUT5Ye7+e+eyyFW0bg''||'||chr(10)||
'''XYL9/Ivo9mB/3Q4U3caS5GdV6ka3sE3VT55D1YcHqfrwL6bqzQvcrOOiKN7aT79r''||'||chr(10)||
'''F9ruAEUWsIb1BjSOOZ+bNq3TRq6pL1armhcPD/zFlp5eugftwaJ43xJfDsoBtQp9''||'||chr(10)||
'''mfbAP9R/sIoDITtKsSir5/oj0wFRGWOMAwMkMRxnUQ5AtQG5RS8bnL/78vnj+acx''||'||chr(10)||
'''L8YUhZ1SceRdBXE7QQ7YrlCsO1mqYUMpYl7ATHu6IeX2k5r2YU37qLrd95V2PQtV''||'||chr(10)||
'''XuYiFcUvisj8vYDWJ/dRRncnLikRyAayVEGovqtSTaQhUzNhyj5XUFA4'||
'omw/zOx+''||'||chr(10)||
'''cbZ5rrCbFtgamvsG2DzXFcJnGeolFFHwwxTcfGlikazsAN+hyeHNwnplXc/mrzQD''||'||chr(10)||
'''0TJe4SV1gVQYSvSP3U1h5wx2n6s/J0vC7gvhNS6LfbAlA2KkQ6VjOJMxXDynGJVU''||'||chr(10)||
'''/B0rbI4V0vt1yh78PLHD0aXrH+rxCSOyz8Zx0rSJCpMMnOmjILIbVmiYLyTL8AWZ''||'||chr(10)||
'''/BFy3vG63qJGvObgFdhKcKwCwacCAQMkUOwCWd0hZk+wpXZlBoNCv6HpPxoJoG3o''||'||chr(10)||
'''oNlCpY/t2oAZsBA+UzB2GbS8wbuD/0uRqiFFq17XhKE2+rif8B2Xhp9cTIdH9EPr''||'||chr(10)||
'''wzvUxaT+KS3yhzOag5XN7HJJZYEvnRmytVzey+46lC'||
'6m/a0lf2vJU2gJ6VTfmNqW''||'||chr(10)||
'''bu2KT/VCXRcLxSLXYqF2wHJKdUi7rGRenX+4vjQN7X6R+duXr9BKY9Y/x1qVr6Z1''||'||chr(10)||
'''xL1wlVmlWpFH3oV1R3gHYyuznNxpt0f2DI+2sHmWLI+Bp2U5Rebyx96f3SeGc0CM''||'||chr(10)||
'''soH3Z/U6TPccxPq6yHJVaLUpLmVsh4Ob4ooDJWhbAfWRAVyR4Apabiczbgzs2gxb''||'||chr(10)||
'''BSk8vbYdDWo0DMmyMA30g6oztJaML7+rWFx8f5xFNc2fxfSVi/Q4u1T3Ljj8FFJO''||'||chr(10)||
'''ZdQuwyEJwLZTeru68WqM9rvwp0dSsJ/LG6oUrouDzw7HzIE32vJHScSOVmZXUfmZ''||'||chr(10)||
'''ReTq4sAUTf2C/ECeVu+GWb4Xn0f1'||
'CfIfGBd4e/DCPVHuWOZ0jgy5015nVwmy5zfA''||'||chr(10)||
'''5NkdPajdZI1OusMXVtRjJskZHhoKRGvUmKJ9kugyYh08SXRZQt7N44z47+U8lRIh''||'||chr(10)||
'''fN0K6qn5tuwoXV+ad6IZJpqfEqvCBhbectZfAvF2fxGl9KfxJDMrOlENL1jOVCeV''||'||chr(10)||
'''lQpKV5GHBEowTsff8ORnWtToIoZUh8uwMwzqYaBucrw8GomZKcTQ9RIKI+AWv+lD''||'||chr(10)||
'''6fY1uiXVkjZBtPKLVGUGAfllpmAuqpZw9ssbWflXjzgkrx2Zt4WM+6fqVqYfoGpX''||'||chr(10)||
'''qWKNKmdcNc/mRdLu/zQsTRl7FQuqJl4517KaFOqylXK1+/RHNiVbq8CIn5Thv7uJ''||'||chr(10)||
'''B8j/AW8HtZkjVA'||
'AA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_html varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC9VXzW7jOAy++ym0e7GNOm28M9PJbJpeOpc97aEPYCi2khhQJEOS''||'||chr(10)||
'''23QxDz+k/mLHTtEeN0Bii6Io8uMnUkl2vahNKwXpqNIsybqqkTXZcrlNiq7SB8ZM''||'||chr(10)||
'''JRTpuK5aYdieKfL3hoiec5xnJ6MoabZHLXvT9abirWCaKkXfolqeKGZ6JYgB29TQ''||'||chr(10)||
'''pNWJqWrGOUrwuYaxkq84hIcfaT/UOMZ1YT2OD+bISQ1O2kmmTSV3O80MGfhY4pxW''||'||chr(10)||
'''dZiazNW6bcDF45YpHHIq9lUtQelkvBhVMbgKdrpt2I72POiZE655pUq0Yk/sx9u3''||'||chr(10)||
'''pvsRZCjqpL4U'||
'GbqtmGguxRD0nBi0OatqYSYTalbazEl1R8WlrJZ8VnxARhjyQhW+''||'||chr(10)||
'''/pWVy+UyXydbtm9F0u5IRhxZWu0SLdUZrD0znIm9OThC5WRDliMF3W+1UW62+FaU''||'||chr(10)||
'''OfljQ9IvT/er71/vf94/pcAbc2AiksfnHoFpdzF9SDJw2/tatU3WG1615UrcHmkX''||'||chr(10)||
'''5Fn6z/O/i9Xq249FmRZL2A3iiK7UilHDDDt2UlH1ljl6FUb1bKQmxQtTxkjknVfC''||'||chr(10)||
'''MwABJEXUgu+RnnT7H0uKETVxeGZjUogXnrkgimWOk0P+4dhzK8kDoSDWViBo3sH0''||'||chr(10)||
'''YSubtzQP7Joq+PA3qAMJc2qPZEkooOhGD8Qad1jHpIMln6AQp9W+WSUFZ1SbDL3H''||'||
''||chr(10)||
'''pLe7bLwlSZ1qDlEV1nTuYp3V/vNT2vD5jPrjjHa+sKLFKnGQfIQ8ERXHHCTqOHke''||'||chr(10)||
'''u2Edmqs/o7rzQeJe7P3/oGM4o+FpqYdLgHoBrHM1AzvLte8It3jIK/PWMRSnz+k6''||'||chr(10)||
'''4VJ2V3e0VlKfXNjw1BryChv4/bzlUGen6++sgcd5C2EZWiGXLg+GN2VoWdAjOBSS''||'||chr(10)||
'''QVF2wb0fg3o3AAJVM6AXfbqagxDKzZdPWgP3o/eQr9HpdyYXZajSd2nIYmhVc8iq''||'||chr(10)||
'''K7CGNdGbIBh6REYQhveI9BDo5sNAN58A2jsVauvHgUbtaM3V24G1GWixHFloR8j6''||'||chr(10)||
'''EFzZLeP5gJVwCKsXysP9CnbncHHzrX3aAlxz35xDt6fRKp87gR0+u'||
'N2cB67Lny8H''||'||chr(10)||
'''6Ius3LUo4+DFMVP29zIc1L5Z+TZhDRYzHQK1cizG+LJY5dgK0jQ8LKQ16/Bimlhc''||'||chr(10)||
'''JTil4EqI7z5qhNOHPnAyToZbwgTH2XQCX5srfH03oWQ+MTPHx2c67hA9PBM4vEea''||'||chr(10)||
'''Z0GSu2l3WXbl1If8SMpYUqeGot6iHJdlPCgjeCJDz45hRcvC0cuj2hUDg1qCRTwb''||'||chr(10)||
'''FMj8VtCjq+hWRlLy69ewgs4vsn8Cwq56uG3wMba5nWKTCxyAPL07rn8DAB+QK/EM''||'||chr(10)||
'''AAA='';'||chr(10)||
'--'||chr(10)||
'  cursor c_api( b_app_id number, b_page_id number, b_item_name varchar2 )'||chr(10)||
'  is'||chr(10)||
'    select api.attr'||
'ibute_01 '||chr(10)||
'    from apex_application_page_items api'||chr(10)||
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
'  function'||
' dc( p varchar2 ) return varchar2'||chr(10)||
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
'    p'||
'_separator := chr(9);'||chr(10)||
'  elsif upper( p_process.attribute_04 ) in ( ''VT'', ''^K'', ''\V'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(11);'||chr(10)||
'  else'||chr(10)||
'    p_separator := substr( ltrim( p_process.attribute_04 ), 1, 1 );'||chr(10)||
'  end if;'||chr(10)||
'  p_enclosed_by     := substr( ltrim( p_process.attribute_05 ), 1, 1 );'||chr(10)||
'  p_encoding        := p_process.attribute_06;'||chr(10)||
'  p_round := substr( ltrim( p_process.attribute_07 ), 1, 1 );'||chr(10)||
'  p_50 := sub'||
'str( ltrim( p_process.attribute_08 ), 1, 1 );'||chr(10)||
'--'||chr(10)||
'  open c_api( nv(''APP_ID''), nv(''APP_PAGE_ID''), upper( p_browse_item ) );'||chr(10)||
'  fetch c_api into r_api;'||chr(10)||
'  if c_api%notfound'||chr(10)||
'  then'||chr(10)||
'    log( ''FILE BROWSE item '' || p_browse_item || '' not found'' );'||chr(10)||
'  end if;'||chr(10)||
'  close c_api;'||chr(10)||
'  t_filename := apex_util.get_session_state(  p_browse_item );'||chr(10)||
'  log( ''looking for uploaded file '' || t_filename || '' in '' || r_api.att'||
'ribute_01 );'||chr(10)||
'--'||chr(10)||
'  begin'||chr(10)||
'    if r_api.attribute_01 = ''WWV_FLOW_FILES'''||chr(10)||
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
'    elsif r_api.attribute_01 = ''APEX_APPLICAT'||
'ION_TEMP_FILES'''||chr(10)||
'    then'||chr(10)||
'      execute immediate ''select aaf.blob_content'||chr(10)||
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
'  if t_document is null or dbms_lob.getlength( t_document '||
') = 0'||chr(10)||
'  then'||chr(10)||
'    log( ''file is empty'' );'||chr(10)||
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
'  '||
'    apex_collection.delete_collection( p_collection_name || i );'||chr(10)||
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
'    t_pars'||
'e := dc( t_parse_xls );'||chr(10)||
'  elsif dbms_lob.substr( t_document, 5, 1 ) = hextoraw( ''3C68746D6C'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing HTML'' );'||chr(10)||
'    t_what := ''HTML-file'';'||chr(10)||
'    t_parse := dc( t_parse_html );'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = hextoraw( ''003C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'   '||
'     )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XML'' );'||chr(10)||
'    t_what := ''XML-file'';'||chr(10)||
'    t_parse := dc( t_parse_xml );'||chr(10)||
'  else'||chr(10)||
'    log( ''parsing CSV'' );'||chr(10)||
'    t_what := ''CSV-file'';'||chr(10)||
'    t_x := dbmsoutput_linesarray(p_separator, p_enclosed_by, p_encoding);'||chr(10)||
'    t_parse := dc( t_parse_csv );'||chr(10)||
'  end if;'||chr(10)||
'  execute immediate dc( t_parse_bef ) || t_parse || dc( t_parse_aft ) using p_collection_name,t_document,p_sheet_nrs,t_x,p_'||
'round,p_50;'||chr(10)||
'--'||chr(10)||
'    t_rv.success_message := ''Loaded a '' || t_what || '' in '' || to_char( trunc( ( sysdate - t_time ) * 24 * 60 * 60 ) ) || '' seconds'';'||chr(10)||
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
'    t_rv.succ'||
'ess_message := ''Oops, something went wrong in '' || p_plugin.name ||'||chr(10)||
'         ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||'||chr(10)||
'       dbms_utility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could i'||
'magine''||'||chr(10)||
'           ''</li></ul><br/>'' ||'||chr(10)||
'           ''try running this plugin in debug mode, and send the debug messages to me, scheffer@amis.nl'';'||chr(10)||
'    return t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.823'
 ,p_plugin_comment => '0.823'||chr(10)||
'  XLS: fix date during MULRK'||chr(10)||
'0.822'||chr(10)||
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
