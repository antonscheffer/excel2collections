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
'--'||chr(10)||
'  t_parse_csv varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC7Va62/byBH/7r9iURxAEqEE8eE87MaA6xp3QXNJkRhpPxQlKHIl''||'||chr(10)||
'''E6VIgqT8KPzH3+xjOMuHKOVyJ8QxtTs7O79579JnKU/yuOZnjLXPFWdtFSU8z1nW''||'||chr(10)||
'''sJonZZ3CBGM2S+M2jiTFQ1wn93Ht254j51zWtHVWbKOHOKfJwH/z+g0SFPvdmteS''||'||chr(10)||
'''QD3qcWDK5ah4'||
'0GPrvFzLMfEgx5xLQ7i6fBSytfE656zckLxFyp/Y+plVeRNlRcu3''||'||chr(10)||
'''vB6sa4YLJa8j65p7ztuRNop4ZyjCX61WCFXuo/cbSy+0OJRC73BIDrVGr1UjSZnn''||'||chr(10)||
'''PGmzsojWccOHSh8R9aU1iLRUPtD2pIor/hTFVZVnSSw5bMEWcb58SKK4rv0ZYSUr''||'||chr(10)||
'''zfLybLGAwaouE57ua852z1Febm1WRbtm2wnEhOoyoaw132aFVJoUIOXr/Tba8aaJ''||'||chr(10)||
'''t3wJK/FZc3DhV84feM7eX7FQKZoXqdx2sy8kdlbFdSNcS6xJywS9SqyVio+K2kTB''||'||chr(10)||
'''Lt6Di+a5JuFPbR2zdL1ryn1b7dsozwregA7iZ4PSOat5u68LtNKZRNMqx9QOqtQj''||'||
''||chr(10)||
'''PE45R/e985aD1m4eWAJS63netFG52TTgM8wQ2lPTTZ10sxPTSZOlOgTVQB5D4CYl''||'||chr(10)||
'''ED61ekKQC8Rgq/Uy5Zt4nyNd+6RWPcZ1ARHP5Kdnf14aOcBn4rf2x4ZXRuowZ3gB''||'||chr(10)||
'''8Bqejqalih9ymzX7NeQYGw1i+47LPPjH4Lf1F0vHGDhDMfbIqmzGg00b1+0krUQw''||'||chr(10)||
'''mhBmj5JiYskm43kKQ+lwigvDRRvwG8afEl4Jb1RL1vvNdMjCxJRkGBbZRvswhKrw''||'||chr(10)||
'''PFbWZKgtbwH+tr1HR3fYe7YSbO+5iin00c61IFaA58AG36ly6VCwJinjnDcJhGYB''||'||chr(10)||
'''ogto4IJRlhKDwGEqRw4/7mjJvs2jzHtbLHdxhRMmI5cofr79dPvlw'||
'0108/nT3e2/''||'||chr(10)||
'''74yZD9efrqO7z9HnL9c3H2/Z6btbN79cf4luvloHVkjkYIt9VXFDQR7sALEAicb6''||'||chr(10)||
'''5c4CJf33g/j/P3eKT2cGFQlCZfe1/U4lrbyZ5fdN8fuH5Pdtjp/njRmiJXOo0rs+''||'||chr(10)||
'''f2nSQOgGnAVwf7FMzpSOgeMTT/YtZ9lux9MMqjWz5DS7eBJ7W+zlxeQM36xLmYwt''||'||chr(10)||
'''tm9EqhBxIEW9PFP8dEho/o+wKSth67ohAXrwrEtLLxUpXmLkfQX0/PYQWuXAl1ZX''||'||chr(10)||
'''LnQIdIGU1BzgtXxXlXVcP9sqA7usrfdcLSLSsnjgdduWIj1rwkmXUY4m43JmvuML''||'||chr(10)||
'''P7v4qcn+z2eoe6Vglo5qwiyZCOVZArNWzBLq8nC'||
'QBiMoK6SptIKF/66EK14N8lac''||'||chr(10)||
'''NbzXjfC6LmHdQvRdYFLrU9mymN18/bbYZDm3TFuRgSf38wLpq/Jxam9V0DC4esQU''||'||chr(10)||
'''ZxNsV0QZHGXbIz7G9iivWQbHhTElMDOj6CFtTPgyXfzr9u3t327+/uHmfLWyDjL0''||'||chr(10)||
'''u4zED4vbGQk7REu0bSJtgFHZY9bey4YgTlouhFHpZkY6kX5cnXgkreGKokDU8eMy''||'||chr(10)||
'''iSF62lI82zqHqIUsbhh8g+3asnbl+uPLu/pJPNSQEKGTncWA9ESGoCXidfv5o9Wt''||'||chr(10)||
'''cfrNCuiyb2m9WDs9EV4x2WycHls+oP8InQ9TnQVry5LBWXE7HWKy2VdNGIiEzYjq''||'||chr(10)||
'''Xx2z7aJ2tGuraIj6KaNrhf55S'||
'QdQUQy+WtRLwXfM+p0G5E6uAX7Rbe9cskG3BQxw''||'||chr(10)||
'''cqH2zMuy0nUqa1VxQoorhVHVItDvoa09GSXkGcr7qbRpWMbZWeDSNa6nLHx8pWQT''||'||chr(10)||
'''n04+RSp63Ck30Fu7BvZuFbqGbhM1K7P0avcwOllaTSHbcRspQjB/pWvuWBUT202q''||'||chr(10)||
'''ZDwIQTFrb8PWr8Tel70tDLUqAX0DFWapP0uegSxw7LMNl3eI/yUzc9ZJ2oWcZTLv''||'||chr(10)||
'''q/YYckXRCz7zq+F6Wk+zIlHwqzSmzV/m8wKKU7BNWUGrQx+WB4RwMs2hSxvOjDB6''||'||chr(10)||
'''8DMQZ7jGzELGtwHm6eRkzs4n5Mkg1MadSlOUrWd09sdk8KFhSRwzNxwQ4EgOntiB''||'||chr(10)||
'''s+9jMZfGDca'||
'DjNQxPpjkJ0Czv6rsPuenh5OiRrdYMC5uyOCQX7B7aFfW0KiLyr/m''||'||chr(10)||
'''Nc/+1/5erx/7dm/rEX5Ruw5lbPFNFBF9pKK8JzUhmiF9yYDlqH8m0wVn1bETDAD3''||'||chr(10)||
'''kGAYB8B40jPGC8BwowWLnkGnatnV4VrWbYHaM3gZrjRWE30zS6Zs5aYCRWx7ugtM''||'||chr(10)||
'''lhgKA9TCPPxTC8lJvmZ6jYoMm5RLqGWkIHpHXEUdUsaPY52to6eDn4uf02pfrz/4''||'||chr(10)||
'''UTijfPbn2HOIW247UxNPq4eHa+HvqoMn1sCp9vQPqX1zdW+UR06ud8Na98N1bpjj''||'||chr(10)||
'''j9c3cwU9m9m/u3Xa1Hx07YUHN3H4sj1nKd8kiXNKd9nSn5fvM9AH5RuNwa2zee8n''|'||
'|'||chr(10)||
'''j1VUR81z6QlCHTN/0F0MQWhm6dT1kLxJxFvO8Ws1wHEBY/JywXg5A8PypZJ9IS/0''||'||chr(10)||
'''XFkm3emXRDYDIlnD4Lc4/uADcxzjvkNed4hzmvXyonZZJuW+aF9eLCbfUjUMNFSk''||'||chr(10)||
'''lqOP2bhuVz6IC4a2ZDed8HbjWJK5fIlGoPTNZlTWESigSMQzzdoj/LB59NOv1/9U''||'||chr(10)||
'''zDaQ4TNxH+2x5ZKZQprH5fFrR5W4BpqFE1NbyssbWygv29iZ6znarANs6vWouDTJ''||'||chr(10)||
'''QKILoSJ0uEw5pNASaEDqbrC9ZjnURJym0Y6Ll10zsAdNqvi4VZSsVt77q74AByl9''||'||chr(10)||
'''QTkQaZq4kGyzickDEL7DmFoR0nF0qkXpRZQqK9pO1zz1LinEi9zB'||
'WUu4Qj1whY5Z''||'||chr(10)||
'''HjfY3XReMd4SmoymbezaGW4oeCcd7/OVyUoJYycOrBMXiMKT9NWMyRxmkX/iqHas''||'||chr(10)||
'''ezulE+9oAVAahdz13FC80nfRSSfp6Y8aXOvu13fWEXL8WwfXStPFbrd4ho/lOPg6''||'||chr(10)||
'''AxP0ZFOukXsCuXlNNNfTz3l9Y48j9cxwbrkb85wzw43VmI9jAY0FOBbSWIhj5zR2''||'||chr(10)||
'''jmOvaew1jr2hsTc49pbG3uLYOxp7p8e8VTfmrXCMcHiIwyMcHuLwCIeHODzC4SEO''||'||chr(10)||
'''j3B4iMMjHB7i8AiHhzg8wuEhDo9weIjDJxw+4vAJh484fMLhIw6fcPiIwyccPuLw''||'||chr(10)||
'''CYePOHzC4SMOn3D4iMMnHD7i8AmHjzgCwhEgjo'||
'BwBIgjIBwB4ggIR4A4AsIRII6A''||'||chr(10)||
'''cASIIyAcAeIICEeAOALCESCOgHAEiCMkHCHiCAlHiDhCwhEijpBwhIgjJBwh4ggJ''||'||chr(10)||
'''R4g4QsIRIo6QcISIIyQcIeIICUeIOM4JxzngcOa6QaP48nSyrxD56jfKK7YYNSYA''||'||chr(10)||
'''AA=='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xml varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC6WYbW/jNgyAv/dXCMUA2zgnF8vutU3R2w43DBhwNwxbh+1b4NhK''||'||chr(10)||
'''4tW2AsvpC9AfP0oWTdlJ+rYAbVxaovhQJEX1JBdZmTbihLH2cStYu11koixZoVgj''||'||chr(10)||
'''Mtnk8IIxn+Vpmy7MiLu0yTZpw/0oMO9CptqmqNeLu7SklzE//'||
'3SOA+pdtRSNGdA9''||'||chr(10)||
'''WjkoFUaqH6xsWcqlkekHIwuuHOMaea9ta9NlKZhckb11Lh7Y8pFtS7Uo6lasRTOa''||'||chr(10)||
'''p8YTja4X5qmNEO2eN+q0chzBZ7MZopp17Hr71msvjq2wKxyzo5tj53aSTJalyNpC''||'||chr(10)||
'''1otlqsTY6XuDhtY6g6xVHMYOrEq34mGRbrdlkaVGwxr2Ii2nd9kibRr+jLFGlVV5''||'||chr(10)||
'''dTKZgHDbyEzku0aw6nFRyrXPtotKrXuDmHZdoZ21FOuiNk4zBuRiuVsvKqFUuhZT''||'||chr(10)||
'''mInPVkMIX6W4EyW7/sySztGizu2yq11t6Nk2bZSw+wZelNmuEnVL4aXVmD1QZNL8''||'||chr(10)||
'''GgK1LLsNhN+NaHdNjbuA9mpgE66ZKnIb2WY'||
'qeEXrUaJdFLnPvC/fYv7XzS8XHhjJ''||'||chr(10)||
'''JhOWbUR2C7ZmMofEAXeyf75/Yz/Cx2p9qEoGP3qDrqyoLGrRRxYKjd11M94H/UoH''||'||chr(10)||
'''9wGx3p8D4gO5i69Mkq6q1kl8CHfN6eX5pKomj/Bhmw1P5lUxV8rDibUapEg3Bahq''||'||chr(10)||
'''dX0K3pwrcEOVqklVZI1UctVOMlnN5WpVZGKuto1Ic8N3yjz29GSUHv50SmHpN+ol''||'||chr(10)||
'''S3OWLyul3Z7Lago/tcx7z9flobdloVoawV8eEj83hEIfk8TTcaujQ4fGfdFumPZk''||'||chr(10)||
'''mrVCx5VxySDQdJL7g4AMWL+HOp7A+zak3DwIh1PGgQWTZo6X4E8XokpvhabwB9K1''||'||chr(10)||
'''aFG7KIX+Gr6vxT184RDfm'||
'he49tYlLaVKU0GUks1UCV3T9JLKNxaFzPv4t2xul1Le''||'||chr(10)||
'''mgdjuBd24Wf1rWTDCp1lMzadjk0tRb1uN363aMAmLDJzSim3NuQG3qA/PrDoyo4o''||'||chr(10)||
'''VlBbqIxAKe2rh/no9Ws4JWFX52bj+qHwDKIQ5a00++k7ywR2DDx8ZrN36Nz3IiT7''||'||chr(10)||
'''TsjVcFeKVlSdF0JwVgDTf1Jq/htEVe/NI5YE6KeNqHtpd2759nuayR3UXHAZC6bm''||'||chr(10)||
'''ODq4ve817Kpfts8eneVdkhy0xFrhzLQVdgo5KVrhynUlBXMjV6Yz/uUIfR7jRh+3''||'||chr(10)||
'''H/+Q9wc4dMj++5qQ5U7MjuJ2YH19V/pv9zgPwQp0+a/61O9tPVKPw27JI28dQjyM''||'||chr(10)||
'''hp7FUvl'||
'e3/YGf4Wm8IBfO8/evsaz8cize751CN7n3TgES97k3c6/sOjR9wNWPNnf''||'||chr(10)||
'''k2y9cWDbz5A4B51pSt//Vv1R89/AwUSVBjoFeCNuCsjyIZBbZEaMVD2l6Vr87hUs''||'||chr(10)||
'''pFsU3ark+enNKbUq01Po3E89bYvT54wIoaUEyrFbTbHwTawHvtmSYEp3JN3p/Om9''||'||chr(10)||
'''Zo5zdzKnCzyMp9kY6x4+DLNFG6fD8upQzncPgxn74w+VRx+O4qm5yRgtxm6cYd0x''||'||chr(10)||
'''2IGTfdXYMffXFuzMsdPZv8bAWnOQmU7GufqA2LTwPpubtiXU3/aoM1tla75pmITu''||'||chr(10)||
'''CJ6eXJinJ4/Z4Sv4O/cCe0PAeZW8031WK9nX3iJfBZ5Rbm4iZOk0g4MF4kQ2i7'||
'aB''||'||chr(10)||
'''G4Z+prf+HhQsvvjh+5ffO2V9IxLp2uMaeeJUl/27G+7+wF1Ou6C7jWLlF2EU2OAd''||'||chr(10)||
'''sXV3TH0cFmDRXLsIN77ojkLtJfCA8d1oeaty7Ik0z+FCpu88z2A/07XrTwi399ks''||'||chr(10)||
'''uv48NOZVs7ieNTL15Ym1Wa54YeAR5DdsvnWcCTRTJYlQJ1afZ9hJOXWtu0WPGhEd''||'||chr(10)||
'''Os0odHplZapaO25wRu0vKx7gwqH8hg6YUUHV62T9OmdOm9ep7ozzswB0QFhmOhLv''||'||chr(10)||
'''QcVoIXiLa2WBWYNlMi2FyoSvdkvdt+5NgJFOOQyjMNH/VwkxyA+Op/8shd7N90vv''||'||chr(10)||
'''heH4D6fwyNU1CLo6RdD7BVOUyo0z65BIO8TUfW9YbenoGKs6'||
'nlDmcjMObSdXzIos''||'||chr(10)||
'''Ck6cTOhkHGUxyWKUJSRLUHZGsjOUfSLZJ5Sdk+wcZRcku0DZJckurSya9bJohjLi''||'||chr(10)||
'''iJAjIo4IOSLiiJAjIo4IOSLiiJAjIo4IOSLiiJAjIo4IOSLiiJCDEwdHDk4cHDk4''||'||chr(10)||
'''cXDk4MTBkYMTB0cOThwcOThxcOTgxMGRgxMHRw5OHBw5YuKIkSMmjhg5YuKIkSMm''||'||chr(10)||
'''jhg5YuKIkSMmjhg5YuKIkSMmjhg5YuKIkSMmjhg5EuJIkCMhjgQ5EuJIkCMhjgQ5''||'||chr(10)||
'''EuJIkCMhjgQ5EuJIkCMhjgQ5EuJIkCMhjgQ5zojjDDjs2UO1w60bzrku8oMti65f''||'||chr(10)||
'''/wHhC2kg1RcAAA=='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xl'||
'sx varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+Vb6Y7bRhL+P0/RMBaglOFI4jH3jmHHB9ZAHAQeB8giGxAcsqXh''||'||chr(10)||
'''hiIFkvJoAj/8VvXBPkiKGh8LLJY5Ruqjqr7qqurqauoopUkeV/SIkOZxQ0mziRKa''||'||chr(10)||
'''5ySrSUWTskqhg5AJSeMmjtiIT3GV3MeVP/GmrM8ldVNlxSr6FOeqM/DPz87lgGK7''||'||chr(10)||
'''vqMVG8A/inYgSlkrfhBtd3l5x9rwA2ubXmvCVeUDytbEdzkl5VLJW6R0R+4eySav''||'||chr(10)||
'''o6xo6IpW1rzanshojcyr7yltOtoo4rWmCH+xWEiojI/g15UetWhLITgMycHniLm8''||'||chr(10)||
'''JSnznCZNVhbRXVxTW+mdQaa02iAhlQ9j'||
'DaniDd1F8WaTZ0nMKKxgLeJ89imJ4qry''||'||chr(10)||
'''9wjLSAmS10cnJ9C4qcqEptuKkvVjlJerCdlE63rVCkRQdRkq646usoIpjQmQ0rvt''||'||chr(10)||
'''KlrTuo5XdAYz5WdBwYU/Of1Ec3LznIRc0bRIBdvltmDomR35RZmyafiFtTCuFW22''||'||chr(10)||
'''VUHSu3Ud7dZ5Wq5n8B+O7YoEDUtJAHRVbMHoyorPhbbZijY5LVbNfctmSm7IQsxt''||'||chr(10)||
'''7qkk07JFEteiEeQG+vJbj1zr+E/KQeitwDQtk+2awhrkFP+Y/QV9gD9yyIRAMy66''||'||chr(10)||
'''FBE8ExYQV6GmTZSlE+K8/Cnwf/349sIB8cU/XCq6S+gGFSpkfABEpARcVd2HUYUV''||'||chr(10)||
'''+TQRYOxR9bUxJkHNyQ'||
'e/mN0prZuoXC5BXlgQZXlqRF0l7YD+EXkMwSopoWvXiHhE''||'||chr(10)||
'''rm7USqZ0GW9zOa7ZmbMf4qqAaCdMwqav2wtTgySaVBRiXEPXm7KKq8eJgOqSptpS''||'||chr(10)||
'''qeM+lCCZN4zQ7lX8yuITrZqmRC6Smzaw/3GFYRwwsOUE/63jXZ39RQ+YZWA7aLxC''||'||chr(10)||
'''e8Bwy5yVNU8P4qVbxkEThDGMjrXWFxxBGtw3dW/hPprX8qddq2VFuzZojhWxB4XU''||'||chr(10)||
'''gtPe2LpdG6GVx+VCOgd+3ZS1/KoH3jYZsGKt6N42eVTFD7MkBpNpyuguK0BsueFM''||'||chr(10)||
'''FKx6ewc5iIpqjL/kO3VbQnnWQJCOAEgWF4MbhjGKEc1WQlTmH48NrfWdD9cy1GEB''||'||chr(10)||
'''q1FM'||
'UmQD47Iq1x2UjP8gBpd4SqghRLAZR3G+5Ghwhzb2XiGZhmhQ+rhOsmxClL6B''||'||chr(10)||
'''mEtOPGZyJ+QsVIZ0TIpP+QRypYE5PkjeToM/PxD/zCULMj2cRNAhcXbOaQzoAfwp''||'||chr(10)||
'''WmY5FVncJvor22xoqkxXJHEbNsrMm3gyp9Qlhmd89wP7XG9Y27X4nuGOrm8PTXSf''||'||chr(10)||
'''9rUu875WWiRlivuMSrcXU9mpede1sUycrb6ZGWmJDhe15ou9Iy/LjfT1XdbwvZ3T''||'||chr(10)||
'''+juoWE9z1BpoxFwSumI8Jj33ED4hwjxAOnG6CH9cnC7OIJ24Jicn5A0MgQQzgXBV''||'||chr(10)||
'''Yd6fQVoNYx9Jna2KGBQrN5EWCf9wIrc5TJRQXLG0LCsTkspsS8tDOpmWzLP'||
'E5HZN''||'||chr(10)||
'''gJEey/qxHRPvDAAeS1mWoJgMFgJUNJsNz/fV/Ath3prCQX7p2ndZE8VF2hvYDIqe''||'||chr(10)||
'''qyQ/JpcYBTSdL0TydtNp7EvUNFMDJagdky3XtlleSMPIazo06dfbi19ehcE5n/Tu''||'||chr(10)||
'''x/cQcVK6gVSdQGtvisuSaeVlN0wJmXdRzEBeDPZo9MP76piORndk9bgjK9fq2b8g''||'||chr(10)||
'''42mETlebG549YeYeLq6m+uFRAwuNYWPU0BXcUPgsRM9yvang7EXB91gwaYky70O6''||'||chr(10)||
'''6qhjsWVj1Bq1Sy62DfAesM654xLnX46BHKkQ5N8GifmyzFNqWkXPWQoftFacC7lO''||'||chr(10)||
'''80jamG/NYr0M/MTIgUxT7UQNAWrMS03r8RZdl1ws0FMRI'||
'l3msgTSo8F2kzh89ULf''||'||chr(10)||
'''Tjpxg7oyBPDeXvyIQmhPIAP1CmjD2NjUt3a82LD8EYgOmaF7mEe65GCDXAx7BsRE''||'||chr(10)||
'''b7iv1d8xCQaHHY/EgZaEf84X7S1YFa8EWU7xxYQvOeE3O9gcwWhp3vE36+nP8mPg''||'||chr(10)||
'''gNsIWx6VOcLBJomb8d3F1Drb8kCoVx9eBf4TgpjUvZVN82gxHYsrhz57QmXfqQZV''||'||chr(10)||
'''IZnO8r8iJYLQlj7rO3n9ovX6j/eUhSasJ9XQD2qYFCWRIkHGOv2OEWFfaYLZTbcy''||'||chr(10)||
'''8V3cn1nEHr/+f3fr9kAOyu4aZ983Pavdn4OMYTByH3KQdg4mGSwEyQP0cjhRX+xf''||'||chr(10)||
'''TE7wJCyM6FQ75wcrgZCnxvbMuMFq0hE'||
'/LqZlws99wIAZOKvdR0VllwOQ2pE2pFYn''||'||chr(10)||
'''brOXMuzoV+W22WzBF7KC1nFVxY/ayOmRNAJ+DXDETp1NpF82DF0W4NWKd7kIyV1Z''||'||chr(10)||
'''5jQurOsIahT+xZg9Bf7dks8Ss3kjrMty3XQ75B0Kux8yr1+s64g9HLmOs7TWSOk9''||'||chr(10)||
'''aIw9fYKn3V7135bU/c1Nf3PPTZdQRCUKRUJZPfrraUu6TVXVbStq48ppyo5eu3Ve''||'||chr(10)||
'''1DfP7ptmczWf18k9Xcf1rIQEAHrggLqOG/hareY17ClxylS2zucw/2y+jrPimSOI''||'||chr(10)||
'''D9bmsc/f05n39eVZ3cj+3sn6gGD/APvWkbeu452tOFkHkfdMDvounlF/++n2N4dM''||'||chr(10)||
'''W6TtpskqrrIqJDwcT'||
'iK7fP5QVn+CN/w5A6kcWU/VvAlI5OVDW4Xc1Tm756rrspqB''||'||chr(10)||
'''eWxpuZwwZkCuJdZ++KWav5CkHJev7bQ9DeHGiwciT8mcq4KxzqmmeMeHMOoebjz0''||'||chr(10)||
'''8D8tFyTYFi4WWLiwKs6yXMS4YpUIt9a2YKH54wRoHLMKXK9srRZ0+hmkGZy0C7On''||'||chr(10)||
'''IO6L6ipLES2z5KvqEFsul8ssoa9F3Zsbc0VzdldZ32eb+plD2mKZFiW+kcRIy2mL''||'||chr(10)||
'''jGI7IcYsLLRz62IG9yTTq5vHnNaW4T3JAhiFW8Q9h3D0dg1GwP9+OyvAEPhVSuTr''||'||chr(10)||
'''+QoEb9cKsusJ3qmxtJqxgIFpilp4rsoLKLU5ZL0eHfL4aA2Z2qVCYxfb69Vj1sE0''||'||chr(10)||
'''/S7'||
'lRThMwcCdzeqjaTcWZy80p9ndp/u7z/Z3n+/t9v1O9xfaHb6U8duynu+Wc6WR''||'||chr(10)||
'''b2Z9IgtBf+by6jBmdAd7R925SkNh2SLuXULpct/Fs2EHo+ktz0cMBwfTL8rGlKvG''||'||chr(10)||
'''7E+yOdKMFRML4LaQEW7Hvnp4suzU85+6gnUzr7PfN2WdYTCdTJ/fOOTzZyIKshPG''||'||chr(10)||
'''+wfOk0dS6HRIDCKqOViKN2fxeXyCmM1n/mHYBPOR9gJiv020+Ft9CBay9ekGZqlO''||'||chr(10)||
'''SyMn6iOcfbdwpPi6LWTm6Gc8VkRtOaENihdMjNM/MY7/xvCvEeWHOd52T6aOeeoc''||'||chr(10)||
'''l6krlUz3xs1tv0jVvOkXii/qvw9ZVN9Y1Z61HVKk1QJG+tQwAifSf9s38G'||
'Y80dv6''||'||chr(10)||
'''6sx9M/RvahxPzg8IPRHkR7WR1c6wpQ1A5l2WluVxez+y76wm6mjbMQy1/TpXLA60''||'||chr(10)||
'''Q9HlrzDZuzLjg9A0Nhu79FNo2YneEMWenZ+fJa6MkIJn6hkcQ2hDVSMeqyfirwgE''||'||chr(10)||
'''LKjNWEWEW48lhZzcHkrwGEaGRJ4qXuMZFlt8jNof9NzX+Pb7i3fpzTODm8jcuXqe''||'||chr(10)||
'''/TF/8TGuVuyAcPhhchMnf8YrujfzPnxbFOIhYEMDO2tJOvtcJ1zjWfJpByWmE35E''||'||chr(10)||
'''eg2LOodl/2/ufka9+ZCdLxBbH9FQ9+1+3KOrQ0JlYIVKK0x+XUwPXBACg3pixfKv''||'||chr(10)||
'''iOSdOI5lnS/ZA3mkZofQTh7SUmakc9gT2KQK8GifnYXn'||
'B+Hp2fnFpdON+Q2PKtrr''||'||chr(10)||
'''N0+Z20alFSvQ1+wFL9boMsqdCV96JmvV8Kmz32IJ7Os023RostSiASt2asdkdt+5''||'||chr(10)||
'''CGBjERduMmVjZyADs2T8nuDyTeH/yXSmXmDHstmtc33AHO3FdjMzANfmdb5JN27J''||'||chr(10)||
'''x97cWVteC/S80gMEMe5mBZZ9b/kXKm6HMN5u89gltKrK6n9LUfDhQHXYL42yGirS''||'||chr(10)||
'''sDTcEcJ6XJLgq/AsfFpn/zeO8Sr23oeltE0VF3XOzpeSxqz1VffkGFfp9aV8nMPe''||'||chr(10)||
'''CmFvJGiU5fWh4OC5vWKf4KYxyp9tJm/gccYlgXUY16Xz80+30c+/vn/z4d2r6NU/''||'||chr(10)||
'''Xn54+erjmw+3NzN3lEPHD7C4/nUhpO'||
'6EEHk+0a2dbcNtaaAtAhiGxKusxsC+Ed/C''||'||chr(10)||
'''cV73OA4TWtZ9uxT72Awwoq2vlRwFbCYn8C8vKDuvX5+8f3/yT3icKTlGn+oK0+N8''||'||chr(10)||
'''T2QXILtFhx3Ld8CLT8iZ1124/kgwIM6Ykn8+KDppPz/itaKONnqDU6ete4SzW+zv''||'||chr(10)||
'''Y4UjfJhRsNMGP1A87//RiMglFDqckcd1M50ts4rflciRUj89gy0t9qSL4gDYTtmX''||'||chr(10)||
'''G4qylRgtXa7qvMdl51QoVe+KNpZU/WdkcxG6ClTyWswRZKKBZNnU/sxSSma/YaZp''||'||chr(10)||
'''zLc0NlZ0aAUGHUilJQcGHWtpQYn9y9mqCw4VA9ZOOuZu1ydkroY8u+Wf4TyEiebt''||'||chr(10)||
'''x0bGwXn7wbEdtffZ'||
'Q7onoTnM+fd4yAHrrbzkC9a8b6X7nUUTfXx1e8KZGYOf7C0m''||'||chr(10)||
'''0EED6IHZv+K9C9aDrz8wD78e01PGmc7YyxSt8e27sBmO6uIVq/aVHf4ahnynRN5P''||'||chr(10)||
'''d3/BCWyv8JSIlSDtRQ5oZq+fTK54teRKFr8YF1FRYrfcFAsanz/rkD5/dogolS3h''||'||chr(10)||
'''e+pMxTsvct66/ISX401JXrXiTOqpw4izX2AqMcVLYlFZRU21xfcIqdY76SAC5tHf''||'||chr(10)||
'''3r/8xektLiohj4xrHfs3q2w1bF1plRUMSNlykrneVGynFjb+21qsxmQg0RWqSC5/''||'||chr(10)||
'''xot2qCXQANOdxV6QtDURp2m0pixfHIY9kiW7myhZLLyb56YwB83ycZYl6vjEgrHL''||'||chr(10)||
'''Rg'||
'YOQH7C4gvF6T/OkAjVFj1RJVmjDou/GrZqrnbQNYhpwdeIRV22IhBVgy9UmrHu''||'||chr(10)||
'''VD8sMtJcOIhOQANLOu1h02RkRHe+zyVlnNM6oRNx4utMmBgHaNdzQ/w9uSuNvHe8''||'||chr(10)||
'''Smld5+P7S2dkuEzhXSdNT9brk0d4yP29H16ts6u6dqZT+SM/+YxuDkIhHiqExWln''||'||chr(10)||
'''X/TVSQ07FKvN2qat+QrjSLzpkeYJvM2XbYFqC2RbqNpC2Xaq2k5l25lqO5Nt56rt''||'||chr(10)||
'''XLZdqLYL2Xap2i5Fm7do27yFbFM4PInDUzg8icNTODyJw1M4PInDUzg8icNTODyJ''||'||chr(10)||
'''w1M4PInDUzg8icNTODyJw1c4fInDVzh8icNXOHyJw1c4fInDVzh8icNXO'||
'HyJw1c4''||'||chr(10)||
'''fInDVzh8icNXOHyJw1c4fIkjUDgCiSNQOAKJI1A4AokjUDgCiSNQOAKJI1A4Aokj''||'||chr(10)||
'''UDgCiSNQOAKJI1A4AokjUDgCiSNUOEKJI1Q4QokjVDhCiSNUOEKJI1Q4QokjVDhC''||'||chr(10)||
'''iSNUOEKJI1Q4QokjVDhCiSNUOEKJ41ThOAUc030pl7av07Q3ZcH49R9muL6fzUQA''||'||chr(10)||
'''AA=='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xls varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+09a2/bOLbf8yu4wL2QPGNn9cqrnRRIG2e3uEk6SFLs7idDsZlE''||'||chr(10)||
'''U9syJLltFv3xl4dvUpQsx04yu6hngDoUeV485/Dw8IjemeDxNC3wDkLV4wKjajEa''||'||chr(10)||
''||
'''4+kUZSUq8DgvJuQBQj6apFU6oj2+psX4IS0iP+zRZ31UVkU2vx99TafqYRwd7B+I''||'||chr(10)||
'''DvPl7BYXtAP7ytsJUExb4Qtvu53mt7QNvtC23luNuCL/BrRV6e0Uo/xO0Tuf4O/o''||'||chr(10)||
'''9hEtpuUom1f4HhfWuNIeSGGtGFc+YFzVpDFPZ5ogoiAIBKsUD8dXpx6kaFPBMTTR''||'||chr(10)||
'''wcbwsaxlnE+neFxl+Xx0m5bYFnqtk0mt1olTFZG+BlXpAn8fpYvFNBunFMI9mYt0''||'||chr(10)||
'''uvt1PEqLImohloLiIN/uDAakcVHkYzxZFhjNHkfT/N5Hi9GsvJcEIRBdBsK6xffZ''||'||chr(10)||
'''nAqNEjDBt8v70QyXZXqPd8lI8Z1D6JN/pvgrnqLjdyhhgsbzCUV7t5'||
'xT3tEiLUpQ''||'||chr(10)||
'''LRgzycfLGZ5XTLUGA5gvLv/RvNCZQW+OiaZOpztal1JRbD7F36siRZPbWZkvq8Wy''||'||chr(10)||
'''Gk2zOS6JoNJHrWdvp8DVspiLqdwBliumvFyJ30KDrkC0wZr/avQtL77c5vkXygZt''||'||chr(10)||
'''IfOB1DRUo9JumOK58fcs/V5rG88r4+/74jarUJF+I4ZOG26zu7s9RDBPcTpneKrC''||'||chr(10)||
'''oVfVqJot6ECtiZiP3QRGHx4FiQ5SWF1ZGQppIWlSwIoOZOM1aIDIAMcRNoP5fscG''||'||chr(10)||
'''8cG07W5W1Ro5AtKdPDVQ6MrUhgbGSQgCj1Oo0DAqsfYwJG4HNMz7x/Dw4vofHy/D''||'||chr(10)||
'''aC/ydDFS1QbRGw7M9l/KV/eRpjk73HsZ0GpOVMPR'||
'OClsoAShGg0AjMvaaHvRkQps''||'||chr(10)||
'''dQVno3xNgdPJaDnPxvkEj9gCtcO8DBlN2k1llJ6H6TS3WnAo6NtDRnhl5vEOBdA0''||'||chr(10)||
'''zfMFdVMou0PLajoisHaJsYzS+cQXltNHD8Qx5IAGeUHooR7577jWyOBUD5g5PgLQ''||'||chr(10)||
'''Z2TARPzK8f6CIoJbYCKGe189+NyoeqRXyKAQv0kGgSMifvZ2t1zeEmZ8zWP0UdTn''||'||chr(10)||
'''7uJX7hV+Bc9p0hV/CAIglzjID58ubz5efh4K+D3xRRKsJMa+/PhB6czCw/kuATeq''||'||chr(10)||
'''cqq4vqReUUWo7wtOe33knZyH+59vzsL986HHvDkFDwKg4OHLoCaFFXDJf39FkQQG''||'||chr(10)||
'''bRSYJQPZAf4mHQTUcVpWwMNtNk'||
'+LR6FsfmchR8CZJDmrqikekTUqI85Hccg8LcHa''||'||chr(10)||
'''CjVUUBNtMOjAqqGMrYEJgqiNBqbkkgnfiinG0xJvcYr7mi63zHYpZ8i2AFshAkUp''||'||chr(10)||
'''+Kw7/qciu8mauljSMxuS045g1dRUr0Ght2YXP21iM5voMl1C6Vfpd0fdFmuXvj7B''||'||chr(10)||
'''5y4nQQZZfwn1u7sO7QZSpcqp1UsCkzObz0nA77MHfQdrBBAJEfogJXN9o3reM6gG''||'||chr(10)||
'''PBrd3VwIx+z2DposNAQi5Ecy5i++RGybCUF/8QWWemCfx99iBwrBgFz3+bMxbKdI''||'||chr(10)||
'''9yonzPn1td2WCICnWkgF4gUxFYNgmsQORMW8IPKona80oBo6Bt47+3BGP16L4ZBV''||'||chr(10)||
'''LrHxxi+ENwhs'||
'zEE75km+JAGkX9M7MpB9vD6buWa8NsZwc4wdxNAuiFAKguqkQzOJ''||'||chr(10)||
'''7kWwdwDY5DvXRU05WSLEUE2yiKm90o6xZogdZU6f+0QKA/I/9PP63unp4OJi8C/y''||'||chr(10)||
'''8WBlowil7XAzcgGIAUBQByBoHqB95iQle1bUPb67hb7jO7pBBeZE3P1AHhN2wWfs''||'||chr(10)||
'''hREza7KvfKzwiGxNcGHnE8hDPCcRPAneyR9qvxKIoWX5b5CDPgzBclviMXFNqMz+''||'||chr(10)||
'''jUVH1tPZ+SEvKscQ0vBxUhuyI5y/6CB6/i9sVNhjsWHC42xibZj0zo15FNjglGml''||'||chr(10)||
'''YAh2SVu90dmTcQOSjoLkUMoLWB0R5a/SbE7kzTMI3D/jdKa3wPpYJ8zeOiL40uO5''||'||
''||chr(10)||
'''HjQenRUYj67x+OMpFR3BVVYpWdWs7MogfAuyh95c9H00Sx8R/p7B3n8OWo7uyNar''||'||chr(10)||
'''j26XdGs9zyvI5lQ0QTV/RIxghnQ4n4w+3Y0+PBC2OPJGxBFFfFOk2RT0ivUmCFP+''||'||chr(10)||
'''dQxAGNjrkxuNlWaQMQV5zWROSF2WeALTCjzwmUin05wl05gyMAQXJoZGBEkLghnx''||'||chr(10)||
'''dKRbEx4xL6cfr0bD2aJ6NBCx9A7gsFdzipEOUOOvocc9Xjk+FOM/l0AZG6WDoaq2''||'||chr(10)||
'''EkxkgVHzDVDO8/EX1IGZWECBAe+JrykVjN+LfIELIpMVMBIBQwxQIK5yopcdyNgT''||'||chr(10)||
'''IOgAKRMt88C9oytwBW/aR8Rn9mWAyvY2chQYCEs0wocoQj0K5D176'||
'DeAVO+pwjzW''||'||chr(10)||
'''kwY2h6T/XwxOToMPZ2E4DE7C92F4MlRJDPavvTrZS47h7wmvNOT6pi/ddTqioz7s''||'||chr(10)||
'''Gszd1dmQLcnGsm8uyhCua8v6vWynyzNfWjVyjt1wTLa0NQlyb3qkynjV9gjunl5d''||'||chr(10)||
'''JnR5Ip0W+TeIyKJ+56CtLq047LM9lsGbCM/5WrgtXHEjLuJ4iLZDRNDFTSFtFxPA''||'||chr(10)||
'''LiYMjmB3Zubb5KrcYTvaTPTBAQlnMvQLSvqwbbSJF7uN72QDShVTYj021je5aYO1''||'||chr(10)||
'''2icAe3yDQzvb25RtEb9/1Ey0yFVyPH85di6NLpHmbX6Hqid1P3S/Curzi8Ki75nN''||'||chr(10)||
'''KWRdyQaBTCT3NwqvEhz7l4Tky3nl95gU15ePCCL'||
'ovAJRrXNr7k83mxmBedCiTgqh''||'||chr(10)||
'''ZhaQZLpdZtPJqkABxPqHJlZDXg1G8pQZZfPxB8uEdZjU0DWpfE5fdUq7iBtC4UGL''||'||chr(10)||
'''0Ldkri1E/4nN1T2zYmr/ROaq9I01tZjbJCsoUhI2Ex++vSlO/vM8chgdNk1yx2Rv''||'||chr(10)||
'''+4wC/F/R/p4zOJBJQRp+Ab53Ynkw4yy61eS0dDltqFMQqjwvJ0RGZGayUkux0oC0''||'||chr(10)||
'''E3sHNBpn42igoG9vdix2kJrLMXle4QrPFiSULR59ufsmBBZLrJFmJBq2NCtheNBm''||'||chr(10)||
'''a1vWgTBqtWxdCTaxwT03T3WtQppRarJtMUxUMxJjMtPFArNjXzGH69msRgS1W000''||'||chr(10)||
'''Lg2Q/k5r1kfUMu/6edjLs15LO'||
'fX5BkT8+0QZrCsE08QlmVWRzQzzo5poKSd1Q1Bl''||'||chr(10)||
'''wc+OPLdWaYU54pyDwGwiwYD8fjtQNR8ESYY1PVBtnv4Ermh9dTWV1aWqNp9bNNf1''||'||chr(10)||
'''jNXSUt1QjdM96AeL0ubBENM7yXBWtmkAzbeEZu5DDr0jEVT7YDvH0YaY5QPXw8fH''||'||chr(10)||
'''mGhoYoen1ES1oQclgLDi//P8mp0l6qcUsiYQHlCjlPbGU2qQIpN03ONKJdRkT6A8''||'||chr(10)||
'''2JF0S8yXOZJ9IJdNorHlfCIONIs0K7FRZomLIicKOICC0rgP4yuUoq/pNJsA9QOA''||'||chr(10)||
'''4WmWKfmWh/ihrI7ia/gqyhnXvi7r1uN7u4bpKDiEJBx8SJz9/tMZnbh1yiegbILE''||'||chr(10)||
'''p76Zgab5Ugr'||
'y49nZnr4auD7WYXSwrw0+XDW4tzbJ+zUx7MlKD7FKIFYzy4uAlXKI''||'||chr(10)||
'''OspV9QmWhI4d4tHOaV6yPGNFxYjywHoGDXq+O1a6WUuyPU39TrSzCq57ryAR07ut''||'||chr(10)||
'''w8CZKhG6vr5xrNiyOp8yViz1ml3WRoBZbeo8Np1MqE/2aam0cZwngmN2NqsXX6N6''||'||chr(10)||
'''4dSCb9M6lCCuaUpPqUJEzgIqtFo1RaeX1w8uVC7Q346bJKlRaTCmVTXZJQwrCytX''||'||chr(10)||
'''l0GZrsaIpI3dw1q1Va7SLArSDIQbCq2Mkj5+XGOpaX3cepVfh4pCEuTpCZM/arVU''||'||chr(10)||
'''T1KRRCE4XFnKogeuymxjIwLn1WHrh95GSVondXVUqkXaQ1metwJX2A5STXjnSupD''|'||
'|'||chr(10)||
'''VyX1odfkEZQoIytUB1/6QsJcIU7TyCRljUWAnWWVuGSVdJBVYhEPa8zmskrW8JOA''||'||chr(10)||
'''8TcUtPlDThT7QrxMdJQc7R9ER/vdnI2ciKRxIjiGxolwvGSga3vJs+VWspxuXtqs''||'||chr(10)||
'''gmkAy4tTItw7P90xEsqfGoIcqtjVf//p8+Vp7/rvw6EjFtnY97Pjdoh+6/q3qXM7''||'||chr(10)||
'''4DWYq+qK26t2Dx0Fu/B6ym57KpoXxmrv6PQcOrUdFl010s3chHqEut1XVZBW1dtA''||'||chr(10)||
'''wJFR9O/Ic9Rft+kyS0f2LD25AtrJhKqCJg+2WAVtOI+uikVJcJdDO4rDGUzuT56o''||'||chr(10)||
'''ZmFHR82xlb78VnNz0Lq5g4oi6aBECaythvJVwo121SHbTG5McDhk'||
'Ky/UN366ujj5''||'||chr(10)||
'''T/Ol8VZ8aVL3pfBq4ys70bhTyLbat+69tm/dfx7fuv9f4VtXKNp6TlW8+Otv4FHb''||'||chr(10)||
'''dE4Jj5DsE22a88EEMSFzAglj8eop/8CMmL1msy69Hh/rvbbg8IaB9ND/PHsGZyfe''||'||chr(10)||
'''lPblt03LT9bwBRvIJYm0HNbp8PeTvw2fZynwkfbWkkjK0aS6FwbRgQfvJgWHgpaT''||'||chr(10)||
'''xWKK0VU+SwURkLGbT0tqIMTzjjLiwOhb5Scfrj5dnFzSTTevwdfKjJ2vMUr3Ld5M''||'||chr(10)||
'''lzAaszu66bYm8Kx6SmWZYcKDjmKJ6w/32h7utz08aHkYRdZDu9bGUlVHoR6/Z0Ar''||'||chr(10)||
'''HhXgd+mLEKWv6X5G1w6YKp0K67ktJiFd+hoSvN'||
'+i1wJpURujTtCmTYMI8krU29WT''||'||chr(10)||
'''Ns9warT+uZF9KuI699noYCcMjIMdKgwNro/0axHMAnzuer03HrzuKPuR76SpL9rl''||'||chr(10)||
'''qlTy82T23PDS3YGJ2Sp7bGNhAIMLT+qUw80ngnbZg2DUHh8z4iyjt6r9xZ0MWr6E''||'||chr(10)||
'''XWayO8FTXGHZBveY+PxfrnuUc7kVMnUOWvlYea5Ky/lMjmVfLYZ7jfeWV5w/6OFR''||'||chr(10)||
'''h+Ox5zkgo14a7p2pB4evcTLy1NX1YEjfEKLv1PyfayXaaF2lGyzpn58YYex1i/zM''||'||chr(10)||
'''cACmZlfdtwXL6Kn3tv6cXZ1F51C8Vaq9+dycRKJnPA1bBgfuyxpu7Tov0qE7TveC''||'||chr(10)||
'''P36+CE47YdDc0z0tfmLJWdpI'||
'tzz69QHEaz1bsE99nc8walE49Rn8EigkJuaplhHE''||'||chr(10)||
'''0jIuP1+8H179tI4WMu13w+va23Z6tz1DehbyftrcS9ncvowUIen3+fzkOYzO2Oit''||'||chr(10)||
'''OCeguzW2CaT3G0CmqU9fqxVXVUhZON8CZaJl0229A8qvQ5DjHZb6kh6iXgbS7iVe''||'||chr(10)||
'''1U/UjxnbfcUreAtHEuxlPMY6PuN1vIbtM/S5bLg9psE81fxaV5jQHfGn8+HJpear''||'||chr(10)||
'''3GpyrauJ7FOq+1jFC9YrqToSTsO6wcU7Ozm/Hno2jd7N1WfSqlfmvKyerKsrr6Uv''||'||chr(10)||
'''Lp3R5jyy5vzqSh9pbM5ql+tAzeDN1cfLv0FiZ7acpvrQzstYSwlecCDDSIbIEKbh''||'||chr(10)||
'''cY06RU3a9k'||
'0Wzyd6Ww/z6ZZwr6eVRhklI6VDSeLrFSVupaRv82O5FRNs4RIVM7YI''||'||chr(10)||
'''V3vI+rFpXZcZrPZjsrh+TGYQYbrg7geeYGvjBzz+QoLIyxuasc0JdQW9ZScdsxsU''||'||chr(10)||
'''qlLHaZdoGqeXjjkV8o5rtLeVM7VwZ9YzUZLsqqsOvprYq9tbMz/CHCt0crpTeyGq''||'||chr(10)||
'''UUCvAiHCxfQKHJ9x0FtXfZz8e7U+P9fADmug47UmbcY22Yklctk6P3k/PH+e5Ifm''||'||chr(10)||
'''RFYmKK6Nnf+mRWBdk6oM1bE67HVukkxdNl88s/Ypa1dlvbQ7/Llr6bpr2Zqxnaq0''||'||chr(10)||
'''x5UZJL6Uub2IOT1B+Tt4ghc0jZ+28Py2cHYqbYEuPPKNri0aQ7tW/Rkzu+6Isaye'''||
'||'||chr(10)||
'''POsH7QWq/01J5fdKoy4+nz/DKefLlFPKwpjnwaIHmh3e2WpAMoi6YDEvy2lfFPZo''||'||chr(10)||
'''RckvCEpzBmJ96EORiRmmbZAlp+tC5/rCrWbJW899KV2xfda8pdR3d8zN+ew2/5UZ''||'||chr(10)||
'''Nyi9lCPhWFvXqbZLTVYmmiwAVPVogQ4rwpH1RlZ8xUBSCfD+U8J/b/cuK8pKD5D4''||'||chr(10)||
'''BDr6kj/GPTXNchD4hUJWFmsj1OVU1q+twJEW7ycK5Ar3OTElorBRMwI1IuzV3xZy''||'||chr(10)||
'''XUph3ZqAj7HGB9Ujp7/gJNRu76dSiCwp1CVgUES4E0IYt744bM0MEYpzNij/37NK''||'||chr(10)||
'''a+gkHXaVtVH+ZhGhSA6fRnLYSHL9BWV37sbBifZnoyI2ToFSxM7'||
'T4BJ+TR9XS73l''||'||chr(10)||
'''hqeOemiS75oSe6FwTYIt41pRb7OzsqoRHBWBvV36O2hSA2hf/ZoXAV3cYM9/Hg3z''||'||chr(10)||
'''O+lFGr7+Y3kE5BvSNhJ1hfwH1kgz/ak4/w29E6b/RtRY0mWAVx7Sq2TwpI+8Hz90''||'||chr(10)||
'''cn/88BCvyGQ3vIj70MW4Wf4VbqCpcvRBkuOXPY8Cpz92p8jklzON8mJUFUt4XQJr''||'||chr(10)||
'''T/0aRwT56H8uTn5nwMyXNXQidzQlqGo/D8hWG0tWWn0qGHd252f9sMcXRos39nte''||'||chr(10)||
'''UJSZEYregIjE1GasMhOkRCRAZWeh5yBtScALyTNMV/pmtnUj45/+YjQOgvD4nUlA''||'||chr(10)||
'''Y88IelokuTvPKdjM8bCBhTUmkwuCXdguf/aBU'||
'q8WIF8VBmtGyn540ay0rTk1A5jm''||'||chr(10)||
'''3KRW1FFyx1D0bISmp9kLdFCMGOIryLg3+gXfJnDDb7ITzXGeTnE5xj6PoGoDwAGp''||'||chr(10)||
'''rWQ/7Cfw05t9oaTO/ip27Hs3F0feiu4i2O17k8lgNhs8kg96eIiSN7PsTVl6vZ5+''||'||chr(10)||
'''2GD6OW0x4kIIQQj6IYHp22032WwApV832h1Nzyk2FPZ2NI1mbZFoi1VbLNoS1ZaI''||'||chr(10)||
'''tj3Vtifa9lXbvmg7UG0Hou1QtR2KtiPVdsTbwkC2hYFoU3yEgo9Q8REKPkLFRyj4''||'||chr(10)||
'''CBUfoeAjVHyEgo9Q8REKPkLFRyj4CBUfoeAjVHyEgo9I8REJPiLFRyT4iBQfkeAj''||'||chr(10)||
'''UnxEgo9I8REJPiLFRyT4iBQ'||
'fkeAjUnxEgo9I8REJPiLFRyT4iBUfseAjVnzEgo9Y''||'||chr(10)||
'''8RELPmLFRyz4iBUfseAjVnzEgo9Y8RELPmLFRyz4iBUfseAjVnzEgo9E8ZEIPhLF''||'||chr(10)||
'''RyL4SBQfieAjUXwkgo9E8ZEIPhLFRyL4SBQfieAjUXwkgo9E8ZEIPhLFRyL42FN8''||'||chr(10)||
'''7BE+erbv0P2Gtg7jiTPEAH/1/2xztCvoeQAA'';'||chr(10)||
'--'||chr(10)||
'  procedure log( p_msg varchar2 )'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'--    apex_debug_message.error( p_msg );'||chr(10)||
'    apex_debug_message.log_message( p_msg, p_level => 4 );'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'begin'||chr(10)||
'  p_browse_'||
'item     := p_process.attribute_01;'||chr(10)||
'  p_collection_name := p_process.attribute_02;'||chr(10)||
'  p_sheet_nrs       := p_process.attribute_03;'||chr(10)||
'  if upper( p_process.attribute_04 ) in ( ''HT'', ''^I'', ''\T'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(9);'||chr(10)||
'  elsif upper( p_process.attribute_04 ) in ( ''VT'', ''^K'', ''\V'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(11);'||chr(10)||
'  else'||chr(10)||
'    p_separator := substr( ltrim( p_process.attribute_04 ), 1, 1 );'||chr(10)||
' '||
' end if;'||chr(10)||
'  p_enclosed_by     := substr( ltrim( p_process.attribute_05 ), 1, 1 );'||chr(10)||
'  p_encoding        := p_process.attribute_06;'||chr(10)||
'--'||chr(10)||
'  t_filename := apex_util.get_session_state(  p_browse_item );'||chr(10)||
'  log( ''looking for uploaded file '' || t_filename );'||chr(10)||
'--'||chr(10)||
'  begin'||chr(10)||
'    select aaf.id'||chr(10)||
'         , aaf.blob_content'||chr(10)||
'         , aaf.filename'||chr(10)||
'    into t_file_id'||chr(10)||
'       , t_document'||chr(10)||
'       , t_filename'||chr(10)||
'    from apex'||
'_application_files aaf'||chr(10)||
'    where aaf.name = t_filename;'||chr(10)||
'--'||chr(10)||
'    delete from apex_application_files aaf'||chr(10)||
'    where aaf.id = t_file_id;'||chr(10)||
'--'||chr(10)||
'    log( ''retrieved!''  );'||chr(10)||
'  exception'||chr(10)||
'    when no_data_found'||chr(10)||
'    then'||chr(10)||
'      raise e_no_doc;'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'  if t_document is null or dbms_lob.getlength( t_document ) = 0'||chr(10)||
'  then'||chr(10)||
'    log( ''file is empty'' );'||chr(10)||
'    return null;'||chr(10)||
'  else'||chr(10)||
'    log( ''file with length '' || dbms_lob'||
'.getlength( t_document ) || '' found '' );'||chr(10)||
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
'      apex_collection.delete_collection( p_collection_name || i );'||chr(10)||
'    end if;'||chr(10)||
'  end loop;'||chr(10)||
'--'||chr(10)||
'  if dbms_lob'||
'.substr( t_document, 4, 1 ) = hextoraw( ''504B0304'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLSX'' );'||chr(10)||
'    t_what := ''XLSX-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xlsx ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  elsif dbms_lob.substr( t_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B'||
'11AE1'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLS'' );'||chr(10)||
'    t_what := ''XLS-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xls ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = '||
'hextoraw( ''003C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'        )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XML'' );'||chr(10)||
'    t_what := ''XML-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xml ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  else'||chr(10)||
'    log( ''parsin'||
'g CSV'' );'||chr(10)||
'    t_what := ''CSV-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_csv ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_separator, p_enclosed_by, p_encoding;'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'    t_rv.success_message := ''Loaded a '' || t_what || '' in '' || to_char( trunc( ( sysdate - t_time ) * 24 * '||
'60 * 60 ) ) || '' seconds'';'||chr(10)||
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
'    t_rv.success_message := ''Oops, something went wrong in '' || p_plugin.name ||'||chr(10)||
'         ''<br/>'' || dbms_utility.format_error_stack ||'||
' ''<br/><br/>'' ||'||chr(10)||
'       dbms_utility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could imagine''||'||chr(10)||
'           ''</li></ul><br/>'' ||'||chr(10)||
'           ''try running this plugin in debug mode, and send the debug messages t'||
'o me, scheffer@amis.nl'';'||chr(10)||
'    return t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.808'
 ,p_plugin_comment => '0.808'||chr(10)||
'  Use dd-mm-yyyy hh24:mi:ss for date format'||chr(10)||
'0.806'||chr(10)||
'  save mapping between sheet name and collection name in <Collection name>_$MAP'||chr(10)||
'  XLSX: also strings on 10.2 databases'||chr(10)||
'        read formulas'||chr(10)||
'  XLS: fix empty string results for formulas'||chr(10)||
'       added standard data formats'||chr(10)||
'  CSV: performance'||chr(10)||
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
