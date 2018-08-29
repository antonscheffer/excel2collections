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
'''H4sIAAAAAAAAC7Uaa2/TyPa7f4XFF3u2zsNJSEu7XcFS0EUCtKIgccVdRY49Sb34''||'||chr(10)||
'''Ec1M2hTtj7/nzIzHY8dxQ4EIiD1z5ryfE5zVtohFWhbuMiuXk6JMqL9Z4LNcIA6j''||'||chr(10)||
'''YssKN1nmfLHLs6TMh/AX4ZyUO0u6TgsnXbn6TMr'||
'dYptlbsnUCVgbrqnIaLEWNxox''||'||chr(10)||
'''cS/dsSNuaFEhxyMXDi0SN11ddFHMo69UsmYvAt6kjLc5LQTNKH41tgt6B18VhA+r''||'||chr(10)||
'''4n5TCRcUGV/ENxHjVCzSxPdevJ1OPn18feYR/AAzu5huUC/OHTDqlsAu44rphMZZ''||'||chr(10)||
'''xKgjFsBwh14uYCdGZVQffMHFhHKxKFcroOm6KXC9pgzXOYvNsr2eRcV6EZewsBOg''||'||chr(10)||
'''o3xJmXt+WSs2oatom1VwYodn7iJWpMVaETa4lJnMwZjRSFBB803JInbvK34DwbaU''||'||chr(10)||
'''tBkFgmGbSbVWoyuLW8qEKBGLRuYEStFOYMDgbx7tePqNOkGDBr7W6J0e2yCkrRV8''||'||chr(10)||
'''1xI7knOwSKWhn+c6SiLpFkaYF'||
'aN7CiTGd5ER6dD6n1aQbXM7xkBTEB+VseBtU/Lq''||'||chr(10)||
'''jdQhguavQ04vb0W2YNHdMI5Am6JcLNMC+Fno075hl2+XXLDK+SVBRYgEFYosFRCn''||'||chr(10)||
'''C+A3jQrSZryxi3jSteYJDX0vKHc3YDZNGI0wM7wD9oOMa8YacqxYmbclkRQP8BqE''||'||chr(10)||
'''FQ97bMdltoiylWQZnt3biKFnTQxvFtN7PEY8TlPfqA7OB4OQkMF85pwUt5nvdwFM''||'||chr(10)||
'''AgVCfpvMgzHpgZwayPkpgrZ5ByddrNKMOnDgW7rZ0KT2GQwv3FsUUU6NVI4RS8KA''||'||chr(10)||
'''POAU+Ua+YXSkmGHr/HKTtFdWWXuFFnGZYEKpaPjhWEaa5bJVflEE7Axlp35LBDKY''||'||chr(10)||
'''QP7IynIDeTY'||
'Vrkyx6vTvbtgoHkZl1vFgFkhgLCQ3kAUgBu987+l49uf46XjukYua''||'||chr(10)||
'''E/kwCFVxQYIXWKw0qf4yZPQDaKyw7eDjJJyTE6CxAsZTUAqIMBweOjPRZ86IUgCw''||'||chr(10)||
'''U3n1MhWLqEg6otZGEAYVZyfPSFDLP8ba1dAIrigBLTuCNHVCBWkzTtvbn67P/no5''||'||chr(10)||
'''m556tTJkha8d7lLynIZnxRAoYeJB33D6OXeCHpVoiSZnMsfrt9ncka8Vd44RB72v''||'||chr(10)||
'''3y4VwhnRJscjxuKwYlg0YmF0o/l8b+QF3v+08tyWe6DC9Arkf3EvSfqk1pWls35L''||'||chr(10)||
'''WnJDULVMNx7XxtNheZTAs4n0fwz7cxtj+PrsT8RqfaYeaVTxDRYyOIjJ5Ri72WqG''|'||
'|'||chr(10)||
'''TBeEIRpLMXsyDZ2THntrqMkpOQrsGXFsXiOAgkCR3JqiAD1BHIkHosfiGaLWCZp1''||'||chr(10)||
'''TXoJkHLqUo7Y4zLfMMr5MPu2gOys3xR58pMMPv4hg/e0dqgi3dkdY2upArDlLzal''||'||chr(10)||
'''aZSAh/3QsXOvnQ368NcZxD0Gbjo+Em5C7OrRLhVWvd5gx4rFGhpHU6T5DfSJ3FRP''||'||chr(10)||
'''FAjP4hbYnkXSY8qt2GxB8WlBecRYdG/ATEEXgDYSkarprLzjuILfsl+HnQpCv9Pw''||'||chr(10)||
'''2XjmLssyo1EBazD6aAiKQ5qIlhl1y1UFAWkvoTt3eW83RIhqt1Jn9FnZY2/zVS7a''||'||chr(10)||
'''y5oAOD0kat6gYVqH6eR0fkoO0pK6go6fW4jqdczQezuaWnOVtSlK'||
'0K5F0bV4G2Vd''||'||chr(10)||
'''ywXTDa9Uy56e9lbiPfH2VhhrrxQWm5MxuCjWY5hKCn755EaIzfloxOMbmkd8WEIK''||'||chr(10)||
'''hB1oOvJIwCtbjzjkpSiR6sqzEZyfj/IoLZ54F73DapFMDm5lXTtZyoXa7TxYb0/7''||'||chr(10)||
'''tqXL1G2lVDIMiG3Fqd4yv4fEtfY9DDLsUz6/vf7sWSNffXtRtc0qEANvl43uSvYV''||'||chr(10)||
'''HP3rEBjxCGmECJzNyrtqVtrxbMPKGLJ7yYbgCFtarnykEXgGi3n4i42eV3i8AI1H''||'||chr(10)||
'''dP+A+RZaiFBzmNVDqY2fw+wZC2Sa79FQeUN9adxWgznGBrM10OpGG8mRQaiaSyum''||'||chr(10)||
'''/PQkJN18VHLaCFMoIRJXkJLAe87O0wQEkp54zo'||
'7xRRjm05he6RlaOSOjWYSpkt+k''||'||chr(10)||
'''G/5EKccK7h9jEVF4jVxtA+O8Lt0DFX2s33Bxn1Fuec13WFKevUbhRpA2XudgTPX9''||'||chr(10)||
'''I9bE1PRY/SjjvAQePdUS+0AbexSJNvCSxCPuH9AgI1v2Rp4f2Li/1xumb7FKQ088''||'||chr(10)||
'''9RlRquhNgqMM1n6Io2Z3oCzbpBTOLODW1tPDW/PDW6cHtyaT5tajHCKmWfZ5xUe7''||'||chr(10)||
'''1aiW+AfcQhdpP1W82QwPYcDmgrdvv5AzaY6DxiA/OZQgydPkWhVpE1HghUUpGkKm''||'||chr(10)||
'''HBsfhbtyqx2iH+syi5eP2C1fVNJ/jw24GPH0y6bkKeYhn/xx+cRz//3X1RMswO1+''||'||chr(10)||
'''QyqYiGDZe+LCQO7W8L+34PEA'||
'wMoz+sTfxpL13UaPFd1KMmW6XeMi4TvyfKzO6zYI''||'||chr(10)||
'''OvxtIawWyUeQRyfXoVdN0U10+rq/stNPofXbCG92fXIcSWxBHrT+YWJsJCxyqPd/''||'||chr(10)||
'''jtD7xFZ8W+b2EjjF9wXfJPinGXzt6ai504RR3dxD0biASswbbdEQV2RMNm+xrA5C''||'||chr(10)||
'''+ZS5tfLNcFOZxNQH71wGiQHAuDiH9uG8ETsp0Rut6vLA6WbH0MRhMobqI6usgXPS''||'||chr(10)||
'''EBpPqgYYHJN89aVkgggeynstZb4G/gvTemJv7XbyYMaGXpeXpoEk9MHughpvX56/''||'||chr(10)||
'''SaoEY3duVWYZPf8YsTU2hMfPBJso/hqt6eEG7IjkrTkCQZSoD+Xj6Xf1u1JQ1ele''||'||chr(10)||
'''gUlGYK1fna'||
'GPTM7Tg9mZHZElplaWeHyamgYM8lT85fbvx2Yo9ohMjDkI235Ty+Sw''||'||chr(10)||
'''irMS5DYEYQEzT944nExnT+enZ890nyxDr/7tpQ/UROpa3lxx/LlNrgHl+LjA6pHg''||'||chr(10)||
'''1tNz/qNVIEwdEuAMHvfMBbLiDJNfKRo1CdMNSssI/jBIhpho1LSL0/y1d9EBo2pG''||'||chr(10)||
'''JatVQ8qFunXwTfyZMpBxzZecOeEE5IW0wFuka/lMqwvFX80sPDTYouq6BPea7DtB''||'||chr(10)||
'''HHGqwq4xSrzy6v8VAM11VPAMG1q9OzReEwxOQLCrZ9UHJER61hF98apOhkGbyiAk''||'||chr(10)||
'''/fhkingFHw8lcgLv/dvrxftP7159ePNy8fI/Lz68ePnx1Yfry2HgOfpi6dG+xese'''||
'||'||chr(10)||
'''xzaNzGimq686eFuVeNHQAGrvHmfdK0+Tr24xeo5RY+5SUYRQHsAfdfnhXV0N3r0b''||'||chr(10)||
'''/Bc+HjlB6xtHOBrXFHGN27hQX2wwD8meh/XL9r7Tc5WOas+VfB7ZXj08CUldymZD''||'||chr(10)||
'''thWyJdEa1e15xQ/CZBEXZLhKmXUd1g3Uks8qQbpHM6BV1teDld7RHsSabtGpN6Ep''||'||chr(10)||
'''7CtjX7hQoUNmYosZmb2r4lPhVRfmhu9Ji2/DteGtYjo2TLcUBOw3lYIV/SDj8nBj''||'||chr(10)||
'''dqiJhQ8TC/eIKR9sJMq2Ix20UoeNOiXukrPfSNYTMthjmib1LhV0Cd4pa/eU0tFn''||'||chr(10)||
'''k6H85cKotQvNwfia2L8aqV868PeX/wPAohG0wSYAAA=='';'||chr(10)||
'--'||chr(10)||
' '||
' t_parse_xls varchar2(32767) :='||chr(10)||
'''H4sIAAAAAAAAC+0cXW/bSO7dv0L7cJBUyz5Jdhyn2S6QbRKgQNs9NLvYuydDtseJ''||'||chr(10)||
'''trZkSPImWeyPP3K+NZZkxXbS3rVBAFujGZLDITkckuPOYpPMijhNrHWU5aTjrCfz''||'||chr(10)||
'''dLZZkaSwpst02vHWk/yOkCK3/oyy2V2UhdbrN1ayWS7xFXkossiaT1d5uinWm2Ky''||'||chr(10)||
'''jBOSR1kWPcpubicjxSZLrAJgR0XUifNOMZmR5RJb8PMcnrP0Psdn/MRn7ClG4PN9''||'||chr(10)||
'''mn2epulnShU2xMncipOC3JIMH3PjeUkS/XEVPZhNM5ii9nibTePCyqJ7J3DxeRov''||'||chr(10)||
'''FicWoFySKKEYikzywBmEp6'||
'NT2q9Yreko1ZKRmdECkyDBmT/UwD2uCU4vz4EImHg0''||'||chr(10)||
'''XRIrXZgIgMA5ebCmj9Z6mU/06cI4NlzBQiwlYBxbLZCHBRvDx2LTYlWYbRw6dIaX''||'||chr(10)||
'''JfgauCYcOEwC4EiqOInPk5xo7wLfd1GO7N+vxh9ufn/3MQhPQlvjHkom5TeQBR9p''||'||chr(10)||
'''Nu84SbQiJviOp4lHxzUg5KVZleHW8Z+NkxBkW2k4nZU5lKJWU3SFeBod11k6I/NN''||'||chr(10)||
'''RmBi0XyySeJZOicohXFyy3QI2kqCNiW3ccIllWvfeef+LoZ5MXH/yfI7yzRdd+KF''||'||chr(10)||
'''tSmWExjcB6mfRMnc4Rrg3YFOpwjV9gPbda03VrmlU9yRBAE4lsXUrkuBvwoBvAAK''||'||chr(10)||
'''qnZb3DmU'||
'CW436AACaiUmoLz9fDMFCh2l017oUX3uUrXtDstIB299H9ByxHJ27Mvf''||'||chr(10)||
'''f1OccTBO+tB7UqRUjBxBiMQFhHiMXNezL94Ho99+vQ5G769sV9gCChO+9IxJNIFy''||'||chr(10)||
'''rX9aobBGFIA2DWGGoF3AmEV5gTRO4yTKHsViOy1YE7qepCsuiiWZkGQeR4mrbBfg''||'||chr(10)||
'''aQAUcEBDaaOa+1Pae3JUlwlqzicanHfIEvaLw5fD49JTtSy5ZKsuZ9qC+UAGKvaC''||'||chr(10)||
'''k7Mtli8klLgLaOtcJSsHydm3LWO7ucukqFZoqkWGWVBpKRcpbGNg8a3A6ve3pQaI''||'||chr(10)||
'''cJn1lOMky9NkFhUObfe2qISBXuwFrm5aQXhcRghCPG+rRwyDqShSBSQ4+AbzEa5'||
'd''||'||chr(10)||
'''9jlMNqspCAH4V59xy5A+GWvH7YRtHrwZZIhgvyIFmh1zqzBmiEBh6WGCtj+AecGW''||'||chr(10)||
'''AxJp+6FtoXbsEkwTOgVnX7+9pn92nUyC5R0KTINnx+T7ApffjGuebsCPcAzJgGHs''||'||chr(10)||
'''z/YQaR0mgSM4EMeuiTbMFFwuJj1lEQI5CdEfBFDwlYuNlCJ8o2QIjLByeZmBFCeA''||'||chr(10)||
'''lLajI9GDf3xve/blZe/Dh95/4M92uxS+EumqgQMc6JsDGWW9UeBy2g0HaraYQpfZ''||'||chr(10)||
'''gh4gXOZA3cEL8F1RJU+CkLn9jwWZgB8JzYbfRhJwwMD3sizNu/SZycn/gtbSAIs2''||'||chr(10)||
'''s/aqV2RWvJtvvWK2TrwV3f6BLqPms5JZPDd8Vr1nrdO6yqNCA'||
'aCEQ4PRst0HIKeM''||'||chr(10)||
'''SaE/HLMJ36UZWNQ0KSI48GXyUAbmgEQr+Yg7k0GD6Z1b+AVgzibXGSGTGzJ7d0nZ''||'||chr(10)||
'''AsDzIgKbrZ8yXr/pBdj3KplPfllM3t4Bej6mrn+I/W8uftVA1/YdYN8P5c51fYfY''||'||chr(10)||
'''9/Ldp8nVal08lnqyQyRa87LFFyNusO2W7BoR6CMoX3eNCNWI9+nss7WbqoEa8a8s''||'||chr(10)||
'''XZMMptI8YqhGfErTogWOE1s7m3CVq/ALUDk9UEMPNZg6crI3iDoNJYAYbm3LrItr''||'||chr(10)||
'''/WjBWL2H3H9ZD9ihxq71g07Zpf/2Ogiu/Ivg5yC4uAqUQ8fMju4paHYBaKf7471u''||'||chr(10)||
'''ok1s4ZkXll3G6ys0vWXDXjK/Fno72rnsVra'||
'jOaNWVaPiTTUQ4ZBKa4XHZ91fkE5V''||'||chr(10)||
'''dQ9bnzS1X/B6nd7D9hl6LfdXkxeDAHjh6dS73GwC/COAH1SBl96cj95c4J/1AuG9''||'||chr(10)||
'''cfO622euw3h62o1fDb2hgRVY9wA+MpULiQWERTNtwgw7scu9PdrLcAUPpW90VkGb''||'||chr(10)||
'''CARw6D8gYdt2VOdRWq+nVDZQW7v02ysBlrrwZdYzMQIfqhcK4JQD7AO8l01SOK67''||'||chr(10)||
'''z3QZkR6sRTeoWo2j8JQj6VWut8SAc/5Dm7M+t7LkPYmrlFN/uI1sVdApV1+MqccV''||'||chr(10)||
'''2SpcX15kFW85c7+IyMqlpS1Hk2zO+uHXaC2CcKyY3y7CUc9rANYdnWztEnxTReg/''||'||chr(10)||
'''WaHYOamHyrHtDmSVcAQ8o'||
'kERif1VO6BTt2EHmafg/7BzoO76MeIkc2fQVpCCrNbg''||'||chr(10)||
'''W2SPjvC8vSLbENc4RhzKuSA4rRCQ46xKEFZpgVqWvYX6ZJtmxkMh2BqDGoVb8jxa''||'||chr(10)||
'''rwmNk3NWt5R0hQekvWJphG6r1rKRRWft2WjeOsl5zCvjH+3Ib6afi77EXGTxSpNX''||'||chr(10)||
'''XGax4lTzMNvD44O2UEmZ/BMBMhiqQJfG/tx+nKZkeJLZrWImq15M146w/gbtLyi8''||'||chr(10)||
'''LLiKjWj+9tjiYH0luXHesCJ43gqMZVyA6900pCRGdWio4LSCznqWQrLi7Lt6hCG3''||'||chr(10)||
'''jo2Jdjx2/fv9DR6MteCUyLwLfZDiy8+/FuyUEvUtKeQZWHREEn1GosD2MbUkmAVK''||'||chr(10)||
'''0QKclzl'||
'FHMU5mYCELONZhEG+CcmyNHN6oe/7Aw9GFlZk/Rkt4znS2sPRthB6dUZU''||'||chr(10)||
'''wXqVZdf9gEo6+QG/RfrFSECe+WM4Q8Nf2+zNEHPolqMHYjAg0SkF4/0RPfq3BDky''||'||chr(10)||
'''aDopp4JY4UBz4kOjrhwkYsGSl8rpVGeUqAnRT7LY7SfsxtdXP+c+eQUvWCTsZaao''||'||chr(10)||
'''63RLAq9ZZo/pOZktowyDJdmmVDsCvdWjCjRH8zk1LaDLRujTLYXHVY5yzb3Pl8hR''||'||chr(10)||
'''fsn8IbVnNDP345vqyQoqedbQSG405vN3ZRilsrky+NUyN6nlM7WomJaf3Dbzpfft''||'||chr(10)||
'''k6BjjoqmIWQwoZSJfPrCDDnQcW3Cieq6FNuBnqR+qh+jJWMbjY6Rnw1LyeUmqE'||
'HV''||'||chr(10)||
'''8OC8ZTHLeKuYZSzUXM6fpYBQ1190/kImGV6/5JK0mNlwa2bDrZmxjDyarcNmNtyh''||'||chr(10)||
'''4ojhR+GDSIT0S3cYng3PRqfh2ahKmzg7hio+/WDm6ysKoXgtHI3MlAMz1Bk7Vxyg''||'||chr(10)||
'''/H017FLA1YUCWoetZDoQtcdmMj5Rm8k+RocF/dGhEDAOUE6MLDTIZVORxVivr8Dq''||'||chr(10)||
'''tn5jlITVPKiKPmV3DyTf3W0sxiJ/dFiBmyzIqERyJquWzDoodtpp5uaZ5OYTSk4M''||'||chr(10)||
'''cmTJCbTvV3KiqWCbFUU8dYUnAgRXqH1WN2gyLRx+7ogvpqZj4746Goa6jspS3f0c''||'||chr(10)||
'''+IB5t/tRElwpy/3FrcVgf2sx1KwF1vq+qJkYNO++zcbj5CWM'||
'x+gg4zH6yoxH8wI3''||'||chr(10)||
'''Ww1Rbe7sZzFqF9rtAEUOsIb1BjSePZ/bLi2ARq7pL1armhePj/zF3gp95R+2/Yvy''||'||chr(10)||
'''eUd8OSj1tFM79pvkMDzYx3FUrSE7DNKYjR344antgfCNEQEehRM4UaNkgbGYxHOH''||'||chr(10)||
'''3gu4ePvplw8XHzEuhHGytBDXToQNFNcKxEUCOaBcOVkKZxmHZD1mKYU2GLLtJ9uQ''||'||chr(10)||
'''cvtJTfuopv20uj0MtXYzS1aWB5Uq43c6ZH2BgNYnD3FOd1AuUjEIEbJUQ6i/q1J2''||'||chr(10)||
'''pCHXM3XaXqwoUF4127Nzt68Oai8V8zOiaiN73+hewFQYBzuWfl9EFCQxk2G/trFo''||'||chr(10)||
'''V3aA79Dk8WZhD/Nu4PJXhsnZMV7jJXXTdB'||
'hahIddI2GHJnalqj8nS8Ku9uBNKod9''||'||chr(10)||
'''sCUDYqTTZ2I4lwFkPHRZlVR8K4FKelVN252/0sDl6RXW/x3oPQrzsc/ectK0IQtj''||'||chr(10)||
'''DLzsowiya1Boki/tc+0FmfwZcW7zimNVvV5zLBy6WmCvAsFHhYABEijaQNb3htkz''||'||chr(10)||
'''7LpdmTih0G9p1pEGNGgbOnuuUOZju0lgAByE32FXUuhNzP18AH/w/yl77QrwDamp''||'||chr(10)||
'''jbbuJ6XHpeG7PLeS59Exfdr6cBZ1V6mvSy80wAnSwypudpGmspiZsgD5Xy5lZvc6''||'||chr(10)||
'''Oup25nd1+q5Oz6NOpFN9O2xbuo3rTNULdaMWioX0xUK1wHJGdci4mGVfX7y/ubIt''||'||chr(10)||
'''4y6V/eun36CVBvO/jbUq'||
'X8PriOvgOrPa+ZnV6WX/VO35WqI8vTduyuwZDt7B5lm6''||'||chr(10)||
'''PAaeHcspUrpf9urtPoGjAyKoDbzX02bD83qF3o5EN4U0B1q8uMIQPDF23HBRmc1u''||'||chr(10)||
'''4NamEiuw8zyiMvONCp4ulYrTD6qW0GrpRpTfr1T31p9mGW37WzFh5apBzq59/Lnh''||'||chr(10)||
'''Ec4n5cxK7XodkuHcVUGDwN+o9HqFbPBqy9335s+OpHTflvtzkBReHn6qOGY1QKOV''||'||chr(10)||
'''f5LotLRbbWXquyy1KFO8PDS1VL9yX5D51RtwXuy1IKf1NQX/AzGInw9f4WfKostc''||'||chr(10)||
'''1JEhd3YXO1aC7IUNMHlWqsmenXRHr5y4x4yaNzo0Hon2rDE5/SyxcMQ6eJZYuITc''||'||chr(10)||
'''zguO+c'||
'/4PJd2IXzTjppFCbuyuHR9aX6MZsJoHk2sChuoPPi8vwTi3f4izuiv7Ulm''||'||chr(10)||
'''VnSiqq9YzlQlkzUaWleRLwVKMAbI3/AkbabUHjFkJlyGnWHQU9h1k+PXVpCYmUYM''||'||chr(10)||
'''XS+pIByu+i0kSndo0C2plrQJolUJt8EgIL/MFEzK1RLOfsGE51dVNJNCCnYjC7aQ''||'||chr(10)||
'''cVdY3+PMtH/tKlWsUeWMq+bZvEjGJamGpSljr2JB1cQr51pWE6UuW6lht09/j1Oy''||'||chr(10)||
'''tQqM+Gke/hOdeKj9L6y32s9OVAAA'';'||chr(10)||
'--'||chr(10)||
'  procedure log( p_msg varchar2 )'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'--    apex_debug_message.error( p_msg );'||chr(10)||
'    apex'||
'_debug_message.log_message( p_msg, p_level => 4 );'||chr(10)||
'  end;'||chr(10)||
'  function dc( p varchar2 ) return varchar2'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'    return utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( p ) ) ) );'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'begin'||chr(10)||
'  p_browse_item     := p_process.attribute_01;'||chr(10)||
'  p_collection_name := p_process.attribute_02;'||chr(10)||
'  p_sheet_nrs       := p_process.attribute_03;'||chr(10)||
'  if '||
'upper( p_process.attribute_04 ) in ( ''HT'', ''^I'', ''\T'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(9);'||chr(10)||
'  elsif upper( p_process.attribute_04 ) in ( ''VT'', ''^K'', ''\V'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(11);'||chr(10)||
'  else'||chr(10)||
'    p_separator := substr( ltrim( p_process.attribute_04 ), 1, 1 );'||chr(10)||
'  end if;'||chr(10)||
'  p_enclosed_by     := substr( ltrim( p_process.attribute_05 ), 1, 1 );'||chr(10)||
'  p_encoding        := p_process.attribute_06;'||chr(10)||
'  p_rou'||
'nd := substr( ltrim( p_process.attribute_07 ), 1, 1 );'||chr(10)||
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
'    from apex_application_files aaf'||chr(10)||
'    where aaf.name = t_filename;'||chr(10)||
'--'||chr(10)||
'    delete fro'||
'm apex_application_files aaf'||chr(10)||
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
'    log( ''file with length '' || dbms_lob.getlength( t_document ) || '' found '' );'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'  if apex_collectio'||
'n.collection_exists( p_collection_name )'||chr(10)||
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
'  if dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''504B0304'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''par'||
'sing XLSX'' );'||chr(10)||
'    t_what := ''XLSX-file'';'||chr(10)||
'    execute immediate dc( t_parse_bef ) || dc( t_parse_xlsx ) || dc( t_parse_aft ) using p_collection_name, t_document, p_sheet_nrs, p_round;'||chr(10)||
'  elsif dbms_lob.substr( t_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B11AE1'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLS'' );'||chr(10)||
'    t_what := ''XLS-file'';'||chr(10)||
'    execute immediate dc( t_parse_bef ) || dc( t_parse_xls ) || dc( t_parse_aft )'||
' using p_collection_name, t_document, p_sheet_nrs, p_round;'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = hextoraw( ''003C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'        )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XML'' );'||chr(10)||
'    t_what := ''XML-file'';'||chr(10)||
'    execute immediate dc( t_parse_bef ) || dc( t_parse_xml ) || d'||
'c( t_parse_aft ) using p_collection_name, t_document, p_sheet_nrs, p_round;'||chr(10)||
'  else'||chr(10)||
'    log( ''parsing CSV'' );'||chr(10)||
'    t_what := ''CSV-file'';'||chr(10)||
'    execute immediate dc( t_parse_csv ) using p_collection_name, t_document, p_separator, p_enclosed_by, p_encoding;'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'    t_rv.success_message := ''Loaded a '' || t_what || '' in '' || to_char( trunc( ( sysdate - t_time ) * 24 * 60 * 60 ) ) || '' seconds'';'||chr(10)||
' '||
'   return t_rv;'||chr(10)||
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
'         ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||'||chr(10)||
'       dbms'||
'_utility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could imagine''||'||chr(10)||
'           ''</li></ul><br/>'' ||'||chr(10)||
'           ''try running this plugin in debug mode, and send the debug messages to me, scheffer@amis.nl'';'||chr(10)||
'   '||
' return t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.812'
 ,p_plugin_comment => '0.812'||chr(10)||
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
