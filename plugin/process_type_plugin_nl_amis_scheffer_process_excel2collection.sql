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
'--'||chr(10)||
'  t_parse_bef varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC31QyW7DIBC98xUcE8mKUrdqDlH7K2iAKUEaAxqIm/x9MXE2q+1t''||'||chr(10)||
'''lrfNCIuGgFGUc0JZkjJIJH2WjCayFSsLBVRbjsDmANyvXtaiy4V9cGoEus9f+937''||'||chr(10)||
'''ru7CcdDIbXcpRVdVsA2mQnSaom7tVIj1/ubO8XsyL6AJZfy6BwoWT1KfZa'||
'KsfCjo''||'||chr(10)||
'''kJ9YeUlrSv+y8gGxPJ4aYHi4st9ut/WYpj17PCad/rL0nBV/d70wZubUm0iEpvgY''||'||chr(10)||
'''lIaMyz8uIM/hbpA5TV+RT2kg4UlBSuQNNL6rnwbajEYBc/9XyP4qtheJo0F7ZJTD''||'||chr(10)||
'''WVF0q6SG7G4R1sJnodH5IJqXRX10asCcweGm4q/1hdclRTgiyY9P+VaDY7D7H52c''||'||chr(10)||
'''7d18AgAA'';'||chr(10)||
'  t_parse_aft varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC8XWSYvbMBQA4Lt/hQ4FWeAYa8ksGWaglB4LPfTSk3FkZSLwEixn''||'||chr(10)||
'''FsiPr6Tnl/Ek6QItdC7Jk/Sk72mZmWRtHm2XjKXum8bo0fZdua6cIat7svJtZVe1''||'||chr(10)||
''||
'''5s7319VYhcZdNTiTrnZl3evMf7itMaNjd0n7Wjb9Y0rjgDqjhwMk5brfd+PhQAkM''||'||chr(10)||
'''JRsf13SW0fZPtnskY08+HRGpY2FItTMvM1quB1ONpuyHchz2nQ7f33rTsyr8quWH''||'||chr(10)||
'''Lx+/hqk2/UAssR3hJM/J3JY0fb97vwWh6lDt+b4cDh5a6m01pN2+aewmtRln59XE''||'||chr(10)||
'''Ygn1461XrAgNiXHR1LI8zB+2xNccN+pk6QuVV3VdtqZdm+EXZSbZrtRFwe8f3i81''||'||chr(10)||
'''tYvQfrJU6Opiik3+bsMnuN3M6hz6ZwebnDLyQIpk3Bp/20Rem8aMBk5lODmVY2JT''||'||chr(10)||
'''uelwzic1L9aNLh0YTBnm0cd5lsUxzV/RIVw4ck/od4rrp5r5VH/AOp'||
'zps288md/3''||'||chr(10)||
'''4hKakZBFdF81xmmTuv3ajeEYThL8yNx3+NMvn6om45kqioJleF0i43JWtw8HC1lq''||'||chr(10)||
'''gfNPeb/LoN++fKYsW0jGwvdb+rbkxdQ6HGJMrOtF2y5e/Q/ZboVatXblHGWMmK6+''||'||chr(10)||
'''S0zjzH/aqj8o+d+V6e+G3cBnuDRvhfNQePgtQOmlYT9/oe78YcxeZph49iBFKjCU''||'||chr(10)||
'''MZQYqhgqDJcxXGJ4FcMrDK9jeI3hTQxvMLyN4e0U8gIYBcYTC10cXBxhHGAcZRxk''||'||chr(10)||
'''HGkcaBxtHGwccRxwHHUcdBx5HHgcfQJ8An0CfAJ9Yto39AnwCfQJ8An0CfAJ9Anw''||'||chr(10)||
'''CfQJ8An0CfAJ9AnwCfRJ8En0SfBJ9EnwSfTJ6WDR'||
'J8En0SfBJ9EnwSfRJ8En0SfB''||'||chr(10)||
'''J9EnwSfRp8Cn0KfAp9CnwKfQp8Cn0Kemm4c+BT6FPgU+hT4FPoU+BT6FPgU+hb4l''||'||chr(10)||
'''+Jbexy69rNmfUlNf/L8gvNwfVlv4JbsIAAA='';'||chr(10)||
'  t_parse_csv varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+2ZWW/cyBGA3+dXNIIAJGFKGB7yIUUCHEXIGvHagS04eQhCcMie''||'||chr(10)||
'''EQEOSTR7dAT68anq6uI1nJEW67zFwK7YV/XXdfUxi1xmZarkQj81UugmyWRZiqIV''||'||chr(10)||
'''Sma1yhdunuo0MY33qcruUhW6gbfwW62KapPcp2VfH4Xv3r6Dtmq3XUll2uhz4YMU''||'||chr(10)||
'''aSrwY+Gvynplivix8C662V'||
'X9gJPrdFVKUa97oCqXj2L1JJqyTYpKy41Uo1HtdJiR''||'||chr(10)||
'''dHRUeyelHi61SreDVYbL5RIWY2TbOYakqJfpnFbi/Kw0wo7EclaXpcx0UVfJKm3l''||'||chr(10)||
'''VI+TLmO4roulCaHniCZt5GOSNk1ZZKkZvwFNp+XpfZakSoWHIEMWdrFoVJ3JfKek''||'||chr(10)||
'''2D4lZb1xm2TbbjoEb1G0i5XcFNXCzJXL1W6TbGXbpht5Cv35m8b5TVLKe1mKyysR''||'||chr(10)||
'''A7is8ovFeleZxYkmVa1cQM+8zsgnfKvNpFJDRHF+CT5VltguH7VKRb7atvVONzud''||'||chr(10)||
'''lEUlW1hd+tR18xZK6p2qWO8IrcmlrGuhmtFXyMS21Fl81m7tvciA0bTJVif1et2C''||'||chr(10)||
'''3cWAMcDG'||
'VmVd215j1ha5DQ8slilEU1ZDp0dtq7Errg6UvzrN5TrdldxPP+KYh1RV''||'||chr(10)||
'''EITC/Bs4mqwHQRkK/Gu8qZXNIIj7elnBclqZ7zUaNd6XbrtbQby7VuVu6PmBH3i+''||'||chr(10)||
'''8wfHjC9lNfX1pm6nVa1OlZ7pZ3An1WjJJKv2uq8LWeZQkY8bJNokWYMbCPmYyQZ9''||'||chr(10)||
'''Cruvduu5qILqORpy5mItyA0hmtCFRK16K2ykhsVu9B25qicuxXKh72TVuZn1EnBv''||'||chr(10)||
'''UaxHyn2dLo1bQNesTkvZZtKtABEXAF6UFHk3LvIw0Y7bdrpMiuB9dbpNG64fDPC7''||'||chr(10)||
'''9r/efLn59uk6uf765fbmn7d9w6ePXz4mt1+Tr98+Xn++mZnCuf7l47fk+rvjYS4'||
'E''||'||chr(10)||
'''Xe2aRvarCTwPHFG4zi+3ju/8+xP871+30NeoiBwQ13an3A+YA8r2sIQfRsLfUMKP''||'||chr(10)||
'''WQlBMBFhNVvCzrQdygMFg7bAVAD/zSFJZGv5KLOdlqLYbmVewM4kHNMgzh9xFkc8''||'||chr(10)||
'''P4teEJacC4GZyxG7FiMPPc5AAQk73uIBJhA1TKMgjYywnQvHZj7gln39wC/m6NE9''||'||chr(10)||
'''Lhyv96rOHzMlgVrLbVOrVD25Jjn5Wu2kN+xVV/dSaV1j1qI+mD/BgWFj5k7w3zZ9''||'||chr(10)||
'''bIv/wPY8ymtY7DMZltBH8e8wZ2HZ5iPrGUWF6yEitNcSbHDVhUtatHK0P0mlauWe''||'||chr(10)||
'''4K4b+M6XWotUXH//cbIuSunwklgBM+KDyBjIfI6monzITjPqx'||
'f6zJ2vZ94oOyxr1''||'||chr(10)||
'''OiLriICDo45M2881DE48H7hkG+Pr/7h5f/Pn6798uj5bLp0ZMaENHznHZNVsN34H''||'||chr(10)||
'''t2d0d7CHeCj0ndkd0kxLnJnC5CAKBo1P0YIdF5hrVPpwmqXgYbrGb9cEAnUVaSug''||'||chr(10)||
'''AOJ1rfwjIziv9sOoBifq8EQKKzkmpC778TdfPzvmhNftSqCToWGov/G+vs+VMBvL''||'||chr(10)||
'''K9w69J3PsK8J2kGErmsBJ+/NvnfTjgqT273GzO71eygfIbpdkiv67bE7ZcAJ57Q/''||'||chr(10)||
'''wmMO+u7sraBzM9wwoY/NRbxqM6vfDTixNew/RhgS/0xVkGNaHgPS66fXU7+Tm17m''||'||chr(10)||
'''8wQWXtZ1Axm50MIkY1bcFYGa9c+uMcDQ6X2'||
'L1WK0OLjxoBqdkT3s5xuem05A+/5j''||'||chr(10)||
'''Bfu9CtkUg6MEak70Z5pR2ptgw8A3wW/A3q8E7z9s7pNuXd5kuThx2Nnp583k2RO4''||'||chr(10)||
'''O/Bmr5f3og4gd3RnhT3aSYQMimg4yqmzwrtAxARglV2XPBFeFNw+HC1uf5uAw3sJ''||'||chr(10)||
'''m/SMBoM3I8nToO5Lbw7E97FMNeNkw/D9yeE6SimXr0ope3H++rzzYgYYEIk/Udgf''||'||chr(10)||
'''jC5iOGrFqd0GyQiyzDg1YQIYpkY85NnLBCvFJodlN/kkW8CqfDOQtXAyWOkwaQxy''||'||chr(10)||
'''txVBgIPu+3lzmHLMDjlruJmY7uxj+WbIjgfvUS1bTRrDud3yekBjRwvq4bXsZ2H/''||'||chr(10)||
'''xgw05w0vZpYDWfJ1aBPv/'||
'x06nrKj5P/noP9VDprEXZ8culvXWsnp9c3jNye4/Z2a''||'||chr(10)||
'''Vz88bnRXoWGreali47YXe48Q4ytpn/NILy9AHLVGxFc08OMin72o8YPK/kMnEJ9D''||'||chr(10)||
'''nbkndA9sUGleAd1zczP1MV36s4972ANTI/zBE4/963nj+wocspznZxION+BdpZ+f''||'||chr(10)||
'''HWHeFFsBSqhyZzBiW9/jxUHX4rqDdVsPu5jXzX4J9s6d1CqBtVYZfvet7t5qYdbk''||'||chr(10)||
'''j79+/DuKWkPSKvB5IxCnp2LIxqfG6YMvxfVEf3CQghsMXnJc1FKxdgs4/uyvhp6j''||'||chr(10)||
'''8fpTAMW5cHAgOU9BroUqgTUbRU2mnll5mufJVuLT5JFl4stCBnf4y6vxVLY+xPrJ''||'||chr(10)||
'''VNhUmSH'||
'F4vcp3IKbPMCTY2iQkt3hlTrsTmVoFTWxSjewhPsiGWdfKGxYrW5dZV+n''||'||chr(10)||
'''UE7WyTlbWpuGbuZBH7xfo/HshWQoCFpZVuaZJ6P++a9LR5MB0HOwlfiBH+PPFT77''||'||chr(10)||
'''xWz//ncZ37n99YPzQnf+zcZ38vxkuz15gn8OnH7pAWt80NH4q5BLL8aOM5fyDjtT''||'||chr(10)||
'''u2/DgRPRz02d74RuyMXIFCMuxqYYc/HMFM+4+NYU33LxnSm+4+J7U3zPxQ+m+MEW''||'||chr(10)||
'''gyVhLLlssZgrIK6AwQICC5gsILKA0QJCC5gtILaA4QKCC5guILqA8QLCC5gvJL6Q''||'||chr(10)||
'''+ULiC5kvtHpjvpD4QuYLiS9kvpD4QuYLiS9kvpD4QuYLiS9kvpD4QuaLiC9ivo'||
'j4''||'||chr(10)||
'''IuaLiC9ivsgalvki4ouYLyK+iPki4ouYLyK+iPki4ouYLyK+iPli4ouZLya+mPli''||'||chr(10)||
'''4ouZLya+mPli63nMFxNfzHwx8cXMFxNfzHwx8cXMFxNfzHxnxHe2NG/u+5E1yPoy''||'||chr(10)||
'''n93CMGL/CyKJQ6rpHQAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xml varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC6VWW2/TMBR+z6+w+hJbpFkviKFUQyAQEtLgAYrgLUqTk8arY1ex''||'||chr(10)||
'''u27SfjzHzrXdCuuoVMXxuX3n+Ds+8fKdTA1XkmyTSoNHt3Gm0l0J0pCVUCsv2Ma6''||'||chr(10)||
'''ADCa3CZVWiTVjERXRO6E8JhXgdlVkhg0Skzice2Z2FrFqeYZKpUrqJy60'||
'LG11WBi''||'||chr(10)||
'''nlH/w/V89nP5+a3PFmhxVwqCf3O/BfsquARtfVZqr+2Giy8rskUvXBpYQ2W3UXy8''||'||chr(10)||
'''lSpxvHWbiA45nc8u31y6mIgX4rw0vWw6mTCL1c+ycVmO7/FHimL2Oip5pLVvjWRf''||'||chr(10)||
'''BDpr1RG51FcjrEOk0wLKRI9LnlZKq9yMU1VGKs95CpHeVpBkLpcR8cnDg1ebovMz''||'||chr(10)||
'''rWssGclWpbbFy1QZ4l+qzNVPiqckgmtTS2d/F89Pi1ew5tIr72Oh1tS3hOFyTX5/''||'||chr(10)||
'''vSZ7bgpiC5OkBuwxuwwPzl0mJdABPVh39ljF5vgH7AuGqkMWoPakKQAuh1jLZAMW''||'||chr(10)||
'''LB1ursG0LkGAfRyIJezx0WpQB4jV0KToA2ixrVQKWqs'||
'q1OgnNTaQphZG4F/8UtVm''||'||chr(10)||
'''pdTGLRxQP7B0QT+5qggnXJIJCUNyhEyAXJvCehFsPPWEUtvDTLuXV9OFx3NCSdeO''||'||chr(10)||
'''XNddaP1LbSrqR67mnQKucStoto1yJ0E7j6xRYOQdmTzXy+NqYH/tQOUHReUGSpdU''||'||chr(10)||
'''wFngv9c6+oaH35TkICzzTAGy7seE1o8wVTtpXk1ZaCnz9BmcHXXR0db2Uc3OJ6LW''||'||chr(10)||
'''MVl3DYVIfTDQXjeIZdo20T+5cRrbMlkJuPiu9gcsuXkGS2YDmjSA5K2gZxZoFtw0''||'||chr(10)||
'''FfoiM7hrUHiB8+mx9ibts52/MNs60EcQ4iDTzTMynQ8ybcC8INN5sDmRKfqsM7UD''||'||chr(10)||
'''4nyO1Y7R7yfkTpccduj/+LmwQJd4D'||
'7atguMF92HJkcdtpzR4u35WbpZRJwh8O7bs''||'||chr(10)||
'''+Mqy0XLUj69wNJlMRj4L+smHcAHvUJ53ZKfu/Bl1xWGh7YrY3spuzP3wT+nhrYFj''||'||chr(10)||
'''oMNlFwMGuYW9vWwwe56DXnKLY9mjnqSMhfZToLZwCHrovWX7LeIsnWDxB4dfK6rd''||'||chr(10)||
'''CAAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xlsx varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC70aa4/TuPZ7fkXEl8Q7mbZJS+e1s2KXAS0SoBUDElfcVZWmbidL''||'||chr(10)||
'''HpXtznTQ/vh7ju04zqOdzgC3AtrYx+f9dHCWmyIRaVm486ycR0W5oP56hr/lAnEY''||'||chr(10)||
'''FRtWuIt5zmfbPFuU+QD+IpyTcmdOV2nhpEtXn0m'||
'5W2yyzC2ZOgFrgxUVGS1W4kYj''||'||chr(10)||
'''Ju6lO3LEDS0q5HjkwqHFwk2XF30U8/grlazZi4B3USabnBaCZhS/GtsFvYOvCsKH''||'||chr(10)||
'''VXG/roQLiozPkpuYcSpm6cL3fn87jj59fH3qEfwAM9uErlEvzh0w6pbALuOK6QVN''||'||chr(10)||
'''sphRR8yA4R69XMBOgsqoPviAiwvKxaxcLoGm66bA9YoyXOcsMcv2ehYXq1lSwsJW''||'||chr(10)||
'''gI7yOWXu+WWt2AVdxpusghNbPHMXsyItVoqwwaXMZA4mjMaCCpqvSxaze1/xGwi2''||'||chr(10)||
'''oaTNKBAM20yqtRpdWdxSJkSJWDQyJ1CKdgIDBn/zeMvTb9QJGjTwsUbv7LENQtpa''||'||chr(10)||
'''wWctsSM5B4tUGvpxrqMkkm5hh'||
'Fky2lEgMb6LjEiH1v+0gmyT2zEGmoL4qIwFT+uS''||'||chr(10)||
'''V0+kDhE0fx1yenkjshmL7wZJDNoU5WyeFsDPTJ/2Dbt8M+eCVc4vCSpCJKhQZKmA''||'||chr(10)||
'''OJ0Bv2lckDbjjV3Ek640T2joe0G5uwazacJohInhHbDvZFwz1pBjycq8LYmkuIPX''||'||chr(10)||
'''IKx46LCdlNkszpaSZfjt3sYMPSsyvFlMd3iMeZKmvlEdnA+OQ0KOpxPnqLjNfL8P''||'||chr(10)||
'''IAoUCPklmgYjsgdybCCnJwja5h2cdLZMM+rAgW/pek0Xtc9geOHerIhzaqRyjFgS''||'||chr(10)||
'''BuQBp8jX8gmjI8UMW+eXm0V7ZZm1V2iRlAtMKBUNPxzJSLNctsovioCdoezUb4lA''||'||chr(10)||
'''jiPIH1lZriH'||
'PpsKVKVad/tUNG8XDqMw6HkwCCYyF5AayAMTgne89H03+GD0fTT1y''||'||chr(10)||
'''UXMifxyHqrggwQssVprU/jJk9ANorLDt4eMonJIjoLEExlNQCogwGOw6E+kzp0Qp''||'||chr(10)||
'''ANipvHqeillcLHqi1kYQBhVnR2ckqOUfYe1qaARXlICWHUGaOqGCtBmn7e1P16d/''||'||chr(10)||
'''vZyMT7xaGbLC1w53KXlOw9NiAJQw8aBvOPs5d4I9KtESRacyx+unydSRjxV3jhEH''||'||chr(10)||
'''vW+/XSqEE6JNjkeMxWHFsGjEwuhG8/ne0Au8/2rluS33QIXpFcj/4l6S9EmtK0tn''||'||chr(10)||
'''+y1pyQ1B1TLdaFQbT4flQQJPIun/GPbnNsbw9ekfiNX6jD3SqOJrLGRwEJPLIXaz''|'||
'|'||chr(10)||
'''1QyZLghDNJZi9mgcOkd77K2hohNyENgZcWxeY4CCQJHcmqIAPUESiweix+IZotYJ''||'||chr(10)||
'''mnVNegmQcupSjtiTMl8zyvkg+zaD7KyfFHnygww++i6D72ntUEW6szvE1lIFYMuf''||'||chr(10)||
'''bErTKAEP3dCxc6+dDfbhrzOIewjceHQgXETs6tEuFVa9XmPHisUaGkdTpPkN9Inc''||'||chr(10)||
'''VE8UCM/iFtiexdJjyo1Yb0DxaUF5zFh8b8BMQReANhaxqumsvOO4gt+yX4edCkI/''||'||chr(10)||
'''0/BsNHHnZZnRuIA1GH00BMUhTcTzjLrlsoKAtLegW3d+bzdEiGq7VGf0Wdljb/Jl''||'||chr(10)||
'''LnYty2GlXtZ0IRYgf/MGadNRjKOT6QnZyYJUIQwC3EJUr2Pi7uxo'||
'as1V1qYoQfsW''||'||chr(10)||
'''Rd/ibZz1LRdM98FSWx31dVaSjnidFcbaK4XFZjQCz8UyDcNKwS+f3QixPh8OeXJD''||'||chr(10)||
'''85gPSsiMsAO9SB4LeGSrIYd0FS+kuvJsCOenwzxOi2fexd4ZtlhEu7fGu7Zo1t7R''||'||chr(10)||
'''E5Y819nEY1nK9W4vwXq7l2i1LV2t7lKlcWDebCtctar5PeTBle9hzGLb8/nt9WfP''||'||chr(10)||
'''miDry5CqC1dxHXjbbHhXsq8QN18HwIhHSCPi4GxW3lWj15Zna1YmUCxKNgAH2tBy''||'||chr(10)||
'''6SONwDNYzI+/2PBFhccL0OhEtyOYvqEjCTWHWT3j2vg5KDoRyDTv0FBpSH1p3Fa/''||'||chr(10)||
'''OsJ+tTUf674dyZHjUPWqViz66VFI+vmo5LQRpl'||
'CRJK4gJYH3gp2nCxBIevA5O8SH''||'||chr(10)||
'''y+UyTeiVHsmVEzOaxZh5+U265s+Ucqyk8H0sIgqvkfptYBz/zf1AS3PlXUGZdXkA''||'||chr(10)||
'''g8qhnsXFfUa55VePsLU8e43iDyEhvc7B3Or7e+yNSe+pGlTmewk8eqoH94E2NkUS''||'||chr(10)||
'''beAtFh5xf4OOHNmyN/J8x8b9vd4wjZJVi/ZE3D4zSxW9WeDshM0GRFqzHVG2b1IK''||'||chr(10)||
'''JxZwa+v57q3p7q2TnVtR1Nx6kkMkNMs+L/lwuxzWEv8otzCwSF2qfKfCidVS+KkS''||'||chr(10)||
'''zJZ2QLeQzbmyN2l1FeYAUof6Nznz/t/hCaWFLq5VS2GiFDy7KEVDGSnH7k0hr1x1''||'||chr(10)||
'''i+hHuinAG1Rs+S8qjT7GrlwM'||
'efplXfIUs59Pfrt85rn//uvqMRzgtr8gFUx/sOw9''||'||chr(10)||
'''c2MQrob/tQWPBwBWntEn/jbeUV/Q7PEMt5JMGWjbuA15RHVJ1HndtMGYslF9g17w''||'||chr(10)||
'''EYQc4HldDWKVz7oXwc1sIIbSz0hl1jZh/XbDJJ8sethou6mxYU1PqeufA9QV2fpq''||'||chr(10)||
'''q6W9BLZ8XIxGwT+kUfS6qbC79/2RFzVDz+2JvRlUe95ovQa4Ik3VvHizuhTlQeai''||'||chr(10)||
'''zTfzWGVJU2G8cxkSBgCj4BxalPNGpKREb7Tq0wOnm11JE4fJD6pXrXIEjnYDaG6p''||'||chr(10)||
'''Gq5wsvPVl5IJ4nUgr+KU1Rv4L0x7i32/28uDGWn2VndpG0g5H+xOq/H05cWbRZVO''||'||chr(10)||
'''7O6wyiPDFx'||
'9jtsKm8/B5ZR0nX+MV3d3kHZCqNUdYRsjFAdl3/KieWgqquukrMMkQ''||'||chr(10)||
'''rPWz8/GBqXi8MxezA5LL2EouT89u44BBeku+3P791MSG82UryzdSlB40e171Va/z''||'||chr(10)||
'''JA6ixv5uvYgFpMn5BpoQxAOpWPkVk7AZ7CEpFjDzyxuF0XjyfHpyeqY7cxmq9eul''||'||chr(10)||
'''faAmslfyco4jd3INamzSDcSnVTUpcODd2iUMbzIeFl54VbUT2FZxz1yRK8YwV5ai''||'||chr(10)||
'''UfkwO6GwjOCrTzLAvKQGcLyYuPYuemBUZapEtSpVOVMXKL4JV1N0Mq75kmMwnIA0''||'||chr(10)||
'''khZ4T3Ytf9PqyvRnMws/GmxRdfODe032nSCJOVVR2phdXnn1/3uAbj4ueBZLE8jd'''||
'||'||chr(10)||
'''gXGa4PgIBLs6qz4gIdKzjuirZXUyDNpUjkOyH5/MKK/g46FETuC9f3s9e//p3asP''||'||chr(10)||
'''b17OXv75+4ffX3589eH6chB4jr4je9iJuHEibttAZjrT8pv23tIZXnI0gNq7h5nx''||'||chr(10)||
'''ytPkqxuUPceosWupKELIHsMfdfHiXV0dv3t3/B/4eOQIzWwsfjCuMeIatXFhjLLj''||'||chr(10)||
'''aUhariT5tgedJ2ngMY68UxwL3/tefIqvGp/UTuv2/qGe8UfMa1JnskmS7ZBspbSa''||'||chr(10)||
'''9BBRcY4wWcwFGSxTZl0V9gO1NGGVTt1bGtCqWunxT+9oD2dNo/VqWGgKXXV1hQsV''||'||chr(10)||
'''OmQmsZiRVaQqmhVe9W7C8B21+DZcG94qphPDdEtBwH5TKdiJ7GR'||
'cHm6MSjWx8GFi''||'||chr(10)||
'''YYeY8taGo7ddbaeVemzUK3GfnPuNZP1CBveYpkm9TwV9gvfK2h3K1OuyznxABvIl''||'||chr(10)||
'''kVFrH5qnR2BE7Fd46rUTvgz7Hxf0btZOKAAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xls varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+0cXW/jRu7dv0J9OEhayz5JVmyn6RZINwmwwO72sGnRuydDtseJ''||'||chr(10)||
'''urZkSHKTHPrjj5wvzYwl2bGdbHHbIICt0QzJ4ZAcDslxZ7FJZ2WSpdY6zgvScdaT''||'||chr(10)||
'''eTbbrEhaWtNlNu1460lxT0hZWH/E+ew+zkPr+7dWulku8RV5LPPYmk9XRbYp15ty''||'||chr(10)||
'''skxSUsR5Hj/Jbm4nJ+UmT60SYMdl3E'||
'mKTjmZkeUSW/DzAp7z7KHAZ/zEZ+wpRuDz''||'||chr(10)||
'''Q5Z/mWbZF0oVNiTp3ErSktyRHB8L43lJUvVxFT+aTTOYovJ4l0+T0srjBydw8Xma''||'||chr(10)||
'''LBZnFqBckjilGMpc8sAZhKPhiPZL5lVrZOEnbb4n8ZzkFF5EG8rVmj5VI3MyM1pg''||'||chr(10)||
'''siQ49yMF7dOaIBuKAogFBsXTJbGyhUkITGROHq3pk7VeFhOVLTCODa9gIRYNGMfW''||'||chr(10)||
'''CORxwcbwsdi0WJVmG4cOneGlBl8B14YDh0kAHEkdx/F5UhDlXeD7Lsqb/dv1+OPt''||'||chr(10)||
'''b+8/BeFZaCvcQwmm/Aay4CPL5x0njVfEBN/xFDHquAaEQpuVDreJ/2ychCDbtOF0''||'||chr(10)||
'''VuZQirqaoivE2Oi4'||
'zrMZmW9yAhOL55NNmsyyOUFpTdI7pmvQpgnalNwlKZdorqUX''||'||chr(10)||
'''nYf7BObF1OJHy+8ss2zdSRbWplxOYHAftGMSp3OHa4p3D7qfIVTbD2zXtd5aekun''||'||chr(10)||
'''vCcpAnAsi6lnlwJ/EwJ4ARRU8q68dygT3G7QAQTUmkxAyfvFZgoUOpXue6FH9b5L''||'||chr(10)||
'''1bsb6UgH73wf0HLEcnbsy59/UpxJME770HtSZlSMHEGIxAWEeIxc17MvPwTDX3+5''||'||chr(10)||
'''CYYfrm1X2AwKE770jEm0gXKtf1qhsFoUgDINYa6gXcCYxUWJNE6TNM6fxGI7e7Am''||'||chr(10)||
'''dD1JV1KWSzIh6TyJU7eycYCnBVDAAUXSRrX3p7T35KguE9SCTzS46JAl7CvHL4fH''||'||chr(10)||
'''pa'||
'duWQrJVlXOlAXzgQxU7AUnZ1ssX0UoAS0n9oe39eiE8OJuochDnUwdJY9yWTgi''||'||chr(10)||
'''ZgMEj75lOd3NeSaJjYJXL3Z06RE2bCFpVjLXSAiFQAbOVFosYTt1aF/JoUdovyOO''||'||chr(10)||
'''fXNje/boxgYdgK8uhSXh7KliDLL96+3o8vbd+/d2JQq4TUhRWGSwV8O2ZgVWv78t''||'||chr(10)||
'''qwDDZVuEHCdlIktncenQdm+LjYg88QJX3T9AQ1zGKYR4sf9MEINpDaSe13wy8PAN''||'||chr(10)||
'''5if83vxLmG5WU5BacD6/4D4pHVbWjnso2zF5Mwg9wX5lBnNwzP3RmDECBVmFCdv+''||'||chr(10)||
'''AOYJ+yyokO2HtoWrtkuTTOgUnH3z7ob+2U1KBNtNJDANXhyT7wtcfjuue'||
'bYB58kx''||'||chr(10)||
'''JAWGsT/bQ6RNmASO4EgcuybaMlPwM5n06CIEchKiEwyg4CsXGylF+KaSIWoHhJ/P''||'||chr(10)||
'''FFccjzLajt5TD/7xPWj71VXv48fef+DPdrsUfiXSdQMHONA3BzLKesPA5bQbXuNs''||'||chr(10)||
'''MYUuswU9XbnMa1ROMGdByM5ETyWZgPMMzYazSlLwOsHhtCzFpfaZjSz+C63aAIs2''||'||chr(10)||
'''s/a6V2RWvp9vvWLGWbwV3f6BfrLiqJNZMjccdbVno6e+KuKyAkAJhwajZbsPQM4Y''||'||chr(10)||
'''k0I/GrMJ32c5bAFZWsZwGs7liRXMAYlX8hG3UoMG80gijpOzyU1OyOSWzN5fUbYA''||'||chr(10)||
'''8KKMYZNRj1bfv+0F2Pc6nU9+Xkze3QN6Pqapf4j9by9'||
'/UUA39h1g349656a+Efa9''||'||chr(10)||
'''ev95cr1al09aT3bCRuuu7wBixC223ZFdIwJ1BOXrrhFhNeJDNvti7aZqUI34V56t''||'||chr(10)||
'''SQ5TaR8RVSM+Z7DL78ZxZisHMq5yNY4MKqcHauihBlPvVfYWTgCI4dY2zbq41g8W''||'||chr(10)||
'''jFV7yP2Y9YAdauxa36mUXfnvboLg2r8MfgqCy+ug8mKZ2VG9RcUuAO10f3xQTbSJ''||'||chr(10)||
'''LTz3Qt1PvrmmDo1m2DXza6GTohxG72Q7mjNqVRUq3tYDEY6StFYYM1D9B+kL1few''||'||chr(10)||
'''1UlT+wWv19kDbJ+ht+f+avJiEAAvPJV6l5tNgH8C8IM68NK789G7C/zzXiC8OW5e''||'||chr(10)||
'''dzv5TRhHo27yJvIiAyuw7hGceioXE'||
'gsIi2LahBl2Epd7f7SX4RoeS9/wvIY2Ef3g''||'||chr(10)||
'''0L9DwrbtqMqjrFlPqWygtnbptzcCLD1z6KxnYgQ+VC8UwCkH2Ad4L5u0dFz3kOky''||'||chr(10)||
'''Ij1Yi25Qtxon4SlH0qtdb4kB5/y7Mmd1brrkPYurlFO/u61sraBTrr4aU08rsnW4''||'||chr(10)||
'''vr7IVrzlzP0qIiuXlracTLI566O/orUIwnHF/P1CMs28BmDd4dnWLsE3VYT+oxWK''||'||chr(10)||
'''nZN6qBzb7uidhiPgIRiKSOyvyoGdug07yByB/8POgarrx4iTzJ1BW0lKslqDb5E/''||'||chr(10)||
'''OcLz9sp8Q1zjGHEs54JgVCMgp1mVIKzTgmpZDhbqs22aGQ+FYCsMahVuyfN4vSY0''||'||chr(10)||
'''OcBZvaekV3hA2mu'||
'WRuh21aobWXTWXozmrZOcx7wy/rEf+e30c9GXmMs8WSnyisss''||'||chr(10)||
'''VpxqHqa4eEDTFiopM6MiYAZDjbijGPvT/uMUJcOTzG4VM1n1arp2gvU3aH9F4a3i''||'||chr(10)||
'''7mj+DtjiYH0luUnRsiJ43gqMZVyA6902RBOjJjRUcPaCznpqIVlx9l09wZA7x8Yq''||'||chr(10)||
'''BDx2/fvDLR6MleCUKEsQ+iDFl59/LdgpJeo7UsozsOiIJPqMRIHtU2ZJMAuUogU4''||'||chr(10)||
'''L3OKOE4KMgEJWSazGIN8E5LnWe70Qt/3Bx6MLK3Y+iNeJnOktYejbSH0W2mUQC1B''||'||chr(10)||
'''UP2AWjr5AX+PnJORdT33x3CGhr99U1YRFg5YjhqIwYBERwvO+0N69N8T5NCg6UxP''||'||chr(10)||
'''y'||
'rKqivZMjUKdHiRiwZLXSkLVp8CoCVFPstjtR+zG11cp/mifZsTXkBeRQOetnMJ2''||'||chr(10)||
'''lCZ0jYN0godo278ENh/hdohggdfCEap1DN0NZjW5tpPZMs4xZJJvtPIaWLfqsQo3''||'||chr(10)||
'''x/M5NTCg0UYA1DWC5DSjxno1ZUu7QVNE6jkrIDO3z18JhSeDiifHpk8PX569css8''||'||chr(10)||
'''V2pkSForIXblVaXGVtnEPTOyShZXCa0ZWVk9O61sG1rX/bPAY46VpjVkcELLdD7f''||'||chr(10)||
'''qAhpGjcmsKjtkAowUDP4z5UIJRvdasSMBHWoZdfboAZ1w4OLPSuCxlsVQWNRESTn''||'||chr(10)||
'''z1JKaDVedf5CPBlePUO/x8yirZlFWzNjlgQN4HEzi3ZoO2L4Qfg0EiH9'||
'0o3C8+h8''||'||chr(10)||
'''OArPh3WKxdkRVfHuR7NgoaaajBcU0kiPHuihzt1FxQHK3zdRlwKur5RQOmwl54Eo''||'||chr(10)||
'''xbKOzxTL+nyzwnID6HcIGEfoHAYgWsStrXhkrNaNYOVfvzWYwkolqmrHyrIeSb67''||'||chr(10)||
'''2waMRZrpuOI/WcdRi+RcVnSZNWLM3Ldz81xy8xmVKgY5slIF2g+rVFE0a58VRTxN''||'||chr(10)||
'''9SoCBNeTQ1Y3aLMYHH7hiC+mAmOjqXphqKierE4+zH0PWJZXRxBcg/38i+j24HDd''||'||chr(10)||
'''jhTdxqrlV1XqVrdwl6qfvYaqD49S9eFfTNXbF7hdx0XdvHOYfjcutNsBihxgDesN''||'||chr(10)||
'''aDx7PrddWsqNXFNfrFYNL56e+IstPb32j9qDRX2/I7'||
'4clSbaKfQ67VF4rP/gVAdC''||'||chr(10)||
'''dpSiYRM78MOR7YGojDHGgQGSFI6zKAeg2oDcofcRLt99/vnj5acxr9cUtZ9SceR1''||'||chr(10)||
'''BnGBQQ7YLmJsOlmqYUMpYkHETHu+IXr7WUP7sKF9VN8ehkq7majSl7nKVvG7JDLF''||'||chr(10)||
'''L6D1yWNS0N2JS0oCsoEsVRCq7+pUE2ko1GSZss9VFFSOKNsPC7dfnW1eK+xmBLaG''||'||chr(10)||
'''9qEBtsD3hfA5lnpPRdQEMQW3v7exjlZ2gO/Q5PFmYb2KbuDyV4aB2DFe4SV1gVQY''||'||chr(10)||
'''SvSPXV9h5wx25as/J0vCrhThTS+HfbAlA2KkQ2ViuJAxXDynWLVU/B0rbI8V0it4''||'||chr(10)||
'''yh78OrHD0bUfHuvxCSNyyMZx1raJ'||
'CpMMnOmjILJLWGiYryTL8AWZ/BFz3vHS36qM''||'||chr(10)||
'''vOHgFblKcKwGwacKAQMkUOwDWd0hZi+wpXZlBoNCv6PpPxoJoG3ooLlCpU/t2oAZ''||'||chr(10)||
'''cBA+UzB2X1Tf4P3B/6VINZBiFLgbwtAYfTxM+E5LwzcupsMT+qHN4R3qYlL/lN4D''||'||chr(10)||
'''gDOah8XP7P5JbQ0wnRmyVa8AZtchtLtrf2vJ31ryElpCOvWXqral27gFVL9Qt9VC''||'||chr(10)||
'''sci1WKg9sJxTHTLuM9k3lx9ur23LuIJk//L5V2ilMetvY63022sdcXVcZZZWK/LM''||'||chr(10)||
'''67L+CK9pbGWWswfjgsmB4dEdbJ5ly1Pg2bGcInP5da/YHhLDOSJG2cJ7NTsUXTQr''||'||chr(10)||
'''9Hasty1oOFAisj'||
'WG4JnR2ZYLyWx2A7cxY1aDnafLKjPfquDZslJx+kHVElo1I8qv''||'||chr(10)||
'''JVZ33J9nGW37WzFherEdZ5fqpkXHnyb0lETjMhyTyNt12kbgb6vkcM2S86qK3dfe''||'||chr(10)||
'''z0+kS9+WV1MrXFdHnwFOmctutcnPkog9rcy+ovIti8jN1ZGpluYF+Yo8rd8Fi/Ig''||'||chr(10)||
'''Po+aE91f8Xz/09EL90I5YJmbOTHkzu56uVqQvbAFJs/StFmfs+7wjZP0mAnyhseG''||'||chr(10)||
'''8ND6tKZWXyQqjFgHLxIVlpD38zAT/lM4L6U0CN+0emZKfVdWk64vzRfRzBDNK4lV''||'||chr(10)||
'''YQMr77joL4F4t79Icvqrd5KZNZ2oRlcsZ6qSywoDpavIHwIlGF/jb3jSMq9qaxFD''||'||chr(10)||
''''||
'bsJl2BkGNaXbNDle1ozEzBRi6HpJBeFwq5/roXSHBt2SakmbIFr5sSmdQUC+zhTM''||'||chr(10)||
'''ITUSzn5Uo9B/0IhDCnYjC7aQcX9U3brMNHjjKtWsUe2M6+bZvkjGvZ2WpdGx17Gg''||'||chr(10)||
'''buK1c9XVpFKXrVSp26e/nynZWgdG/FoM/0lNPDD+DzoaiNz+UwAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_html varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC9VXzW7jOAy++ym0e7GNOm28M9PJbJpeOpc97aEPYCi2khhQJEOS''||'||chr(10)||
'''23QxDz+k/mLHTtEeN0Bii6Io8uMnUkl2vahNKwXpqNIsybqqkTXZcrlNiq7SB8ZM''||'||chr(10)||
'''JRTpuK5aYdieKfL3hoiec5xnJ6MoabZ'||
'HLXvT9abirWCaKkXfolqeKGZ6JYgB29TQ''||'||chr(10)||
'''pNWJqWrGOUrwuYaxkq84hIcfaT/UOMZ1YT2OD+bISQ1O2kmmTSV3O80MGfhY4pxW''||'||chr(10)||
'''dZiazNW6bcDF45YpHHIq9lUtQelkvBhVMbgKdrpt2I72POiZE655pUq0Yk/sx9u3''||'||chr(10)||
'''pvsRZCjqpL4UGbqtmGguxRD0nBi0OatqYSYTalbazEl1R8WlrJZ8VnxARhjyQhW+''||'||chr(10)||
'''/pWVy+UyXydbtm9F0u5IRhxZWu0SLdUZrD0znIm9OThC5WRDliMF3W+1UW62+FaU''||'||chr(10)||
'''OfljQ9IvT/er71/vf94/pcAbc2AiksfnHoFpdzF9SDJw2/tatU3WG1615UrcHmkX''||'||chr(10)||
'''5Fn6z/O/i9Xq249Fm'||
'RZL2A3iiK7UilHDDDt2UlH1ljl6FUb1bKQmxQtTxkjknVfC''||'||chr(10)||
'''MwABJEXUgu+RnnT7H0uKETVxeGZjUogXnrkgimWOk0P+4dhzK8kDoSDWViBo3sH0''||'||chr(10)||
'''YSubtzQP7Joq+PA3qAMJc2qPZEkooOhGD8Qad1jHpIMln6AQp9W+WSUFZ1SbDL3H''||'||chr(10)||
'''pLe7bLwlSZ1qDlEV1nTuYp3V/vNT2vD5jPrjjHa+sKLFKnGQfIQ8ERXHHCTqOHke''||'||chr(10)||
'''u2Edmqs/o7rzQeJe7P3/oGM4o+FpqYdLgHoBrHM1AzvLte8It3jIK/PWMRSnz+k6''||'||chr(10)||
'''4VJ2V3e0VlKfXNjw1BryChv4/bzlUGen6++sgcd5C2EZWiGXLg+GN2VoWdAjOBSS''||'||chr(10)||
'''QVF'||
'2wb0fg3o3AAJVM6AXfbqagxDKzZdPWgP3o/eQr9HpdyYXZajSd2nIYmhVc8iq''||'||chr(10)||
'''K7CGNdGbIBh6REYQhveI9BDo5sNAN58A2jsVauvHgUbtaM3V24G1GWixHFloR8j6''||'||chr(10)||
'''EFzZLeP5gJVwCKsXysP9CnbncHHzrX3aAlxz35xDt6fRKp87gR0+uN2cB67Lny8H''||'||chr(10)||
'''6Ius3LUo4+DFMVP29zIc1L5Z+TZhDRYzHQK1cizG+LJY5dgK0jQ8LKQ16/Bimlhc''||'||chr(10)||
'''JTil4EqI7z5qhNOHPnAyToZbwgTH2XQCX5srfH03oWQ+MTPHx2c67hA9PBM4vEea''||'||chr(10)||
'''Z0GSu2l3WXbl1If8SMpYUqeGot6iHJdlPCgjeCJDz45hRcvC0cuj2hUDg1'||
'qCRTwb''||'||chr(10)||
'''FMj8VtCjq+hWRlLy69ewgs4vsn8Cwq56uG3wMba5nWKTCxyAPL07rn8DAB+QK/EM''||'||chr(10)||
'''AAA='';'||chr(10)||
'--'||chr(10)||
'  cursor c_api( b_app_id number, b_page_id number, b_item_name varchar2 )'||chr(10)||
'  is'||chr(10)||
'    select api.attribute_01 '||chr(10)||
'    from apex_application_page_items api'||chr(10)||
'    where api.application_id = b_app_id'||chr(10)||
'    and   api.page_id = b_page_id'||chr(10)||
'    and   api.display_as_code = ''NATIVE_FILE'''||chr(10)||
'    and   api.item_name = b_item_name;'||chr(10)||
'  '||
'r_api c_api%rowtype;'||chr(10)||
'--'||chr(10)||
'  procedure log( p_msg varchar2 )'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'--    apex_debug_message.error( p_msg );'||chr(10)||
'    apex_debug_message.log_message( p_msg, p_level => 4 );'||chr(10)||
'  end;'||chr(10)||
'  function dc( p varchar2 ) return varchar2'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'    return utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( p ) ) ) );'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'begin'||chr(10)||
'  p_browse_item     := p_p'||
'rocess.attribute_01;'||chr(10)||
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
'  end if;'||chr(10)||
'  p_en'||
'closed_by     := substr( ltrim( p_process.attribute_05 ), 1, 1 );'||chr(10)||
'  p_encoding        := p_process.attribute_06;'||chr(10)||
'  p_round := substr( ltrim( p_process.attribute_07 ), 1, 1 );'||chr(10)||
'--'||chr(10)||
'  open c_api( nv(''APP_ID''), nv(''APP_PAGE_ID''), upper( p_browse_item ) );'||chr(10)||
'  fetch c_api into r_api;'||chr(10)||
'  if c_api%notfound'||chr(10)||
'  then'||chr(10)||
'    log( ''FILE BROWSE item '' || p_browse_item || '' not found'' );'||chr(10)||
'  end if;'||chr(10)||
'  close c_api;'||chr(10)||
'  t_fi'||
'lename := apex_util.get_session_state(  p_browse_item );'||chr(10)||
'  log( ''looking for uploaded file '' || t_filename || '' in '' || r_api.attribute_01 );'||chr(10)||
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
'      delete from apex_a'||
'pplication_files aaf'||chr(10)||
'      where aaf.id = t_file_id;'||chr(10)||
'--'||chr(10)||
'      log( ''retrieved!''  );'||chr(10)||
'    elsif r_api.attribute_01 = ''APEX_APPLICATION_TEMP_FILES'''||chr(10)||
'    then'||chr(10)||
'      execute immediate ''select aaf.blob_content'||chr(10)||
'                         from apex_application_temp_files aaf'||chr(10)||
'                         where aaf.name = :fn'''||chr(10)||
'      into t_document using t_filename;'||chr(10)||
'--'||chr(10)||
'      log( ''retrieved!''  );'||chr(10)||
'    end if;'||chr(10)||
'  exc'||
'eption'||chr(10)||
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
'    log( ''file with length '' || dbms_lob.getlength( t_document ) || '' found '' );'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'  if apex_collection.collection_exists( p_collection_name )'||chr(10)||
'  then'||chr(10)||
'    apex_collection.delete_collection( p_coll'||
'ection_name );'||chr(10)||
'  end if;'||chr(10)||
'  for i in 1 .. 10'||chr(10)||
'  loop'||chr(10)||
'    if apex_collection.collection_exists( p_collection_name || i )'||chr(10)||
'    then'||chr(10)||
'      apex_collection.delete_collection( p_collection_name || i );'||chr(10)||
'    end if;'||chr(10)||
'  end loop;'||chr(10)||
'--'||chr(10)||
'  if dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''504B0304'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLSX'' );'||chr(10)||
'    t_what := ''XLSX-file'';'||chr(10)||
'    execute immediate dc( t_parse_bef ) || dc( t_par'||
'se_xlsx ) || dc( t_parse_aft ) using p_collection_name, t_document, p_sheet_nrs, p_round;'||chr(10)||
'  elsif dbms_lob.substr( t_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B11AE1'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLS'' );'||chr(10)||
'    t_what := ''XLS-file'';'||chr(10)||
'    execute immediate dc( t_parse_bef ) || dc( t_parse_xls ) || dc( t_parse_aft ) using p_collection_name, t_document, p_sheet_nrs, p_round;'||chr(10)||
'  elsif dbms_lob.substr( t_docume'||
'nt, 5, 1 ) = hextoraw( ''3C68746D6C'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing HTML'' );'||chr(10)||
'    t_what := ''HTML-file'';'||chr(10)||
'    execute immediate dc( t_parse_bef ) || dc( t_parse_html ) || dc( t_parse_aft ) using p_collection_name, t_document, p_sheet_nrs, p_round;'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = hextoraw( ''003C'' )'||chr(10)||
'        or dbms_lob.subst'||
'r( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'        )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XML'' );'||chr(10)||
'    t_what := ''XML-file'';'||chr(10)||
'    execute immediate dc( t_parse_bef ) || dc( t_parse_xml ) || dc( t_parse_aft ) using p_collection_name, t_document, p_sheet_nrs, p_round;'||chr(10)||
'  else'||chr(10)||
'    log( ''parsing CSV'' );'||chr(10)||
'    t_what := ''CSV-file'';'||chr(10)||
'    execute immediate dc( t_parse_csv ) using p_collection_name, t_document, p_separ'||
'ator, p_enclosed_by, p_encoding;'||chr(10)||
'  end if;'||chr(10)||
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
'    log( dbms_utility.format_e'||
'rror_backtrace );'||chr(10)||
'    t_rv.success_message := ''Oops, something went wrong in '' || p_plugin.name ||'||chr(10)||
'         ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||'||chr(10)||
'       dbms_utility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot mor'||
'e with Apex than I ever could imagine''||'||chr(10)||
'           ''</li></ul><br/>'' ||'||chr(10)||
'           ''try running this plugin in debug mode, and send the debug messages to me, scheffer@amis.nl'';'||chr(10)||
'    return t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.820'
 ,p_plugin_comment => '0.820'||chr(10)||
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
