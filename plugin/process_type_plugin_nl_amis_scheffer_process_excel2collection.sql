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
'''H4sIAAAAAAAAC+2ZWW/cyBGA3+dXNIIAJGFKGB7yIUUCHEXIGvHagS04eQhCcMie''||'||chr(10)||
'''EQEOSTR7dAT68anq6uI1nJEW67zFwK7YV/XXdfUxi1xmZarkQj81UugmyWRZiqIV''||'||chr(10)||
'''Sma1yhdunuo0MY33qcruUhW6gbfwW62KapPcp2VfH4Xv3r6Dtmq3XUll2uhz4YMU''||'||chr(10)||
'''aSrwY+Gvynpl'||
'ivix8C662VX9gJPrdFVKUa97oCqXj2L1JJqyTYpKy41Uo1HtdJiR''||'||chr(10)||
'''dHRUeyelHi61SreDVYbL5RIWY2TbOYakqJfpnFbi/Kw0wo7EclaXpcx0UVfJKm3l''||'||chr(10)||
'''VI+TLmO4roulCaHniCZt5GOSNk1ZZKkZvwFNp+XpfZakSoWHIEMWdrFoVJ3JfKek''||'||chr(10)||
'''2D4lZb1xm2TbbjoEb1G0i5XcFNXCzJXL1W6TbGXbpht5Cv35m8b5TVLKe1mKyysR''||'||chr(10)||
'''A7is8ovFeleZxYkmVa1cQM+8zsgnfKvNpFJDRHF+CT5VltguH7VKRb7atvVONzud''||'||chr(10)||
'''lEUlW1hd+tR18xZK6p2qWO8IrcmlrGuhmtFXyMS21Fl81m7tvciA0bTJVif1et2C''||'||
''||chr(10)||
'''3cWAMcDGVmVd215j1ha5DQ8slilEU1ZDp0dtq7Errg6UvzrN5TrdldxPP+KYh1RV''||'||chr(10)||
'''EITC/Bs4mqwHQRkK/Gu8qZXNIIj7elnBclqZ7zUaNd6XbrtbQby7VuVu6PmBH3i+''||'||chr(10)||
'''8wfHjC9lNfX1pm6nVa1OlZ7pZ3An1WjJJKv2uq8LWeZQkY8bJNokWYMbCPmYyQZ9''||'||chr(10)||
'''Cruvduu5qILqORpy5mItyA0hmtCFRK16K2ykhsVu9B25qicuxXKh72TVuZn1EnBv''||'||chr(10)||
'''UaxHyn2dLo1bQNesTkvZZtKtABEXAF6UFHk3LvIw0Y7bdrpMiuB9dbpNG64fDPC7''||'||chr(10)||
'''9r/efLn59uk6uf765fbmn7d9w6ePXz4mt1+Tr98+Xn++mZnCuf7l4'||
'7fk+rvjYS4E''||'||chr(10)||
'''Xe2aRvarCTwPHFG4zi+3ju/8+xP871+30NeoiBwQ13an3A+YA8r2sIQfRsLfUMKP''||'||chr(10)||
'''WQlBMBFhNVvCzrQdygMFg7bAVAD/zSFJZGv5KLOdlqLYbmVewM4kHNMgzh9xFkc8''||'||chr(10)||
'''P4teEJacC4GZyxG7FiMPPc5AAQk73uIBJhA1TKMgjYywnQvHZj7gln39wC/m6NE9''||'||chr(10)||
'''Lhyv96rOHzMlgVrLbVOrVD25Jjn5Wu2kN+xVV/dSaV1j1qI+mD/BgWFj5k7w3zZ9''||'||chr(10)||
'''bIv/wPY8ymtY7DMZltBH8e8wZ2HZ5iPrGUWF6yEitNcSbHDVhUtatHK0P0mlauWe''||'||chr(10)||
'''4K4b+M6XWotUXH//cbIuSunwklgBM+KDyBjIfI6'||
'monzITjPqxf6zJ2vZ94oOyxr1''||'||chr(10)||
'''OiLriICDo45M2881DE48H7hkG+Pr/7h5f/Pn6798uj5bLp0ZMaENHznHZNVsN34H''||'||chr(10)||
'''t2d0d7CHeCj0ndkd0kxLnJnC5CAKBo1P0YIdF5hrVPpwmqXgYbrGb9cEAnUVaSug''||'||chr(10)||
'''AOJ1rfwjIziv9sOoBifq8EQKKzkmpC778TdfPzvmhNftSqCToWGov/G+vs+VMBvL''||'||chr(10)||
'''K9w69J3PsK8J2kGErmsBJ+/NvnfTjgqT273GzO71eygfIbpdkiv67bE7ZcAJ57Q/''||'||chr(10)||
'''wmMO+u7sraBzM9wwoY/NRbxqM6vfDTixNew/RhgS/0xVkGNaHgPS66fXU7+Tm17m''||'||chr(10)||
'''8wQWXtZ1Axm50MIkY1bcFYGa9'||
'c+uMcDQ6X2L1WK0OLjxoBqdkT3s5xuem05A+/5j''||'||chr(10)||
'''Bfu9CtkUg6MEak70Z5pR2ptgw8A3wW/A3q8E7z9s7pNuXd5kuThx2Nnp583k2RO4''||'||chr(10)||
'''O/Bmr5f3og4gd3RnhT3aSYQMimg4yqmzwrtAxARglV2XPBFeFNw+HC1uf5uAw3sJ''||'||chr(10)||
'''m/SMBoM3I8nToO5Lbw7E97FMNeNkw/D9yeE6SimXr0ope3H++rzzYgYYEIk/Udgf''||'||chr(10)||
'''jC5iOGrFqd0GyQiyzDg1YQIYpkY85NnLBCvFJodlN/kkW8CqfDOQtXAyWOkwaQxy''||'||chr(10)||
'''txVBgIPu+3lzmHLMDjlruJmY7uxj+WbIjgfvUS1bTRrDud3yekBjRwvq4bXsZ2H/''||'||chr(10)||
'''xgw05w0vZpY'||
'DWfJ1aBPv/x06nrKj5P/noP9VDprEXZ8culvXWsnp9c3jNye4/Z2a''||'||chr(10)||
'''Vz88bnRXoWGreali47YXe48Q4ytpn/NILy9AHLVGxFc08OMin72o8YPK/kMnEJ9D''||'||chr(10)||
'''nbkndA9sUGleAd1zczP1MV36s4972ANTI/zBE4/963nj+wocspznZxION+BdpZ+f''||'||chr(10)||
'''HWHeFFsBSqhyZzBiW9/jxUHX4rqDdVsPu5jXzX4J9s6d1CqBtVYZfvet7t5qYdbk''||'||chr(10)||
'''j79+/DuKWkPSKvB5IxCnp2LIxqfG6YMvxfVEf3CQghsMXnJc1FKxdgs4/uyvhp6j''||'||chr(10)||
'''8fpTAMW5cHAgOU9BroUqgTUbRU2mnll5mufJVuLT5JFl4stCBnf4y6vxVLY+xPrJ''|'||
'|'||chr(10)||
'''VNhUmSHF4vcp3IKbPMCTY2iQkt3hlTrsTmVoFTWxSjewhPsiGWdfKGxYrW5dZV+n''||'||chr(10)||
'''UE7WyTlbWpuGbuZBH7xfo/HshWQoCFpZVuaZJ6P++a9LR5MB0HOwlfiBH+PPFT77''||'||chr(10)||
'''xWz//ncZ37n99YPzQnf+zcZ38vxkuz15gn8OnH7pAWt80NH4q5BLL8aOM5fyDjtT''||'||chr(10)||
'''u2/DgRPRz02d74RuyMXIFCMuxqYYc/HMFM+4+NYU33LxnSm+4+J7U3zPxQ+m+MEW''||'||chr(10)||
'''gyVhLLlssZgrIK6AwQICC5gsILKA0QJCC5gtILaA4QKCC5guILqA8QLCC5gvJL6Q''||'||chr(10)||
'''+ULiC5kvtHpjvpD4QuYLiS9kvpD4QuYLiS9kvpD4QuYLiS9kvpD4'||
'QuaLiC9ivoj4''||'||chr(10)||
'''IuaLiC9ivsgalvki4ouYLyK+iPki4ouYLyK+iPki4ouYLyK+iPli4ouZLya+mPli''||'||chr(10)||
'''4ouZLya+mPli63nMFxNfzHwx8cXMFxNfzHwx8cXMFxNfzHxnxHe2NG/u+5E1yPoy''||'||chr(10)||
'''n93CMGL/CyKJQ6rpHQAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xml varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC6WYbW/jNgyAv/dXCMUA2zgnF8vutU3R2w43DBhwNwxbh+1b4NhK''||'||chr(10)||
'''4tW2AsvpC9AfP0oWTdlJ+rYAbVxaovhQJEX1JBdZmTbihLH2cStYu11koixZoVgj''||'||chr(10)||
'''Mtnk8IIxn+Vpmy7MiLu0yTZpw/0oMO9CptqmqNeLu7SklzE'||
'//3SOA+pdtRSNGdA9''||'||chr(10)||
'''WjkoFUaqH6xsWcqlkekHIwuuHOMaea9ta9NlKZhckb11Lh7Y8pFtS7Uo6lasRTOa''||'||chr(10)||
'''p8YTja4X5qmNEO2eN+q0chzBZ7MZopp17Hr71msvjq2wKxyzo5tj53aSTJalyNpC''||'||chr(10)||
'''1otlqsTY6XuDhtY6g6xVHMYOrEq34mGRbrdlkaVGwxr2Ii2nd9kibRr+jLFGlVV5''||'||chr(10)||
'''dTKZgHDbyEzku0aw6nFRyrXPtotKrXuDmHZdoZ21FOuiNk4zBuRiuVsvKqFUuhZT''||'||chr(10)||
'''mInPVkMIX6W4EyW7/sySztGizu2yq11t6Nk2bZSw+wZelNmuEnVL4aXVmD1QZNL8''||'||chr(10)||
'''GgK1LLsNhN+NaHdNjbuA9mpgE66ZKnIb2'||
'WYqeEXrUaJdFLnPvC/fYv7XzS8XHhjJ''||'||chr(10)||
'''JhOWbUR2C7ZmMofEAXeyf75/Yz/Cx2p9qEoGP3qDrqyoLGrRRxYKjd11M94H/UoH''||'||chr(10)||
'''9wGx3p8D4gO5i69Mkq6q1kl8CHfN6eX5pKomj/Bhmw1P5lUxV8rDibUapEg3Bahq''||'||chr(10)||
'''dX0K3pwrcEOVqklVZI1UctVOMlnN5WpVZGKuto1Ic8N3yjz29GSUHv50SmHpN+ol''||'||chr(10)||
'''S3OWLyul3Z7Lago/tcx7z9flobdloVoawV8eEj83hEIfk8TTcaujQ4fGfdFumPZk''||'||chr(10)||
'''mrVCx5VxySDQdJL7g4AMWL+HOp7A+zak3DwIh1PGgQWTZo6X4E8XokpvhabwB9K1''||'||chr(10)||
'''aFG7KIX+Gr6vxT184RD'||
'fmhe49tYlLaVKU0GUks1UCV3T9JLKNxaFzPv4t2xul1Le''||'||chr(10)||
'''mgdjuBd24Wf1rWTDCp1lMzadjk0tRb1uN363aMAmLDJzSim3NuQG3qA/PrDoyo4o''||'||chr(10)||
'''VlBbqIxAKe2rh/no9Ws4JWFX52bj+qHwDKIQ5a00++k7ywR2DDx8ZrN36Nz3IiT7''||'||chr(10)||
'''TsjVcFeKVlSdF0JwVgDTf1Jq/htEVe/NI5YE6KeNqHtpd2759nuayR3UXHAZC6bm''||'||chr(10)||
'''ODq4ve817Kpfts8eneVdkhy0xFrhzLQVdgo5KVrhynUlBXMjV6Yz/uUIfR7jRh+3''||'||chr(10)||
'''H/+Q9wc4dMj++5qQ5U7MjuJ2YH19V/pv9zgPwQp0+a/61O9tPVKPw27JI28dQjyM''||'||chr(10)||
'''hp7FU'||
'vle3/YGf4Wm8IBfO8/evsaz8cize751CN7n3TgES97k3c6/sOjR9wNWPNnf''||'||chr(10)||
'''k2y9cWDbz5A4B51pSt//Vv1R89/AwUSVBjoFeCNuCsjyIZBbZEaMVD2l6Vr87hUs''||'||chr(10)||
'''pFsU3ark+enNKbUq01Po3E89bYvT54wIoaUEyrFbTbHwTawHvtmSYEp3JN3p/Om9''||'||chr(10)||
'''Zo5zdzKnCzyMp9kY6x4+DLNFG6fD8upQzncPgxn74w+VRx+O4qm5yRgtxm6cYd0x''||'||chr(10)||
'''2IGTfdXYMffXFuzMsdPZv8bAWnOQmU7GufqA2LTwPpubtiXU3/aoM1tla75pmITu''||'||chr(10)||
'''CJ6eXJinJ4/Z4Sv4O/cCe0PAeZW8031WK9nX3iJfBZ5Rbm4iZOk0g4MF4kQ2'||
'i7aB''||'||chr(10)||
'''G4Z+prf+HhQsvvjh+5ffO2V9IxLp2uMaeeJUl/27G+7+wF1Ou6C7jWLlF2EU2OAd''||'||chr(10)||
'''sXV3TH0cFmDRXLsIN77ojkLtJfCA8d1oeaty7Ik0z+FCpu88z2A/07XrTwi399ks''||'||chr(10)||
'''uv48NOZVs7ieNTL15Ym1Wa54YeAR5DdsvnWcCTRTJYlQJ1afZ9hJOXWtu0WPGhEd''||'||chr(10)||
'''Os0odHplZapaO25wRu0vKx7gwqH8hg6YUUHV62T9OmdOm9ep7ozzswB0QFhmOhLv''||'||chr(10)||
'''QcVoIXiLa2WBWYNlMi2FyoSvdkvdt+5NgJFOOQyjMNH/VwkxyA+Op/8shd7N90vv''||'||chr(10)||
'''heH4D6fwyNU1CLo6RdD7BVOUyo0z65BIO8TUfW9YbenoGK'||
's6nlDmcjMObSdXzIos''||'||chr(10)||
'''Ck6cTOhkHGUxyWKUJSRLUHZGsjOUfSLZJ5Sdk+wcZRcku0DZJckurSya9bJohjLi''||'||chr(10)||
'''iJAjIo4IOSLiiJAjIo4IOSLiiJAjIo4IOSLiiJAjIo4IOSLiiJCDEwdHDk4cHDk4''||'||chr(10)||
'''cXDk4MTBkYMTB0cOThwcOThxcOTgxMGRgxMHRw5OHBw5YuKIkSMmjhg5YuKIkSMm''||'||chr(10)||
'''jhg5YuKIkSMmjhg5YuKIkSMmjhg5YuKIkSMmjhg5EuJIkCMhjgQ5EuJIkCMhjgQ5''||'||chr(10)||
'''EuJIkCMhjgQ5EuJIkCMhjgQ5EuJIkCMhjgQ5zojjDDjs2UO1w60bzrku8oMti65f''||'||chr(10)||
'''/wHhC2kg1RcAAA=='';'||chr(10)||
'--'||chr(10)||
'  t_parse_'||
'xlsx varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC7VaeW/bxhL/n5+CCB5AsqYl8bBsy3WQNEnRAk1RxCnQh76CoMmV''||'||chr(10)||
'''zIaHsEvZcpEP/2b24pKiZMVJhQTmnvObc2eWtHKSlSklVvu4Jna7TjJSlnbBbEqy''||'||chr(10)||
'''huaWm6dtmvDB+5RmdykN3cCzfNbSol4l92nZ9Ufh+fwcxupNdUsoHxOPlg+7EN6B''||'||chr(10)||
'''D5Z/Wza3vIkPlnelqdPmAYm36W1J7GbZAapzsrVvH+11yZKibsmK0N4qNlzGdzq4''||'||chr(10)||
'''it0R0pqs1mllcBnOZjNghu8taZhIUS5DmnLHcapihVyJ7awpS5K1RVMntykjQzkO''||'||chr(10)||
'''pvTB6SkSTQgze2jSNdkm6XpdFlnK16'||
'9A0mk5uc+SlNJwH8hQbXZlrWmTkXxDiV09''||'||chr(10)||
'''JmWzctdJxVYagmcVzLolq6K2OK2c3G5WSUUYS1dkAvPVs1jnr5OS3JPSvn5pxwCc''||'||chr(10)||
'''1PmVtdzUnDluBmHd5DgZn3mHZ1HSbmht57cVS7ZVmTfVBP7jvI54sbTlGmC/3oCt''||'||chr(10)||
'''NFSsgL7JirQlqVftndzYs6/tmdXekVptjks4HLtYXo1RrNJPhEMzO2HfvMk2FQHJ''||'||chr(10)||
'''lQT/9IZr8gB/1AwXelFREoNfg8hRhoy0SZG7zutfovD3jz9eOB7+AMw2I2uUi/UA''||'||chr(10)||
'''QO0G4FImQGtvTQDwiFy40aAw1A8b3PgIa5NmuQSatm0YJaOZ7jb7yxS8O2ugY9tK''||'||chr(10)||
'''L7YX151gc7JMN6Wa'||
'125xzUNKawgKgrDeS6hJL8wogRDQkmrd0JQ+ugKv39IN8YZA''||'||chr(10)||
'''gWAwBCn6uu2a+p7Qtm1wF7mZ5QtBQ9hR0+B/lW5Z8Q8Enx4NbHbbWwd0gzNNqWBb''||'||chr(10)||
'''cszjAmpESejbmY7giJuFZmZJyY4APW27CET615iTbSrTx7hb1kpZ0Fo3TLW8zkV4''||'||chr(10)||
'''ENcuJ7s3bZnQ9GGSpSDNtkluixrwqGDiarhscwunhTJ+TlAQ8ny1RVm04KcJ4C3S''||'||chr(10)||
'''eic69EZxn2IlMaGiH1vCzCiGSog1dth9L3AJrMfHkjbVkBNOcQ9WP1AYdmBDFE3S''||'||chr(10)||
'''cskhY3juIqfEYYDewZiyrChcLTpY758Gnnc6j62T+r503bEJoS+meN+Fcx8Or/0z''||'||chr(10)||
'''Iz'||
'1zfo5Th9jBSJNlURILFvxTrNck72wG3QvH+keSpdnic4AfMIpqzVvoHQVG2C6+''||'||chr(10)||
'''3OXDnmU57CF11uQYULrMY8Y9zTBZFV8EATNCmaHfYME7DSF+lE2zhjhbtDYPsWL1''||'||chr(10)||
'''93bQOzy0yIzlfuzzyXiQ3EEUAB98cJ2zWfzD7Gw2d7yrDgl/OA3E4YIEr/CwkqQO''||'||chr(10)||
'''H0NaPrCN4bYjOE6CuXcCNJYAvAChAAuTyb41oVxz4QkBABxl1bdFm6R1PuK15gaB''||'||chr(10)||
'''r5CdXHp+x/8Mz66eRLBHMGjoEbjpAipwWzIyHP795uK3N3F07nTC4Cd8Z3DXHHMR''||'||chr(10)||
'''XNQToISBB23DOoxcpJx7RCI5Ci94jJeteG7xpkJnaXbQ+g7rRW2IiQ5XO'||
'S7RGoce''||'||chr(10)||
'''DVGzhd6N6nOdqeM7/5PCswfmgQKTPRD/20dO0vU6WRkyO6xJg29wqoHqZrNOedIt''||'||chr(10)||
'''j2I4Drn9o9svzB2DHy9+wF2NX+R4vVN8jQcZLMTgcozeTDFjmh4EqCwB9iQKrJMD''||'||chr(10)||
'''+pazQqhVjpl26VkmVkiqQcoCrT4UICeAPPsJ7zEwg9dafv9c41YCpKzuKMfds6Za''||'||chr(10)||
'''U8ikJ+U/CURn2RLkvW+k8NlXKfxAaocikpndMbrmIgBd/suq1IkSYNh1HTP2mtHg''||'||chr(10)||
'''0P5dBLGPmRfNjpwXeubpMTwqjPN6jRkrHtaQOOpDmpejTJ+eyBCuxSHQPU25xTSb''||'||chr(10)||
'''dr0BwRc1YVAZpo96mj7QZc0qznSzHh6rarHADy5nsX3'||
'bNCVJ617FTHo1qpyxt2De''||'||chr(10)||
'''LsUauZbn2JtqWbXDblXQ8zuJ/k3AoGLeS4vLCjJ+ZmzU9WOE3hmR1Pq9dKyMZ2Od''||'||chr(10)||
'''7VjnyH0KZ5vKhJeLZUdOOz3ZDns7PZQOe2rWu/zw+HkMVUnNrl/cte16MZ2y7I5U''||'||chr(10)||
'''KZs0EAJhBJKOKm2hSVdTBnEpzbm4qnIK6+fTKi3qF87VwWK1zsO9Q+XYSFmwVoyO''||'||chr(10)||
'''LuyGo0PDwwst7IMCcSg4kVvK+w8HnQzzlD9+ufnDMUq+7vZCpc3CEX1nW04fGvoJ''||'||chr(10)||
'''DP3TBIA4ntdzEVhbNg+qVtqykt+5MNbQCRjChjRLF2n4jt5FP/xGp6/UPo6PyvNk''||'||chr(10)||
'''/oDxFlKIQCIsu6LU3J8RvFhC0GyHh'||
'ogb4o/c20gwZ5hgDgpamWgjOe80EMml4VNu''||'||chr(10)||
'''cRJ44zgUn+aGBRwhfC+/8HznFV0UOTDELXFBj7FFKOaLjLyVNbQwRkpKfhHG7oo1''||'||chr(10)||
'''eyGEYzj310HELZxerDYnY73OzQMFfazdsPaxJMywmi/QJF97g8xNIWz8WIEyxd+v''||'||chr(10)||
'''0SaGpufKRyjnDWB0RErsAm3MUfi2vpPnjme/hAQZYZkDVbVn4PFRDui8xTgaDvjT''||'||chr(10)||
'''ISVyEf2cYymDZz/4UT87EJrtUwpiY/Jg6Gz/0Hz/0PneoTDsDz3LIPA6/Y8lm26X''||'||chr(10)||
'''047jrzALeUi7hcBmAp5Agc1aNrz9QmRcHXuV4X1jV4IgT/IbcUhrjwIrrJu2x2TB''||'||chr(10)||
'''MPEReyuz2uL2M3n'||
'M4uUjZstXivsv0QFrp6z4c92wAuOQ6728fuHYnz/bsoKFedvv''||'||chr(10)||
'''kAoGIuh2XthQkNvd/O8H83EBzOVr5Iq/tCa7u40DWrQVZ0J1295FwhfE+Uysl2kQ''||'||chr(10)||
'''ZPibujVSJBenPDu4ThxVRfe3k9f9Sk/fhNZ3U7zZdb3jSGIK8qT29xOj09Ygh3L/''||'||chr(10)||
'''+wi5h6bghzwPu8Aovsz5Qv/vvvMNq6P+SH+OyOae8sYETmLWS4sm2MN9sn+LZWQQ''||'||chr(10)||
'''wqb0rZWrixulEn0+OAvuJHoC+sUC0odFz3cKTw4MTpcnVvczhv4eOmKIPFJFDayT''||'||chr(10)||
'''JpB4ElHAYJnkij+CJ/DgCb/XEurr7X+lU0/Mre1RDLpsOGjyXDUQhD6YWVCv9eer''||'||chr(10)||
'''n'||
'3MVYMzMTUWW6auPKV1hQnh8TbBOs0/piuxPwI4I3hIRMCJYfSoeR1+U73JGRab7''||'||chr(10)||
'''FlQyBW392xH6yOAc7Y3O9IgoERlR4vlhKvIpxKnsz/u/nhuh6DMiMcYgTPv1WcaL''||'||chr(10)||
'''VayVILbhFOpT/eTMgjCKz+bnF5cyT+au1717OTRVe+qK31wxfN3G+4BydpxjHeDg''||'||chr(10)||
'''3pF1/rNF0OpzqAVjcJijL5AFMgx+Tds7kzDcILfUwxeD3qT7fAOr+RvnamSO8S1H''||'||chr(10)||
'''/wxpEnHr4Gr/08dAySQuXnPCCogLRY23SDf8magLxX8bLDz0YBFxXYJjffiWn+FX''||'||chr(10)||
'''FtzteqXEO6f7KgCS67RmJSa0cnSircY/PQHG3l6qH3CI9Iwl8uJVrAz8'||
'IZXTwDu8''||'||chr(10)||
'''Hw8R7+DnIEeW7/z6y03y6+/v3334+U3y5qfXH16/+fjuw831xHcsebH0bNtiXY5j''||'||chr(10)||
'''qoZHNJ3VqwzeFCVeNPQmDUeP0+5bR5JXtxgHlhGt7kZQBFc+hX/i8sN5+/b0/fvT''||'||chr(10)||
'''/8LP8U5Q+9oQjt4rwr1mw71QXvR0Hng7FnaYt19HLdf4LEpUSvT49OrpSojLkicb''||'||chr(10)||
'''PK3gKYmUqEzPFR6cU6as9SbLghrXYeOTBvwZR5DM0fRUFfVlYSVHpAXRvlmMyq2V''||'||chr(10)||
'''FHaFsctcILZDMJkBhkdvdfiofcWFucYdDnBr1BqbAp1p0AMBAfy+UPBE3wucL+7V''||'||chr(10)||
'''Dh2x4GliwQ4xYYO9QDk0pL1aGtHRKMdjfB5WkvGEAA'||
'+opk99TARjjI/yOl6ljOTZ''||'||chr(10)||
'''3oS/udBiHdtmr3+F5lsj8aaDv39R3x4MP+UDKgtMQTBJ1y9JoJO/pnEXIrtdqCrD''||'||chr(10)||
'''yPP5BEhOP382sX/+7NiyIFlCO3eMFVVzj3fSbWO/0SBcxktK/l1eB02+n0samrR0''||'||chr(10)||
'''g+8riTHq7nABVJP/vH/9mzNSmHXYlLMNP1Xkgh7KxciN0RmKpVvghyg73IgPKTGX''||'||chr(10)||
'''LgDFwnZ4DcB1WohyCUUCPHNBDUiPcJ7meVIReUTtYxPfi2WzWXD9sk9K9ofYPyCF''||'||chr(10)||
'''QzVfUlhfJ3AJXJ2InHgX8FzPiOehLieHTt5bOAhtvbFBUO676tlM6jQE94M5mE7r''||'||chr(10)||
'''zKm/US9y2DyBypq0JCwzkqHBAreX'||
'xEGaFOOHtn5XY43M745O3/n4HjKlw9PVMY8X''||'||chr(10)||
'''y6dVdfoIP/vuLowXVbFgeNVgq+/jzIjV4psg2IIHmtE4s9+u2K46DXsS30xrMwrd''||'||chr(10)||
'''UDUj3oxUM+bNWDXPePNMNee8OVfNc948V80L3rxQzUvevJTNYCZgzFRbwlK4AoEr''||'||chr(10)||
'''UMACASxQyAKBLFDQAgEtUNgCgS1Q4AIBLlDoAoEuUPACAS9Q+EKBL1T4QoEvVPhC''||'||chr(10)||
'''KTeFLxT4QoUvFPhChS8U+EKFLxT4QoUvFPhChS8U+EKFLxT4QoUvEvgihS8S+CKF''||'||chr(10)||
'''LxL4IoUvkopV+CKBL1L4IoEvUvgigS9S+CKBL1L4IoEvUvgigS9S+GKBL1b4YoEv''||'||chr(10)||
'''VvhigS9W+GKBL1'||
'b4Yml5Cl8s8MUKXyzwxQpfLPDFCl8s8MUKXyzwxQrfmcB3NuNf''||'||chr(10)||
'''YOx6lnEAkHz0NEOP/T+2nQMNrjAAAA=='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xls varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+1cUW/bOBJ+96/QAneQ1Mg5UZIdO9kUyDYJUKDtLtou9u7JkG06''||'||chr(10)||
'''0da2DEluk0V//A05JEXRkuzYSbp3bVCgFkXOfBzODIccUp0pnczjjHaK+xW1itVo''||'||chr(10)||
'''QudzK8mtjE7SbNpxpnERj/jLz3E2uY2zwCFux8uLLFnejD7H87I8DE76J/BuuV6M''||'||chr(10)||
'''acbf4c+OB1QoL2A/Ot54no75I/vRcc8U9yz9wpgX8XhOrXRWAlpO6Z01vrdW83yU''|'||
'|'||chr(10)||
'''LAt6Q7NKq9xsxim1tspvKS30ri7jhdbLwPd96AynLXjoSJlcTJ6CYj1XbCFasudJ''||'||chr(10)||
'''Op/TSZGky9E4zqkpR6NKFZyqItAEULOCJl7Ru1G8Ws2TSczb34Ck4/nx58kozrKg''||'||chr(10)||
'''CWQgiZ11Vlk6odN1Rq3F/Wie3jir0SK/URDcTpJ3xvQmWXY4rykdr29GC5rn8Q09''||'||chr(10)||
'''hvryN7bzVqM5/Uzn1vlLKwLgdDk968zWS945axVnOe1AzWk6WS/oskDF8IRIc8XV''||'||chr(10)||
'''Oj0HnZrP2St6V2SxNR0v8nRdrNbFaJ4saQ69i+9VNbeT0WKdLaXcGegCVUqoFhOz''||'||chr(10)||
'''PsZ1I/UlzT6N0/QTR8UKQHqWNrK58TynS/1xEd+ZRZNloT/eZOOk'||
'sLL4C9gWex4n''||'||chr(10)||
'''s1nPApZzGi85hyKr049iseKtyhLQZaOEWRwZ+pFGThpAXlR0xmDQqMisHTavmAOt''||'||chr(10)||
'''EBPcGonczbCNaMuKZovCLBPUoTK8rNDXyLXxYM0UAcGk1tLgeZRT7R0B82d6ZP9x''||'||chr(10)||
'''NXj74Y/X70jQC2zDfXB5N7oQ6RA19dBdiNDtOieCdJvkj+0UBVVWac57ZTY1HblU''||'||chr(10)||
'''T6NiafsZjaej9TKZpFM6QqePNgRlFUVDV4CaKqzvrPPlNoF+obq/tPzOPE1XnWRm''||'||chr(10)||
'''rYv5CBofg9aP4uXUERbg3YJNp4yq7RPbda1zq1rSKW7pkhFwLAvN7ogTfxEAeUkU''||'||chr(10)||
'''TO2muHW4ENwj0gEG3EuAExsf5+sxIHRKm/YCj9'||
'vzETfbo6jKNHzl+8BWMFa9wx9f''||'||chr(10)||
'''v3KeCRksj6H2qEi5GjkSiOIFQDyE63r2xRvS//3jNem/ubJd6Qs4TfjRNTrRRsq1''||'||chr(10)||
'''/mUF0htxAlo3pBuCckljEucFwzhOlnF2Lwfb2UE0gespXElRzOkI3HcSL93SdwGf''||'||chr(10)||
'''FkJEEIqUj2qvz7F3VasjVNRcdJTA9DGH+eLw4fCE9tQNS67EquuZNmA+n8WsZCbg''||'||chr(10)||
'''bKrlMyklmwW0ca7TlYP07PvWse3SRS1qVJp6lUEPqjzlLIVpDDy+Razj402tARAu''||'||chr(10)||
'''ek/VTok8XUKI5/BybwMlNPQSj7i6awXlwQjMYhTPdrUj5GAaijIBRa4a2mWfAlwE''||'||chr(10)||
'''QHSXfWJThorJxOJAxZGieMKC'||
'YahXpIDZMacKo4eMKAw9dND2Q+gXTDmgkbYf2Baz''||'||chr(10)||
'''jm2KaVLn5OzrV9f8z27SSfC8keQUPjkn35e8/HZe03QNcYRjaAY0wz/bY0ybOEke''||'||chr(10)||
'''5EAe2zra0lMIuVB7qioEehKweBBIwU+hNkqL+IpS6RA44TLkRQcpVwApL2eBRBf+''||'||chr(10)||
'''sfe2Z19edt++7f4H/mz3iNMvVbquYcga+mZDRNbtE7myMQKoyWwMVSYzvoBwMYC6''||'||chr(10)||
'''hRcQuzKT7JEAw/57WCVDHAnFRtxGlxCAQexlWVp06aPLyf+C0koDixdjed0rWFK+''||'||chr(10)||
'''nm68Ql8n38pq/2Qhoxaz0kkyNWJWvWZj0LrI46IkwIFDgVGyWQcopyikwI8G2OHb''||'||chr(10)||
'''NGNL42URw4'||
'IvU4sycAc0XqhHNjMZGMzo3GI/gOZkdJ1ROvpAJ68vuViAeF7E4LP1''||'||chr(10)||
'''VcbpeZewulfL6ejX2ejVLbAXbZrqB6z+h4uPGunGuiGr+7ZaualuxOpevn4/ulqs''||'||chr(10)||
'''ivtKTVxEMm9e9fiyxQdWdkO3tSB6Cy7XbS2CssWbdPLJ2o4qLFv8lqUrmkFX2ltE''||'||chr(10)||
'''ZYv3aVrswKNna2sTYXI1cQEzTg/M0GMWzAM5VRtUnW8lgBpuTMtYxbV+tqCtXkPN''||'||chr(10)||
'''v1gDZqiBa/2kI7v0X10TcuVfkF8IubgiZUCHbkePFDS/ANj5/PhFd9Emt2DoBdWQ''||'||chr(10)||
'''8fqKud6qY6+4X4tFO9q67EaVM3fGvaqG4ryeiAxIlbdiy2c9XlBBVX0NW+8091/w'''||
'||'||chr(10)||
'''epV+gekz8HacX01ZhARk4enoXeE2gf4jkA/ryKtozmfRHPGHXSKjN+Fet8fMTRxP''||'||chr(10)||
'''To6SF5EXGVxBdHcQI3O9UFxAWTTXJt2wk7gi2uO1jFDwUHz9YQ02uREgqP/EgG36''||'||chr(10)||
'''UV1GabOdct1g1nrEf72QZHkIXxU9qhHEUN1AEucSwP8gelkvC8d19+kugvRgLI5I''||'||chr(10)||
'''3Wg8ikwFk27teCsOrM9/an3W+1bVvAdJlUvqT7dVrCV1LtVnE+rjqmwdr2+vsqVs''||'||chr(10)||
'''hXC/icqqoeUlj6bZQvTR39FbkGBQCn+3HY5mWQOxo35vY5YQkyqj/tIK5MzJI1TB''||'||chr(10)||
'''bftGVoUHETsanJGcX7UFOg8btsA8gfgH14F66IfglHAnUFbQgi5'||
'WEFtk946MvL0i''||'||chr(10)||
'''W1PXWEYcKjlCTmoU5HFGhQR1VlAOy95K3dvEjDKUiq0JqFW5lczj1YryfXIh6h01''||'||chr(10)||
'''veQD2l4zNNK2y9Kqk2XB2pNh3ljJeRiVif92g9+OX6i+4lxkyULTVzbMcsS55bFs''||'||chr(10)||
'''j9gftKVJquSf3CCDpiXpSttfdm+nGRlbyWw3MVNUz2ZrjzD+BvZnVF7cXGWFzP3t''||'||chr(10)||
'''McXB+Cq4Sd4yImy9RYxhnEHo3dakokZNbLji7EQda1a2ZOXaV6TwbZZoZ8uuf7/5''||'||chr(10)||
'''wBbG2uaUzLxLe1DqK9a/FsyUivUNLdQaWFZkEH2EKLm9Sy1FZsa0aAbBy5QzjpOc''||'||chr(10)||
'''Vs4n0CxLM6fLTl2EHrQsrNj6HM+TKcPaZa1tq'||
'fTlGrHcrC+z7HocUItTLPB3SL8Y''||'||chr(10)||
'''CcihP4A1NPztmr2JWA7dcvSNGLYh0alsxvt9vvTfkWTfwNSrpoLw4EB74kNDV90k''||'||chr(10)||
'''ws2S58rp1GeUuAvRV7Ks2ktWTYyvvs598Ahe4E7Y83RRt+kdAV5jZg/tXB7MGmXr''||'||chr(10)||
'''ytkRqF0+lhvN8XTKXYuzMrc+3cr2eJmjXIno8zlylN8yf8j9Gc/M/Xxe31mJUmQN''||'||chr(10)||
'''jeRGaz5/W4ZRGZurNr92zE1q+UxtV0zLT266+cr73ZOgA8GKpyHUZkIlE/nwgYkE''||'||chr(10)||
'''0UFjwonbulLbUE9SPzSO0ZKxrU7HyM8GleRyG1VS15yc7XiYZbBxmGUgzVz1H1NA''||'||chr(10)||
'''zNaftf9SJ5GvXwlJduhZtNG'||
'zaKNnmJFnbuuwnkVbTJxx+FnGIIoh/3EUBcNo2D8J''||'||chr(10)||
'''hv06axLiiMr96TszX19zEEqcheM7M9WNGR6M1Z4HADm/iI44g42cOfDeY84Y9Mo5''||'||chr(10)||
'''Yx/fgnv7LG6QNA6wQbaB0KJ+bWcpBvoxCnaI7bh1MwSPNpQH90r3eiB8d7tPGMg0''||'||chr(10)||
'''0WHn2NS5i1omQ3U4yTzuhIuadmkOlTQfcLLEgKNOlkD5fidLNEvbZUQZn6bzJZKE''||'||chr(10)||
'''MKh9Rpe0eRBBP3fkD9OgWeG+NhoEuo2qE7n7xekEg9j9kJCr0kF/c28R7u8tIs1b''||'||chr(10)||
'''sCO9z+omwvZJtt159J7DefQPch79v5nzaB/gdq8hD5U7+3mMxoF2O4DIAdFgbWDj''||'||chr(10)||
'''2dOp7fJzz'||
'kxq+ovFouHF/b14sbdBX/mHTf/ylLwjfxyUYdpqHft1MgoOjnGc8kgh''||'||chr(10)||
'''rvn41oxN/ODE9kD5BowBW/EuYeHMNAucxSiZOvz4/8Wr97++vXjHtn/YdlhayNsl''||'||chr(10)||
'''0gfK2wPyvoBqUD0gWdm1MtbC+takUloS4fSTrWm1vNdQ3m8oP6kvDwKt3EyGVfWh''||'||chr(10)||
'''zIiJqxvqGIGkdkzvkpzPoEKlElAiJlKNof6uztgZhlxPyGlzcYmgjKpxzs7d43I9''||'||chr(10)||
'''9lxbe8bmWd/edxOPoAmzxo5+K0QeO0KPYZ/a7GiuqgC/ocgTxdId5kfEFa8Mj7Ol''||'||chr(10)||
'''vSZKHqXpNLR9HLwsgksjvDh1PKVzihd42H0pB//DEQMwKuYzOZypbWK2tLJqUXwv'||
'''||'||chr(10)||
'''25H8Qpo2Of9NtydPrtgpvwODR+k99plaem3zsfTFIMvj8tYq88iX9pn2Ai+icmmL''||'||chr(10)||
'''c8XlGfWGVWHkatt3NQzelQy0y6/wZhfK+tQweYJJ90ilRzj1G55b5NsWvIzFeq40''||'||chr(10)||
'''5seOksABOIx+By+e8PuW+4UAfvj/qXu7HbM3tKZxT3U/LX1cDD/0eSd97j9mSNu8''||'||chr(10)||
'''m8WjVR7q8msLsID02FltvC5Te2SZi4DJv3pgGW9vdMo7mD/M6Yc5PY050U79HbBN''||'||chr(10)||
'''7TYuLdUP1IdyoPLysxXyJH07lyG3IeP6lX198ebDlW0ZN6bsj+9/h1K+l/99jFX1''||'||chr(10)||
'''sl1HXvrWhbVbnFmfRPZPyjlfS4enX4z7MHvuBm8RM/ukxiPw2T'||
'KcMnH7bS/Y7rNv''||'||chr(10)||
'''dMAGaovs9axZdNZs0Jsb0W07mqG2XVzjCB64ddxyHRl7F7qNCcMa7iJbWLr5VgNP''||'||chr(10)||
'''56WJ8/+4WUKppTtRcYuyvJ3+MM9o29+LC6ueDRTi2ieeix5hfVJNrDSO1yEJzm3n''||'||chr(10)||
'''ZBjx8zKJXqMb4kzl9tvxw0cyuu8r/DlICy8PX1U85mGAVi//INXZ0W/tqlM/dGmH''||'||chr(10)||
'''w4iXh2aWmkfuGwq/fgLOi70G5KT5SMH/wB7EL4eP8BMl0VUq6pEpd7Yfaawl2Q1a''||'||chr(10)||
'''aIqkVJs/6x31XzhJF52a1z90P5L5s9bc9JPshTOu4ZPshSvKu0XBifhYz1NZF6Nv''||'||chr(10)||
'''+lHzTMK2JC4fX54f45kwnkeTo4INywg+P54D'||
'ePd4lmT8m3pKmDWVuOmXIkdTydQR''||'||chr(10)||
'''Da2qTJcCErYHKN6IHG1Wmj3jkJl0kTty0DPYTZ0Tl1MYmIkGho+XMhBBt/ziEccd''||'||chr(10)||
'''GLgVaoVNgi4PahsCAvhVobCkXCNw/E6JyK+Wu5mcEtnOjGwwE6GwPseZWf/GUaoZ''||'||chr(10)||
'''o9oe1/WzfZCMq1AtQ1PlXieCuo7X9rVqJqW5bKSG3WP+1U0l1joy8gM84kOclYPu''||'||chr(10)||
'''5tdTgdAplI0wtSy+4QmF/NOizim/4OSdyuy3e1a5EkWnnv31qw7v61fbEolydWlJ''||'||chr(10)||
'''tlikn9kdqiK1XikQTu6yKvxTqCU0cZFvlGajIluzA1FUe+ts9AK4jv7x9uI3e+Po''||'||chr(10)||
'''lY5N2pP5dVj0WIZctLMBTN'||
'+TmZPgIVejN/gBSZaFTwDFqWXzdDwftgST8Uwk0Gcu''||'||chr(10)||
'''KIN1Tc/Z6e8F5e6+uZvsM64T3yfnL6usRHnAyg1W7NWSN0k6hwlcAJdfjOLMS5/m''||'||chr(10)||
'''uJrLDtQhB9OOKw0N71V5Z/jdqjX2xKcxiwAsDOqc6l95qRKqOAfcd56k8ZzmE+qo''||'||chr(10)||
'''Oc5owMy2jHjZOVj2bWOvXB/V1C/nbs/++HZob6kuYwl2CK67WHTv4c+6vQ2i00Vy''||'||chr(10)||
'''mufsHKPak9KcUsE+Qgok5J7Tpg9o1qt8czg1fcLPVCs1CpxAPob8MZSPEX+M5GOP''||'||chr(10)||
'''P/bkY58/9uXjCX88kY8D/jiQj0P+OBSPxEcYvnwWsCQugriIBEYQGJHICCIjEhpB''||'||chr(10)||
'''aERiI4iN'||
'SHAEwRGJjiA6IuERhEckvgDxBRJfgPgCiS8QcpP4AsQXSHwB4gskvgDx''||'||chr(10)||
'''BRJfgPgCiS9AfIHEFyC+QOILEF8g8YWIL5T4QsQXSnwh4gslvlAMrMQXIr5Q4gsR''||'||chr(10)||
'''XyjxhYgvlPhCxBdKfCHiCyW+EPGFEl+E+CKJL0J8kcQXIb5I4osQXyTxRULzJL4I''||'||chr(10)||
'''8UUSX4T4IokvQnyRxBchvkjiixBfJPH1EF8P8Ll1lqVNAHRaO5sxi/0vZsyfPiFe''||'||chr(10)||
'''AAA='';'||chr(10)||
'--'||chr(10)||
'  procedure log( p_msg varchar2 )'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'--    apex_debug_message.error( p_msg );'||chr(10)||
'    apex_debug_message.log_message'||
'( p_msg, p_level => 4 );'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'begin'||chr(10)||
'  p_browse_item     := p_process.attribute_01;'||chr(10)||
'  p_collection_name := p_process.attribute_02;'||chr(10)||
'  p_sheet_nrs       := p_process.attribute_03;'||chr(10)||
'  if upper( p_process.attribute_04 ) in ( ''HT'', ''^I'', ''\T'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(9);'||chr(10)||
'  elsif upper( p_process.attribute_04 ) in ( ''VT'', ''^K'', ''\V'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(11);'||chr(10)||
'  else'||chr(10)||
'    p_separator :'||
'= substr( ltrim( p_process.attribute_04 ), 1, 1 );'||chr(10)||
'  end if;'||chr(10)||
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
' '||
'      , t_document'||chr(10)||
'       , t_filename'||chr(10)||
'    from apex_application_files aaf'||chr(10)||
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
'    return n'||
'ull;'||chr(10)||
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
'      apex_collection.delete_collection( p_collection_n'||
'ame || i );'||chr(10)||
'    end if;'||chr(10)||
'  end loop;'||chr(10)||
'--'||chr(10)||
'  if dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''504B0304'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLSX'' );'||chr(10)||
'    t_what := ''XLSX-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xlsx ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  elsif dbms_lob'||
'.substr( t_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B11AE1'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLS'' );'||chr(10)||
'    t_what := ''XLS-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xls ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'''||
' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = hextoraw( ''003C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'        )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XML'' );'||chr(10)||
'    t_what := ''XML-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xml ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_na'||
'me, t_document, p_sheet_nrs;'||chr(10)||
'  else'||chr(10)||
'    log( ''parsing CSV'' );'||chr(10)||
'    t_what := ''CSV-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_csv ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_separator, p_enclosed_by, p_encoding;'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'    t_rv.success_message := ''Loaded a '' || t_what || '' '||
'in '' || to_char( trunc( ( sysdate - t_time ) * 24 * 60 * 60 ) ) || '' seconds'';'||chr(10)||
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
'  '||
'       ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||'||chr(10)||
'       dbms_utility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could imagine''||'||chr(10)||
'           ''</li></ul><br/>'' ||'||chr(10)||
'           ''try running this'||
' plugin in debug mode, and send the debug messages to me, scheffer@amis.nl'';'||chr(10)||
'    return t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.810'
 ,p_plugin_comment => '0.810'||chr(10)||
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
